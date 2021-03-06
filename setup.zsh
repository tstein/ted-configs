#!/bin/zsh

CONFIGS=`pwd`
cd ~
ln -s "$CONFIGS/dir_colors" .dir_colors
ln -s "$CONFIGS/tmux.conf" .tmux.conf
ln -s "$CONFIGS/vim" .vim
ln -s "$CONFIGS/vimrc" .vimrc
ln -s "$CONFIGS/zsh" .zsh
ln -s "$CONFIGS/zshrc" .zshrc
if [[ "$USER" == "ted" ]]; then
    ln -s "$CONFIGS/gitconfig" .gitconfig
else
    print "not certain you're ted, skipping gitconfig"
fi

mkdir -p ~/.local/bin
# vim expects this to exist
mkdir -p ~/.local/tmp

ln -s "$CONFIGS/bin/mtmux" ~/.local/bin/

cd $CONFIGS
git submodule init
git submodule update
vim +BundleInstall +qa

exec zsh
