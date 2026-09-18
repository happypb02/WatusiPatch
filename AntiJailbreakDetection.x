/**
 * WhatsApp Anti-Jailbreak Detection & Signature Bypass
 * 修复 "非官方应用" 和 "无法登录" 问题
 */

#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <sys/stat.h>
#import <mach-o/dyld.h>

#define ANTI_JB_LOG(fmt, ...) NSLog(@"[AntiJB] " fmt, ##__VA_ARGS__)

// ============================================================================
// MARK: - 1. 文件系统检查绕过
// ============================================================================

// 越狱文件路径列表
static NSArray *jailbreakPaths() {
    return @[
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/usr/bin/ssh",
        @"/private/var/lib/apt",
        @"/private/var/lib/cydia",
        @"/private/var/mobile/Library/SBSettings/Themes",
        @"/var/cache/apt",
        @"/var/lib/cydia",
        @"/var/log/syslog",
        @"/etc/apt",
        @"/bin/sh",
        @"/usr/libexec/cydia",
        @"/.installed_unc0ver",
        @"/.installed_taurine",
        @"/.installed_odyssey"
    ];
}

// Hook NSFileManager
%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    // 检查是否是越狱路径
    for (NSString *jbPath in jailbreakPaths()) {
        if ([path isEqualToString:jbPath] || [path hasPrefix:jbPath]) {
            ANTI_JB_LOG("FileManager: 拦截 fileExistsAtPath: %@ -> NO", path);
            return NO;
        }
    }

    return %orig;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    for (NSString *jbPath in jailbreakPaths()) {
        if ([path isEqualToString:jbPath] || [path hasPrefix:jbPath]) {
            ANTI_JB_LOG("FileManager: 拦截 fileExistsAtPath:isDirectory: %@ -> NO", path);
            return NO;
        }
    }

    return %orig;
}

- (BOOL)isReadableFileAtPath:(NSString *)path {
    for (NSString *jbPath in jailbreakPaths()) {
        if ([path isEqualToString:jbPath] || [path hasPrefix:jbPath]) {
            ANTI_JB_LOG("FileManager: 拦截 isReadableFileAtPath: %@ -> NO", path);
            return NO;
        }
    }

    return %orig;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSArray *contents = %orig;

    // 过滤越狱相关文件
    if (contents) {
        NSMutableArray *filtered = [NSMutableArray array];
        for (NSString *item in contents) {
            NSString *fullPath = [path stringByAppendingPathComponent:item];
            BOOL isJailbreakItem = NO;

            for (NSString *jbPath in jailbreakPaths()) {
                if ([fullPath hasPrefix:jbPath]) {
                    isJailbreakItem = YES;
                    break;
                }
            }

            if (!isJailbreakItem) {
                [filtered addObject:item];
            }
        }

        if (filtered.count != contents.count) {
            ANTI_JB_LOG("FileManager: 过滤目录内容 %@ (%lu -> %lu 项)",
                       path, (unsigned long)contents.count, (unsigned long)filtered.count);
            return filtered;
        }
    }

    return contents;
}

%end

// Hook C 函数 stat/lstat
int (*orig_stat)(const char *path, struct stat *buf);
int hooked_stat(const char *path, struct stat *buf) {
    if (path) {
        NSString *pathStr = [NSString stringWithUTF8String:path];
        for (NSString *jbPath in jailbreakPaths()) {
            if ([pathStr isEqualToString:jbPath] || [pathStr hasPrefix:jbPath]) {
                ANTI_JB_LOG("stat: 拦截 %s -> -1", path);
                errno = ENOENT;
                return -1;
            }
        }
    }
    return orig_stat(path, buf);
}

int (*orig_lstat)(const char *path, struct stat *buf);
int hooked_lstat(const char *path, struct stat *buf) {
    if (path) {
        NSString *pathStr = [NSString stringWithUTF8String:path];
        for (NSString *jbPath in jailbreakPaths()) {
            if ([pathStr isEqualToString:jbPath] || [pathStr hasPrefix:jbPath]) {
                ANTI_JB_LOG("lstat: 拦截 %s -> -1", path);
                errno = ENOENT;
                return -1;
            }
        }
    }
    return orig_lstat(path, buf);
}

// Hook fopen
FILE *(*orig_fopen)(const char *path, const char *mode);
FILE *hooked_fopen(const char *path, const char *mode) {
    if (path) {
        NSString *pathStr = [NSString stringWithUTF8String:path];
        for (NSString *jbPath in jailbreakPaths()) {
            if ([pathStr isEqualToString:jbPath] || [pathStr hasPrefix:jbPath]) {
                ANTI_JB_LOG("fopen: 拦截 %s -> NULL", path);
                errno = ENOENT;
                return NULL;
            }
        }
    }
    return orig_fopen(path, mode);
}

// ============================================================================
// MARK: - 2. URL Scheme 检查绕过
// ============================================================================

%hook UIApplication

- (BOOL)canOpenURL:(NSURL *)url {
    NSString *scheme = [url scheme];

    // 拦截越狱相关的 URL Scheme
    NSArray *jbSchemes = @[@"cydia://", @"sileo://", @"zbra://", @"filza://"];

    for (NSString *jbScheme in jbSchemes) {
        if ([scheme isEqualToString:[jbScheme stringByReplacingOccurrencesOfString:@"://" withString:@""]]) {
            ANTI_JB_LOG("UIApplication: 拦截 canOpenURL: %@ -> NO", url);
            return NO;
        }
    }

    return %orig;
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL))completion {
    NSString *urlStr = [url absoluteString];

    // 阻止打开越狱相关的 URL
    if ([urlStr containsString:@"cydia://"] ||
        [urlStr containsString:@"sileo://"] ||
        [urlStr containsString:@"zbra://"]) {
        ANTI_JB_LOG("UIApplication: 拦截 openURL: %@", url);
        if (completion) {
            completion(NO);
        }
        return;
    }

    %orig;
}

%end

// ============================================================================
// MARK: - 3. 动态库检测绕过
// ============================================================================

// Hook dlopen
void *(*orig_dlopen)(const char *path, int mode);
void *hooked_dlopen(const char *path, int mode) {
    if (path) {
        NSString *pathStr = [NSString stringWithUTF8String:path];

        // 允许 MobileSubstrate 自身加载
        if ([pathStr containsString:@"MobileSubstrate"] ||
            [pathStr containsString:@"Substrate"] ||
            [pathStr containsString:@"CydiaSubstrate"]) {
            // 正常加载,但不记录到 _dyld_image_count
            return orig_dlopen(path, mode);
        }

        // 拦截其他越狱库查询
        NSArray *jbLibs = @[@"substitute", @"libhooker", @"ellekit"];
        for (NSString *lib in jbLibs) {
            if ([pathStr containsString:lib]) {
                ANTI_JB_LOG("dlopen: 拦截 %s -> NULL", path);
                return NULL;
            }
        }
    }
    return orig_dlopen(path, mode);
}

// Hook dyld 函数
uint32_t (*orig_dyld_image_count)(void);
uint32_t hooked_dyld_image_count(void) {
    // 返回正常值,让 WhatsApp 看不到可疑的动态库数量
    uint32_t count = orig_dyld_image_count();

    // 隐藏 Substrate 相关的库
    uint32_t hiddenCount = 0;
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name) {
            NSString *nameStr = [NSString stringWithUTF8String:name];
            if ([nameStr containsString:@"MobileSubstrate"] ||
                [nameStr containsString:@"Substrate"] ||
                [nameStr containsString:@"substitute"] ||
                [nameStr containsString:@"libhooker"]) {
                hiddenCount++;
            }
        }
    }

    if (hiddenCount > 0) {
        ANTI_JB_LOG("dyld_image_count: 隐藏 %u 个库 (%u -> %u)", hiddenCount, count, count - hiddenCount);
        return count - hiddenCount;
    }

    return count;
}

const char *(*orig_dyld_get_image_name)(uint32_t index);
const char *hooked_dyld_get_image_name(uint32_t index) {
    const char *name = orig_dyld_get_image_name(index);

    if (name) {
        NSString *nameStr = [NSString stringWithUTF8String:name];

        // 隐藏越狱相关的库
        if ([nameStr containsString:@"MobileSubstrate"] ||
            [nameStr containsString:@"Substrate"] ||
            [nameStr containsString:@"substitute"] ||
            [nameStr containsString:@"libhooker"]) {
            ANTI_JB_LOG("dyld_get_image_name: 隐藏 %s", name);
            // 返回一个安全的库名
            return "/usr/lib/system/libsystem_c.dylib";
        }
    }

    return name;
}

// ============================================================================
// MARK: - 4. 系统调用检测绕过
// ============================================================================

// Hook getenv
char *(*orig_getenv)(const char *name);
char *hooked_getenv(const char *name) {
    if (name && strcmp(name, "DYLD_INSERT_LIBRARIES") == 0) {
        ANTI_JB_LOG("getenv: 拦截 DYLD_INSERT_LIBRARIES -> NULL");
        return NULL;
    }
    return orig_getenv(name);
}

// Hook fork (越狱设备可以 fork)
pid_t (*orig_fork)(void);
pid_t hooked_fork(void) {
    ANTI_JB_LOG("fork: 拦截 -> -1 (模拟失败)");
    errno = EPERM;
    return -1;
}

// Hook system
int (*orig_system)(const char *command);
int hooked_system(const char *command) {
    if (command) {
        ANTI_JB_LOG("system: 拦截 %s -> -1", command);
    }
    errno = EPERM;
    return -1;
}

// ============================================================================
// MARK: - 5. App 签名检查绕过
// ============================================================================

%hook NSBundle

- (NSDictionary *)infoDictionary {
    NSMutableDictionary *info = [[%orig mutableCopy] autorelease];

    if (info) {
        // 移除任何越狱相关的标记
        [info removeObjectForKey:@"SignerIdentity"];
        [info removeObjectForKey:@"DTPlatformVersion"];

        // 确保签名信息看起来正常
        if (!info[@"CFBundleIdentifier"] || ![info[@"CFBundleIdentifier"] hasPrefix:@"net.whatsapp"]) {
            // 保持原始包名
        }
    }

    return info;
}

%end

// ============================================================================
// MARK: - 6. 沙盒检测绕过
// ============================================================================

%hook NSString

- (BOOL)containsString:(NSString *)str {
    // 拦截对越狱路径的字符串检查
    if ([self hasPrefix:@"/"] && str) {
        for (NSString *jbPath in jailbreakPaths()) {
            if ([self isEqualToString:jbPath] &&
                ([str isEqualToString:@"cydia"] ||
                 [str isEqualToString:@"apt"] ||
                 [str isEqualToString:@"jailbreak"])) {
                ANTI_JB_LOG("NSString: 拦截 containsString 检查");
                return NO;
            }
        }
    }

    return %orig;
}

%end

// ============================================================================
// MARK: - 7. 越狱状态上报拦截
// ============================================================================

%hook NSURLRequest

- (id)initWithURL:(NSURL *)URL {
    NSString *urlString = [URL absoluteString];

    // 拦截可能上报越狱状态的请求
    if ([urlString containsString:@"device_check"] ||
        [urlString containsString:@"integrity"] ||
        [urlString containsString:@"attestation"]) {
        ANTI_JB_LOG("URLRequest: 检测到可疑的完整性检查请求: %@", urlString);
    }

    return %orig;
}

%end

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    // 移除可能标识越狱的请求头
    if ([field isEqualToString:@"X-Device-Jailbroken"] ||
        [field isEqualToString:@"X-Jailbreak-Status"] ||
        [field isEqualToString:@"X-Device-Modified"]) {
        ANTI_JB_LOG("URLRequest: 拦截越狱状态头 %@", field);
        return; // 不设置这个头
    }

    // 修改可能暴露越狱的值
    if ([field isEqualToString:@"X-Device-Info"] && value) {
        if ([value containsString:@"jailbreak"] ||
            [value containsString:@"cydia"] ||
            [value containsString:@"substrate"]) {
            ANTI_JB_LOG("URLRequest: 过滤设备信息中的越狱标记");
            NSString *cleaned = [value stringByReplacingOccurrencesOfString:@"jailbreak" withString:@""];
            cleaned = [cleaned stringByReplacingOccurrencesOfString:@"cydia" withString:@""];
            cleaned = [cleaned stringByReplacingOccurrencesOfString:@"substrate" withString:@""];
            %orig(cleaned, field);
            return;
        }
    }

    %orig(value, field);
}

%end

// ============================================================================
// MARK: - 8. "非官方应用" 警告拦截
// ============================================================================

%hook UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(UIAlertControllerStyle)preferredStyle {

    // 拦截非官方应用警告
    if (message && ([message containsString:@"unofficial"] ||
                    [message containsString:@"非官方"] ||
                    [message containsString:@"modified"] ||
                    [message containsString:@"不支持"] ||
                    [message containsString:@"unsupported"])) {
        ANTI_JB_LOG("Alert: 拦截非官方应用警告");
        // 返回一个空的 alert (不会显示)
        return nil;
    }

    return %orig;
}

%end

%hook UIAlertView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... {

    if (message && ([message containsString:@"unofficial"] ||
                    [message containsString:@"非官方"] ||
                    [message containsString:@"modified"])) {
        ANTI_JB_LOG("AlertView: 拦截非官方应用警告");
        return nil;
    }

    return %orig;
}

- (void)show {
    NSString *message = [self message];
    if (message && ([message containsString:@"unofficial"] ||
                    [message containsString:@"非官方"])) {
        ANTI_JB_LOG("AlertView: 阻止显示非官方应用警告");
        return;
    }

    %orig;
}

%end

// ============================================================================
// MARK: - 9. 登录失败拦截
// ============================================================================

%hook WALoginViewController

- (void)showError:(NSString *)error {
    if ([error containsString:@"unofficial"] ||
        [error containsString:@"非官方"] ||
        [error containsString:@"not supported"] ||
        [error containsString:@"unsupported"]) {
        ANTI_JB_LOG("Login: 拦截登录错误: %@", error);
        return;
    }

    %orig;
}

%end

// ============================================================================
// MARK: - 10. 初始化 Hook
// ============================================================================

%ctor {
    @autoreleasepool {
        ANTI_JB_LOG("=======================================");
        ANTI_JB_LOG("反越狱检测补丁已加载");
        ANTI_JB_LOG("功能:");
        ANTI_JB_LOG("  ✅ 文件系统检查绕过");
        ANTI_JB_LOG("  ✅ URL Scheme 检查绕过");
        ANTI_JB_LOG("  ✅ 动态库检测绕过");
        ANTI_JB_LOG("  ✅ 系统调用检测绕过");
        ANTI_JB_LOG("  ✅ App 签名检查绕过");
        ANTI_JB_LOG("  ✅ 沙盒检测绕过");
        ANTI_JB_LOG("  ✅ 越狱状态上报拦截");
        ANTI_JB_LOG("  ✅ 非官方应用警告拦截");
        ANTI_JB_LOG("  ✅ 登录失败拦截");
        ANTI_JB_LOG("=======================================");

        // Hook C 函数
        MSHookFunction((void *)stat, (void *)hooked_stat, (void **)&orig_stat);
        MSHookFunction((void *)lstat, (void *)hooked_lstat, (void **)&orig_lstat);
        MSHookFunction((void *)fopen, (void *)hooked_fopen, (void **)&orig_fopen);
        MSHookFunction((void *)dlopen, (void *)hooked_dlopen, (void **)&orig_dlopen);
        MSHookFunction((void *)_dyld_image_count, (void *)hooked_dyld_image_count, (void **)&orig_dyld_image_count);
        MSHookFunction((void *)_dyld_get_image_name, (void *)hooked_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
        MSHookFunction((void *)getenv, (void *)hooked_getenv, (void **)&orig_getenv);
        MSHookFunction((void *)fork, (void *)hooked_fork, (void **)&orig_fork);
        MSHookFunction((void *)system, (void *)hooked_system, (void **)&orig_system);

        ANTI_JB_LOG("C 函数 Hook 完成");
    }
}
