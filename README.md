## Usage

### Linux / macOS

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.sh)"
```

### Windows (PowerShell)

```powershell
iex (irm https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.ps1).TrimStart([char]0xFEFF)
```

也可以先存成文件再执行（对编码和 PowerShell 版本都不敏感，更稳妥）：

```powershell
irm https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File install.ps1
```

> 脚本以 UTF-8 **带 BOM** 保存。这是必须的：PowerShell 5.1 用 `-File` 执行时，对无 BOM 的脚本会按 ANSI（简体中文系统上是 GBK）解码，中文注释会乱码并导致语法错误。
> 但 BOM 会让 `irm` 返回的字符串开头多一个 U+FEFF 字符，直接 `| iex` 会报 `The term '<#' is not recognized...`。所以上面的一行命令先用 `TrimStart` 去掉它。

## Windows 说明

Windows 上存在两种 Vim，读取的配置文件名不同：

| Vim | 读取的配置文件 |
| --- | --- |
| 原生 Vim（vim.org 安装包） | `_vimrc` 优先，其次 `.vimrc` |
| git-bash / msys2 自带的 Vim | 只读 `.vimrc` |

安装脚本会把主配置放在 `%USERPROFILE%\.vimrc`，并生成一个 `%USERPROFILE%\_vimrc` 转发过去，因此两种 Vim 共用同一份配置。

安装脚本是幂等的：重复执行不会堆积备份文件；只有当 `.vimrc` 内容确实变化、或 `_vimrc` 是你自己写的时候，才会先备份成 `.bak`。
