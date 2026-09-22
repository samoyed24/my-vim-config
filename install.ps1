<#
    my-vim-config —— Windows 安装脚本（PowerShell 5.1+）

    用法：
        irm https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.ps1 | iex
#>

# 整体包一层脚本块：用 iex 执行时不会把变量、函数和 $ErrorActionPreference 泄漏到用户会话里
& {
    $ErrorActionPreference = 'Stop'

    $RepoBase = 'https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main'

    # PowerShell 5.1 默认可能没启用 TLS 1.2，而 GitHub 需要
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $VimrcPath = Join-Path $HOME '.vimrc'
    $ShimPath  = Join-Path $HOME '_vimrc'

    # Windows 上有两种 Vim，读的配置文件名不一样：
    #   原生 Vim (vim.org 安装包)      -> 优先读 _vimrc
    #   git-bash / msys2 自带的 Vim    -> 只读 .vimrc
    # 所以主配置统一放 .vimrc，再用 _vimrc 转发过去，两边共用同一份。
    $ShimContent = @'
" 由 my-vim-config 的 install.ps1 生成，请勿手动修改
if filereadable(expand('~/.vimrc'))
  source ~/.vimrc
endif
'@

    function Write-Utf8NoBom {
        param([string]$Path, [string]$Content)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
    }

    function Test-IsOwnShim {
        param([string]$Path)
        if (-not (Test-Path -LiteralPath $Path)) { return $false }
        $text = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
        if (-not $text) { return $false }
        return $text -match 'source ~/\.vimrc'
    }

    function Backup-VimFile {
        param([string]$Path)
        if (-not (Test-Path -LiteralPath $Path)) { return }
        $backup = "$Path.bak"
        if (Test-Path -LiteralPath $backup) {
            $backup = "$Path.$(Get-Date -Format 'yyyyMMddHHmmss').bak"
        }
        Move-Item -LiteralPath $Path -Destination $backup -Force
        Write-Host "  已备份 $Path -> $backup"
    }

    Write-Host '正在安装 Vim 配置...'

    # 先下载到临时文件，确认下载成功后再动用户的配置
    $tempFile = Join-Path $env:TEMP ("vimrc-" + [Guid]::NewGuid().ToString('N'))
    try {
        Invoke-WebRequest -Uri "$RepoBase/.vimrc" -OutFile $tempFile -UseBasicParsing
        if ((Get-Item -LiteralPath $tempFile).Length -eq 0) {
            throw '下载到的 .vimrc 是空文件'
        }
    }
    catch {
        if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force }
        throw "下载 .vimrc 失败：$($_.Exception.Message)"
    }

    # 自己生成的 shim 直接覆盖，不备份，免得重复安装时堆一堆 .bak
    if (Test-IsOwnShim $ShimPath) {
        Remove-Item -LiteralPath $ShimPath -Force
    }
    else {
        Backup-VimFile $ShimPath
    }

    # .vimrc 内容没变就不用备份，重复安装时保持干净
    $vimrcUnchanged = (Test-Path -LiteralPath $VimrcPath) -and
        (Get-FileHash -LiteralPath $tempFile).Hash -eq (Get-FileHash -LiteralPath $VimrcPath).Hash
    if (-not $vimrcUnchanged) {
        Backup-VimFile $VimrcPath
    }

    try {
        Move-Item -LiteralPath $tempFile -Destination $VimrcPath -Force
        Write-Utf8NoBom -Path $ShimPath -Content ($ShimContent + "`n")
    }
    finally {
        # 任何一步失败都别在 %TEMP% 里留下残留文件
        if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force }
    }

    if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
        Write-Host ''
        Write-Host '提示：PATH 里没找到 vim，配置已就位，装好 Vim 后即可生效。'
    }

    Write-Host ''
    Write-Host 'Vim 配置安装完成！'
    Write-Host "  $VimrcPath    (主配置)"
    Write-Host "  $ShimPath     (转发到主配置)"
}
