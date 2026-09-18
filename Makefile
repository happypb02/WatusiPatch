export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WatusiPatch

# 整合所有模块（添加反越狱检测模块）
WatusiPatch_FILES = Tweak.x NetworkFix.x WebLoginFix.x AntiJailbreakDetection.x
WatusiPatch_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
WatusiPatch_FRAMEWORKS = UIKit Foundation CoreLocation BackgroundTasks CFNetwork SystemConfiguration
WatusiPatch_PRIVATE_FRAMEWORKS =
WatusiPatch_LIBRARIES = substrate xml2

# 优化编译
WatusiPatch_CCFLAGS = -std=c11
WatusiPatch_CXXFLAGS = -std=c++11

include $(THEOS_MAKE_PATH)/tweak.mk

# 安装后自动重启 WhatsApp
after-install::
	install.exec "killall -9 WhatsApp || true; killall -9 WhatsAppSMB || true"
	install.exec "uicache"

# 清理配置
clean::
	rm -f packages/*.deb
