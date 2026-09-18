# WhatsApp 旧版本登录问题完整分析

## 🚨 问题现象

### 1. 无法联网
```
❌ 显示"需要更新才能继续使用"
❌ 无法连接到 WhatsApp 服务器
❌ 消息无法发送和接收
```

### 2. 无法扫码登录（新发现）
```
❌ 扫描二维码后无反应
❌ 显示"登录失败，请更新应用"
❌ 二维码登录界面直接提示更新
```

---

## 🔍 扫码登录流程分析

### 正常流程

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 用户打开 Web WhatsApp (web.whatsapp.com)                │
│    → 生成二维码（包含加密的 session token）                 │
└─────────────────────┬───────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. 手机 App 扫描二维码                                      │
│    → 解析 QR code 中的 token                                │
│    → 发送到服务器验证                                       │
└─────────────────────┬───────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. 服务器验证（关键阻断点）                                 │
│    → 检查手机 App 版本号 ⚠️                                 │
│    → 检查 Web 端版本号                                      │
│    → 验证 token 有效性                                      │
└─────────────────────┬───────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. 建立配对连接                                             │
│    → 同步加密密钥                                           │
│    → 同步联系人和聊天记录                                   │
└─────────────────────────────────────────────────────────────┘
```

### 旧版本被阻断的地方

```
┌─────────────────────────────────────────────────────────────┐
│ 手机 App 扫描二维码                                         │
│    ↓                                                        │
│ 解析 QR Token                                               │
│    ↓                                                        │
│ 发送登录请求到服务器：                                      │
│    POST /v1/web/login                                       │
│    {                                                        │
│      "token": "xxx",                                        │
│      "client_version": "2.20.201",  ← 旧版本号              │
│      "platform": "iOS"                                      │
│    }                                                        │
│    ↓                                                        │
│ 服务器响应：                                                │
│    {                                                        │
│      "status": "error",                                     │
│      "reason": "old_version",        ← 版本过旧             │
│      "message": "Please update your app",                   │
│      "min_version": "2.24.0.70"                             │
│    }                                                        │
│    ↓                                                        │
│ App 显示：❌ "登录失败，请更新应用"                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 核心问题：多重版本检查

WhatsApp 在**至少 3 个地方**检查版本：

### 检查点 1：启动时配置获取
```objc
// App 启动时获取服务器配置
GET /v2/config
Response:
{
  "min_supported_version": "2.24.0.70",
  "force_upgrade": true,
  "features": {
    "web_login_enabled": true  // 旧版本会被设为 false
  }
}

// 如果版本过旧
if (current_version < min_supported_version) {
    self.webLoginEnabled = NO;  // 禁用二维码登录
    self.networkingEnabled = NO;  // 禁用网络功能
    [self showForceUpdateAlert];
}
```

### 检查点 2：扫码时客户端检查
```objc
// 用户点击扫码按钮
- (void)scanQRCode {
    // 检查是否允许 Web 登录
    if (!self.webLoginEnabled) {
        [self showUpdateAlert:@"Please update to use WhatsApp Web"];
        return;  // 直接返回，不允许扫码
    }
    
    // 打开扫码界面
    [self presentQRScanner];
}
```

### 检查点 3：服务器端验证（最终阻断）
```http
POST /v1/web/login HTTP/1.1
Host: web.whatsapp.net
Content-Type: application/json

{
  "ref": "qr_code_ref_xxx",
  "publicKey": "...",
  "clientId": "...",
  "client_version": "2.20.201",  ← 旧版本号
  "platform": "iOS"
}

# 服务器响应
HTTP/1.1 403 Forbidden
{
  "status": "fail",
  "code": 403,
  "reason": "version_too_old",
  "min_version": "2.24.0.70",
  "message": "Your WhatsApp version is no longer supported for Web login"
}
```

---

## 🛠️ 完整解决方案

### 需要 Hook 的类和方法

| 功能 | 类名 | 方法 | 优先级 |
|------|------|------|--------|
| **配置下发拦截** | `WAServerConfigManager` | `-serverConfig` | 🔴 P0 |
| **Web 登录开关** | `WAWebSessionManager` | `-isWebLoginEnabled` | 🔴 P0 |
| **扫码功能检查** | `WAQRCodeViewController` | `-viewDidLoad` | 🔴 P0 |
| **登录请求版本** | `WAWebLoginRequest` | `-loginParameters` | 🔴 P0 |
| **HTTP 请求伪装** | `NSURLRequest` | `-allHTTPHeaderFields` | 🟡 P1 |
| **错误响应拦截** | `WAWebLoginManager` | `-handleLoginResponse:` | 🟡 P1 |

---

## 💻 完整 Hook 实现

让我创建一个专门针对 Web 登录/扫码问题的补丁：

