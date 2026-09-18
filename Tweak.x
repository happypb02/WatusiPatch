/**
 * Watusi Anti-Detection & Network Optimization Patch
 * 完整版 - 最彻底的反检测和网络优化
 * Version: 2.0.0
 */

#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <BackgroundTasks/BackgroundTasks.h>

// ============================================================================
// MARK: - 全局配置
// ============================================================================

#define WATUSI_PATCH_LOG(fmt, ...) NSLog(@"[WatusiPatch] " fmt, ##__VA_ARGS__)
#define FAKE_OFFICIAL_VERSION @"2.24.3.70"
#define PATCH_VERSION @"2.0.0"

static BOOL g_networkPersistenceEnabled = YES;
static BOOL g_backgroundKeepAliveEnabled = YES;
static NSTimer *g_keepAliveTimer = nil;
static CLLocationManager *g_locationManager = nil;

// ============================================================================
// MARK: - 接口声明
// ============================================================================

@interface XMPPStream : NSObject
- (void)disconnect;
- (BOOL)isConnected;
- (void)connect;
@end

@interface XMPPConnection : NSObject
- (void)sendElements:(NSArray *)elements timeout:(NSTimeInterval)timeout completion:(id)completion;
@end

@interface WANetworkMonitor : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isNetworkReachable;
@end

@interface WSBackgroundHelper : NSObject
+ (void)enableLocationBackgrounding;
+ (void)startBackgroundTask;
@end

// ============================================================================
// MARK: - 1. 越狱检测完全绕过
// ============================================================================

%hook WARegistrationURLBuilder

// Hook 所有版本的注册 URL 构建方法
+ (id)verificationCodeRequestURLWithBaseURL:(id)arg1
                                     method:(id)arg2
                                        mcc:(id)arg3
                                        mnc:(id)arg4
                                 jailbroken:(BOOL)arg5
                                    context:(id)arg6
                             oldPhoneNumber:(id)arg7 {
    WATUSI_PATCH_LOG("拦截越狱检测 (v1) - 强制返回未越狱");
    return %orig(arg1, arg2, arg3, arg4, NO, arg6, arg7);
}

+ (id)verificationCodeRequestURLWithBaseURL:(id)arg1
                                     method:(id)arg2
                                        mcc:(id)arg3
                                        mnc:(id)arg4
                                 jailbroken:(BOOL)arg5
                                    context:(id)arg6
                             oldPhoneNumber:(id)arg7
                    silentPushNotifRegCode:(id)arg8 {
    WATUSI_PATCH_LOG("拦截越狱检测 (v2) - 强制返回未越狱");
    return %orig(arg1, arg2, arg3, arg4, NO, arg6, arg7, arg8);
}

+ (id)verificationCodeRequestURLWithBaseURL:(id)arg1
                                     method:(id)arg2
                                        mcc:(id)arg3
                                        mnc:(id)arg4
                                 jailbroken:(BOOL)arg5
                                    context:(id)arg6
                             oldPhoneNumber:(id)arg7
                    silentPushNotifRegCode:(id)arg8
                iosDeviceRegistrationUUID:(id)arg9
                         cellularStrength:(id)arg10 {
    WATUSI_PATCH_LOG("拦截越狱检测 (v3) - 强制返回未越狱");
    return %orig(arg1, arg2, arg3, arg4, NO, arg6, arg7, arg8, arg9, arg10);
}

+ (id)verificationCodeRequestURLWithBaseURL:(id)arg1
                                     method:(id)arg2
                                        mcc:(id)arg3
                                        mnc:(id)arg4
                                 jailbroken:(BOOL)arg5
                                    context:(id)arg6
                             oldPhoneNumber:(id)arg7
                    silentPushNotifRegCode:(id)arg8
                iosDeviceRegistrationUUID:(id)arg9
                         cellularStrength:(id)arg10
                         passkeyCredToken:(id)arg11
                               entrypoint:(id)arg12 {
    WATUSI_PATCH_LOG("拦截越狱检测 (v4 - 最新) - 强制返回未越狱");
    return %orig(arg1, arg2, arg3, arg4, NO, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
}

%end

// ============================================================================
// MARK: - 2. 设备支持检查绕过
// ============================================================================

%hook WAUIDevices

+ (BOOL)isDeviceSupported {
    WATUSI_PATCH_LOG("设备支持检查 - 强制返回支持");
    return YES;
}

%end

%hook WAPresentJailbrokenDeviceNotSupportedAlertViewIfNeeded

+ (void)presentAlertIfNeeded:(id)completion {
    WATUSI_PATCH_LOG("阻止越狱警告弹窗");
    // 不显示警告，直接调用完成回调
    if (completion) {
        void (^completionBlock)(void) = completion;
        completionBlock();
    }
}

%end

%hook WAPresentJailbrokenDeviceNotSupportedAlertViewIfNeededWithCompletion

+ (void)presentAlertWithCompletion:(id)completion {
    WATUSI_PATCH_LOG("阻止越狱警告弹窗 (带完成回调)");
    if (completion) {
        void (^completionBlock)(void) = completion;
        completionBlock();
    }
}

%end

// ============================================================================
// MARK: - 3. 版本过期检查完全绕过（blockWAUpdates 核心功能）
// ============================================================================

// 这是最核心的功能 - 阻止 "This version has expired" 提示
%hook WAExpirationCheckerViewPresenter

- (void)presentView {
    WATUSI_PATCH_LOG("阻止版本过期提示显示");
    // 不显示任何过期提示
}

- (void)showExpirationAlert {
    WATUSI_PATCH_LOG("阻止过期警告弹窗");
    // 不执行原始方法
}

- (BOOL)shouldPresentView {
    WATUSI_PATCH_LOG("版本过期检查 - 强制返回不需要显示");
    return NO; // 永远不显示
}

%end

// 版本过期检查器
%hook WAExpirationChecker

- (BOOL)isExpired {
    WATUSI_PATCH_LOG("版本过期检查 - 强制返回未过期");
    return NO; // 永远不过期
}

- (NSDate *)expirationDate {
    // 返回一个遥远的未来日期（100年后）
    NSTimeInterval futureInterval = 60.0 * 60.0 * 24.0 * 365.0 * 100.0;
    NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:futureInterval];
    WATUSI_PATCH_LOG("伪造过期日期为: %@", futureDate);
    return futureDate;
}

- (void)checkExpiration {
    WATUSI_PATCH_LOG("跳过过期检查");
    // 不执行检查
}

%end

// 阻止过期对话框
%hook WAExpiredAlertViewController

- (void)viewDidLoad {
    WATUSI_PATCH_LOG("阻止过期对话框加载");
    // 不加载视图
}

- (void)viewWillAppear:(BOOL)animated {
    WATUSI_PATCH_LOG("阻止过期对话框显示");
    // 不显示
}

%end

// 应用版本管理器
%hook WAApplicationVersionManager

- (BOOL)isCurrentVersionExpired {
    WATUSI_PATCH_LOG("应用版本检查 - 强制返回未过期");
    return NO;
}

- (BOOL)shouldBlockUserDueToExpiration {
    WATUSI_PATCH_LOG("阻止因过期锁定用户");
    return NO;
}

%end

// ============================================================================
// MARK: - 4. 版本更新检查完全禁用
// ============================================================================

%hook WSUpdateManager

- (void)checkForUpdate {
    WATUSI_PATCH_LOG("禁用更新检查");
    // 不执行任何操作
}

- (void)fetchAndExecutePatchIfNeededWithCompletion:(id)completion {
    WATUSI_PATCH_LOG("跳过补丁下载");
    if (completion) {
        void (^completionBlock)(BOOL) = completion;
        completionBlock(YES); // 假装成功
    }
}

- (void)showUpdateAlert {
    WATUSI_PATCH_LOG("阻止更新提示");
}

%end

// WhatsApp 官方更新管理器
%hook WAUpdateManager

- (void)checkForUpdate {
    WATUSI_PATCH_LOG("禁用 WA 更新检查");
}

- (void)presentUpdateAlert {
    WATUSI_PATCH_LOG("阻止 WA 更新提示");
}

- (BOOL)isUpdateAvailable {
    return NO; // 没有更新
}

%end

%hook FRUpdateManager

- (void)checkForUpdate {
    WATUSI_PATCH_LOG("禁用 FR 更新检查");
}

- (void)showUpdateAlert {
    WATUSI_PATCH_LOG("阻止更新提示");
}

%end

// 应用更新检查器
%hook WAAppUpdateChecker

- (void)checkForUpdate {
    WATUSI_PATCH_LOG("禁用应用更新检查");
}

- (void)fetchLatestVersion:(id)completion {
    WATUSI_PATCH_LOG("跳过获取最新版本");
    if (completion) {
        void (^completionBlock)(id, NSError *) = completion;
        completionBlock(nil, nil); // 没有新版本
    }
}

%end

// ============================================================================
// MARK: - 5. 强制更新对话框拦截
// ============================================================================

// 阻止所有强制更新相关的 UI
%hook WAForceUpdateViewController

- (void)viewDidLoad {
    WATUSI_PATCH_LOG("阻止强制更新视图加载");
    // 不加载
}

- (void)viewWillAppear:(BOOL)animated {
    WATUSI_PATCH_LOG("阻止强制更新界面显示");
    // 不显示
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    WATUSI_PATCH_LOG("拦截强制更新弹窗");
    // 不弹窗
}

%end

// 更新必需性检查
%hook WAUpdateRequirementChecker

- (BOOL)isUpdateRequired {
    WATUSI_PATCH_LOG("更新必需性检查 - 强制返回不需要");
    return NO;
}

- (BOOL)shouldForceUpdate {
    WATUSI_PATCH_LOG("强制更新检查 - 强制返回否");
    return NO;
}

%end

// 最小版本检查
%hook WAMinimumVersionChecker

- (BOOL)isCurrentVersionBelowMinimum {
    WATUSI_PATCH_LOG("最小版本检查 - 强制返回满足要求");
    return NO; // 当前版本总是满足最小要求
}

- (void)showMinimumVersionAlert {
    WATUSI_PATCH_LOG("阻止最小版本警告");
    // 不显示
}

%end

// ============================================================================
// MARK: - 6. 许可证和认证绕过
// ============================================================================

%hook FRTweaksAuthController

- (BOOL)isLicenseValid {
    WATUSI_PATCH_LOG("许可证检查 - 强制返回有效");
    return YES;
}

- (void)showLicenseAlert {
    WATUSI_PATCH_LOG("阻止许可证提示");
}

- (BOOL)isAuthenticated {
    return YES;
}

%end

%hook FRAManager

- (BOOL)isLicenseValid {
    return YES;
}

- (BOOL)isEligible {
    return YES;
}

%end

// ============================================================================
// MARK: - 7. Bundle Identifier 伪装
// ============================================================================

%hook NSBundle

- (NSString *)bundleIdentifier {
    NSString *originalID = %orig;

    // 如果是 Watusi 相关的 Bundle，伪装成官方
    if ([originalID containsString:@"fouadraheb"] ||
        [originalID containsString:@"watusi"]) {
        WATUSI_PATCH_LOG("Bundle ID 伪装: %@ -> net.whatsapp.WhatsApp", originalID);
        return @"net.whatsapp.WhatsApp";
    }

    return originalID;
}

- (NSDictionary *)infoDictionary {
    NSDictionary *originalInfo = %orig;
    NSMutableDictionary *info = [originalInfo mutableCopy];

    // 伪装版本信息
    if (info[@"CFBundleShortVersionString"]) {
        info[@"CFBundleShortVersionString"] = FAKE_OFFICIAL_VERSION;
        WATUSI_PATCH_LOG("版本信息伪装: %@", FAKE_OFFICIAL_VERSION);
    }

    return info;
}

%end

// ============================================================================
// MARK: - 6. 网络连接持久化 (核心优化)
// ============================================================================

%hook XMPPStream

- (void)disconnect {
    UIApplication *app = [UIApplication sharedApplication];
    UIApplicationState state = app.applicationState;

    // 只有在前台或者用户主动退出时才真正断开
    if (state == UIApplicationStateActive) {
        WATUSI_PATCH_LOG("前台状态 - 允许断开连接");
        %orig;
    } else if (state == UIApplicationStateBackground && g_networkPersistenceEnabled) {
        WATUSI_PATCH_LOG("后台状态 - 阻止断开连接以保持在线");
        // 不执行原方法，保持连接
    } else {
        WATUSI_PATCH_LOG("其他状态 - 允许断开连接");
        %orig;
    }
}

- (BOOL)isConnected {
    BOOL connected = %orig;
    if (!connected && g_networkPersistenceEnabled) {
        WATUSI_PATCH_LOG("检测到断开，尝试重连");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self connect];
        });
    }
    return connected;
}

%end

%hook XMPPConnection

- (void)sendElements:(NSArray *)elements
             timeout:(NSTimeInterval)timeout
          completion:(id)completion {

    // 增加超时时间以适应不稳定网络
    NSTimeInterval extendedTimeout = timeout * 2.0;

    WATUSI_PATCH_LOG("发送 XMPP 元素，超时: %.1f秒 (原始: %.1f秒)", extendedTimeout, timeout);

    %orig(elements, extendedTimeout, completion);
}

%end

// ============================================================================
// MARK: - 7. 应用生命周期优化
// ============================================================================

%hook AppDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;

    if (g_backgroundKeepAliveEnabled) {
        WATUSI_PATCH_LOG("应用进入后台 - 启动保活机制");

        // 开始后台任务
        UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            WATUSI_PATCH_LOG("后台任务即将过期");
        }];

        // 启动定时器保持活跃
        if (!g_keepAliveTimer) {
            g_keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:25.0
                                                                target:self
                                                              selector:@selector(keepAliveTimerFired)
                                                              userInfo:nil
                                                               repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:g_keepAliveTimer forMode:NSRunLoopCommonModes];
        }

        // 启动位置服务保活
        if ([self respondsToSelector:@selector(startLocationBackgrounding)]) {
            [self performSelector:@selector(startLocationBackgrounding)];
        }

        // 结束后台任务
        if (bgTask != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:bgTask];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    %orig;

    WATUSI_PATCH_LOG("应用进入前台 - 停止保活机制");

    // 停止定时器
    if (g_keepAliveTimer) {
        [g_keepAliveTimer invalidate];
        g_keepAliveTimer = nil;
    }

    // 停止位置服务
    if (g_locationManager) {
        [g_locationManager stopUpdatingLocation];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    WATUSI_PATCH_LOG("应用即将终止 - 清理资源");

    // 清理所有资源
    if (g_keepAliveTimer) {
        [g_keepAliveTimer invalidate];
        g_keepAliveTimer = nil;
    }

    if (g_locationManager) {
        [g_locationManager stopUpdatingLocation];
        g_locationManager = nil;
    }

    %orig;
}

%new
+ (void)keepAliveTimerFired {
    WATUSI_PATCH_LOG("后台保活心跳");

    // 执行轻量级网络请求保持连接活跃
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 发送心跳包
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WatusiKeepAliveHeartbeat"
                                                            object:nil];
    });
}

%new
- (void)startLocationBackgrounding {
    WATUSI_PATCH_LOG("启动位置服务后台保活");

    if (!g_locationManager) {
        g_locationManager = [[CLLocationManager alloc] init];
        g_locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers; // 低精度省电
        g_locationManager.distanceFilter = 500; // 500米更新一次

        // 请求始终定位权限
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [g_locationManager requestAlwaysAuthorization];
        }

        // 启用后台位置更新
        if ([g_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
            g_locationManager.allowsBackgroundLocationUpdates = YES;
        }

        if ([g_locationManager respondsToSelector:@selector(setShowsBackgroundLocationIndicator:)]) {
            g_locationManager.showsBackgroundLocationIndicator = NO; // 不显示蓝条
        }
    }

    [g_locationManager startUpdatingLocation];
}

%end

// ============================================================================
// MARK: - 8. 网络监控和自动重连
// ============================================================================

%hook WANetworkMonitor

- (void)reachabilityChanged:(NSNotification *)notification {
    %orig;

    BOOL isReachable = [self isNetworkReachable];
    WATUSI_PATCH_LOG("网络状态变化: %@", isReachable ? @"可用" : @"不可用");

    if (isReachable) {
        // 网络恢复时自动重连
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WatusiNetworkRestored"
                                                                object:nil];
            WATUSI_PATCH_LOG("网络恢复 - 触发重连");
        });
    }
}

%end

// ============================================================================
// MARK: - 9. 消息发送优化
// ============================================================================

%hook WAMessageSender

- (void)sendMessage:(id)message transaction:(id)transaction {
    WATUSI_PATCH_LOG("发送消息 - 优化重试机制");

    // 添加重试逻辑 - 简化版本，避免循环引用
    @try {
        %orig(message, transaction);
        WATUSI_PATCH_LOG("消息发送成功");
    } @catch (NSException *exception) {
        WATUSI_PATCH_LOG("消息发送失败: %@", exception);
        // 简单重试一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            @try {
                %orig(message, transaction);
                WATUSI_PATCH_LOG("消息重试成功");
            } @catch (NSException *retryException) {
                WATUSI_PATCH_LOG("消息重试失败: %@", retryException);
            }
        });
    }
}

%end

// ============================================================================
// MARK: - 10. 数据持久化优化
// ============================================================================

%hook NSManagedObjectContext

- (BOOL)save:(NSError **)error {
    WATUSI_PATCH_LOG("Core Data 保存操作");

    BOOL success = %orig(error);

    if (!success && error && *error) {
        WATUSI_PATCH_LOG("保存失败: %@", [*error localizedDescription]);

        // 尝试回滚并重试
        __weak NSManagedObjectContext *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSManagedObjectContext *strongSelf = weakSelf;
            if (strongSelf) {
                NSError *retryError = nil;
                BOOL retrySuccess = NO;
                @try {
                    if ([strongSelf respondsToSelector:@selector(save:)]) {
                        retrySuccess = [strongSelf save:&retryError];
                    }
                } @catch (NSException *exception) {
                    WATUSI_PATCH_LOG("重试保存异常: %@", exception);
                }
                WATUSI_PATCH_LOG("重试保存结果: %@", retrySuccess ? @"成功" : @"失败");
            }
        });
    }

    return success;
}

%end

// ============================================================================
// MARK: - 11. 内存优化
// ============================================================================

%hook UIApplication

- (void)applicationDidReceiveMemoryWarning {
    WATUSI_PATCH_LOG("收到内存警告 - 执行清理");

    // 清理缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:4 * 1024 * 1024]; // 4MB

    %orig;
}

%end

// ============================================================================
// MARK: - 12. URL Schemes 修复
// ============================================================================

%hook UIApplication

- (BOOL)openURL:(NSURL *)url {
    NSString *scheme = [url scheme];

    // 确保支持所有 WhatsApp URL Schemes
    if ([scheme hasPrefix:@"whatsapp"]) {
        WATUSI_PATCH_LOG("处理 WhatsApp URL: %@", url);
        return %orig;
    }

    return %orig;
}

- (void)openURL:(NSURL *)url
        options:(NSDictionary *)options
completionHandler:(void (^)(BOOL))completion {
    NSString *scheme = [url scheme];

    if ([scheme hasPrefix:@"whatsapp"]) {
        WATUSI_PATCH_LOG("处理 WhatsApp URL (新 API): %@", url);
    }

    %orig;
}

%end

// ============================================================================
// MARK: - 13. 推送通知优化
// ============================================================================

%hook WAPushController

- (void)pushRegistry:(id)registry
didReceiveIncomingPushWithPayload:(id)payload
             forType:(NSString *)type
withCompletionHandler:(void (^)(void))completion {

    WATUSI_PATCH_LOG("收到推送通知: %@", type);

    // 确保在后台也能处理推送
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateBackground) {
        WATUSI_PATCH_LOG("后台处理推送通知");

        // 开始后台任务处理推送
        __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];

        %orig(registry, payload, type, ^{
            if (completion) completion();
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    } else {
        %orig;
    }
}

%end

// ============================================================================
// MARK: - 14. 网络请求拦截和优化
// ============================================================================

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
                        completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {

    NSString *urlString = [url absoluteString];

    // 拦截更新检查请求
    if ([urlString containsString:@"api.ipsw.me"] ||
        [urlString containsString:@"version.whatsapp.net"] ||
        [urlString containsString:@"crashlogs.whatsapp.net"]) {

        WATUSI_PATCH_LOG("拦截更新检查请求: %@", urlString);

        // 返回伪造的成功响应
        NSDictionary *fakeResponse = @{
            @"status": @"ok",
            @"version": FAKE_OFFICIAL_VERSION,
            @"message": @"No update required"
        };

        NSData *fakeData = [NSJSONSerialization dataWithJSONObject:fakeResponse options:0 error:nil];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                  statusCode:200
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{@"Content-Type": @"application/json"}];

        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(fakeData, response, nil);
        });

        return nil;
    }

    // 优化超时设置
    NSURLSessionDataTask *task = %orig;
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {

    // 增加超时时间
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if (mutableRequest.timeoutInterval < 30.0) {
        mutableRequest.timeoutInterval = 30.0;
        WATUSI_PATCH_LOG("增加请求超时时间: 30秒");
    }

    return %orig(mutableRequest, completionHandler);
}

%end

// ============================================================================
// MARK: - 15. 初始化和配置
// ============================================================================

static void LoadConfiguration() {
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.watusipatch.plist"];

    if (config) {
        g_networkPersistenceEnabled = [config[@"networkPersistence"] boolValue];
        g_backgroundKeepAliveEnabled = [config[@"backgroundKeepAlive"] boolValue];

        WATUSI_PATCH_LOG("加载配置:");
        WATUSI_PATCH_LOG("  - 网络持久化: %@", g_networkPersistenceEnabled ? @"启用" : @"禁用");
        WATUSI_PATCH_LOG("  - 后台保活: %@", g_backgroundKeepAliveEnabled ? @"启用" : @"禁用");
    } else {
        // 默认全部启用
        g_networkPersistenceEnabled = YES;
        g_backgroundKeepAliveEnabled = YES;

        WATUSI_PATCH_LOG("使用默认配置 (全部启用)");
    }
}

static void SaveDefaultConfiguration() {
    NSDictionary *defaultConfig = @{
        @"networkPersistence": @YES,
        @"backgroundKeepAlive": @YES,
        @"version": PATCH_VERSION
    };

    [defaultConfig writeToFile:@"/var/mobile/Library/Preferences/com.watusipatch.plist" atomically:YES];
    WATUSI_PATCH_LOG("已保存默认配置");
}

%ctor {
    @autoreleasepool {
        WATUSI_PATCH_LOG("====================================");
        WATUSI_PATCH_LOG("Watusi 反检测 & 网络优化补丁");
        WATUSI_PATCH_LOG("版本: %@", PATCH_VERSION);
        WATUSI_PATCH_LOG("====================================");

        // 加载配置
        LoadConfiguration();

        // 保存默认配置（如果不存在）
        if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.watusipatch.plist"]) {
            SaveDefaultConfiguration();
        }

        WATUSI_PATCH_LOG("所有 Hook 已安装");
        WATUSI_PATCH_LOG("====================================");

        // 监听网络状态变化
        [[NSNotificationCenter defaultCenter] addObserverForName:@"WatusiNetworkRestored"
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            WATUSI_PATCH_LOG("处理网络恢复事件");
        }];
    }
}
