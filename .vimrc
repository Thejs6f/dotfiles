" ============================================================================
" Allgemeine Einstellungen
" ============================================================================

" Erweiterte Vim-Funktionen aktivieren
set nocompatible

" Lange Zeilen nicht umbrechen
set nowrap

" Unvollständige Befehle unten anzeigen
set showcmd

" Statuszeile immer anzeigen
set laststatus=2

" Fenster beim Teilen gleich groß halten
set equalalways
" alt: set ea

" ============================================================================
" Einrückung und Tabulatoren
" ============================================================================

" Leerzeichen statt Tabulatoren einfügen
set expandtab

" Einrückung mit 2 Leerzeichen
set shiftwidth=2

" Tab-Taste zählt beim Bearbeiten als 2 Leerzeichen
set softtabstop=2

" Ein Tabulator entspricht 2 Leerzeichen
set tabstop=2

" Neue Zeilen übernehmen die Einrückung
set autoindent

" ============================================================================
" Bearbeiten
" ============================================================================

" Löschen über Einrückung, Zeilenende und Zeilenanfang erlauben
set backspace=indent,eol,start
" alt: set backspace=2

" Passende Klammern kurz hervorheben
set showmatch

" ============================================================================
" Anzeige
" ============================================================================

" Syntaxhervorhebung aktivieren
syntax on

" Absolute und relative Zeilennummern anzeigen
set number
set relativenumber
" alt: set number rnu

" ============================================================================
" Suchen
" ============================================================================

" Groß-/Kleinschreibung bei der Suche ignorieren
set ignorecase

" Großbuchstaben erzwingen Groß-/Kleinschreibung
set smartcase

" Suchtreffer bereits während der Eingabe anzeigen
set incsearch

" ============================================================================
" Sicherungskopien
" ============================================================================

" Beim Speichern Sicherungskopien anlegen
set backup

" Verzeichnis für Sicherungskopien
set backupdir=~/.backup

" ============================================================================
" Tastenkürzel
" ============================================================================

" F8 speichert die Datei
nnoremap <F8> :write!<CR>
" alt: map ^[[19~ ^[:w!

" F8 speichert auch im Einfügemodus
inoremap <F8> <C-o>:write!<CR>
" alt: map! ^[[19~ ^[:w!

" F7 beendet Vim ohne Rückfrage
nnoremap <F7> :quit!<CR>
" alt: map ^[[18~ ^[:q!

" F7 beendet auch im Einfügemodus
inoremap <F7> <C-o>:quit!<CR>
" alt: map! ^[[18~ ^[:q!
