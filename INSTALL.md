# Watusi Patch 安装和使用指南

## 📋 前提条件

在开始之前，请确保：

- ✅ 已越狱的 iOS 设备（iOS 12.0 或更高版本）
- ✅ 已安装 Cydia 或 Sileo
- ✅ 已安装 Watusi 3（必需）
- ✅ 基本的终端使用知识（如需手动编译）

---

## 🚀 快速安装（推荐）

### 方法 1：通过包管理器安装

```bash
# 1. 在 Cydia/Sileo 中添加源（假设你有自己的源）
# 源地址: https://your-repo.com

# 2. 搜索 "Watusi Patch" 或 "Watusi Network Optimization"

# 3. 点击安装

# 4. 重启 SpringBoard 或重启设备
```

### 方法 2：手动安装 deb 包

```bash
# 1. 下载 deb 包到电脑

# 2. 通过 SSH 传输到设备
scp com.yourname.watusipatch_2.0.0_iphoneos-arm.deb root@192.168.1.xxx:/tmp/

# 3. SSH 连接到设备
ssh root@192.168.1.xxx

# 4. 安装 deb 包
dpkg -i /tmp/com.yourname.watusipatch_2.0.0_iphoneos-arm.deb

# 5. 重启 WhatsApp
killall -9 WhatsApp

# 6. 清理临时文件
rm /tmp/com.yourname.watusipatch_2.0.0_iphoneos-arm.deb
```

---

## 🔨 从源码编译安装

### 步骤 1：准备开发环境

#### macOS/Linux

```bash
# 1. 安装 Theos
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 2. 设置环境变量
echo "export THEOS=~/theos" >> ~/.bash_profile
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile

# 3. 验证安装
ls $THEOS
```

#### Windows (WSL)

```bash
# 1. 安装 WSL2
wsl --install

# 2. 在 WSL 中按照 macOS/Linux 步骤操作
```

### 步骤 2：获取源码

```bash
# 方法 1: 从 GitHub 克隆
git clone https://github.com/yourname/WatusiPatch.git
cd WatusiPatch

# 方法 2: 下载 ZIP 解压
# 下载后解压到任意目录
```

### 步骤 3：配置项目

```bash
# 编辑 Makefile，设置目标设备 IP
# THEOS_DEVICE_IP = 192.168.1.xxx

# 或使用 USB 连接（推荐）
# 需要安装 usbmuxd
brew install libusbmuxd  # macOS
sudo apt-get install libusbmuxd-tools  # Linux

# 设置 SSH 端口转发
iproxy 2222 22
```

### 步骤 4：编译

```bash
# 清理旧的构建文件
make clean

# 编译项目
make

# 如果成功，你会看到：
# ==> Signing WatusiPatch...
# ==> Notice: Build succeeded!
```

### 步骤 5：打包

```bash
# 生成 deb 安装包
make package

# 查看生成的包
ls packages/

# 输出示例：
# com.yourname.watusipatch_2.0.0_iphoneos-arm.deb
```

### 步骤 6：安装到设备

```bash
# 方法 1: 使用 make install（自动安装）
make install

# 方法 2: 手动安装
scp packages/com.yourname.watusipatch_2.0.0_iphoneos-arm.deb root@localhost:/tmp/
ssh root@localhost -p 2222 "dpkg -i /tmp/com.yourname.watusipatch_2.0.0_iphoneos-arm.deb"

# 方法 3: 使用构建脚本
chmod +x build.sh
./build.sh install
```

---

## ⚙️ 配置和使用

### 首次使用配置

#### 1. 打开设置

```
设置 → Watusi Patch
```

#### 2. 推荐配置（默认全部开启）

| 选项 | 推荐 | 说明 |
|------|------|------|
| 网络持久化 | ✅ 开 | 后台保持连接 |
| 后台保活 | ✅ 开 | 使用后台任务 |
| 自动重连 | ✅ 开 | 断线自动重连 |
| 位置服务保活 | ✅ 开 | 长时间后台运行 |
| 调试日志 | ❌ 关 | 仅调试时开启 |

#### 3. 配置位置权限（重要）

```
设置 → 隐私 → 定位服务 → WhatsApp → 始终
```

**为什么需要"始终"权限？**
- 保证后台长时间运行
- 已使用低精度模式，耗电极低
- 不会获取或上传你的位置数据

### 高级配置

#### 通过配置文件

```bash
# SSH 连接到设备
ssh root@192.168.1.xxx

# 编辑配置文件
nano /var/mobile/Library/Preferences/com.watusipatch.plist

# 或使用 defaults 命令
defaults write com.watusipatch networkPersistence -bool YES
defaults write com.watusipatch backgroundKeepAlive -bool YES
defaults write com.watusipatch autoReconnect -bool YES
defaults write com.watusipatch locationBackgrounding -bool YES
defaults write com.watusipatch debugLogging -bool NO

# 重启 WhatsApp 使配置生效
killall -9 WhatsApp
```

---

## 🧪 验证安装

### 快速验证

```bash
# 1. 检查补丁是否已安装
ssh root@192.168.1.xxx
dpkg -l | grep watusipatch

# 应该看到：
# ii  com.yourname.watusipatch  2.0.0  iphoneos-arm  Watusi Network Optimization

# 2. 检查 dylib 文件
ls -la /Library/MobileSubstrate/DynamicLibraries/WatusiPatch.*

# 应该看到：
# WatusiPatch.dylib
# WatusiPatch.plist

# 3. 打开 WhatsApp，查看日志
tail -f /var/log/syslog | grep WatusiPatch

# 应该看到类似：
# [WatusiPatch] ====================================
# [WatusiPatch] Watusi 反检测 & 网络优化补丁
# [WatusiPatch] 版本: 2.0.0
# [WatusiPatch] ====================================
# [WatusiPatch] 所有 Hook 已安装
```

### 完整测试

```bash
# 使用测试脚本
chmod +x test.sh
./test.sh

# 测试脚本会自动检查：
# ✓ Hook 加载
# ✓ 配置文件
# ✓ 日志输出
# ✓ 后台保活
# ✓ 网络重连
# ✓ 内存占用
# ✓ 越狱检测绕过
```

### 手动测试

#### 测试 1：后台保活

```
1. 打开 WhatsApp，确保已登录
2. 按 Home 键，将 WhatsApp 切换到后台
3. 等待 5 分钟
4. 让朋友给你发消息
5. 检查是否实时收到（应该 < 5 秒）

预期结果：✅ 消息实时到达
```

#### 测试 2：网络重连

```
1. 打开 WhatsApp
2. 开启飞行模式（等待 10 秒）
3. 关闭飞行模式
4. 观察是否自动重连（应该 < 15 秒）

预期结果：✅ 自动重连成功
```

#### 测试 3：越狱检测

```
1. 完全卸载 WhatsApp
2. 重新安装并打开
3. 登录账号

预期结果：✅ 正常登录，无越狱警告
```

---

## 🔧 故障排除

### 问题 1：安装失败

**症状：**
```
dpkg: error processing package com.yourname.watusipatch (--install):
 dependency problems - leaving unconfigured
```

**解决方案：**
```bash
# 检查依赖
apt-get install -f

# 强制安装
dpkg -i --force-all com.yourname.watusipatch_2.0.0_iphoneos-arm.deb

# 或重新安装依赖
apt-get install mobilesubstrate preferenceloader
```

### 问题 2：补丁不生效

**症状：** 安装后没有任何效果

**解决方案：**
```bash
# 1. 确认 WhatsApp 进程已重启
killall -9 WhatsApp
killall -9 WhatsAppSMB

# 2. 重启 SpringBoard
killall -9 SpringBoard

# 3. 如果还是不行，重启设备
reboot

# 4. 检查是否冲突
# 卸载其他 WhatsApp 插件后重试
```

### 问题 3：后台仍然断开

**症状：** 后台几分钟后还是断开连接

**解决方案：**
```bash
# 1. 检查配置
defaults read com.watusipatch

# 2. 确保所有选项都是 YES
defaults write com.watusipatch networkPersistence -bool YES
defaults write com.watusipatch backgroundKeepAlive -bool YES
defaults write com.watusipatch locationBackgrounding -bool YES

# 3. 检查位置权限
# 设置 → 隐私 → 定位服务 → WhatsApp → 始终

# 4. 检查低电量模式
# 低电量模式会限制后台活动，建议关闭

# 5. 重启 WhatsApp
killall -9 WhatsApp
```

### 问题 4：找不到配置页面

**症状：** 设置中没有 Watusi Patch 选项

**解决方案：**
```bash
# 1. 确认 PreferenceLoader 已安装
dpkg -l | grep preferenceloader

# 2. 如果未安装
apt-get install preferenceloader

# 3. 检查配置文件
ls /Library/PreferenceLoader/Preferences/WatusiPatch.plist

# 4. 重启 SpringBoard
killall -9 SpringBoard
```

### 问题 5：日志没有输出

**症状：** 查看日志时没有任何 WatusiPatch 相关信息

**解决方案：**
```bash
# 1. 确认 WhatsApp 正在运行
ps aux | grep WhatsApp

# 2. 检查 dylib 是否加载
# 在 WhatsApp 运行时执行
lsof -p $(pgrep WhatsApp) | grep WatusiPatch

# 应该看到 WatusiPatch.dylib

# 3. 启用调试日志
defaults write com.watusipatch debugLogging -bool YES
killall -9 WhatsApp

# 4. 使用 deviceconsole（更详细）
deviceconsole | grep WatusiPatch
```

### 问题 6：编译错误

**症状：** make 时出现错误

**常见错误 1：**
```
make: *** No rule to make target `internal-library-compile'.  Stop.
```
**解决：**
```bash
# 确认 THEOS 环境变量正确
echo $THEOS
export THEOS=~/theos
```

**常见错误 2：**
```
error: unable to find utility "ldid"
```
**解决：**
```bash
# 安装 ldid
brew install ldid  # macOS
```

**常见错误 3：**
```
error: iOS SDK not found
```
**解决：**
```bash
# 下载并安装 iOS SDK
cd $THEOS
git clone https://github.com/theos/sdks.git sdks
```

---

## 📱 日常使用

### 开启后台保活

```
1. 打开 WhatsApp
2. 正常使用
3. 按 Home 键（自动开启后台保活）
```

**指示器：**
- 状态栏可能显示位置图标（正常现象）
- 耗电增加很少（< 5%/小时）

### 关闭后台保活

```
方法 1: 在设置中关闭
设置 → Watusi Patch → 后台保活 → 关闭

方法 2: 完全退出 WhatsApp
双击 Home 键 → 向上滑动 WhatsApp 卡片
```

### 查看运行状态

```bash
# SSH 连接设备
ssh root@192.168.1.xxx

# 查看实时日志
tail -f /var/log/syslog | grep WatusiPatch

# 查看内存占用
ps aux | grep WhatsApp

# 查看网络连接
lsof -i -P | grep WhatsApp
```

---

## 🔄 更新和卸载

### 更新补丁

```bash
# 方法 1: 通过包管理器
# Cydia/Sileo 中检查更新并安装

# 方法 2: 手动更新
# 下载新版本 deb 包
dpkg -i com.yourname.watusipatch_2.1.0_iphoneos-arm.deb

# 重启 WhatsApp
killall -9 WhatsApp
```

### 卸载补丁

```bash
# 方法 1: 通过包管理器
# Cydia/Sileo 中选择卸载

# 方法 2: 命令行卸载
ssh root@192.168.1.xxx
dpkg -r com.yourname.watusipatch

# 清理配置（可选）
rm /var/mobile/Library/Preferences/com.watusipatch.plist

# 重启 WhatsApp
killall -9 WhatsApp
```

---

## 📊 性能监控

### 监控耗电

```
设置 → 电池 → 查看 WhatsApp 使用情况

正常范围：
- 前台使用：与原生相同
- 后台使用：增加 3-5% / 小时
```

### 监控流量

```
设置 → 蜂窝网络 → 查看 WhatsApp 流量

正常范围：
- 心跳包：约 1-2 KB / 分钟
- 总计：约 5-10 MB / 天（仅心跳）
```

### 监控内存

```bash
# 获取内存占用
ssh root@192.168.1.xxx
ps aux | grep WhatsApp | awk '{print $4"%"}'

正常范围：5-10%
```

---

## 🎓 最佳实践

### 推荐设置

1. **全部功能开启**（默认）
   - 最佳在线体验
   - 耗电增加可接受

2. **省电模式**
   ```
   ✅ 网络持久化
   ✅ 自动重连
   ❌ 后台保活
   ❌ 位置服务保活
   ```
   - 后台 3-5 分钟后断开
   - 几乎不增加耗电

3. **极致在线模式**
   ```
   ✅ 全部开启
   + 关闭低电量模式
   + 保持 WiFi 开启
   ```
   - 24/7 保持在线
   - 耗电约 10% / 小时

### 使用场景

**场景 1：日常使用**
```
✅ 全部功能开启（默认）
```

**场景 2：重要会话等待消息**
```
✅ 全部功能开启
+ 充电状态
```

**场景 3：外出省电**
```
✅ 仅网络持久化和自动重连
❌ 关闭后台保活
```

**场景 4：夜间睡眠**
```
可选择完全退出 WhatsApp
或保持后台（消息及时送达）
```

---

## 🆘 获取帮助

### 在线资源

- **文档：** README.md, TECHNICAL.md
- **GitHub Issues：** 提交问题和建议
- **Discord/Telegram：** 社区讨论

### 收集诊断信息

```bash
# 生成诊断报告
ssh root@192.168.1.xxx

# 系统信息
uname -a > /tmp/watusi_diag.txt
sw_vers >> /tmp/watusi_diag.txt

# 补丁信息
dpkg -l | grep watusi >> /tmp/watusi_diag.txt
defaults read com.watusipatch >> /tmp/watusi_diag.txt

# 日志
grep WatusiPatch /var/log/syslog | tail -n 50 >> /tmp/watusi_diag.txt

# 下载报告
exit
scp root@192.168.1.xxx:/tmp/watusi_diag.txt ./

# 提交到 GitHub Issues 或发送给开发者
```

---

**祝你使用愉快！如有问题，请随时反馈。**
