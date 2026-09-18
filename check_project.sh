#!/bin/bash

# WatusiPatch 项目结构检查脚本

echo "========================================"
echo "WatusiPatch 项目完整性检查"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 ${RED}(缺失)${NC}"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ ${RED}(缺失)${NC}"
        return 1
    fi
}

# 计数器
total=0
passed=0

echo "1. 核心源代码文件"
echo "-------------------"
files=(
    "Tweak.x"
    "NetworkFix.x"
    "WebLoginFix.x"
    "Makefile"
    "control"
    "WatusiPatch.plist"
)

for file in "${files[@]}"; do
    total=$((total + 1))
    check_file "$file" && passed=$((passed + 1))
done
echo ""

echo "2. 文档文件"
echo "-------------------"
docs=(
    "README.md"
    "CHANGELOG.md"
    "CONTRIBUTING.md"
    "QUICKSTART.md"
    "LICENSE"
    "WEB_LOGIN_ANALYSIS.md"
)

for doc in "${docs[@]}"; do
    total=$((total + 1))
    check_file "$doc" && passed=$((passed + 1))
done
echo ""

echo "3. GitHub Actions"
echo "-------------------"
total=$((total + 1))
check_dir ".github" && passed=$((passed + 1))
total=$((total + 1))
check_dir ".github/workflows" && passed=$((passed + 1))
total=$((total + 1))
check_file ".github/workflows/build.yml" && passed=$((passed + 1))
echo ""

echo "4. 配置文件"
echo "-------------------"
configs=(
    ".gitignore"
)

for config in "${configs[@]}"; do
    total=$((total + 1))
    check_file "$config" && passed=$((passed + 1))
done
echo ""

echo "5. 脚本文件"
echo "-------------------"
scripts=(
    "test.sh"
)

for script in "${scripts[@]}"; do
    total=$((total + 1))
    if check_file "$script"; then
        passed=$((passed + 1))
        # 检查是否可执行
        if [ -x "$script" ]; then
            echo -e "  ${GREEN}✓${NC} 可执行权限已设置"
        else
            echo -e "  ${YELLOW}!${NC} 建议添加可执行权限: chmod +x $script"
        fi
    fi
done
echo ""

echo "========================================"
echo "检查结果汇总"
echo "========================================"
echo ""
echo "总计: $total 项"
echo -e "通过: ${GREEN}$passed${NC} 项"
echo -e "失败: ${RED}$((total - passed))${NC} 项"
echo ""

# 计算通过率
percentage=$((passed * 100 / total))

if [ $percentage -eq 100 ]; then
    echo -e "${GREEN}✓ 项目结构完整！可以开始编译${NC}"
    echo ""
    echo "下一步："
    echo "  1. 检查 Theos 环境: echo \$THEOS"
    echo "  2. 清理构建: make clean"
    echo "  3. 编译项目: make"
    echo "  4. 打包: make package"
    exit 0
elif [ $percentage -ge 80 ]; then
    echo -e "${YELLOW}! 项目基本完整，但有部分文件缺失${NC}"
    exit 1
else
    echo -e "${RED}✗ 项目结构不完整，请补充缺失文件${NC}"
    exit 2
fi
