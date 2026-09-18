# 🚀 快速开始指南

本指南帮助你快速编译、安装和使用 WatusiPatch。

---

## 📋 目录

1. [编译方法](#编译方法)
2. [安装方法](#安装方法)
3. [验证安装](#验证安装)
4. [基础配置](#基础配置)
5. [常见问题](#常见问题)

---

## 🔨 编译方法

### 方法 1: GitHub Actions 自动编译（推荐）

这是最简单的方法，无需本地环境。

#### 步骤：

1. **Fork 本项目**
   ```
   访问: https://github.com/yourname/WatusiPatch
   点击右上角 "Fork" 按钮
   ```

2. **触发编译**
   ```
   方式 1: Push 代码到 main 分支
   方式 2: 手动触发 Actions
   ```

3. **下载编译产物**
   ```
   进入 Actions 页面
   选择最新的 workflow run
   下载 Artifacts 中的 .deb 文件
   ```

#### 自动发布：

打 Tag 触发自动发布到 Releases：

```bash
git tag v2.0.0
git push origin v2.0.0
```

编译完成后会自动创建 GitHub Release 并上传 .deb 文件。

---

### 方法 2: 本地编译（macOS）

适合开发者或需要自定义的用户。

#### 前置要求：

```bash
# 1. 安装 Xcode Command Line Tools
xcode-select --install

# 2. 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. 安装依赖
brew install ldid
```

#### 安装 Theos：

```bash
# 克隆 Theos
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos

# 设置环境变量
echo "export THEOS=/opt/theos" >> ~/.zshrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.zshrc
source ~/.zshrc

# 安装 iOS SDK
cd $THEOS
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/iPhoneOS*.sdk sdks/
rm -rf sdks-master master.zip
```

#### 克隆项目并编译：

```bash
# 克隆项目
git clone https://github.com/yourname/WatusiPatch.git
cd WatusiPatch

# 清理
make clean

# 编译
make

# 打包
make package

# 查看生成的 deb 包
ls -lh packages/*.deb
```

成功后会在 `packages/` 目录下生成 `.deb` 文件。

---

### 方法 3: 本地编译（Linux）

#### Ubuntu/Debian：

```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y git curl wget build-essential fakeroot \
  libxml2-dev libssl-dev libtool autoconf automake

# 安装 Theos
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
export THEOS=/opt/theos
export PATH=$THEOS/bin:$PATH

# 下载 iOS SDK
cd $THEOS
wget https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/iPhoneOS*.sdk sdks/
rm -rf sdks-master master.zip

# 编译项目
cd /path/to/WatusiPatch
make clean
make package
```

---

## 📦 安装方法

### 方法 1: SSH 安装（推荐）

适合通过 USB 或 WiFi SSH 连接的越狱设备。

```bash
# 1. 将 .deb 文件复制到设备
scp packages/com.yourname.watusipatch_2.0.0_iphoneos-arm.deb root@192.168.1.100:/tmp/

# 2. SSH 连接到设备
ssh root@192.168.1.100
# 默认密码: alpine

# 3. 安装
cd /tmp
dpkg -i com.yourname.watusipatch_2.0.0_iphoneos-arm.deb

# 4. 重启 WhatsApp
killall -9 WhatsApp
killall -9 WhatsAppSMB

# 5. 清理
rm com.yourname.watusipatch_2.0.0_iphoneos-arm.deb
```

---

### 方法 2: Filza 安装

适合不想用命令行的用户。

```
1. 通过 Airdrop/文件共享将 .deb 发送到设备
2. 打开 Filza File Manager
3. 找到 .deb 文件
4. 点击文件 → 右上角 "安装"
5. 等待安装完成
6. 重启设备或手动重启 WhatsApp
```

---

### 方法 3: Cydia/Sileo 安装

如果你有自己的源：

```
1. 打开 Cydia/Sileo
2. 添加源: https://yourrepo.com/
3. 搜索: WatusiPatch
4. 安装
5. 重启 SpringBoard
```

---

## ✅ 验证安装

### 1. 检查是否安装成功

```bash
# SSH 到设备
ssh root@<your-device-ip>

# 检查包是否安装
dpkg -l | grep watusipatch

# 应该看到:
# ii  com.yourname.watusipatch  2.0.0  iphoneos-arm  WatusiPatch
```

### 2. 检查文件是否存在

```bash
# 检查 dylib
ls -lh /Library/MobileSubstrate/DynamicLibraries/WatusiPatch.dylib

# 检查 plist
cat /Library/MobileSubstrate/DynamicLibraries/WatusiPatch.plist
```

### 3. 查看日志

```bash
# 重启 WhatsApp
killall -9 WhatsApp

# 启动 WhatsApp 并查看日志
tail -f /var/log/syslog | grep -i "WatusiPatch\|NetFix\|WebLoginFix"

# 应该看到类似:
# [WatusiPatch] 补丁已加载 v2.0.0
# [NetFix] XMPP: 伪装版本 2.24.3.70
# [WebLoginFix] Web 登录修复补丁已加载
```

### 4. 功能测试

运行测试脚本：

```bash
# 复制测试脚本到设备
scp test.sh root@<device-ip>:/tmp/

# 执行测试
ssh root@<device-ip>
chmod +x /tmp/test.sh
/tmp/test.sh
```

---

## ⚙️ 基础配置

### 查看当前配置

```bash
defaults read com.watusipatch
```

### 常用配置

```bash
# 启用/禁用网络持久化
defaults write com.watusipatch networkPersistenceEnabled -bool YES

# 启用/禁用后台保活
defaults write com.watusipatch backgroundKeepAliveEnabled -bool YES

# 设置心跳间隔（秒）
defaults write com.watusipatch heartbeatInterval -int 25

# 启用调试日志
defaults write com.watusipatch debugLoggingEnabled -bool YES

# 应用配置
killall -9 cfprefsd
killall -9 WhatsApp
```

### 恢复默认配置

```bash
defaults delete com.watusipatch
killall -9 cfprefsd
killall -9 WhatsApp
```

---

## ❓ 常见问题

### Q1: 安装后没有效果？

**解决方法：**

```bash
# 1. 确认补丁已安装
dpkg -l | grep watusipatch

# 2. 完全退出 WhatsApp（不是后台切换）
killall -9 WhatsApp

# 3. 重启设备
reboot

# 4. 重新安装 Mobile Substrate
apt-get install --reinstall mobilesubstrate
killall -9 SpringBoard
```

### Q2: WhatsApp 崩溃或无法启动？

**解决方法：**

```bash
# 1. 查看崩溃日志
cat /var/mobile/Library/Logs/CrashReporter/WhatsApp*.ips

# 2. 卸载补丁测试
dpkg -r com.yourname.watusipatch
killall -9 WhatsApp

# 3. 如果卸载后正常，重新安装最新版本
# 4. 如果还是崩溃，可能是 WhatsApp 版本不兼容
```

### Q3: 仍然提示"版本已过期"？

**解决方法：**

```bash
# 1. 确认日志中有版本伪装信息
grep "NetFix.*伪装版本" /var/log/syslog

# 2. 如果没有，检查补丁是否正确注入
ls -l /Library/MobileSubstrate/DynamicLibraries/WatusiPatch.*

# 3. 重新安装补丁
dpkg -r com.yourname.watusipatch
dpkg -i watusipatch.deb
reboot
```

### Q4: 扫码登录仍然失败？

**解决方法：**

```bash
# 1. 检查 Web 登录功能是否启用
grep "WebLoginFix" /var/log/syslog

# 2. 尝试清除 WhatsApp 数据后重新登录
# 注意：会删除本地聊天记录，请先备份！

# 3. 确保 WhatsApp Web 端是最新版本
```

### Q5: 耗电明显增加？

**解决方法：**

```bash
# 关闭后台保活（只保留网络持久化）
defaults write com.watusipatch backgroundKeepAliveEnabled -bool NO

# 增加心跳间隔
defaults write com.watusipatch heartbeatInterval -int 60

# 关闭位置服务
defaults write com.watusipatch locationBackgroundingEnabled -bool NO

# 应用配置
killall -9 cfprefsd
killall -9 WhatsApp
```

### Q6: 如何完全卸载？

```bash
# 1. 卸载包
dpkg -r com.yourname.watusipatch

# 2. 清理配置
rm -f /var/mobile/Library/Preferences/com.watusipatch.plist

# 3. 清理缓存
killall -9 cfprefsd

# 4. 重启 WhatsApp
killall -9 WhatsApp
```

---

## 📞 获取帮助

如果遇到其他问题：

1. **查看文档**
   - [README.md](README.md) - 完整功能说明
   - [TECHNICAL.md](TECHNICAL.md) - 技术原理
   - [NETWORK_ANALYSIS.md](NETWORK_ANALYSIS.md) - 网络问题分析
   - [WEB_LOGIN_ANALYSIS.md](WEB_LOGIN_ANALYSIS.md) - 扫码问题分析

2. **提交 Issue**
   - https://github.com/yourname/WatusiPatch/issues

3. **社区讨论**
   - GitHub Discussions
   - Reddit: r/jailbreak
   - Telegram: @yourgroup

---

## 🎯 下一步

安装成功后，建议：

1. ✅ 运行测试脚本验证功能
2. ✅ 根据需求调整配置
3. ✅ 阅读完整文档了解更多功能
4. ✅ 给项目点个 ⭐ Star

---

**最后更新：** 2024-01-15  
**当前版本：** v2.0.0
