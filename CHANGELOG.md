# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2024-01-15

### 🎉 完整版发布

这是第一个完整功能版本，整合了所有核心功能。

### ✨ Added - 新增功能

#### 版本过期问题修复
- ✅ 完全屏蔽 "此版本已过期" 提示
- ✅ 允许无限期使用旧版本 WhatsApp
- ✅ 移除强制更新对话框
- ✅ 绕过最低版本限制检查

#### 网络连接修复
- ✅ 修复旧版本无法联网问题
- ✅ XMPP 协议层版本伪装
- ✅ HTTP API 版本伪装
- ✅ 服务器配置拦截和修改
- ✅ 版本比较函数 Hook
- ✅ 网络错误处理优化

#### Web 登录 & 扫码功能修复
- ✅ 修复旧版本无法扫码登录问题
- ✅ 强制启用 Web 登录功能
- ✅ 强制启用二维码扫描
- ✅ 修复 Web 认证请求版本检查
- ✅ WebSocket 连接版本伪装
- ✅ 多设备功能启用

#### 反越狱检测
- ✅ 绕过所有已知的越狱检测方法
- ✅ 阻止越狱状态上报到服务器
- ✅ 移除 "非官方应用" 警告

#### 网络持久化
- ✅ 后台保持 XMPP 连接不断开
- ✅ 网络状态实时监控
- ✅ 智能重连机制（指数退避算法）
- ✅ 心跳包保活（25秒间隔）
- ✅ 防止连接超时

#### 后台保活
- ✅ 位置服务后台保活
- ✅ 后台任务自动续期
- ✅ 定时器保活机制
- ✅ 低功耗优化

#### 消息优化
- ✅ 发送失败自动重试（3次）
- ✅ 网络切换自动重发
- ✅ 消息队列管理优化

### 🔧 Technical - 技术实现

#### Hook 覆盖
- `XMPPStream` - XMPP 连接管理
- `NSBundle` - Bundle 信息伪装
- `NSURLRequest` - HTTP 请求修改
- `WAServerConfigManager` - 服务器配置拦截
- `WAVersionUtils` - 版本比较绕过
- `WAExpirationChecker` - 过期检查绕过
- `WAWebSessionManager` - Web 登录管理
- `WAQRCodeViewController` - 二维码扫描
- `WAWebLoginRequest` - Web 登录请求
- `WAMultiDeviceManager` - 多设备管理

#### 核心模块
- `Tweak.x` - 主补丁（反检测 + 后台保活）
- `NetworkFix.x` - 网络连接修复
- `WebLoginFix.x` - Web 登录修复

### 📦 Build System - 构建系统

- ✅ GitHub Actions 自动编译
- ✅ 自动生成 .deb 包
- ✅ 自动发布 Release
- ✅ 支持多架构编译（arm64, arm64e）

### 📚 Documentation - 文档

- ✅ 完整的 README（中文 + 英文）
- ✅ 详细的安装指南
- ✅ 配置选项说明
- ✅ 技术原理文档
- ✅ 常见问题解答
- ✅ 网络问题深度分析
- ✅ Web 登录问题分析
- ✅ 贡献指南

### 🧪 Testing - 测试

- ✅ 自动化测试脚本
- ✅ 手动测试清单
- ✅ 调试命令集合

---

## [1.5.0] - 2024-01-01

### Added
- 智能网络状态监控
- 消息发送失败自动重试
- 心跳包优化

### Changed
- 降低后台耗电量
- 减少位置服务精度
- 优化重连策略

### Fixed
- 修复后台任务泄漏
- 修复网络状态判断错误
- 修复定时器不释放

---

## [1.0.0] - 2023-12-01

### Added
- 基础反越狱检测
- 后台保活功能
- 网络持久化

---

## 版本说明

### 版本号格式
- **主版本号 (Major)**: 重大架构变更或不兼容更新
- **次版本号 (Minor)**: 新功能添加
- **修订号 (Patch)**: Bug 修复和小改进

### 功能标记
- ✅ 已实现
- 🚧 开发中
- 📝 计划中
- ⚠️ 实验性
- ❌ 已废弃

---

## 路线图 (Roadmap)

### v2.1.0 (计划中)
- 📝 图形化配置界面（Settings Bundle）
- 📝 更多自定义选项
- 📝 性能监控和统计
- 📝 崩溃日志收集

### v2.2.0 (计划中)
- 📝 支持更多 WhatsApp 版本
- 📝 兼容性改进
- 📝 更智能的版本伪装策略

### v3.0.0 (计划中)
- 📝 完全重构代码
- 📝 模块化架构
- 📝 插件系统
- 📝 更好的错误处理

---

## 贡献者

感谢所有为这个项目做出贡献的开发者！

- **Your Name** - 初始开发和维护

---

## 参考项目

本项目受以下项目启发：

- [blockWAUpdates](https://github.com/0xkuj/blockWAUpdates) by 0xkuj
- [Watusi for WhatsApp](https://github.com/FouadRaheb/Watusi-for-WhatsApp) by Fouad Raheb

---

**完整更新日志**: https://github.com/yourname/WatusiPatch/blob/main/CHANGELOG.md
