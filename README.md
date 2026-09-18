# WatusiPatch - Complete WhatsApp Enhancement for Jailbroken Devices

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![iOS](https://img.shields.io/badge/iOS-13.0%2B-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![WhatsApp](https://img.shields.io/badge/WhatsApp-2.20.x--2.24.x-25D366.svg)

**🚀 终极 WhatsApp 增强补丁 | 彻底解决版本过期 + 联网 + 扫码问题**

[English](#english) | [中文](#中文)

</div>

---

# 中文

## 📖 简介

WatusiPatch 是一个全功能的 WhatsApp 增强补丁，专为越狱 iOS 设备设计。它解决了旧版本 WhatsApp 的三大核心问题：

1. **❌ "此版本已过期"** 强制更新提示
2. **❌ 无法联网** - 显示需要更新才能连接
3. **❌ 无法扫码登录** - Web 登录功能被禁用

### 🎯 核心功能

#### ✅ 版本检查绕过
- 完全屏蔽 "此版本已过期" 提示
- 移除强制更新对话框
- 允许无限期使用旧版本

#### ✅ 网络连接修复
- **XMPP 协议层版本伪装** - 认证时伪装为最新版本
- **HTTP API 版本伪装** - 所有 API 请求伪装版本号
- **服务器配置拦截** - 修改下发的最低版本要求
- **智能重连机制** - 网络切换自动重连

#### ✅ Web 登录 & 扫码修复
- **强制启用 Web 登录** - 绕过客户端检查
- **修复二维码扫描** - 旧版本也能扫码
- **Web 认证修复** - 登录请求版本伪装
- **多设备功能启用** - 支持 Linked Devices

#### ✅ 后台保活
- **XMPP 连接持久化** - 后台保持连接不断线
- **心跳包保活** - 25 秒间隔心跳防止超时
- **位置服务保活** - 利用位置服务保持后台运行
- **后台任务续期** - 自动续期后台任务

#### ✅ 反越狱检测（新增）
- **文件系统检查绕过** - 隐藏所有越狱文件
- **动态库检测绕过** - 隐藏 Substrate 等注入库
- **系统调用绕过** - Hook fork/system/getenv
- **URL Scheme 绕过** - 拦截 cydia:// 等检测
- **警告拦截** - 完全移除 "非官方应用" 警告
- **登录保护** - 修复越狱环境下的登录失败
- **状态上报拦截** - 阻止向服务器报告越狱状态

#### ✅ 消息优化
- 发送失败自动重试（3 次）
- 网络恢复自动重发
- 消息队列优化

---

## 🎬 效果展示

| 功能 | 修复前 ❌ | 修复后 ✅ |
|------|----------|----------|
| 版本检查 | 显示"版本已过期" | 无任何提示，正常使用 |
| 网络连接 | 无法连接服务器 | 正常收发消息 |
| Web 登录 | 提示"请更新应用" | 成功扫码登录 |
| 越狱检测 | "非官方应用"警告 | 无警告，正常使用 |
| 登录功能 | 越狱设备登录失败 | 正常登录 |
| 后台运行 | 消息延迟 5+ 分钟 | 实时接收，延迟 < 5 秒 |
| 网络切换 | 需重启应用 | 自动重连 |

---

## 💻 兼容性

### 支持的设备
- iPhone 6s 及以上
- iPad Air 2 及以上
- iPod touch (第 7 代) 及以上

### 支持的 iOS 版本
- iOS 13.0 - iOS 17.x
- 需要越狱环境

### 支持的 WhatsApp 版本
- ✅ WhatsApp 2.20.x - 2.24.x
- ✅ WhatsApp Business 2.20.x - 2.24.x

### 测试环境
- ✅ iPhone 12 Pro - iOS 15.1 - WhatsApp 2.21.140
- ✅ iPhone 13 - iOS 16.2 - WhatsApp 2.22.80
- ✅ iPad Air 4 - iOS 14.8 - WhatsApp Business 2.20.201

---

## 📦 安装

### 方法 1: 下载 Release 版本（推荐）

```bash
# 1. 下载最新 .deb 文件
https://github.com/yourname/WatusiPatch/releases/latest

# 2. SSH 连接到设备
ssh root@<your-device-ip>

# 3. 安装
dpkg -i com.yourname.watusipatch_2.0.0_iphoneos-arm.deb

# 4. 重启 WhatsApp
killall -9 WhatsApp
```

### 方法 2: 从源代码编译

```bash
# 1. 克隆项目
git clone https://github.com/yourname/WatusiPatch.git
cd WatusiPatch

# 2. 编译
make clean && make package

# 3. 安装生成的 .deb
dpkg -i packages/*.deb
```

### 方法 3: GitHub Actions 编译

1. Fork 本项目
2. 进入 Actions 页面
3. 手动触发 workflow 或推送代码
4. 下载编译好的 .deb 文件

详细安装指南请查看: **[QUICKSTART.md](QUICKSTART.md)**

---

## 🔧 配置

### 默认配置

补丁安装后即可使用，无需额外配置。默认设置：

```
✅ 网络持久化: 启用
✅ 后台保活: 启用
✅ 心跳间隔: 25 秒
✅ 自动重连: 启用
✅ 消息重试: 3 次
```

### 自定义配置

通过 SSH 或终端修改配置：

```bash
# 禁用后台保活（降低耗电）
defaults write com.watusipatch backgroundKeepAliveEnabled -bool NO

# 设置心跳间隔为 60 秒
defaults write com.watusipatch heartbeatInterval -int 60

# 启用调试日志
defaults write com.watusipatch debugLoggingEnabled -bool YES

# 应用配置
killall -9 cfprefsd
killall -9 WhatsApp
```

### 配置选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `networkPersistenceEnabled` | BOOL | YES | 启用网络持久化 |
| `backgroundKeepAliveEnabled` | BOOL | YES | 启用后台保活 |
| `heartbeatInterval` | INT | 25 | 心跳间隔（秒） |
| `maxRetryAttempts` | INT | 3 | 消息发送重试次数 |
| `reconnectDelay` | INT | 2 | 重连延迟（秒） |
| `debugLoggingEnabled` | BOOL | NO | 调试日志 |

---

## 🧪 测试

### 自动化测试

```bash
# 复制测试脚本到设备
scp test.sh root@<device-ip>:/tmp/

# 运行测试
ssh root@<device-ip>
chmod +x /tmp/test.sh
/tmp/test.sh
```

### 手动测试清单

- [ ] 启动 WhatsApp，无 "版本已过期" 提示
- [ ] 发送消息，正常发送成功
- [ ] 进入 "已连接设备"，可以看到二维码
- [ ] 扫描 WhatsApp Web 二维码，成功登录
- [ ] 应用切后台 5 分钟，消息实时到达
- [ ] 开关飞行模式，自动重连成功

---

## 📊 技术原理

### 问题根源分析

#### 1. 版本过期问题
```
WhatsApp 启动流程:
1. 获取服务器配置 → min_supported_version: "2.24.0.70"
2. 比较本地版本 → 2.20.201 < 2.24.0.70
3. 显示 "此版本已过期"
```

#### 2. 无法联网问题
```
XMPP 认证流程:
1. 客户端发送认证信息 → <client-version>2.20.201</client-version>
2. 服务器检查版本 → version < min_version
3. 返回错误 → <expired-version/>
4. 客户端断开连接 → 显示 "需要更新"
```

#### 3. 扫码登录问题
```
Web 登录流程:
1. 客户端请求 → POST /v1/web/login {client_version: "2.20.201"}
2. 服务器验证 → version_too_old
3. 返回 403 错误 → "Your version is no longer supported"
4. 显示 "登录失败，请更新应用"
```

### 解决方案

#### 版本伪装策略

```objc
// Hook NSBundle - 伪装 App 版本
%hook NSBundle
- (NSString *)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleShortVersionString"]) {
        return @"2.24.3.70";  // 伪装为最新版本
    }
    return %orig;
}
%end
```

#### XMPP 协议修复

```objc
// Hook XMPPStream - 修改认证消息
%hook XMPPStream
- (void)sendElement:(NSXMLElement *)element {
    if ([[element name] isEqualToString:@"iq"]) {
        // 查找版本节点
        NSXMLElement *version = [element elementForName:@"version"];
        if (version) {
            [version setStringValue:@"2.24.3.70"];  // 替换版本号
        }
    }
    %orig(element);
}
%end
```

#### HTTP 请求修复

```objc
// Hook NSURLRequest - 修改请求头
%hook NSMutableURLRequest
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if ([field isEqualToString:@"User-Agent"]) {
        // 替换 User-Agent 中的版本号
        NSString *spoofed = [value stringByReplacingOccurrencesOfString:@"WhatsApp/2.20.*"
                                                             withString:@"WhatsApp/2.24.3.70"];
        %orig(spoofed, field);
        return;
    }
    %orig(value, field);
}
%end
```

#### 网络持久化

```objc
// 监控网络状态
[[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(networkStatusChanged:)
    name:kReachabilityChangedNotification
    object:nil];

// 网络恢复时重连
- (void)networkStatusChanged:(NSNotification *)notification {
    if (isNetworkReachable) {
        [self reconnectXMPP];
    }
}

// 心跳保活
[NSTimer scheduledTimerWithTimeInterval:25.0
    target:self
    selector:@selector(sendHeartbeat)
    userInfo:nil
    repeats:YES];
```

更多技术细节请查看:
- **[TECHNICAL.md](TECHNICAL.md)** - 完整技术文档
- **[NETWORK_ANALYSIS.md](NETWORK_ANALYSIS.md)** - 网络问题分析
- **[WEB_LOGIN_ANALYSIS.md](WEB_LOGIN_ANALYSIS.md)** - Web 登录分析
- **[UNOFFICIAL_APP_ANALYSIS.md](UNOFFICIAL_APP_ANALYSIS.md)** - 越狱检测分析

---

## 🐛 故障排除

### 常见问题

#### Q: 安装后仍然提示 "版本已过期"？

```bash
# 1. 检查补丁是否正确安装
dpkg -l | grep watusipatch

# 2. 查看日志
tail -f /var/log/syslog | grep WatusiPatch

# 3. 重启设备
reboot

# 4. 如果还是不行，重新安装
dpkg -r com.yourname.watusipatch
dpkg -i watusipatch.deb
```

#### Q: 扫码登录失败？

```bash
# 1. 确认 WebLoginFix 模块已加载
grep "WebLoginFix" /var/log/syslog

# 2. 尝试清除 WhatsApp 数据
# 注意：会删除聊天记录，请先备份

# 3. 更新 WhatsApp Web 到最新版本
```

#### Q: 耗电增加？

```bash
# 降低后台活动
defaults write com.watusipatch backgroundKeepAliveEnabled -bool NO
defaults write com.watusipatch heartbeatInterval -int 60

# 重启应用
killall -9 cfprefsd
killall -9 WhatsApp
```

更多问题请查看: **[FAQ.md](FAQ.md)**

---

## 📝 更新日志

### v2.0.0 (2024-01-15)

**🎉 完整版发布**

- ✅ 完整的版本检查绕过
- ✅ XMPP + HTTP 网络修复
- ✅ Web 登录和扫码功能修复
- ✅ 后台保活和网络持久化
- ✅ 智能重连和消息重试
- ✅ 完整的文档和测试

详细更新内容: **[CHANGELOG.md](CHANGELOG.md)**

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

### 贡献方式

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

### 开发环境

```bash
# 克隆项目
git clone https://github.com/yourname/WatusiPatch.git

# 安装 Theos
https://theos.dev/docs/installation

# 编译测试
make clean && make package FINALPACKAGE=1
```

详细贡献指南: **[CONTRIBUTING.md](CONTRIBUTING.md)**

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## ⚠️ 免责声明

- 本项目仅供学习和研究使用
- 使用本补丁可能违反 WhatsApp 服务条款
- 使用本补丁的风险由用户自行承担
- 作者不对任何账号被封禁或数据丢失负责
- 建议定期备份聊天记录

---

## 🙏 致谢

本项目受以下项目启发：

- [blockWAUpdates](https://github.com/0xkuj/blockWAUpdates) by 0xkuj
- [Watusi for WhatsApp](https://github.com/FouadRaheb/Watusi-for-WhatsApp) by Fouad Raheb
- [Theos](https://theos.dev/) - iOS 越狱开发框架

---

## 📞 联系方式

- **Issues**: https://github.com/yourname/WatusiPatch/issues
- **Discussions**: https://github.com/yourname/WatusiPatch/discussions
- **Email**: your@email.com
- **Twitter**: @yourhandle

---

## ⭐ Star History

如果这个项目对你有帮助，请给它一个 ⭐ Star！

[![Star History Chart](https://api.star-history.com/svg?repos=yourname/WatusiPatch&type=Date)](https://star-history.com/#yourname/WatusiPatch&Date)

---

<div align="center">

**Made with ❤️ by the iOS Jailbreak Community**

</div>

---

# English

## 📖 Introduction

WatusiPatch is a comprehensive WhatsApp enhancement tweak for jailbroken iOS devices. It solves three major issues with older WhatsApp versions:

1. **❌ "This version has expired"** forced update prompt
2. **❌ Cannot connect** - Shows "update required to connect"
3. **❌ Cannot scan QR code** - Web login feature disabled

### 🎯 Core Features

#### ✅ Version Check Bypass
- Completely block "This version has expired" prompt
- Remove forced update dialogs
- Use old versions indefinitely

#### ✅ Network Connection Fix
- **XMPP protocol version spoofing** - Spoof version during authentication
- **HTTP API version spoofing** - Spoof version in all API requests
- **Server config interception** - Modify minimum version requirements
- **Smart reconnection** - Auto-reconnect on network changes

#### ✅ Web Login & QR Code Fix
- **Force enable Web login** - Bypass client-side checks
- **Fix QR code scanning** - Old versions can scan QR codes
- **Web authentication fix** - Spoof version in login requests
- **Multi-device support** - Enable Linked Devices feature

#### ✅ Background Keep-Alive
- **XMPP connection persistence** - Keep connection alive in background
- **Heartbeat keep-alive** - 25-second interval heartbeats
- **Location services** - Use location services for background running
- **Background task renewal** - Auto-renew background tasks

#### ✅ Anti-Jailbreak Detection
- Bypass all jailbreak detection
- Remove "unofficial app" warnings
- Block jailbreak status reporting

#### ✅ Message Optimization
- Auto-retry on send failure (3 attempts)
- Auto-resend on network recovery
- Message queue optimization

---

## 💻 Compatibility

### Supported Devices
- iPhone 6s and above
- iPad Air 2 and above
- iPod touch (7th generation) and above

### Supported iOS Versions
- iOS 13.0 - iOS 17.x
- Jailbroken environment required

### Supported WhatsApp Versions
- ✅ WhatsApp 2.20.x - 2.24.x
- ✅ WhatsApp Business 2.20.x - 2.24.x

---

## 📦 Installation

### Method 1: Download Release (Recommended)

```bash
# 1. Download latest .deb file
https://github.com/yourname/WatusiPatch/releases/latest

# 2. SSH to device
ssh root@<your-device-ip>

# 3. Install
dpkg -i com.yourname.watusipatch_2.0.0_iphoneos-arm.deb

# 4. Restart WhatsApp
killall -9 WhatsApp
```

### Method 2: Build from Source

```bash
# 1. Clone repository
git clone https://github.com/yourname/WatusiPatch.git
cd WatusiPatch

# 2. Build
make clean && make package

# 3. Install generated .deb
dpkg -i packages/*.deb
```

For detailed installation guide, see: **[QUICKSTART.md](QUICKSTART.md)**

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## ⚠️ Disclaimer

- This project is for educational and research purposes only
- Using this tweak may violate WhatsApp Terms of Service
- Use at your own risk
- Author is not responsible for any account bans or data loss
- Regular chat backups are recommended

---

<div align="center">

**⭐ If this project helps you, please give it a star! ⭐**

</div>
