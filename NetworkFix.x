/**
 * WhatsApp Network Connection Fix
 * 修复旧版本无法连接网络的问题
 */

#import <substrate.h>
#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define NET_LOG(fmt, ...) NSLog(@"[NetFix] " fmt, ##__VA_ARGS__)

// 伪装版本
#define SPOOFED_VERSION @"2.24.3.70"
#define SPOOFED_BUILD_NUMBER @"24.3.70"

// ============================================================================
// MARK: - 1. Bundle 信息伪装
// ============================================================================

%hook NSBundle

- (NSString *)objectForInfoDictionaryKey:(NSString *)key {
    NSString *bundleId = [self bundleIdentifier];

    // 只针对 WhatsApp
    if ([bundleId hasPrefix:@"net.whatsapp"]) {
        if ([key isEqualToString:@"CFBundleShortVersionString"]) {
            NET_LOG("Bundle: 伪装 CFBundleShortVersionString -> %@", SPOOFED_VERSION);
            return SPOOFED_VERSION;
        }

        if ([key isEqualToString:@"CFBundleVersion"]) {
            NET_LOG("Bundle: 伪装 CFBundleVersion -> %@", SPOOFED_BUILD_NUMBER);
            return SPOOFED_BUILD_NUMBER;
        }
    }

    return %orig;
}

- (NSDictionary *)infoDictionary {
    NSString *bundleId = [self bundleIdentifier];

    if ([bundleId hasPrefix:@"net.whatsapp"]) {
        NSMutableDictionary *info = [[%orig mutableCopy] autorelease];

        if (info) {
            info[@"CFBundleShortVersionString"] = SPOOFED_VERSION;
            info[@"CFBundleVersion"] = SPOOFED_BUILD_NUMBER;
            NET_LOG("Bundle: infoDictionary 已修改");
        }

        return info;
    }

    return %orig;
}

%end

// ============================================================================
// MARK: - 2. XMPP 连接修复
// ============================================================================

%hook XMPPStream

- (void)sendElement:(id)element {
    @try {
        // 检查是否是 XML 元素
        if ([element respondsToSelector:@selector(XMLString)]) {
            NSString *xmlString = [element XMLString];

            // 查找版本相关的内容
            if ([xmlString containsString:@"version"] ||
                [xmlString containsString:@"client"] ||
                [xmlString containsString:@"iq"]) {

                // 尝试修改版本节点
                if ([element respondsToSelector:@selector(elementForName:)]) {
                    id versionNode = [element elementForName:@"client-version"];
                    if (versionNode && [versionNode respondsToSelector:@selector(setStringValue:)]) {
                        [versionNode setStringValue:SPOOFED_VERSION];
                        NET_LOG("XMPP: 伪装版本节点 -> %@", SPOOFED_VERSION);
                    }

                    id versionAttr = [element elementForName:@"version"];
                    if (versionAttr && [versionAttr respondsToSelector:@selector(setStringValue:)]) {
                        [versionAttr setStringValue:SPOOFED_VERSION];
                        NET_LOG("XMPP: 伪装版本属性 -> %@", SPOOFED_VERSION);
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NET_LOG("XMPP: 修改元素时出错: %@", exception);
    }

    %orig(element);
}

- (void)connect {
    NET_LOG("XMPP: 开始连接");
    %orig;
}

- (void)disconnect {
    NET_LOG("XMPP: 断开连接");
    %orig;
}

%end

// ============================================================================
// MARK: - 3. 服务器配置拦截
// ============================================================================

%hook WAServerConfigManager

- (NSDictionary *)serverConfig {
    NSMutableDictionary *config = [[%orig mutableCopy] autorelease];

    if (!config) {
        config = [NSMutableDictionary dictionary];
    }

    // 修改最低版本要求
    if (config[@"min_supported_version"]) {
        NET_LOG("Config: 拦截 min_supported_version: %@ -> 0.0.1", config[@"min_supported_version"]);
        config[@"min_supported_version"] = @"0.0.1";
    }

    if (config[@"minimum_version"]) {
        NET_LOG("Config: 拦截 minimum_version: %@ -> 0.0.1", config[@"minimum_version"]);
        config[@"minimum_version"] = @"0.0.1";
    }

    // 移除强制更新标记
    if (config[@"force_upgrade"]) {
        NET_LOG("Config: 移除 force_upgrade");
        config[@"force_upgrade"] = @NO;
    }

    return config;
}

- (NSString *)minimumSupportedVersion {
    NET_LOG("Config: minimumSupportedVersion 查询 -> 0.0.1");
    return @"0.0.1";
}

%end

// ============================================================================
// MARK: - 4. 版本比较绕过
// ============================================================================

%hook WAVersionUtils

+ (BOOL)isVersionSupported:(NSString *)version {
    NET_LOG("Version: isVersionSupported -> YES (版本: %@)", version);
    return YES;
}

+ (NSComparisonResult)compareVersion:(NSString *)version1 withVersion:(NSString *)version2 {
    // 让当前版本总是 >= 最低要求版本
    if ([version2 containsString:@"min"] || [version2 containsString:@"require"]) {
        NET_LOG("Version: 比较 %@ >= %@ -> NSOrderedDescending", version1, version2);
        return NSOrderedDescending;
    }

    return %orig(version1, version2);
}

%end

// ============================================================================
// MARK: - 5. HTTP 请求修复
// ============================================================================

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    NSURL *url = [self URL];

    // 针对 WhatsApp 服务器的请求
    if ([url.host containsString:@"whatsapp"]) {

        // 修改 User-Agent
        if ([field isEqualToString:@"User-Agent"]) {
            if ([value containsString:@"WhatsApp"]) {
                // 替换版本号
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression
                    regularExpressionWithPattern:@"WhatsApp/[0-9\\.]+"
                    options:0
                    error:&error];

                if (regex) {
                    NSString *newUA = [regex
                        stringByReplacingMatchesInString:value
                        options:0
                        range:NSMakeRange(0, value.length)
                        withTemplate:[NSString stringWithFormat:@"WhatsApp/%@", SPOOFED_VERSION]];

                    NET_LOG("HTTP: User-Agent 伪装 -> %@", newUA);
                    %orig(newUA, field);
                    return;
                }
            }
        }

        // 添加/修改版本相关的头
        if ([field isEqualToString:@"WA-Version"] ||
            [field isEqualToString:@"Client-Version"] ||
            [field isEqualToString:@"X-WA-Version"]) {
            NET_LOG("HTTP: 版本头 %@ -> %@", field, SPOOFED_VERSION);
            %orig(SPOOFED_VERSION, field);
            return;
        }
    }

    %orig(value, field);
}

- (NSDictionary *)allHTTPHeaderFields {
    NSDictionary *headers = %orig;
    NSURL *url = [self URL];

    if ([url.host containsString:@"whatsapp"]) {
        NSMutableDictionary *modifiedHeaders = [headers mutableCopy];

        // 确保有版本头
        if (!modifiedHeaders[@"WA-Version"]) {
            modifiedHeaders[@"WA-Version"] = SPOOFED_VERSION;
            NET_LOG("HTTP: 添加 WA-Version 头");
        }

        [modifiedHeaders autorelease];
        return modifiedHeaders;
    }

    return headers;
}

%end

// ============================================================================
// MARK: - 6. 过期检查绕过
// ============================================================================

%hook WAExpirationChecker

- (BOOL)isExpired {
    NET_LOG("Expiration: isExpired -> NO");
    return NO;
}

- (BOOL)shouldShowExpirationWarning {
    NET_LOG("Expiration: shouldShowExpirationWarning -> NO");
    return NO;
}

- (void)checkExpiration {
    NET_LOG("Expiration: checkExpiration 被调用，忽略");
    // 不调用原方法，直接返回
}

%end

// ============================================================================
// MARK: - 7. 网络重连优化
// ============================================================================

static NSTimer *g_reconnectTimer = nil;
static NSUInteger g_reconnectAttempts = 0;
static const NSUInteger MAX_RECONNECT_ATTEMPTS = 10;

%hook WANetworkMonitor

- (void)networkStatusChanged:(NSNotification *)notification {
    NET_LOG("Network: 网络状态改变");

    // 调用原始方法
    %orig(notification);

    // 如果网络恢复，尝试重连
    if ([self isNetworkReachable]) {
        NET_LOG("Network: 网络已恢复，准备重连");

        // 延迟 1 秒重连
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self attemptReconnect];
        });
    }
}

%new
- (void)attemptReconnect {
    if (g_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
        NET_LOG("Network: 已达到最大重连次数");
        g_reconnectAttempts = 0;
        return;
    }

    g_reconnectAttempts++;
    NET_LOG("Network: 尝试重连 (第 %lu 次)", (unsigned long)g_reconnectAttempts);

    // 查找 XMPPStream 实例并重连
    Class xmppClass = NSClassFromString(@"XMPPStream");
    if (xmppClass) {
        // 通知需要重连（实际实现可能需要找到具体的 XMPPStream 实例）
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"WANetworkReconnectNeeded"
            object:nil];
    }
}

%end

// ============================================================================
// MARK: - 8. 心跳保活
// ============================================================================

static NSTimer *g_heartbeatTimer = nil;
static const NSTimeInterval HEARTBEAT_INTERVAL = 25.0;

%hook XMPPStream

- (void)connect {
    %orig;

    // 连接成功后启动心跳
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self startHeartbeat];
    });
}

- (void)disconnect {
    [self stopHeartbeat];
    %orig;
}

%new
- (void)startHeartbeat {
    [self stopHeartbeat];

    NET_LOG("Heartbeat: 启动心跳 (间隔 %.0f 秒)", HEARTBEAT_INTERVAL);

    g_heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_INTERVAL
                                                        target:self
                                                      selector:@selector(sendHeartbeat)
                                                      userInfo:nil
                                                       repeats:YES];
}

%new
- (void)stopHeartbeat {
    if (g_heartbeatTimer) {
        NET_LOG("Heartbeat: 停止心跳");
        [g_heartbeatTimer invalidate];
        g_heartbeatTimer = nil;
    }
}

%new
- (void)sendHeartbeat {
    if ([self isConnected]) {
        NET_LOG("Heartbeat: 发送心跳");

        // 发送一个简单的 ping
        @try {
            Class xmlElementClass = NSClassFromString(@"NSXMLElement");
            if (xmlElementClass) {
                id pingElement = [[xmlElementClass alloc] initWithName:@"iq"];
                if ([pingElement respondsToSelector:@selector(addAttributeWithName:stringValue:)]) {
                    [pingElement addAttributeWithName:@"type" stringValue:@"get"];
                    [pingElement addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];

                    id pingChild = [[xmlElementClass alloc] initWithName:@"ping"];
                    if ([pingChild respondsToSelector:@selector(addAttributeWithName:stringValue:)]) {
                        [pingChild addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:ping"];
                    }

                    if ([pingElement respondsToSelector:@selector(addChild:)]) {
                        [pingElement addChild:pingChild];
                    }

                    [self sendElement:pingElement];

                    [pingChild release];
                    [pingElement release];
                }
            }
        } @catch (NSException *exception) {
            NET_LOG("Heartbeat: 发送失败: %@", exception);
        }
    } else {
        NET_LOG("Heartbeat: 未连接，跳过");
    }
}

%end

// ============================================================================
// MARK: - 9. 初始化
// ============================================================================

%ctor {
    @autoreleasepool {
        NET_LOG("=======================================");
        NET_LOG("网络修复补丁已加载");
        NET_LOG("伪装版本: %@", SPOOFED_VERSION);
        NET_LOG("功能:");
        NET_LOG("  ✅ Bundle 信息伪装");
        NET_LOG("  ✅ XMPP 协议修复");
        NET_LOG("  ✅ HTTP 请求修复");
        NET_LOG("  ✅ 服务器配置拦截");
        NET_LOG("  ✅ 版本检查绕过");
        NET_LOG("  ✅ 过期检查绕过");
        NET_LOG("  ✅ 网络重连优化");
        NET_LOG("  ✅ 心跳保活");
        NET_LOG("=======================================");
    }
}
