# 贡献指南

感谢你对 WatusiPatch 项目的关注！我们欢迎任何形式的贡献。

---

## 📋 目录

1. [行为准则](#行为准则)
2. [如何贡献](#如何贡献)
3. [开发环境搭建](#开发环境搭建)
4. [代码规范](#代码规范)
5. [提交规范](#提交规范)
6. [Pull Request 流程](#pull-request-流程)
7. [问题反馈](#问题反馈)

---

## 📜 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：

- 使用友好和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

### 不可接受的行为

- 使用性化的语言或图像
- 发表侮辱性/贬损性评论，人身攻击
- 公开或私下骚扰
- 未经许可发布他人的私人信息
- 其他不道德或不专业的行为

---

## 🤝 如何贡献

### 贡献类型

我们欢迎以下类型的贡献：

#### 1. 代码贡献
- 🐛 修复 Bug
- ✨ 添加新功能
- ⚡ 性能优化
- 🎨 代码重构
- 🔧 配置改进

#### 2. 文档贡献
- 📝 改进文档
- 🌍 翻译文档
- 📖 添加示例
- ❓ 完善 FAQ

#### 3. 测试贡献
- 🧪 编写测试用例
- 🔍 报告 Bug
- ✅ 验证修复

#### 4. 其他贡献
- 💡 提出新想法
- 🎨 设计图标/界面
- 📢 推广项目

---

## 💻 开发环境搭建

### 前置要求

**macOS:**
```bash
# 1. 安装 Xcode Command Line Tools
xcode-select --install

# 2. 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. 安装依赖
brew install ldid
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y git curl wget build-essential fakeroot \
  libxml2-dev libssl-dev libtool autoconf automake
```

### 安装 Theos

```bash
# 克隆 Theos
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos

# 设置环境变量
echo "export THEOS=/opt/theos" >> ~/.bashrc  # 或 ~/.zshrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# 下载 iOS SDK
cd $THEOS
wget https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/iPhoneOS*.sdk sdks/
rm -rf sdks-master master.zip
```

### 克隆项目

```bash
# Fork 项目后克隆你的 Fork
git clone https://github.com/YOUR_USERNAME/WatusiPatch.git
cd WatusiPatch

# 添加上游仓库
git remote add upstream https://github.com/yourname/WatusiPatch.git

# 验证
git remote -v
```

### 构建项目

```bash
# 清理
make clean

# 编译
make

# 打包
make package

# 查看生成的 deb
ls -lh packages/*.deb
```

---

## 📐 代码规范

### Objective-C 代码风格

#### 命名规范

```objc
// ✅ 好的命名
- (void)sendMessageWithText:(NSString *)text toRecipient:(NSString *)recipient;
- (BOOL)isNetworkReachable;
@property (nonatomic, strong) NSString *userName;

// ❌ 不好的命名
- (void)send:(NSString *)t to:(NSString *)r;
- (BOOL)check;
@property (nonatomic, strong) NSString *un;
```

#### 格式规范

```objc
// ✅ 大括号位置
- (void)someMethod {
    if (condition) {
        // do something
    } else {
        // do something else
    }
}

// ✅ 空格使用
NSString *text = @"Hello";
[self sendMessage:text];
if (x == 5) {
    // ...
}

// ✅ 方法间空行
- (void)method1 {
    // ...
}

- (void)method2 {
    // ...
}

// ✅ 指针星号位置
NSString *string = @"Hello";
id<Protocol> *delegate = nil;
```

#### Hook 代码规范

```objc
// ✅ 添加日志和注释
%hook ClassName

// 简要说明这个 Hook 的目的
- (ReturnType)methodName {
    LOG(@"Hook: methodName called");
    
    // 处理逻辑
    ReturnType result = %orig;
    
    // 修改返回值
    return modifiedResult;
}

%end

// ✅ 合理使用 %new
%hook ClassName

%new
- (void)customMethod {
    // 新增方法实现
}

%end

// ✅ 条件编译
#ifdef DEBUG
    LOG(@"Debug info");
#endif
```

### 文档注释

```objc
/**
 * 发送消息
 *
 * @param text 消息文本
 * @param recipient 接收者 JID
 * @param completion 完成回调
 * @return 是否成功加入发送队列
 */
- (BOOL)sendMessageWithText:(NSString *)text
                toRecipient:(NSString *)recipient
                 completion:(void (^)(BOOL success, NSError *error))completion;
```

### 日志规范

```objc
// ✅ 使用统一的日志宏
#define PATCH_LOG(fmt, ...) NSLog(@"[WatusiPatch] " fmt, ##__VA_ARGS__)

// ✅ 不同级别的日志
PATCH_LOG("Info: Network connected");
PATCH_LOG("Warning: Retry attempt %d", attempt);
PATCH_LOG("Error: Failed to send message: %@", error);

// ✅ 调试日志使用条件编译
#ifdef DEBUG
    PATCH_LOG("Debug: Variable value = %@", value);
#endif
```

---

## 📝 提交规范

### Commit Message 格式

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type 类型

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构（既不是新增功能，也不是修复 Bug）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动
- `revert`: 回滚之前的 commit

#### Scope 范围

- `network`: 网络相关
- `auth`: 认证相关
- `web`: Web 登录相关
- `background`: 后台相关
- `ui`: 界面相关
- `build`: 构建相关
- `docs`: 文档相关

#### 示例

```bash
# 好的 commit message
feat(network): add automatic reconnection on network change
fix(web): resolve QR code scanning issue for old versions
docs(readme): update installation instructions
refactor(auth): simplify version spoofing logic
perf(background): reduce battery consumption

# 不好的 commit message
update
fix bug
changes
test
```

### Git 工作流

```bash
# 1. 创建特性分支
git checkout -b feature/add-custom-heartbeat-interval

# 2. 进行开发和提交
git add .
git commit -m "feat(network): add configurable heartbeat interval"

# 3. 保持与上游同步
git fetch upstream
git rebase upstream/main

# 4. 推送到你的 Fork
git push origin feature/add-custom-heartbeat-interval

# 5. 创建 Pull Request
```

---

## 🔄 Pull Request 流程

### PR 前检查清单

提交 PR 前，请确保：

- [ ] 代码遵循项目的代码规范
- [ ] 已添加必要的注释和文档
- [ ] 已测试所有更改
- [ ] 所有测试通过
- [ ] Commit message 符合规范
- [ ] 已更新相关文档
- [ ] 已解决所有冲突

### 创建 Pull Request

1. **标题格式**
   ```
   <type>: <简短描述>
   
   例如:
   feat: Add configurable heartbeat interval
   fix: Resolve Web login authentication issue
   ```

2. **描述模板**
   ```markdown
   ## 改动类型
   - [ ] 新功能
   - [ ] Bug 修复
   - [ ] 文档更新
   - [ ] 代码重构
   - [ ] 性能优化
   - [ ] 其他
   
   ## 改动说明
   简要描述这个 PR 做了什么
   
   ## 测试情况
   - [ ] 已在 iOS 14.0 上测试
   - [ ] 已在 iOS 15.0 上测试
   - [ ] 已在 iOS 16.0 上测试
   - [ ] 已测试 WhatsApp 2.20.x
   - [ ] 已测试 WhatsApp 2.24.x
   
   ## 相关 Issue
   Closes #123
   
   ## 截图（如适用）
   [添加截图]
   
   ## 其他说明
   [其他需要说明的内容]
   ```

3. **提交 PR**
   - 在 GitHub 上创建 Pull Request
   - 选择正确的 base 分支（通常是 `main`）
   - 填写完整的 PR 描述
   - 添加相关标签

### Code Review

你的 PR 会经过以下审查：

1. **自动化检查**
   - GitHub Actions 自动构建
   - 代码风格检查
   - 基础测试

2. **人工审查**
   - 代码质量
   - 功能正确性
   - 性能影响
   - 安全性

3. **反馈和修改**
   - 根据 Review 意见修改代码
   - 推送新的 commit 到同一分支
   - 回复 Review 评论

4. **合并**
   - 所有检查通过
   - 获得维护者批准
   - PR 被合并到主分支

---

## 🐛 问题反馈

### 提交 Issue

在提交 Issue 前，请先：

1. **搜索已有 Issue**
   - 避免重复提交
   - 可以在相关 Issue 下补充信息

2. **使用 Issue 模板**

#### Bug Report 模板

```markdown
**问题描述**
清晰简洁地描述遇到的问题

**复现步骤**
1. 打开 '...'
2. 点击 '...'
3. 滚动到 '...'
4. 看到错误

**预期行为**
描述你期望发生什么

**实际行为**
描述实际发生了什么

**环境信息**
- 设备: [e.g. iPhone 12 Pro]
- iOS 版本: [e.g. iOS 15.1]
- 越狱工具: [e.g. unc0ver 8.0.2]
- WhatsApp 版本: [e.g. 2.21.140]
- WatusiPatch 版本: [e.g. 2.0.0]

**日志**
```
粘贴相关日志
```

**截图**
如适用，添加截图

**其他信息**
任何其他相关信息
```

#### Feature Request 模板

```markdown
**功能描述**
清晰简洁地描述你想要的功能

**使用场景**
描述为什么需要这个功能

**可选方案**
描述你考虑过的其他方案

**其他信息**
任何其他相关信息
```

---

## 🏷️ 版本发布

版本号遵循 [Semantic Versioning](https://semver.org/)：

```
MAJOR.MINOR.PATCH

例如: 2.0.0
```

- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的新功能
- **PATCH**: 向后兼容的 Bug 修复

---

## 🎁 贡献者奖励

### 致谢方式

- 在 README.md 中列出所有贡献者
- 在 Release Notes 中感谢特定贡献
- 项目内置的致谢页面

### 成为核心贡献者

活跃的贡献者可以成为项目维护者，获得：

- 代码审查权限
- 直接 commit 权限
- 参与项目决策

---

## 📞 联系方式

如有任何问题，欢迎通过以下方式联系：

- **GitHub Issues**: https://github.com/yourname/WatusiPatch/issues
- **GitHub Discussions**: https://github.com/yourname/WatusiPatch/discussions
- **Email**: your@email.com

---

## 🙏 感谢

感谢所有为 WatusiPatch 做出贡献的开发者！

你的每一个 commit 都让这个项目变得更好。❤️

---

**Happy Coding! 🚀**
