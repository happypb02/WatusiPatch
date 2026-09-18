#!/bin/bash

echo "========================================"
echo "WatusiPatch 测试脚本"
echo "========================================"
echo ""

# 检查是否在越狱设备上
if [ ! -f "/usr/bin/dpkg" ]; then
    echo "❌ 错误: 此脚本必须在越狱设备上运行"
    exit 1
fi

echo "✅ 检测到越狱环境"
echo ""

# 检查补丁是否安装
if dpkg -l | grep -q "watusipatch"; then
    echo "✅ WatusiPatch 已安装"
    dpkg -l | grep watusipatch
else
    echo "❌ WatusiPatch 未安装"
    echo "请先运行: dpkg -i watusipatch.deb"
    exit 1
fi

echo ""
echo "========================================"
echo "测试项目"
echo "========================================"
echo ""

# 测试 1: 检查 WhatsApp 是否运行
echo "1️⃣  检查 WhatsApp 进程..."
if ps aux | grep -v grep | grep -q WhatsApp; then
    echo "   ✅ WhatsApp 正在运行"
    ps aux | grep -v grep | grep WhatsApp | awk '{print "   进程ID:", $2}'
else
    echo "   ⚠️  WhatsApp 未运行"
    echo "   请启动 WhatsApp 后重新运行测试"
fi

echo ""

# 测试 2: 检查日志输出
echo "2️⃣  检查补丁日志..."
if [ -f "/var/log/syslog" ]; then
    LOGS=$(grep -i "WatusiPatch\|NetFix\|WebLoginFix" /var/log/syslog | tail -5)
    if [ -n "$LOGS" ]; then
        echo "   ✅ 找到补丁日志:"
        echo "$LOGS" | sed 's/^/   /'
    else
        echo "   ⚠️  未找到补丁日志"
        echo "   可能需要重启 WhatsApp"
    fi
else
    echo "   ℹ️  系统日志文件不存在，跳过"
fi

echo ""

# 测试 3: 检查配置文件
echo "3️⃣  检查配置文件..."
PREF_FILE="/var/mobile/Library/Preferences/com.watusipatch.plist"
if [ -f "$PREF_FILE" ]; then
    echo "   ✅ 配置文件存在: $PREF_FILE"
    defaults read com.watusipatch 2>/dev/null && echo "   配置已加载" || echo "   ⚠️  配置可能未正确加载"
else
    echo "   ℹ️  配置文件不存在（使用默认配置）"
fi

echo ""

# 测试 4: 检查 dylib 注入
echo "4️⃣  检查 dylib 注入..."
DYLIB_PATH="/Library/MobileSubstrate/DynamicLibraries/WatusiPatch.dylib"
if [ -f "$DYLIB_PATH" ]; then
    echo "   ✅ dylib 文件存在"
    ls -lh "$DYLIB_PATH" | awk '{print "   大小:", $5}'
else
    echo "   ❌ dylib 文件不存在"
fi

PLIST_PATH="/Library/MobileSubstrate/DynamicLibraries/WatusiPatch.plist"
if [ -f "$PLIST_PATH" ]; then
    echo "   ✅ plist 文件存在"
    cat "$PLIST_PATH" | sed 's/^/   /'
else
    echo "   ❌ plist 文件不存在"
fi

echo ""

# 测试 5: 网络连接测试
echo "5️⃣  测试网络连接..."
if ping -c 1 -W 2 v.whatsapp.net &>/dev/null; then
    echo "   ✅ 可以连接到 WhatsApp 服务器 (v.whatsapp.net)"
else
    echo "   ⚠️  无法连接到 WhatsApp 服务器"
    echo "   请检查网络连接"
fi

echo ""
echo "========================================"
echo "手动测试清单"
echo "========================================"
echo ""
echo "请手动测试以下功能:"
echo ""
echo "✓ [ ] 1. 启动 WhatsApp，是否显示「版本已过期」提示？"
echo "     预期: 不显示任何过期提示"
echo ""
echo "✓ [ ] 2. 尝试发送消息，是否能正常发送？"
echo "     预期: 消息正常发送，无「需要更新」错误"
echo ""
echo "✓ [ ] 3. 点击「设置」-「已连接设备」，是否可以进入？"
echo "     预期: 可以正常进入，显示二维码扫描界面"
echo ""
echo "✓ [ ] 4. 扫描 WhatsApp Web 二维码，是否能成功登录？"
echo "     预期: 成功配对并登录 Web 版"
echo ""
echo "✓ [ ] 5. 将应用切到后台 5 分钟，收到的消息是否延迟？"
echo "     预期: 消息实时到达，延迟 < 5 秒"
echo ""
echo "✓ [ ] 6. 开关飞行模式，是否自动重连？"
echo "     预期: 网络恢复后自动重连，无需重启应用"
echo ""
echo "✓ [ ] 7. 查看「关于」页面的版本号"
echo "     预期: 显示 $SPOOFED_VERSION 或原版本号"
echo ""

echo "========================================"
echo "调试命令"
echo "========================================"
echo ""
echo "# 查看实时日志"
echo "tail -f /var/log/syslog | grep -i 'WatusiPatch\|NetFix\|WebLoginFix'"
echo ""
echo "# 重启 WhatsApp"
echo "killall -9 WhatsApp && killall -9 WhatsAppSMB"
echo ""
echo "# 查看配置"
echo "defaults read com.watusipatch"
echo ""
echo "# 修改配置示例"
echo "defaults write com.watusipatch networkPersistenceEnabled -bool YES"
echo "defaults write com.watusipatch heartbeatInterval -int 25"
echo ""
echo "# 卸载补丁"
echo "dpkg -r com.yourname.watusipatch"
echo ""
echo "========================================"
echo "测试完成"
echo "========================================"
