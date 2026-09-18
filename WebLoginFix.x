/**
 * WhatsApp Web Login & QR Code Fix
 * 修复旧版本无法扫码登录的问题
 */

#import <substrate.h>
#import <Foundation/Foundation.h>

#define WEB_LOGIN_LOG(fmt, ...) NSLog(@"[WebLoginFix] " fmt, ##__VA_ARGS__)

// 伪装的最新版本
#define SPOOFED_VERSION @"2.24.3.70"
#define SPOOFED_BUILD @"24.3.70"

// ============================================================================
// MARK: - 1. Web 登录功能强制启用
// ============================================================================

// Web 会话管理器
%hook WAWebSessionManager

- (BOOL)isWebLoginEnabled {
    WEB_LOGIN_LOG("Web 登录开关检查 - 强制返回 YES");
    return YES;  // 强制启用
}

- (BOOL)isMultiDeviceEnabled {
    WEB_LOGIN_LOG("多设备功能检查 - 强制返回 YES");
    return YES;  // 启用多设备功能
}

- (BOOL)canScanQRCode {
    WEB_LOGIN_LOG("扫码权限检查 - 强制返回 YES");
    return YES;
}

- (void)checkWebLoginEligibility:(void (^)(BOOL eligible, NSError *error))completion {
    WEB_LOGIN_LOG("Web 登录资格检查 - 绕过，直接返回合格");
    if (completion) {
        completion(YES, nil);
    }
}

%end

// Web 功能管理
%hook WAWebClientManager

- (BOOL)isWebClientEnabled {
    return YES;
}

- (BOOL)isQRCodeScanningEnabled {
    return YES;
}

%end

// ============================================================================
// MARK: - 2. 服务器配置拦截
// ============================================================================

%hook WAServerConfigManager

- (NSDictionary *)serverConfig {
    NSMutableDictionary *config = [[%orig mutableCopy] autorelease];

    if (!config) {
        config = [NSMutableDictionary dictionary];
    }

    // 修改最低版本要求
    if (config[@"min_supported_version"]) {
        WEB_LOGIN_LOG("拦截 min_supported_version: %@ -> 0.0.1", config[@"min_supported_version"]);
        config[@"min_supported_version"] = @"0.0.1";
    }

    // 启用 Web 登录功能
    if (!config[@"features"]) {
        config[@"features"] = [NSMutableDictionary dictionary];
    }

    NSMutableDictionary *features = [config[@"features"] mutableCopy];
    features[@"web_login_enabled"] = @YES;
    features[@"web_multidevice_enabled"] = @YES;
    features[@"qr_code_enabled"] = @YES;
    config[@"features"] = features;
    [features release];

    WEB_LOGIN_LOG("服务器配置已修改，启用所有 Web 功能");

    return config;
}

- (BOOL)isFeatureEnabled:(NSString *)featureName {
    // 强制启用 Web 相关功能
    if ([featureName containsString:@"web"] ||
        [featureName containsString:@"qr"] ||
        [featureName containsString:@"multidevice"]) {
        WEB_LOGIN_LOG("功能开关: %@ -> YES", featureName);
        return YES;
    }

    return %orig;
}

%end

// ============================================================================
// MARK: - 3. QR Code 扫描界面修复
// ============================================================================

%hook WAQRCodeViewController

- (void)viewDidLoad {
    WEB_LOGIN_LOG("QR Code 界面加载");

    // 正常加载界面
    %orig;

    // 移除任何版本检查提示
    [self dismissVersionWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    WEB_LOGIN_LOG("QR Code 界面即将显示");
}

%new
- (void)dismissVersionWarning {
    // 移除所有警告视图
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIAlertController class]]) {
            [(UIAlertController *)subview dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

%end

// QR Code 扫描器
%hook WAQRCodeScanner

- (void)startScanning {
    WEB_LOGIN_LOG("开始扫描二维码");
    %orig;
}

- (void)handleScanResult:(NSString *)result {
    WEB_LOGIN_LOG("扫描到二维码: %@", [result substringToIndex:MIN(20, result.length)]);
    %orig(result);
}

%end

// ============================================================================
// MARK: - 4. Web 登录请求修复
// ============================================================================

%hook WAWebLoginRequest

- (NSDictionary *)loginParameters {
    NSMutableDictionary *params = [[%orig mutableCopy] autorelease];

    if (!params) {
        params = [NSMutableDictionary dictionary];
    }

    // 修改版本信息
    params[@"client_version"] = SPOOFED_VERSION;
    params[@"app_version"] = SPOOFED_VERSION;
    params[@"version"] = SPOOFED_VERSION;

    WEB_LOGIN_LOG("Web 登录参数 - 版本伪装为 %@", SPOOFED_VERSION);

    return params;
}

- (NSString *)clientVersion {
    return SPOOFED_VERSION;
}

%end

// Web 登录管理器
%hook WAWebLoginManager

- (void)initiateLoginWithRef:(NSString *)ref completion:(void (^)(BOOL success, NSError *error))completion {
    WEB_LOGIN_LOG("发起 Web 登录请求: %@", ref);

    // 调用原始方法
    %orig(ref, ^(BOOL success, NSError *error) {
        if (!success && error) {
            // 检查是否是版本错误
            if ([error.domain isEqualToString:@"WAWebLoginErrorDomain"] &&
                (error.code == 403 || error.code == 426)) {

                NSDictionary *userInfo = error.userInfo;
                if ([userInfo[@"reason"] containsString:@"version"] ||
                    [userInfo[@"reason"] containsString:@"old"]) {

                    WEB_LOGIN_LOG("拦截版本错误，伪造成功");

                    // 伪造成功回调
                    if (completion) {
                        completion(YES, nil);
                    }
                    return;
                }
            }
        }

        // 正常回调
        if (completion) {
            completion(success, error);
        }
    });
}

- (void)handleLoginResponse:(NSDictionary *)response completion:(id)completion {
    WEB_LOGIN_LOG("处理登录响应");

    // 检查响应中的错误
    if ([response[@"status"] isEqualToString:@"fail"] ||
        [response[@"status"] isEqualToString:@"error"]) {

        NSString *reason = response[@"reason"];
        if ([reason containsString:@"version"] ||
            [reason containsString:@"old"] ||
            [reason containsString:@"update"]) {

            WEB_LOGIN_LOG("拦截版本错误响应，伪造成功");

            // 伪造成功响应
            NSMutableDictionary *fakeResponse = [response mutableCopy];
            fakeResponse[@"status"] = @"success";
            [fakeResponse removeObjectForKey:@"reason"];
            [fakeResponse removeObjectForKey:@"error"];

            %orig(fakeResponse, completion);
            [fakeResponse release];
            return;
        }
    }

    // 正常处理
    %orig(response, completion);
}

%end

// ============================================================================
// MARK: - 5. HTTP 请求版本伪装
// ============================================================================

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    // 针对 Web 登录相关的请求
    if ([self.URL.host containsString:@"whatsapp"] &&
        [self.URL.path containsString:@"web"]) {

        // 修改 User-Agent
        if ([field isEqualToString:@"User-Agent"]) {
            if ([value containsString:@"WhatsApp"]) {
                NSRegularExpression *regex = [NSRegularExpression
                    regularExpressionWithPattern:@"WhatsApp/[0-9\\.]+"
                    options:0 error:nil];

                NSString *spoofedUA = [regex
                    stringByReplacingMatchesInString:value
                    options:0
                    range:NSMakeRange(0, value.length)
                    withTemplate:[NSString stringWithFormat:@"WhatsApp/%@", SPOOFED_VERSION]];

                WEB_LOGIN_LOG("Web 请求 User-Agent 伪装: %@", spoofedUA);
                %orig(spoofedUA, field);
                return;
            }
        }

        // 添加版本头
        if ([field isEqualToString:@"WA-Version"]) {
            WEB_LOGIN_LOG("Web 请求版本头伪装: %@", SPOOFED_VERSION);
            %orig(SPOOFED_VERSION, field);
            return;
        }
    }

    %orig(value, field);
}

%end

// ============================================================================
// MARK: - 6. Web 连接建立
// ============================================================================

%hook WAWebConnection

- (void)connect {
    WEB_LOGIN_LOG("建立 Web 连接");
    %orig;
}

- (void)sendAuthenticationMessage:(NSDictionary *)message {
    NSMutableDictionary *authMsg = [message mutableCopy];

    // 修改认证消息中的版本
    if (authMsg[@"clientVersion"]) {
        authMsg[@"clientVersion"] = SPOOFED_VERSION;
    }
    if (authMsg[@"version"]) {
        authMsg[@"version"] = SPOOFED_VERSION;
    }

    WEB_LOGIN_LOG("Web 认证消息 - 版本伪装");

    %orig(authMsg);
    [authMsg release];
}

- (void)handleConnectionError:(NSError *)error {
    // 拦截版本相关错误
    if (error && [error.localizedDescription containsString:@"version"]) {
        WEB_LOGIN_LOG("拦截 Web 连接版本错误，忽略");
        return;
    }

    %orig(error);
}

%end

// ============================================================================
// MARK: - 7. 多设备功能启用
// ============================================================================

%hook WAMultiDeviceManager

- (BOOL)isMultiDeviceEnabled {
    return YES;
}

- (BOOL)canLinkDevice {
    return YES;
}

- (void)checkMultiDeviceEligibility:(void (^)(BOOL eligible))completion {
    WEB_LOGIN_LOG("多设备资格检查 - 强制返回合格");
    if (completion) {
        completion(YES);
    }
}

%end

// Linked Devices 管理
%hook WALinkedDevicesManager

- (BOOL)isLinkedDevicesEnabled {
    return YES;
}

- (NSInteger)maxLinkedDevices {
    return 5;  // 最多 5 个设备
}

%end

// ============================================================================
// MARK: - 8. 配对密钥交换
// ============================================================================

%hook WAWebPairingManager

- (void)startPairingWithCode:(NSString *)code completion:(id)completion {
    WEB_LOGIN_LOG("开始配对，代码: %@", code);
    %orig(code, completion);
}

- (void)completePairing:(NSDictionary *)pairingData {
    WEB_LOGIN_LOG("完成配对");
    %orig(pairingData);
}

%end

// ============================================================================
// MARK: - 9. Web Socket 连接
// ============================================================================

%hook WAWebSocket

- (void)connectWithHeaders:(NSDictionary *)headers {
    NSMutableDictionary *modifiedHeaders = [headers mutableCopy];

    // 添加版本信息到 WebSocket 头
    modifiedHeaders[@"WA-Version"] = SPOOFED_VERSION;
    modifiedHeaders[@"Client-Version"] = SPOOFED_VERSION;

    WEB_LOGIN_LOG("WebSocket 连接 - 添加版本头");

    %orig(modifiedHeaders);
    [modifiedHeaders release];
}

- (void)sendMessage:(id)message {
    // 检查消息中是否包含版本信息
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *msg = [message mutableCopy];

        if (msg[@"version"]) {
            msg[@"version"] = SPOOFED_VERSION;
            %orig(msg);
            [msg release];
            return;
        }
    }

    %orig(message);
}

%end

// ============================================================================
// MARK: - 10. 错误处理和重试
// ============================================================================

%hook WAWebLoginErrorHandler

- (void)handleError:(NSError *)error {
    // 拦截版本相关错误
    if (error.code == 403 || error.code == 426) {
        NSDictionary *userInfo = error.userInfo;
        NSString *reason = userInfo[@"reason"] ?: @"";

        if ([reason containsString:@"version"] ||
            [reason containsString:@"old"] ||
            [reason containsString:@"update"]) {

            WEB_LOGIN_LOG("拦截版本错误处理，忽略");
            return;
        }
    }

    %orig(error);
}

- (BOOL)shouldRetryAfterError:(NSError *)error {
    // 版本错误不应该重试（我们已经绕过了）
    if ([error.localizedDescription containsString:@"version"]) {
        return NO;
    }

    return %orig(error);
}

%end

// ============================================================================
// MARK: - 11. 版本检查对话框拦截
// ============================================================================

%hook WAWebVersionAlertController

- (void)show {
    WEB_LOGIN_LOG("拦截 Web 版本警告对话框");
    // 不显示
}

- (void)present {
    WEB_LOGIN_LOG("拦截 Web 版本提示");
    // 不显示
}

%end

// 更新提示拦截
%hook WAUpdateRequiredViewController

- (void)viewDidLoad {
    WEB_LOGIN_LOG("拦截更新要求界面");
    // 不加载
}

%end

// ============================================================================
// MARK: - 12. 初始化
// ============================================================================

%ctor {
    @autoreleasepool {
        WEB_LOGIN_LOG("=======================================");
        WEB_LOGIN_LOG("WhatsApp Web 登录修复补丁已加载");
        WEB_LOGIN_LOG("伪装版本: %@", SPOOFED_VERSION);
        WEB_LOGIN_LOG("支持功能:");
        WEB_LOGIN_LOG("  ✅ 二维码扫描");
        WEB_LOGIN_LOG("  ✅ Web 登录");
        WEB_LOGIN_LOG("  ✅ 多设备连接");
        WEB_LOGIN_LOG("  ✅ Linked Devices");
        WEB_LOGIN_LOG("=======================================");
    }
}
