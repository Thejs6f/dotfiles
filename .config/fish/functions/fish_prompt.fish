# ============================================================================
# Helper: format duration from CMD_DURATION (ms)
# ============================================================================
function __fmt_duration
  set -l ms $argv[1]
  set -l sec (math -s0 "$ms / 1000")
  set -l s (math -s0 "$sec % 60")
  set -l m (math -s0 "($sec / 60) % 60")
  set -l h (math -s0 "$sec / 3600")
  if test $h -gt 0
    echo $h"h"$m"m"$s"s"
  else if test $m -gt 0
    echo $m"m"$s"s"
  else
    echo $s"s"
  end
end
# ============================================================================
# Helper: load color depending on CPU count
# ============================================================================
function __load_color
  set -l load $argv[1]
  set -l cores (nproc)
  set -l ratio (math -s0 "$load / $cores")
  if test "$ratio" -lt 1
    set_color normal
  else if test "$ratio" -lt 2
    set_color bryellow
  else
    set_color brred
  end
end
# ============================================================================
# Helper: visible string length (strip ANSI)
# ============================================================================
function __vis_len
#  string length -- (echo $argv | sed -e 's/\x1b[^m]*m//g')
  set -l s (string join ' ' $argv)
  set -l clean (string replace -ra '\e[^m]*m' '' -- $s)
  string length -- $clean
end
# ============================================================================
# Left prompt + top line
# ============================================================================
function fish_prompt
  # --------------------------------------------------------------------------
  # Exit code
  # --------------------------------------------------------------------------
  set -l last_status $status
  set -l color_status "brred"
  if test $last_status -eq 0
    set color_status "brgreen"
  end
  set -l status_seg "["(set_color $color_status)$last_status(set_color normal)"]"
  # --------------------------------------------------------------------------
  # Duration
  # --------------------------------------------------------------------------
  set -l dur_seg ""
  if set -q CMD_DURATION
    set -l dur (__fmt_duration $CMD_DURATION)
    set dur_seg "["(set_color brcyan)$dur(set_color normal)"]"
  end
  # --------------------------------------------------------------------------
  # Date / time
  # --------------------------------------------------------------------------
  set -l datetime (date "+%a, %Y-%m-%d %H:%M:%S")
  set -l time_seg "[$datetime]"

  # --------------------------------------------------------------------------
  # Build top line
  # --------------------------------------------------------------------------
  set -l pwd_seg "["(whoami)"@"(hostname)":"(pwd)"]"
  set -l dir_seg "["(basename (pwd))"]"
  set -l line_left "╭─$dir_seg──$dur_seg$pwd_seg"
  set -l len (__vis_len $line_left)
  set -l fill (math "$COLUMNS - $len - 2")
  test $fill -lt 0; and set fill 0
  set -l fill_seg (string repeat -n $fill '─')
  set line_left "╭─$dir_seg──$dur_seg$fill_seg"

  printf "%s%s─╮\n" $line_left $pwd_seg
  # --------------------------------------------------------------------------
  # Bottom left prompt
  # --------------------------------------------------------------------------
  set -l pwd_short_seg "("(prompt_pwd)")"
  set -g __fish_git_prompt_showupstream auto
  set -g __fish_git_prompt_show_informative_status yes
  set -g _fish_git_prompt_showcolorhints yes
  set -l git (string trim -- (fish_git_prompt))
  set -l user_char '$'
  if test (id -u) -eq 0
    set user_char '#'
  end

  if test -n "$git"
    printf '╰─%s─%s─%s ' $status_seg $git $user_char
  else
    printf '╰─%s─%s ' $status_seg $user_char
  end

#  if test -n "$git"
#    printf '╰─%s─%s ' $git $user_char
#  else
#    printf '╰─%s ' $user_char
#  end

end
# ============================================================================
# Right prompt: git + full path
# ============================================================================
function fish_right_prompt
  printf ' [%s]─╯' (date "+%a, %Y-%m-%d %H:%M:%S")
end
