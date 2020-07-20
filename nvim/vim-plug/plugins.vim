call plug#begin('~/.config/nvim/autoload/plugged')
    Plug 'tpope/vim-commentary'
    Plug 'jiangmiao/auto-pairs'
    Plug 'itchyny/lightline.vim'
    Plug 'mengelbrecht/lightline-bufferline'
    Plug 'ryanoasis/vim-devicons'
    Plug 'tpope/vim-surround'
    Plug 'alvan/vim-closetag'
    Plug 'airblade/vim-gitgutter'
    Plug 'tpope/vim-fugitive'
    Plug 'scrooloose/nerdcommenter'
    Plug 'easymotion/vim-easymotion'
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'dracula/vim', {'as': 'dracula'}
    Plug 'sheerun/vim-polyglot'
    Plug 'honza/vim-snippets'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'voldikss/coc-bookmark', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'clangd/coc-clangd', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'antonk52/coc-cssmodules', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'pappasam/coc-jedi', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'pantharshit00/coc-prisma', {'do': 'yarn install --frozen-lockfile && yarn build'}
    Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile && yarn build'}
call plug#end()
