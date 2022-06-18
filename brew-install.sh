#!/bin/bash

brews=(
    awscli
    bat
    git
    jq
    zsh
    zsh-completion
    zsh-syntax-highlighting
    peco
    fzf
    openssl
    python3
    deno
    gh
    nvm
)

casks=(
    iterm2
    sequel-ace
    hyperswitch
    google-chrome
    slack
    hammerspoon
    docker
    maccy
    postman
)

# brew
for app in "${brews[@]}"; do
    brew install "$app"
done

# cask
for app in "${casks[@]}"; do
    brew install --cask "$app"
done
