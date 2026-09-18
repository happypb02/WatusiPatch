# WatusiPatch GitHub 部署配置脚本
# 运行此脚本前，请先填写下面的信息

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "WatusiPatch GitHub 部署配置向导" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 获取用户信息
Write-Host "请输入以下信息：" -ForegroundColor Yellow
Write-Host ""

$githubUsername = Read-Host "1. 你的 GitHub 用户名（例如：john-doe）"
$yourName = Read-Host "2. 你的名字（例如：John Doe）"
$yourEmail = Read-Host "3. 你的邮箱（例如：john@example.com）"
$packageName = Read-Host "4. 包名后缀（例如：watusipatch，完整包名将是 com.$githubUsername.$packageName）"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "确认信息" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "GitHub 用户名: $githubUsername" -ForegroundColor White
Write-Host "你的名字: $yourName" -ForegroundColor White
Write-Host "你的邮箱: $yourEmail" -ForegroundColor White
Write-Host "包名: com.$githubUsername.$packageName" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "信息正确吗？(y/n)"

if ($confirm -ne 'y') {
    Write-Host "已取消" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "开始配置..." -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 替换 control 文件
Write-Host "1. 配置 control 文件..." -ForegroundColor White
$controlPath = ".\control"
$controlContent = Get-Content $controlPath -Raw
$controlContent = $controlContent -replace 'com\.yourname\.watusipatch', "com.$githubUsername.$packageName"
$controlContent = $controlContent -replace 'Your Name', $yourName
$controlContent = $controlContent -replace 'your@email\.com', $yourEmail
$controlContent = $controlContent -replace 'https://github\.com/yourname/', "https://github.com/$githubUsername/"
Set-Content $controlPath $controlContent -NoNewline
Write-Host "   ✅ control 文件已更新" -ForegroundColor Green

# 替换 README.md
Write-Host "2. 配置 README.md..." -ForegroundColor White
$readmePath = ".\README.md"
$readmeContent = Get-Content $readmePath -Raw
$readmeContent = $readmeContent -replace 'yourusername', $githubUsername
Set-Content $readmePath $readmeContent -NoNewline
Write-Host "   ✅ README.md 已更新" -ForegroundColor Green

# 替换 QUICKSTART.md
Write-Host "3. 配置 QUICKSTART.md..." -ForegroundColor White
$quickstartPath = ".\QUICKSTART.md"
if (Test-Path $quickstartPath) {
    $quickstartContent = Get-Content $quickstartPath -Raw
    $quickstartContent = $quickstartContent -replace 'yourusername', $githubUsername
    Set-Content $quickstartPath $quickstartContent -NoNewline
    Write-Host "   ✅ QUICKSTART.md 已更新" -ForegroundColor Green
}

# 替换 DEPLOYMENT_GUIDE.md
Write-Host "4. 配置 DEPLOYMENT_GUIDE.md..." -ForegroundColor White
$deployPath = ".\DEPLOYMENT_GUIDE.md"
if (Test-Path $deployPath) {
    $deployContent = Get-Content $deployPath -Raw
    $deployContent = $deployContent -replace 'yourusername', $githubUsername
    Set-Content $deployPath $deployContent -NoNewline
    Write-Host "   ✅ DEPLOYMENT_GUIDE.md 已更新" -ForegroundColor Green
}

# 配置 Git
Write-Host "5. 配置 Git..." -ForegroundColor White
git config --global user.name "$yourName"
git config --global user.email "$yourEmail"
Write-Host "   ✅ Git 配置完成" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ 配置完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 在 GitHub 创建新仓库" -ForegroundColor White
Write-Host "   访问: https://github.com/new" -ForegroundColor Gray
Write-Host "   仓库名: WatusiPatch" -ForegroundColor Gray
Write-Host "   可见性: Public 或 Private" -ForegroundColor Gray
Write-Host "   不要勾选 'Initialize with README'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 创建完成后，运行以下命令：" -ForegroundColor White
Write-Host ""
Write-Host "   git init" -ForegroundColor Cyan
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m `"Initial commit: WatusiPatch v2.0.0`"" -ForegroundColor Cyan
Write-Host "   git branch -M main" -ForegroundColor Cyan
Write-Host "   git remote add origin https://github.com/$githubUsername/WatusiPatch.git" -ForegroundColor Cyan
Write-Host "   git push -u origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. 创建 Release：" -ForegroundColor White
Write-Host ""
Write-Host "   git tag -a v2.0.0 -m `"Release v2.0.0`"" -ForegroundColor Cyan
Write-Host "   git push origin v2.0.0" -ForegroundColor Cyan
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "💡 提示" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "GitHub Actions 将自动编译并创建 Release" -ForegroundColor White
Write-Host "编译好的 .deb 文件可以在 Releases 页面下载" -ForegroundColor White
Write-Host ""
Write-Host "项目地址: https://github.com/$githubUsername/WatusiPatch" -ForegroundColor Green
Write-Host ""
