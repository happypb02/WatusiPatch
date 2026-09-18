#!/bin/bash

# WatusiPatch 完整功能测试脚本
# 测试所有模块的功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo "WatusiPatch 完整功能测试"
echo "========================================"
echo ""

# 测试 1: 检查安装
echo "1️⃣  检查补丁安装状态..."
if dpkg -l | grep -q watusipatch; then
    echo "   ✅ WatusiPatch 已安装"
    VERSION=$(dpkg -l | grep watusipatch | awk '{print $3}')
    echo "   版本: $VERSION"
else
    echo "   ❌ WatusiPatch 未安装"
    echo "   请先安装补丁"
    exit 1
fi

echo ""

# 测试 2: 检查文件
echo "2️⃣  检查补丁文件..."

DYLIB_PATH="/Library/MobileSubstrate/DynamicLibraries/WatusiPatch.dylib"
if [ -f "$DYLIB_PATH" ]; then
    echo "   ✅ dylib 文件存在"
    ls -lh "$DYLIB_PATH" | awk '{print "   大小: " $5}'
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

# 测试 3: 检查 WhatsApp 进程
echo "3️⃣  检查 WhatsApp 状态..."
if ps aux | grep -v grep | grep -q WhatsApp; then
    echo "   ✅ WhatsApp 正在运行"
    PID=$(ps aux | grep -v grep | grep WhatsApp | head -1 | awk '{print $2}')
    echo "   进程 PID: $PID"
else
    echo "   ⚠️  WhatsApp 未运行"
    echo "   提示: 请启动 WhatsApp 后重新测试"
fi

echo ""

# 测试 4: 检查补丁日志
echo "4️⃣  检查补丁日志..."

echo -n "   主补丁: "
if grep -q "WatusiPatch.*补丁已加载" /var/log/syslog 2>/dev/null || \
   grep -q "WatusiPatch" /var/mobile/Library/Logs/CrashReporter/DiagnosticLogs/*.log 2>/dev/null; then
    echo -e "${GREEN}✓ 已加载${NC}"
else
    echo -e "${YELLOW}? 未确认${NC}"
fi

echo -n "   网络修复: "
if grep -q "NetFix" /var/log/syslog 2>/dev/null || \
   grep -q "NetFix" /var/mobile/Library/Logs/CrashReporter/DiagnosticLogs/*.log 2>/dev/null; then
    echo -e "${GREEN}✓ 已加载${NC}"
else
    echo -e "${YELLOW}? 未确认${NC}"
fi

echo -n "   Web 登录: "
if grep -q "WebLoginFix" /var/log/syslog 2>/dev/null || \
   grep -q "WebLoginFix" /var/mobile/Library/Logs/CrashReporter/DiagnosticLogs/*.log 2>/dev/null; then
    echo -e "${GREEN}✓ 已加载${NC}"
else
    echo -e "${YELLOW}? 未确认${NC}"
fi

echo -n "   反越狱检测: "
if grep -q "AntiJB" /var/log/syslog 2>/dev/null || \
   grep -q "AntiJB" /var/mobile/Library/Logs/CrashReporter/DiagnosticLogs/*.log 2>/dev/null; then
    echo -e "${GREEN}✓ 已加载${NC}"
else
    echo -e "${YELLOW}? 未确认${NC}"
fi

echo ""

# 测试 5: 网络连接
echo "5️⃣  测试网络连接..."
if ping -c 1 -W 2 v.whatsapp.net &>/dev/null; then
    echo "   ✅ 可以连接到 WhatsApp 服务器 (v.whatsapp.net)"
else
    echo "   ⚠️  无法连接到 WhatsApp 服务器"
    echo "   请检查网络连接"
fi

echo ""

# 测试 6: 越狱检测绕过
echo "6️⃣  测试越狱检测绕过..."

# 检查是否能检测到越狱文件
echo -n "   Cydia 文件隐藏: "
if [ -d "/Applications/Cydia.app" ]; then
    echo -e "${GREEN}✓ 文件存在但应被隐藏${NC}"
else
    echo -e "${YELLOW}- Cydia 未安装${NC}"
fi

echo -n "   Substrate 库隐藏: "
if [ -f "/Library/MobileSubstrate/MobileSubstrate.dylib" ]; then
    echo -e "${GREEN}✓ 库存在但应被隐藏${NC}"
else
    echo -e "${YELLOW}- Substrate 未找到${NC}"
fi

echo ""

# 测试 7: 配置检查
echo "7️⃣  检查配置..."

CONFIG_PATH="/var/mobile/Library/Preferences/com.watusipatch.plist"
if [ -f "$CONFIG_PATH" ]; then
    echo "   ✅ 配置文件存在"
    echo "   配置内容:"
    if command -v plutil &> /dev/null; then
        plutil -p "$CONFIG_PATH" | sed 's/^/   /'
    else
        cat "$CONFIG_PATH" | sed 's/^/   /'
    fi
else
    echo "   ℹ️  配置文件不存在 (使用默认配置)"
fi

echo ""

# 测试 8: 最新日志
echo "8️⃣  最新补丁日志 (最近 10 条)..."
echo "-----------------------------------"
if [ -f /var/log/syslog ]; then
    grep -E "WatusiPatch|NetFix|WebLoginFix|AntiJB" /var/log/syslog 2>/dev/null | tail -10 | sed 's/^/   /'
else
    echo "   ⚠️  系统日志不可用"
fi

echo ""
echo "========================================"
echo "手动测试清单"
echo "========================================"
echo ""
echo "请手动验证以下功能:"
echo ""
echo "□ 1. 版本检查绕过"
echo "     操作: 启动 WhatsApp"
echo "     预期: 不显示「版本已过期」提示"
echo ""
echo "□ 2. 网络连接"
echo "     操作: 发送消息"
echo "     预期: 消息正常发送，无需更新"
echo ""
echo "□ 3. Web 登录"
echo "     操作: 设置 → 已连接设备 → 扫码"
echo "     预期: 成功扫码登录 WhatsApp Web"
echo ""
echo "□ 4. 越狱检测绕过"
echo "     操作: 登录或使用应用"
echo "     预期: 无「非官方应用」警告"
echo ""
echo "□ 5. 后台保活"
echo "     操作: 切换到后台 1 分钟后返回"
echo "     预期: 立即接收新消息，延迟 < 5 秒"
echo ""
echo "□ 6. 网络切换"
echo "     操作: WiFi ↔ 蜂窝数据切换"
echo "     预期: 自动重连，无需重启应用"
echo ""
echo "========================================"
echo "问题排查"
echo "========================================"
echo ""
echo "如果遇到问题:"
echo ""
echo "1. 重新安装补丁:"
echo "   dpkg -r com.yourname.watusipatch"
echo "   dpkg -i watusipatch.deb"
echo ""
echo "2. 完全重启 WhatsApp:"
echo "   killall -9 WhatsApp"
echo "   # 等待 5 秒"
echo "   # 重新打开 WhatsApp"
echo ""
echo "3. 查看崩溃日志:"
echo "   ls -lt /var/mobile/Library/Logs/CrashReporter/ | head -5"
echo ""
echo "4. 查看完整日志:"
echo "   grep -i 'watusi\|netfix\|weblogin\|antijb' /var/log/syslog"
echo ""
echo "5. 清除配置并重置:"
echo "   rm /var/mobile/Library/Preferences/com.watusipatch.plist"
echo "   killall -9 cfprefsd"
echo "   killall -9 WhatsApp"
echo ""
echo "6. 提交问题:"
echo "   https://github.com/yourname/WatusiPatch/issues"
echo ""
echo "========================================"
echo "测试完成!"
echo "========================================"
