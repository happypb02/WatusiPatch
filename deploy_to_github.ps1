# WatusiPatch 一键部署脚本
# 此脚本将帮助你完成所有部署步骤

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "🚀 WatusiPatch 一键部署到 GitHub" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否已配置
$controlPath = ".\control"
$controlContent = Get-Content $controlPath -Raw

if ($controlContent -match 'yourname|yourusername') {
    Write-Host "⚠️  检测到配置信息尚未填写" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "请先运行: .\setup_github.ps1" -ForegroundColor White
    Write-Host "填写你的 GitHub 信息后，再运行此脚本" -ForegroundColor White
    Write-Host ""
    exit
}

# 提取配置信息
if ($controlContent -match 'Homepage: https://github\.com/([^/]+)/') {
    $githubUsername = $Matches[1]
    Write-Host "✅ 检测到 GitHub 用户名: $githubUsername" -ForegroundColor Green
} else {
    Write-Host "❌ 无法检测 GitHub 用户名，请先运行 setup_github.ps1" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 1: 检查 Git 安装" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

try {
    $gitVersion = git --version
    Write-Host "✅ Git 已安装: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git 未安装" -ForegroundColor Red
    Write-Host "请访问 https://git-scm.com/download/win 下载安装" -ForegroundColor White
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 2: 创建 GitHub 仓库" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "请按照以下步骤操作：" -ForegroundColor White
Write-Host ""
Write-Host "1. 在浏览器中打开:" -ForegroundColor White
Write-Host "   https://github.com/new" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. 填写以下信息:" -ForegroundColor White
Write-Host "   - Repository name: WatusiPatch" -ForegroundColor Gray
Write-Host "   - Description: Complete WhatsApp anti-detection and network optimization patch" -ForegroundColor Gray
Write-Host "   - Visibility: Public (推荐) 或 Private" -ForegroundColor Gray
Write-Host "   - ❌ 不要勾选 'Add a README file'" -ForegroundColor Gray
Write-Host "   - ❌ 不要勾选 'Add .gitignore'" -ForegroundColor Gray
Write-Host "   - ❌ 不要选择 License" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 点击绿色按钮 'Create repository'" -ForegroundColor White
Write-Host ""

$continue = Read-Host "已经在 GitHub 创建好仓库了吗？(y/n)"

if ($continue -ne 'y') {
    Write-Host "请先创建仓库，然后重新运行此脚本" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 3: 初始化 Git 仓库" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否已经初始化
if (Test-Path ".git") {
    Write-Host "ℹ️  Git 仓库已存在，跳过初始化" -ForegroundColor Yellow
} else {
    Write-Host "初始化 Git 仓库..." -ForegroundColor White
    git init
    Write-Host "✅ Git 仓库初始化完成" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 4: 添加文件到 Git" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "添加所有文件..." -ForegroundColor White
git add .
Write-Host "✅ 文件已添加" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 5: 创建首次提交" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "创建提交..." -ForegroundColor White
git commit -m "Initial commit: WatusiPatch v2.0.0

Features:
- Version check bypass
- Network connection fix (XMPP/HTTP)
- Web login & QR code fix
- Anti-jailbreak detection (7+ dimensions)
- Background keep-alive (triple mechanism)
- Message optimization (auto-retry)

Modules:
- Tweak.x (828 lines) - Main patch
- NetworkFix.x (412 lines) - Network fix
- WebLoginFix.x (484 lines) - Web login fix
- AntiJailbreakDetection.x (513 lines) - Anti-detection

Documentation:
- 14 comprehensive docs
- 12,628 words total
- Complete guides and tutorials

Build System:
- GitHub Actions auto-build
- Makefile configuration
- Test scripts"

Write-Host "✅ 首次提交完成" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 6: 连接远程仓库" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否已有 remote
$remoteExists = git remote | Select-String "origin"

if ($remoteExists) {
    Write-Host "ℹ️  远程仓库已存在，更新 URL..." -ForegroundColor Yellow
    git remote set-url origin "https://github.com/$githubUsername/WatusiPatch.git"
} else {
    Write-Host "添加远程仓库..." -ForegroundColor White
    git remote add origin "https://github.com/$githubUsername/WatusiPatch.git"
}

Write-Host "✅ 远程仓库已配置" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 7: 推送代码到 GitHub" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "设置主分支..." -ForegroundColor White
git branch -M main

Write-Host ""
Write-Host "推送代码到 GitHub..." -ForegroundColor White
Write-Host "⚠️  如果提示需要认证，请输入你的 GitHub 凭据" -ForegroundColor Yellow
Write-Host ""

try {
    git push -u origin main
    Write-Host ""
    Write-Host "✅ 代码推送成功！" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "❌ 推送失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "1. GitHub 仓库尚未创建" -ForegroundColor White
    Write-Host "2. 用户名或密码错误" -ForegroundColor White
    Write-Host "3. 需要使用 Personal Access Token" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 使用 Personal Access Token：" -ForegroundColor Yellow
    Write-Host "1. 访问: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "2. 点击 'Generate new token (classic)'" -ForegroundColor White
    Write-Host "3. 勾选 'repo' 权限" -ForegroundColor White
    Write-Host "4. 生成后复制 token" -ForegroundColor White
    Write-Host "5. 推送时使用 token 作为密码" -ForegroundColor White
    Write-Host ""
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 8: 创建 Release Tag" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "创建 v2.0.0 标签..." -ForegroundColor White
git tag -a v2.0.0 -m "Release v2.0.0

🎉 Initial Release

Features:
✅ Version check bypass
✅ Network connection fix
✅ Web login & QR code fix
✅ Anti-jailbreak detection
✅ Background keep-alive
✅ Message optimization

Installation:
Download the .deb file from Releases and install via Filza or SSH.

Full documentation available in the repository."

Write-Host "✅ 标签创建完成" -ForegroundColor Green

Write-Host ""
Write-Host "推送标签到 GitHub..." -ForegroundColor White
git push origin v2.0.0
Write-Host "✅ 标签推送成功！" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "🎉 部署完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ 代码已推送到 GitHub" -ForegroundColor Green
Write-Host "✅ Release tag 已创建" -ForegroundColor Green
Write-Host "✅ GitHub Actions 将自动开始编译" -ForegroundColor Green
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "📖 访问你的项目" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 项目主页:" -ForegroundColor White
Write-Host "   https://github.com/$githubUsername/WatusiPatch" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚙️  查看 Actions 编译状态:" -ForegroundColor White
Write-Host "   https://github.com/$githubUsername/WatusiPatch/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 下载编译好的 .deb:" -ForegroundColor White
Write-Host "   https://github.com/$githubUsername/WatusiPatch/releases" -ForegroundColor Cyan
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "⏳ 下一步" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 访问 Actions 页面，等待编译完成（约 5-10 分钟）" -ForegroundColor White
Write-Host "2. 编译完成后，在 Releases 页面下载 .deb 文件" -ForegroundColor White
Write-Host "3. 将 .deb 安装到你的越狱设备" -ForegroundColor White
Write-Host "4. 重启 WhatsApp，享受功能！" -ForegroundColor White
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "💡 提示" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "- 如果 Actions 编译失败，请查看日志排查问题" -ForegroundColor White
Write-Host "- 可以在 Issues 页面反馈问题" -ForegroundColor White
Write-Host "- 记得给项目添加 Star ⭐" -ForegroundColor White
Write-Host ""
Write-Host "🎊 恭喜！项目部署成功！" -ForegroundColor Green
Write-Host ""
