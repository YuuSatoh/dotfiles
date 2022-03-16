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

# symlink dotfile
for dotfile in .?*; do
    if [ $dotfile != ".." ] && [ $dotfile != ".git" ] && [ $dotfile != ".gitmodules" ] && [ $dotfile != ".config" ]; then
        symlink "$PWD/$dotfile" "$HOME/$dotfile"
    fi
done

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
