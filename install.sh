#!/bin/bash

git clone https://github.com/samoyed24/my-vim-config.git ~/my-vim-config

# 备份旧的 Vim 配置
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak

mv ~/my-vim-config/.vimrc ~/.vimrc
rm -rf ~/my-vim-config

echo "Vim 配置安装完成！"
