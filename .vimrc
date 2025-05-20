" Version compatible avec Vim 9 et simplifié
" Désactive la compatibilité avec Vi
set nocompatible

" Configuration de l'encodage
set encoding=utf-8

" Configuration des couleurs
set termguicolors " Active les vraies couleurs si supportées
set background=dark
colorscheme wildcharm

" Gestion des polices
if has("gui_running")
    set guifont=Monaco:h13
endif

" Résout un problème de terminaison de ligne dans certains fichiers
set display+=lastline

" Remet le curseur à la dernière position à l'ouverture d'un fichier
augroup RestoreCursor
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
augroup END

" Ne pas découper les lignes automatiquement
set nowrap

" Notifications visuelles au lieu des bips
set visualbell
set noerrorbells

" Gestion de la complétion intelligente
set wildmenu
set wildmode=longest:full,list:full
set omnifunc=syntaxcomplete#Complete

" Activer la numérotation des lignes
set number

" Sauvegarder automatiquement avant de quitter un buffer
set autowrite

" Recharger un fichier modifié à l'extérieur
set autoread

" Empêcher la création de fichiers d'échange
set noswapfile
set nobackup

" Tabs et indentations
set tabstop=4
set shiftwidth=4
set expandtab " Convertit les tabulations en espaces
set autoindent
set smartindent

" Recherche interactive et surlignage
set incsearch
set hlsearch
highlight Search ctermbg=yellow ctermfg=red

" Activer la correspondance des parenthèses
set showmatch

" Historique et annulations
set history=1000
set undolevels=1000

" Ignorer certains fichiers
set wildignore+=*.o,*.obj,*.exe,*.dll,*.jpg,*.png,*.gif,*.zip,*.tar.gz

" Optimisations pour les macros
set lazyredraw

" Barre de statut simplifiée
set laststatus=2
set statusline=%f\ [%Y]\ [%{&fileencoding}]

" Activer la souris
set mouse=a

" Configuration des replis
set foldmethod=indent
set nofoldenable

" Mappages utiles
let mapleader="," " Définit la virgule comme leader
nnoremap <leader>pp :setlocal paste!<CR>
nnoremap Y y$
cnoreabbrev w!! w !sudo tee % >/dev/null

" Plugins essentiels
syntax enable
filetype plugin indent on

" Afficher les espaces et tabulations
set list
set listchars=tab:»─,trail:·,eol:¬,space:·,extends:>,precedes:<

" Barre de statut avec des informations détaillées
set statusline=%f\ [%Y]\ [%{&fileencoding}]\ %l/%L\ [%p%%]

" Certaines options inutiles ou redondantes ont été désactivées pour simplification
" Exemple :
" set t_Co=256 " Redondant avec termguicolors
" let base16colorspace=256 " Spécifique à certains schémas, souvent inutile

" Explications des suppressions de directives "set":
" 1. set backspace=eol,indent,start
"    -> Supprimé car cette option est activée par défaut dans les versions récentes de Vim.
" 2. set complete+=kspell
"    -> Supprimé car l'inclusion des suggestions orthographiques est spécifique aux besoins d'édition de texte,
"       et peut ralentir la complétion dans de gros fichiers.
" 3. set completeopt=menuone,longest
"    -> Supprimé pour simplifier, mais peut être réintégré si vous souhaitez une gestion fine de la complétion.
" 4. set confirm
"    -> Supprimé car la confirmation explicite peut être redondante avec les habitudes d'enregistrement et d'utilisation.
" 5. set copyindent
"    -> Supprimé car redondant avec des options comme autoindent et smartindent, qui gèrent déjà l'indentation.
" 6. set cursorline
"    -> Supprimé pour alléger l'interface visuelle, mais utile si vous voulez une meilleure lisibilité du curseur.
