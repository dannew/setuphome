#!/usr/bin/env sh

# Functions have to go first?
install_oh_my_zsh()
{
    # ZSH
    echo Installing Oh-my-zsh...
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # echo Installing zplug...
    # curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    echo "Installing powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo "Installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "Installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    PLUGINS="git command-not-found sudo pass zsh-autosuggestions zsh-syntax-highlighting docker"
    # Configure plugins in ~/.zshrc
    sed -i "s/^plugins=.*/plugins=($PLUGINS)/" ~/.zshrc
    cat <<EOF > ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/misc.zsh
# Misc settings
ZSH_THEME="powerlevel10k/powerlevel10k"
export TERM='xterm-256color'
export EDITOR='vim'
plugins=(git command-not-found sudo pass zsh-autosuggestions zsh-syntax-highlighting docker)
export PATH="\$PATH:\$HOME/bin"
ENABLE_CORRECTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# zplug
# source ~/.zplug/init.zsh
# zplug romkatv/powerlevel10k, as:theme, depth:1
# zplug zsh-users/zsh-autosuggestions, as:plugin
# zplug zsh-users/zsh-syntax-highlighting, as:plugin
# zplug load

EOF

    cat <<EOF > ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/aliases.zsh
# Settings
DEBFULLNAME="Daniel Wiberg"
DEBEMAIL="danne@wiberg.nu"
# BROWSER=google-chrome

# Aliases
alias rmbak='rm *~'
alias cdiff='colordiff'
alias x='exit'
alias less='less -R'
alias bc='bc -l'
alias webtimer='curl -o /dev/null -w %{time_connect}:%{time_starttransfer}:%{time_total}'

alias attachadmin1='echo -ne "\033]0;danne@admin1: ~\007" && ssh -L 8080:192.168.243.254:80 -R 2222:localhost:22 -L 4443:192.168.243.10:443 -t admin1.wiberg.nu screen -Ux'
alias attachadmin1ipv4='echo -ne "\033]0;danne@admin1: ~\007" && ssh -4 -L 8080:192.168.243.254:80 -R 2222:localhost:22 -L 4443:192.168.243.10:443 -t admin1.wiberg.nu screen -Ux'
alias itlinux='ssh -L 8080:10.34.32.32:80 -X -t wiberg03@itlinux.om.tre.se'
alias itlinux-dk='ssh -X -t wiberg03@itlinux-dk.om.tre.se'
alias attachitlinux='echo -ne "\033]0;danne@itlinux: ~\007" && ssh -L 8080:10.34.32.32:80  -X -t wiberg03@itlinux.om.tre.se screen -Ux'
alias attachitlinuxipv4='echo -ne "\033]0;danne@itlinux: ~\007" && ssh -L 8080:10.34.32.32:80 -4 -X -t wiberg03@itlinux.om.tre.se screen -Ux'
alias moshadmin1='mosh danne@admin1.wiberg.nu -- sh -c "screen -Ux"'
alias moshitlinux='mosh wiberg03@itlinux.om.tre.se -- sh -c "screen -Ux"'
EOF
}

install_vim()
{

    # VIM
    echo Installing VIM plugins and themes...
    mkdir -p ~/.vim/colors
    cd ~/.vim/colors
    curl https://raw.githubusercontent.com/skielbasa/vim-material-monokai/master/colors/material-monokai.vim > material-monokai.vim
    mkdir -p ~/.vim/autoload/airline/themes
    cd ~/.vim/autoload/airline/themes
    curl https://raw.githubusercontent.com/skielbasa/vim-material-monokai/master/autoload/airline/themes/materialmonokai.vim > materialmonokai.vim
    cd
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # VIM config
    cat <<EOF > $HOME/.vimrc
" Dannes .vimrc
  
set expandtab " Replaces tab with spaces in source files
set softtabstop=4
set shiftwidth=4
set bs=2
set ai   " Autoindent
set t_kb=^V<BS>
set t_kD=^V<Delete>
set wildmenu "Visa meny för tab-completion
set showmatch "Parantes-highlite
set title " Uppdatera Fönstertitel
"set number "Visa radnummer på varje rad
"CTRL-SPACE för completion:
inoremap <Nul> <C-P>
set mouse=a
set enc=utf-8

" set term=linux
set background=dark
" syntax on
if \$TERM == "xterm-256color"
    set t_Co=256
endif
colorscheme material-monokai
let g:materialmonokai_italic=1
let g:airline_theme='materialmonokai'

" Tagbar
let g:tagbar_left = 1
autocmd VimEnter * nested :call tagbar#autoopen(1)

" Airline
let g:airline_powerline_fonts = 1
" Always show statusline
set laststatus=2

" NERD Commenter
let mapleader=","
set timeout timeoutlen=1500

" vim-plug
call plug#begin('~/.vim/plugged')
Plug 'davidhalter/jedi-vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'ervandew/supertab'
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'jamessan/vim-gnupg'
Plug 'momota/cisco.vim'
call plug#end()
EOF
    vim -T dumb -c PlugInstall -c ":q" -c ":q"
    # End VIM
}

configure_ssh()
{

    # ssh
    mkdir -p ~/.ssh
    cat <<EOF > $HOME/.ssh/config
Host *.wiberg.nu
    User danne

Host admin1
    HostName admin1.wiberg.nu
    User danne

Host *.om.tre.se
    User wiberg03
EOF
    # End ssh
}

install_linuxbrew()
{
    # Linuxbrew
    read -p "Do you wish to install Linuxbrew? y/n " linuxbrew
    if [ "$linuxbrew" != "${linuxbrew#[Yy]}" ] ;then
        echo Installing Linuxbrew...
        mkdir -p ~/.oh-my-zsh/custom
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
        test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
        test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
        echo "eval \$($(brew --prefix)/bin/brew shellenv)" >~/.oh-my-zsh/custom/homebrew.zsh
    else
        echo Skipping Linuxbrew...
    fi
}


### Main script

# OS specific stuff, identify operating system.
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

# Setup / Install
if [ "$1" = "setup" ] || [ "$1" = "install" ] ; then
    echo "Installing..."
    if [ ${machine} = 'Linux' ]
    then
        sudo apt install -y zsh vim curl git exuberant-ctags python3-pygments mtr-tiny nmap htop colordiff
        install_oh_my_zsh
        install_linuxbrew
    fi
    if [ ${machine} = 'Mac' ]
    then
	echo Installing Homebrew...
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install ctags htop mtr nmap pass colordiff mosh tig
        brew cask install atom iterm2 visual-studio-code owncloud vlc
        install_oh_my_zsh
    fi

    # Common for all platforms
    install_vim
    configure_ssh

exit
fi
# End Install

# Update

if [ ${machine} = 'Linux' ]
then
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove --purge -y
    sudo apt clean -y

    # Check for homebrew
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]
    then
        echo Updateing Homebrew
        brew update
        brew upgrade
        brew upgrade --cask
        # brew cask upgrade
        brew cleanup
    fi
fi
if [ ${machine} = 'Mac' ]
then
    softwareupdate -ia
    echo Updateing Homebrew
    brew update
    brew upgrade
    brew upgrade --cask
    # brew cask upgrade
    brew cleanup
fi

# ZSH
echo Updating ZSH
env ZSH=$ZSH sh $ZSH/tools/upgrade.sh
echo Updating powerlevel10k
cd ~/.oh-my-zsh/custom/themes/powerlevel10k
git pull origin
# echo Updating zplug
# zplug update
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull origin
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git pull origin
cd

# Vim
clear
echo Updating ZSH
vim -T dumb -c PlugUpgrade -c PlugUpdate -c ":q" -c ":q"

# End update
