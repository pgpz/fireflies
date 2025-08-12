#!/usr/bin/env bash
CFG="${1:-$HOME/.config/fireflies/fireflies.conf}"
NUM=${NUM:-28}
DELAY=${DELAY:-0.06}
MOVE_CHANCE=${MOVE_CHANCE:-6}
WANDER=${WANDER:-1}
GLOW_STEPS=${GLOW_STEPS:-6}
MIN_TTL=${MIN_TTL:-80}
MAX_TTL=${MAX_TTL:-220}

if [[ -f "$CFG" ]]; then
  source "$CFG"
fi

CHARS=( '.' '·' '·' '•' '●' '✦' )

PALETTE=(136 172 214 220 226 229)

while (( ${#CHARS[@]} < GLOW_STEPS )); do
  last_index=$(( ${#CHARS[@]} - 1 ))
  CHARS+=( "${CHARS[last_index]}" )
done
while (( ${#PALETTE[@]} < GLOW_STEPS )); do
  last_index=$(( ${#PALETTE[@]} - 1 ))
  PALETTE+=( "${PALETTE[last_index]}" )
done
ESC=$'\033'
hide_cursor(){ printf '%s[?25l' "$ESC"; }
show_cursor(){ printf '%s[?25h' "$ESC"; }
save_alt(){ tput civis 2>/dev/null || true; printf '%s[?1049h' "$ESC"; }
restore_alt(){ printf '%s[?1049l' "$ESC"; tput cnorm 2>/dev/null || true; }
clear_screen(){ printf '%s[2J%s[H' "$ESC" "$ESC"; }
put_char(){ printf '\033[%d;%dH\033[38;5;%dm%s\033[0m' "$1" "$2" "$3" "$4"; }
get_size(){
  read -r rows cols < <(stty size 2>/dev/null || echo "24 80")
  LINES=${rows:-24}
  COLUMNS=${cols:-80}
}
rand_range(){ local min=$1 max=$2; printf "%d" $(( min + RANDOM % (max - min + 1) )); }
declare -a FX FY VX VY FPHASE FB TTL

get_size

for ((i=0;i<NUM;i++)); do
  FX[i]=$(rand_range 1 "$COLUMNS")
  FY[i]=$(rand_range 1 "$LINES")
  VX[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
  VY[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
  FPHASE[i]=$(( RANDOM % (GLOW_STEPS * 4) ))
  FB[i]=0
  if (( MAX_TTL > MIN_TTL )); then
    TTL[i]=$(rand_range "$MIN_TTL" "$MAX_TTL")
  else
    TTL[i]=$MIN_TTL
  fi
done

respawn(){
  local i=$1
  FX[i]=$(rand_range 1 "$COLUMNS")
  FY[i]=$(rand_range 1 "$LINES")
  VX[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
  VY[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
  FPHASE[i]=$(( RANDOM % (GLOW_STEPS * 4) ))
  FB[i]=0
  if (( MAX_TTL > MIN_TTL )); then
    TTL[i]=$(rand_range "$MIN_TTL" "$MAX_TTL")
  else
    TTL[i]=$MIN_TTL
  fi
}

cleanup(){
  restore_alt
  show_cursor
  clear_screen
  exit
}
trap cleanup INT TERM EXIT

save_alt
hide_cursor
clear_screen

while :; do
  old_lines=$LINES; old_cols=$COLUMNS
  get_size
  if (( LINES != old_lines || COLUMNS != old_cols )); then
    for ((i=0;i<NUM;i++)); do
      (( FX[i] > COLUMNS )) && FX[i]=$COLUMNS
      (( FY[i] > LINES )) && FY[i]=$LINES
    done
    clear_screen
  fi

  clear_screen

  for ((i=0;i<NUM;i++)); do
    if (( RANDOM % MOVE_CHANCE == 0 )); then
      VX[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
      VY[i]=$(( RANDOM % (WANDER*2 + 1) - WANDER ))
    fi

    FX[i]=$(( FX[i] + VX[i] ))
    FY[i]=$(( FY[i] + VY[i] ))
    if (( FX[i] < 1 )); then FX[i]=$COLUMNS; fi
    if (( FX[i] > COLUMNS )); then FX[i]=1; fi
    if (( FY[i] < 1 )); then FY[i]=$LINES; fi
    if (( FY[i] > LINES )); then FY[i]=1; fi

    TTL[i]=$(( TTL[i] - 1 ))
    if (( TTL[i] <= 0 )); then
      respawn "$i"
      continue
    fi
    FPHASE[i]=$(( (FPHASE[i] + (1 + RANDOM % 2)) % (GLOW_STEPS * 4) ))
    p=${FPHASE[i]}; g=$GLOW_STEPS
    if (( p < g )); then
      level=$p
    elif (( p < 2*g )); then
      level=$(( 2*g - p - 1 ))
    else
      level=$(( RANDOM % g ))
    fi
    (( level < 0 )) && level=0
    (( level >= GLOW_STEPS )) && level=$((GLOW_STEPS-1))
    FB[i]=$level

    if (( FB[i] > 0 )); then
      ch=${CHARS[FB[i]]}
      color=${PALETTE[FB[i]]}
      put_char "${FY[i]}" "${FX[i]}" "$color" "$ch"
    fi
  done

  sleep "$DELAY"
done
