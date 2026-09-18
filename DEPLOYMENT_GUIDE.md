# 🚀 部署到 GitHub 指南

本指南帮助你将 WatusiPatch 项目部署到 GitHub 并配置自动编译。

---

## 📋 前置要求

- GitHub 账号
- Git 客户端
- 基本的 Git 操作知识

---

## 🔧 步骤 1: 创建 GitHub 仓库

### 1.1 在 GitHub 创建新仓库

1. 访问 https://github.com/new
2. 填写信息:
   - **Repository name**: `WatusiPatch`
   - **Description**: `Complete WhatsApp anti-detection and network optimization patch`
   - **Visibility**: Public 或 Private
   - **不要** 勾选 "Initialize with README"
3. 点击 "Create repository"

### 1.2 记录仓库地址

```
HTTPS: https://github.com/yourusername/WatusiPatch.git
SSH:   git@github.com:yourusername/WatusiPatch.git
```

---

## 📤 步骤 2: 推送代码到 GitHub

### 2.1 在项目目录初始化 Git

```bash
# 进入项目目录
cd C:\Users\Administrator\Desktop\WatusiPatch

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 创建首次提交
git commit -m "Initial commit: Complete WatusiPatch v2.0.0

Features:
- Version check bypass
- Network connection fix
- Web login & QR code fix
- Background keep-alive
- Anti-jailbreak detection
- Message optimization"
```

### 2.2 连接到 GitHub 并推送

```bash
# 添加远程仓库（替换成你的仓库地址）
git remote add origin https://github.com/yourusername/WatusiPatch.git

# 推送代码
git branch -M main
git push -u origin main
```

如果遇到权限问题，可能需要配置 GitHub 凭据:

```bash
# 配置用户名和邮箱
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# 使用 Personal Access Token
# 1. 在 GitHub 创建 Token: Settings → Developer settings → Personal access tokens
# 2. 推送时使用 Token 作为密码
```

---

## ⚙️ 步骤 3: 配置 GitHub Actions

### 3.1 验证 Actions 配置

确认以下文件存在:
```
.github/workflows/build.yml  ✅ 已创建
```

### 3.2 启用 Actions

1. 进入 GitHub 仓库页面
2. 点击顶部 "Actions" 标签
3. 如果看到提示，点击 "I understand my workflows, go ahead and enable them"

### 3.3 触发首次构建

Actions 会在以下情况自动触发:
- ✅ 推送代码到 main 或 develop 分支
- ✅ 创建 Pull Request
- ✅ 创建 tag (例如 v2.0.0)
- ✅ 手动触发

**手动触发构建:**
1. 进入 "Actions" 页面
2. 选择 "Build WhatsApp Tweak" workflow
3. 点击右上角 "Run workflow"
4. 选择分支，点击 "Run workflow"

---

## 📦 步骤 4: 创建 Release

### 4.1 通过 Tag 自动创建 Release

```bash
# 创建 tag
git tag -a v2.0.0 -m "Release v2.0.0

- Complete version check bypass
- Network connection fix
- Web login & QR code fix
- Anti-jailbreak detection
- Background keep-alive"

# 推送 tag
git push origin v2.0.0
```

GitHub Actions 会自动:
1. 编译 .deb 包
2. 创建 GitHub Release
3. 上传 .deb 文件到 Release

### 4.2 手动创建 Release

如果自动创建失败，可以手动创建:

1. 进入 "Actions" 页面
2. 找到最新的成功构建
3. 下载 Artifacts 中的 .deb 文件
4. 进入 "Releases" 页面
5. 点击 "Create a new release"
6. 填写信息并上传 .deb 文件

---

## 🔍 步骤 5: 验证构建

### 5.1 查看构建状态

1. 进入 "Actions" 页面
2. 查看最新的 workflow run
3. 点击进入查看详细日志

**构建成功标志:**
```
✅ Install dependencies
✅ Setup Theos
✅ Install iOS SDK
✅ Build tweak
✅ Upload artifacts
```

### 5.2 下载编译产物

**方式 1: 从 Actions 下载**
1. 进入成功的 workflow run
2. 滚动到底部 "Artifacts" 区域
3. 下载 `WatusiPatch-<commit-hash>`

**方式 2: 从 Releases 下载**
1. 进入 "Releases" 页面
2. 找到最新的 release
3. 下载 .deb 文件

### 5.3 验证 deb 包

```bash
# 检查包信息
dpkg-deb -I WatusiPatch.deb

# 查看包内容
dpkg-deb -c WatusiPatch.deb

# 应该看到:
./Library/MobileSubstrate/DynamicLibraries/WatusiPatch.dylib
./Library/MobileSubstrate/DynamicLibraries/WatusiPatch.plist
```

---

## 📝 步骤 6: 更新 README

### 6.1 更新仓库链接

编辑 `README.md`，将所有 `yourusername` 替换为你的 GitHub 用户名:

```bash
# 使用 PowerShell 批量替换
(Get-Content README.md) -replace 'yourusername', 'YOUR_GITHUB_USERNAME' | Set-Content README.md
(Get-Content QUICKSTART.md) -replace 'yourusername', 'YOUR_GITHUB_USERNAME' | Set-Content QUICKSTART.md
```

### 6.2 添加 Badge

在 `README.md` 顶部添加状态徽章:

```markdown
# WatusiPatch

[![Build](https://github.com/yourusername/WatusiPatch/actions/workflows/build.yml/badge.svg)](https://github.com/yourusername/WatusiPatch/actions)
[![Release](https://img.shields.io/github/v/release/yourusername/WatusiPatch)](https://github.com/yourusername/WatusiPatch/releases)
[![License](https://img.shields.io/github/license/yourusername/WatusiPatch)](LICENSE)
```

### 6.3 提交更新

```bash
git add README.md QUICKSTART.md
git commit -m "docs: update GitHub links and add badges"
git push
```

---

## 🎯 步骤 7: 配置项目设置

### 7.1 设置项目描述

1. 进入仓库页面
2. 点击右上角齿轮图标（About 区域）
3. 填写:
   - **Description**: `Complete WhatsApp anti-detection and network optimization patch for iOS jailbreak`
   - **Website**: 留空或填写文档链接
   - **Topics**: `ios`, `jailbreak`, `whatsapp`, `tweak`, `cydia`, `theos`

### 7.2 启用 Discussions（可选）

1. 进入 "Settings" 页面
2. 找到 "Features" 区域
3. 勾选 "Discussions"

### 7.3 配置 Issues 模板（可选）

创建 `.github/ISSUE_TEMPLATE/bug_report.md`:

```yaml
name: Bug Report
about: Report a bug
labels: bug

---

**Bug 描述**
简要描述遇到的问题

**复现步骤**
1. 
2. 
3. 

**预期行为**
应该发生什么

**实际行为**
实际发生了什么

**环境信息**
- 设备: iPhone X
- iOS 版本: 15.1
- 越狱工具: unc0ver
- WhatsApp 版本: 2.21.140
- WatusiPatch 版本: 2.0.0

**日志**
```
粘贴相关日志
```
```

---

## 🚀 步骤 8: 发布到社区

### 8.1 Reddit

在 r/jailbreak 发布:
```
Title: [Release] WatusiPatch - Complete WhatsApp Anti-Detection Patch

Description:
WatusiPatch is a comprehensive solution for using old WhatsApp versions:
- ✅ Bypass version check
- ✅ Fix network connection
- ✅ Enable Web login & QR scan
- ✅ Anti-jailbreak detection
- ✅ Background keep-alive

GitHub: https://github.com/yourusername/WatusiPatch
```

### 8.2 添加到 Cydia 源（高级）

如果想创建自己的 Cydia 源:
1. 购买服务器空间
2. 配置 APT 仓库
3. 上传 .deb 文件
4. 生成 Packages 文件

---

## 🔄 步骤 9: 持续维护

### 9.1 处理 Issues

定期检查并回复:
- Bug 报告
- 功能请求
- 使用问题

### 9.2 发布更新

```bash
# 修改代码后
git add .
git commit -m "fix: resolve network connection issue"
git push

# 发布新版本
git tag -a v2.0.1 -m "v2.0.1: Bug fixes"
git push origin v2.0.1
```

### 9.3 更新文档

- 及时更新 CHANGELOG.md
- 修复文档中的错误
- 添加用户反馈的常见问题

---

## ✅ 完成检查清单

部署完成后，确认以下项目:

- [ ] ✅ 代码已推送到 GitHub
- [ ] ✅ GitHub Actions 构建成功
- [ ] ✅ 已创建至少一个 Release
- [ ] ✅ .deb 文件可以下载
- [ ] ✅ README 中的链接已更新
- [ ] ✅ 已添加项目描述和 Topics
- [ ] ✅ 已测试 .deb 安装
- [ ] ✅ 文档完整且准确

---

## 🎉 成功！

你的项目现在已经部署到 GitHub，任何人都可以:
- 浏览源代码
- 下载编译好的 .deb 包
- 提交 Issues 和 Pull Requests
- Fork 并自行修改

**项目地址:**
```
https://github.com/yourusername/WatusiPatch
```

**Release 下载:**
```
https://github.com/yourusername/WatusiPatch/releases
```

---

## 📞 需要帮助？

如果在部署过程中遇到问题:
- 查看 GitHub Actions 日志
- 搜索错误信息
- 在 GitHub Discussions 提问
- 查看 GitHub 官方文档

---

**祝部署顺利！** 🚀
