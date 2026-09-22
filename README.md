## Usage

### Linux / macOS

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.sh)"
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/samoyed24/my-vim-config/refs/heads/main/install.ps1 | iex
```

## Windows 说明

Windows 上存在两种 Vim，读取的配置文件名不同：

| Vim | 读取的配置文件 |
| --- | --- |
| 原生 Vim（vim.org 安装包） | `_vimrc` 优先，其次 `.vimrc` |
| git-bash / msys2 自带的 Vim | 只读 `.vimrc` |

安装脚本会把主配置放在 `%USERPROFILE%\.vimrc`，并生成一个 `%USERPROFILE%\_vimrc` 转发过去，因此两种 Vim 共用同一份配置。

安装脚本是幂等的：重复执行不会堆积备份文件；只有当 `.vimrc` 内容确实变化、或 `_vimrc` 是你自己写的时候，才会先备份成 `.bak`。
