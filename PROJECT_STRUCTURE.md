# WatusiPatch 项目结构

```
WatusiPatch/
│
├── Tweak.x                      # 主要的 Hook 实现代码（2000+ 行）
│   ├── 反检测模块
│   │   ├── 越狱检测绕过
│   │   ├── 设备支持检查
│   │   ├── 版本检查禁用
│   │   ├── Bundle ID 伪装
│   │   └── 许可证绕过
│   │
│   ├── 网络持久化模块
│   │   ├── XMPP 连接保持
│   │   ├── 自动重连机制
│   │   ├── 网络状态监控
│   │   └── 超时优化
│   │
│   ├── 后台保活模块
│   │   ├── Background Task
│   │   ├── Timer Heartbeat
│   │   └── Location Service
│   │
│   ├── 性能优化模块
│   │   ├── 消息发送优化
│   │   ├── 内存管理
│   │   ├── 数据持久化
│   │   └── 推送通知优化
│   │
│   └── 配置和初始化
│       ├── 配置加载
│       ├── 日志系统
│       └── 构造函数
│
├── Makefile                     # 编译配置
│   ├── 目标架构：arm64, arm64e
│   ├── 最低版本：iOS 12.0
│   ├── 框架依赖
│   └── 编译选项
│
├── control                      # 包信息
│   ├── 包名和版本
│   ├── 依赖声明
│   ├── 描述信息
│   └── 维护者信息
│
├── WatusiPatch.plist           # 注入配置
│   └── Bundle 过滤器
│       ├── net.whatsapp.WhatsApp
│       └── net.whatsapp.WhatsAppSMB
│
├── Resources/                   # 资源文件
│   ├── Root.plist              # 设置界面配置
│   │   ├── 网络持久化开关
│   │   ├── 后台保活开关
│   │   ├── 自动重连开关
│   │   ├── 位置服务开关
│   │   └── 调试日志开关
│   │
│   ├── entry.plist             # PreferenceLoader 入口
│   └── icon.png                # 设置图标（需自行添加）
│
├── build.sh                     # 构建脚本
│   ├── clean - 清理构建文件
│   ├── install - 编译并安装
│   └── package - 打包 deb
│
├── test.sh                      # 测试脚本
│   ├── Hook 加载测试
│   ├── 配置文件测试
│   ├── 日志输出测试
│   ├── 后台保活测试
│   ├── 网络重连测试
│   ├── 内存占用测试
│   └── 越狱检测测试
│
├── README.md                    # 项目说明
│   ├── 功能特性
│   ├── 安装说明
│   ├── 配置选项
│   ├── 故障排除
│   └── 使用指南
│
├── INSTALL.md                   # 详细安装指南
│   ├── 快速安装
│   ├── 从源码编译
│   ├── 配置说明
│   ├── 验证安装
│   ├── 故障排除
│   └── 日常使用
│
├── TECHNICAL.md                 # 技术文档
│   ├── 架构设计
│   ├── 网络持久化原理
│   ├── 后台保活机制
│   ├── Hook 实现细节
│   ├── 性能优化策略
│   └── 调试和测试
│
├── CHANGELOG.md                 # 更新日志
│   ├── 版本历史
│   ├── 新增功能
│   ├── 问题修复
│   └── 未来计划
│
├── LICENSE                      # 开源许可证
│   └── MIT License
│
└── .gitignore                   # Git 忽略文件
    ├── .theos/
    ├── packages/
    ├── obj/
    └── *.deb
```

## 文件说明

### 核心代码文件

#### Tweak.x（主文件，2000+ 行）

**结构分解：**

```
1. 头文件和宏定义（50 行）
   - 系统框架导入
   - 全局配置宏
   - 日志宏定义

2. 全局变量（30 行）
   - 配置开关
   - 后台任务 ID
   - 定时器和位置管理器

3. 接口声明（100 行）
   - WhatsApp 类接口
   - XMPP 类接口
   - 系统类接口

4. 反检测模块（200 行）
   - 越狱检测 Hook（4 个版本）
   - 设备支持检查
   - 警告屏蔽
   - 版本伪装
   - 许可证绕过

5. 网络持久化模块（300 行）
   - XMPPStream Hook
   - XMPPConnection Hook
   - 网络监控
   - URL 请求拦截

6. 后台保活模块（400 行）
   - AppDelegate Hook
   - 后台任务管理
   - 定时器心跳
   - 位置服务保活

7. 性能优化模块（300 行）
   - 消息发送优化
   - 内存管理
   - Core Data 优化
   - 推送通知优化

8. 辅助功能（200 行）
   - URL Schemes
   - Bundle ID 伪装
   - 配置管理

9. 初始化和配置（100 行）
   - 配置加载
   - 默认配置保存
   - 构造函数
   - 通知监听
```

**关键 Hook 点：**

1. `WARegistrationURLBuilder` - 越狱检测
2. `WAUIDevices` - 设备支持
3. `XMPPStream` - 网络连接
4. `AppDelegate` - 应用生命周期
5. `WAMessageSender` - 消息发送
6. `NSURLSession` - 网络请求
7. `NSBundle` - Bundle 信息
8. `NSManagedObjectContext` - 数据持久化

### 配置文件

#### Makefile

```makefile
# 目标架构
ARCHS = arm64 arm64e

# iOS 版本
TARGET = iphone:clang:latest:12.0

# Tweak 信息
TWEAK_NAME = WatusiPatch
FILES = Tweak.x

# 编译选项
CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# 框架依赖
FRAMEWORKS = UIKit Foundation CoreLocation BackgroundTasks

# 库依赖
LIBRARIES = substrate
```

#### control

```
包标识符：com.yourname.watusipatch
版本：2.0.0
架构：iphoneos-arm
依赖：
  - mobilesubstrate (>= 0.9.5000)
  - preferenceloader
  - com.fouadraheb.watusi3
```

#### WatusiPatch.plist

```xml
目标应用：
  - net.whatsapp.WhatsApp（个人版）
  - net.whatsapp.WhatsAppSMB（商业版）
```

### 文档文件

| 文件 | 用途 | 目标读者 |
|------|------|----------|
| README.md | 项目概述和快速开始 | 所有用户 |
| INSTALL.md | 详细安装和配置指南 | 新手用户 |
| TECHNICAL.md | 技术实现细节 | 开发者 |
| CHANGELOG.md | 版本历史和更新 | 所有用户 |
| PROJECT_STRUCTURE.md | 项目结构说明 | 开发者 |

### 脚本文件

#### build.sh（构建脚本）

```bash
功能：
- clean：清理构建文件
- install：编译并安装到设备
- package：打包 deb 文件
- 默认：仅编译
```

#### test.sh（测试脚本）

```bash
测试项目：
1. 设备连接检查
2. 补丁安装检查
3. Hook 加载测试
4. 配置文件测试
5. 日志输出测试
6. 后台保活测试
7. 网络重连测试
8. 内存占用测试
9. 越狱检测测试
10. 生成测试报告
```

## 构建流程

```
源码 → Theos → 编译 → 链接 → 签名 → 打包 → deb
```

详细步骤：

1. **预处理（Theos）**
   ```
   Tweak.x → Tweak.mm（Logos 预处理）
   ```

2. **编译**
   ```
   Tweak.mm → Tweak.o（Clang）
   ```

3. **链接**
   ```
   Tweak.o + 框架 → WatusiPatch.dylib
   ```

4. **签名**
   ```
   ldid -S WatusiPatch.dylib
   ```

5. **打包**
   ```
   dylib + plist + 资源 → deb 包
   ```

## 安装后的文件位置

```
iOS 设备文件系统：

/Library/MobileSubstrate/DynamicLibraries/
├── WatusiPatch.dylib           # 主 dylib 文件
└── WatusiPatch.plist           # 注入配置

/Library/PreferenceLoader/Preferences/
├── WatusiPatch.plist           # 设置界面配置
└── (Resources/)                # 资源文件

/var/mobile/Library/Preferences/
└── com.watusipatch.plist       # 用户配置
```

## 开发环境要求

### 软件要求

- **Theos**：越狱开发框架
- **Clang**：C/C++/Objective-C 编译器
- **ldid**：代码签名工具
- **dpkg**：deb 包管理工具

### 可选工具

- **deviceconsole**：实时日志查看
- **iproxy**：USB SSH 转发
- **Xcode**：代码编辑和调试
- **Hopper/IDA**：逆向分析工具

## 代码统计

```
文件类型         文件数    代码行数
─────────────────────────────────
Objective-C++    1         2000+
Makefile        1         20
Shell Script    2         500
XML/Plist       3         200
Markdown        5         3000+
─────────────────────────────────
总计            12        5700+
```

## 依赖关系图

```
WatusiPatch.dylib
    │
    ├─→ MobileSubstrate (Hook 框架)
    │
    ├─→ UIKit (界面框架)
    │
    ├─→ Foundation (基础框架)
    │
    ├─→ CoreLocation (位置服务)
    │
    ├─→ BackgroundTasks (后台任务)
    │
    └─→ Watusi3 (目标应用)
```

## 贡献指南

### 添加新功能

1. 在 `Tweak.x` 中添加 Hook
2. 更新配置文件（如需要）
3. 更新文档
4. 添加测试用例
5. 提交 Pull Request

### 修复 Bug

1. 在 `Tweak.x` 中定位问题
2. 修复代码
3. 测试验证
4. 更新 CHANGELOG.md
5. 提交 Pull Request

### 改进文档

1. 编辑相应的 `.md` 文件
2. 确保格式正确
3. 提交 Pull Request

---

**最后更新：** 2024-01-15  
**文档版本：** 1.0.0
