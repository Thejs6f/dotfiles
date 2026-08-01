#!/bin/bash

##
# functions
# ------------------------------------------------------------------------------
updateBashrc() {
  local url="${1:-$envVarUpdateUrlBashrc}" tmp
  tmp=$(mktemp) || return 1
  [[ -z $url ]] && return 1
  [[ "$url" =~ ^(http|https|ftp|file): ]] || url="file://$url"

  (curl -sSf -k -o "$tmp" "$url" 2>/dev/null ||
   wget -q --no-check-certificate -O "$tmp" "$url") || { rm -f "$tmp"; return 1; }

  [[ -s "$tmp" ]] && chmod 644 "$tmp" &&
    source "$tmp" && mv -f "$tmp" "$HOME/.bashrc" || rm -f "$tmp"
}
# ------------------------------------------------------------------------------
isDecimal() {
  [[ -n $1 && $1 =~ ^(0|[1-9][0-9]*)$ ]]
}
# ------------------------------------------------------------------------------
wsr() {
  local host="$1"
  [[ -z "$host" ]] && return 1

  until LANG=en_US.UTF-8 ssh -l root -XY "$host";
  do
    printf '%s reconnecting...\n' "$(date)"
    sleep 1
  done
}
# ------------------------------------------------------------------------------
countdown() {
  local idx=10
  isDecimal "$1" && idx=$1

  local fmt="%Y-%m-%d %H:%M:%S.%3N"
  local start end finish
  local label_width=15

  start=$(date +"$fmt")
  end=$(date -d "+$idx seconds" +"$fmt" 2>/dev/null || \
        date -v+"${idx}"S +"$fmt")

  printf '%-*s %s\n' "$label_width" "Start:" "$start"
  printf '%-*s %s\n' "$label_width" "End (expected):" "$end"

  printf '%s' "$idx"
  ((idx--))

  while (( idx >= 0 )); do
    sleep 1
    (( idx % 5 )) && printf '.' || printf '%s' "$idx"
    ((idx--))
  done
  printf '\n'

  finish=$(date +"$fmt")
  printf '%-*s %s\n' "$label_width" "End (final):" "$finish"
}
# ------------------------------------------------------------------------------
removeColorCodes() {
  local re=$'\x1B\\[[0-9;]*[mK]'

  if [[ -z $1 ]]; then
    sed -E "s/${re}//g"
  elif sed --version &>/dev/null; then
    sed -E -i "s/${re}//g" "$1"
  else
    sed -E -i '' "s/${re}//g" "$1"
  fi
}
# ------------------------------------------------------------------------------
ltrim() {
  if [[ -n "$1" ]]; then
    printf '%s' "$1" | sed -E 's/^[[:space:]]+//'
  else
    sed -E 's/^[[:space:]]+//'
  fi
}
# ------------------------------------------------------------------------------
rtrim() {
  if [[ -n "$1" ]]; then
    printf '%s' "$1" | sed -E 's/[[:space:]]+$//'
  else
    sed -E 's/[[:space:]]+$//'
  fi
}
# ------------------------------------------------------------------------------
trim() {
  rtrim "$(ltrim "$1")";
}
# ------------------------------------------------------------------------------
stripComments() {
  grep -E -v '^[[:space:]]*#|^[[:space:]]*$' "${1:-/dev/stdin}";
}
# ------------------------------------------------------------------------------
center_string() {
    local input="$1"
    local str_length=${#1}
    local term_width padding_width padding odd_padding
    term_width=$(tput cols)
    padding_width=$(( (term_width - str_length - 2) / 2 ))
    padding=$(printf '%*s' "$padding_width" "" | tr ' ' '-')
    odd_padding=$(( (term_width - str_length - 2) % 2 ))

    printf '%s %s %s' "$padding" "$input" "$padding"
    (( odd_padding != 0 )) && printf '-'
    printf '\n'
}
# ------------------------------------------------------------------------------
history_summary() {
  history | sort -n | awk '
    /^[ 0-9]+ [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} / {
      date = $2
      time = $3
      $1 = $2 = $3 = ""; sub(/^  +/, "")
      command = $0

      if (!(date in first)) {
        first[date] = time " - " command
      }
      last[date] = time " - " command
    }
    END {
      PROCINFO["sorted_in"] = "@ind_str_asc"
      for (d in first) {
        print d, first[d]
        if (first[d] != last[d]) {
          print d, last[d]
        }
        print ""
      }
    }
  ';
}
# ------------------------------------------------------------------------------
# shellcheck disable=SC2034  ### Keep all color codes accessible for convenience
setColorCodes() {
  ESC="\033" ;             OFF="${ESC}[0m";      BOLD="${ESC}[1m"
  BG_BLACK="${ESC}[40m";   BLACK="${ESC}[30m";   HALFINTENSITY="${ESC}[2m"
  BG_RED="${ESC}[41m";     RED="${ESC}[31m";     INTENSITY="${ESC}[3m"
  BG_GREEN="${ESC}[42m";   GREEN="${ESC}[32m";   UNDERLINE="${ESC}[4m"
  BG_YELLOW="${ESC}[43m";  YELLOW="${ESC}[33m";  FLASH="${ESC}[5m"
  BG_BLUE="${ESC}[44m";    BLUE="${ESC}[34m";    INVERSE="${ESC}[7m"
  BG_MAGENTA="${ESC}[45m"; MAGENTA="${ESC}[35m"; CLRHOME="${ESC}[H${ESC}[2J"
  BG_CYAN="${ESC}[46m";    CYAN="${ESC}[36m";    CLREOL="${ESC}[K"
  BG_WHITE="${ESC}[47m";   WHITE="${ESC}[37m";   CURSOROFF="${ESC}[?50l"
  BG_NORMAL="${ESC}[49m";  NORMAL="${ESC}[39m";  CURSORON="${ESC}[?50h"
}
# ------------------------------------------------------------------------------
# shellcheck disable=SC2034  ### Keep all color codes accessible for convenience
setNoColors() {
  ESC="" ;      OFF="";    BOLD="";       CLREOL="";  CURSOROFF=""
  BG_BLACK="";  BLACK="";  BG_RED="";     RED="";     HALFINTENSITY=""
  BG_GREEN="";  GREEN="";  BG_YELLOW="";  YELLOW="";  INTENSITY=""
  BG_BLUE="";   BLUE="";   BG_MAGENTA=""; MAGENTA=""; UNDERLINE=""
  BG_CYAN="";   CYAN="";   BG_WHITE="";   WHITE="";   FLASH=""
  BG_NORMAL=""; NORMAL=""; CURSORON="";   INVERSE=""; CLRHOME=""
}
# ------------------------------------------------------------------------------
add_to_path() {
  local dirs=("$@")
  for dir in "${dirs[@]}"; do
    [[ ":$PATH:" == *":$dir:"* ]] || PATH+=":$dir"
  done
}
# ------------------------------------------------------------------------------
sp() {
  local GIT_PART=""
  if [[ $1 == "g" ]]; then
    GIT_PART="\$(__git_ps1 \"[%s] \")"
  fi

  export PS1='\
╭[$(EC=$?; echo -n \[\e[32m\]; [[ $EC -ne 0 ]] && echo -n \[\e[31m\]; echo $EC)\[\e[0m\]]\
──[\D{%a, %Y-%m-%d %H:%M:%S}]\
──[$(cut -d" " -f1,2 /proc/loadavg 2>/dev/null)]\
──[$(uname -r)]\
──[\u@\h:${PWD}]\n\
╰[\u@\h:\W] \
'"$GIT_PART"'\
$([[ $(id -u) == 0 ]] && echo "\[\e[0;31m\]")\
\$\[\e[0m\] '

}

##
# includes
for f in "$HOME"/.alias ; do
  [[ -r "$f" ]] && . "$f"
done

##
# alias
alias ..='cd ..'
alias Nmap='nmap -T4 -v -PN -sT'
alias cp='cp -i'
alias ctmp='cd "$(mktemp -d)"'
alias grep='grep -I --color=auto'
alias lr='ls -rtl --group-directories-first'
alias mv='mv -i'
alias rcp='rsync -a --info=progress2'
alias rm='rm -i'
alias sr="LANG='en_US.UTF-8' /usr/bin/ssh -l root -XYv"
alias sshcpid='ssh-copy-id -i ~/.ssh/id_rsa.pub'
case "$OSTYPE" in
  linux*)   alias l='ls -al --group-directories-first --color' ;;
  darwin*)  alias l='ls -al -G' ;;
  *)        alias l='ls -al' ;;
esac

##
# PATH extenstion
add_to_path "$HOME"/bin /usr/bin
export PATH

##
# variables
export PS1='\
 -=( $(EXC=$?; if [ $EXC == 0 ] ;then echo \[\e[32m\]OK 0; else echo \[\e[31m\]ERR $EXC; fi)\[\e[0m\] )\
---($(date "+%a, %Y-%m-%d %H:%M:%S"))\
---($(uptime | sed -e "s/.*: *//" | cut -d" " -f1,2 | sed "s/,\$//"))\
---($(uname -r))\
---[ \w ]=-\n\
\u@\h \W $(if [ "$(id -u)" = "0" ] ; then echo "\[\e[0;31m\]#\[\e[0m\]"; else echo "\[\e[0m\]\[\e[0;35m\]$\[\e[0m\]"; fi)> '

# source local extensions at the end
[[ -r $HOME/.bashrc.local ]] && . "$HOME"/.bashrc.local || true;

# EOF ##########################################################################
