#!/usr/bin/env sh

# OS specific stuff
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
        sudo apt install -y zsh vim curl git exuberant-ctags python-pip python-pygments
    fi
    if [ ${machine} = 'Mac' ]
    then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install coreutils zsh
    fi
    # ZSH
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # plugins=(git command-not-found sudo zsh-autosuggestions zsh-syntax-highlighting)
    cat <<EOF > ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/misc.zsh
# Misc settings
ZSH_THEME="agnoster"
export TERM='xterm-256color'
export EDITOR='vim'
plugins=(git command-not-found sudo fabric pass zsh-autosuggestions zsh-syntax-highlighting docker)
# export PATH="$PATH:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/bin:/usr/X11R6/bin:$HOME/bin"
ENABLE_CORRECTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

if [ -f /usr/local/bin/virtualenvwrapper.sh ] 
then
    source /usr/local/bin/virtualenvwrapper.sh
fi
EOF


    # VIM
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
    cat <<EOF >> $HOME/.vimrc
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
if $TERM == "xterm-256color"
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
    exit
fi

# Update

if [ ${machine} = 'Linux' ]
then
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove --purge -y
    sudo apt clean -y
fi
if [ ${machine} = 'Mac' ]
then
    brew update
    brew upgrade
    brew cleanup
fi

# ZSH
env ZSH=$ZSH sh $ZSH/tools/upgrade.sh
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull origin
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git pull origin
cd

# Vim
vim -T dumb -c PlugUpgrade -c PlugUpdate -c ":q" -c ":q"
