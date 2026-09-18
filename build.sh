#!/bin/bash

# Watusi Patch 编译和安装脚本
# 使用方法: ./build.sh [clean|install|package]

set -e

TWEAK_NAME="WatusiPatch"
PACKAGE_NAME="com.yourname.watusipatch"

echo "======================================"
echo "Watusi Patch 构建脚本"
echo "======================================"

# 检查 Theos 环境
if [ -z "$THEOS" ]; then
    echo "错误: THEOS 环境变量未设置"
    echo "请先安装 Theos: https://theos.dev/docs/installation"
    exit 1
fi

echo "✓ Theos 路径: $THEOS"

# 解析命令
case "$1" in
    clean)
        echo "清理构建文件..."
        make clean
        rm -rf packages/
        echo "✓ 清理完成"
        ;;

    install)
        echo "编译并安装到设备..."

        # 检查设备连接
        if ! which iproxy > /dev/null 2>&1; then
            echo "警告: iproxy 未安装，无法自动连接设备"
            echo "请手动安装: brew install libusbmuxd"
        fi

        # 编译
        echo "正在编译..."
        make package

        # 安装
        echo "正在安装到设备..."
        make install

        echo "✓ 安装完成"
        echo "请重启 WhatsApp 使补丁生效"
        ;;

    package)
        echo "编译 deb 包..."
        make package

        # 显示包信息
        DEB_FILE=$(find packages -name "*.deb" | head -n 1)
        if [ -f "$DEB_FILE" ]; then
            echo ""
            echo "✓ 打包完成"
            echo "文件: $DEB_FILE"
            echo ""
            dpkg-deb -I "$DEB_FILE"
        else
            echo "错误: 未找到 deb 文件"
            exit 1
        fi
        ;;

    *)
        echo "仅编译..."
        make
        echo "✓ 编译完成"
        echo ""
        echo "可用命令:"
        echo "  ./build.sh clean   - 清理构建文件"
        echo "  ./build.sh install - 编译并安装到设备"
        echo "  ./build.sh package - 编译 deb 安装包"
        ;;
esac

echo "======================================"
