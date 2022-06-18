#!/bin/sh

function symlink() {
    orig=$1
    dest=$2

    if [ "$(readlink $dest)" != "$orig" ]; then
        ln -Fis $orig $dest
    fi
}

git submodule init
git submodule update

cd $(dirname $0)

touch ".zsh/zshrc.local"
touch ".zsh/zshenv.local"
touch ".zsh/zprofile.local"
touch "$HOME/.gitconfig.local"

# zeno
git clone https://github.com/yuki-yano/zeno.zsh.git ~/.zeno/

# symlink dotfile
for dotfile in .?*; do
    if [ $dotfile != ".." ] && [ $dotfile != ".git" ] && [ $dotfile != ".gitmodules" ] && [ $dotfile != ".config" ]; then
        symlink "$PWD/$dotfile" "$HOME/$dotfile"
    fi
done

# symlink iterm2
symlink "$PWD/iterm2/com.googlecode.iterm2.plist" ~/Library/ApplicationSupport/iTerm2/Scripts

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
