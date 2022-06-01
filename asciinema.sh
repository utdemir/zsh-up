#!/usr/bin/env bash

set -o errexit

tmpdir="$(mktemp -d)"
trap "rm -rf '$tmpdir'" EXIT

TMUX="tmux -S $tmpdir/tmux.sock"
echo "$TMUX attach -r"
$TMUX new-session -d
sleep 5

function ty {
    sl="$1"
    arg="$2"
    echo "Type : $arg" >&2
    for (( i=0; i<${#arg}; i++ )); do
        chr="${arg:$i:1}"
        sleep "$sl"
        $TMUX send-keys "$chr"
    done
}

function pr {
    arg="$@"
    echo "Press: $arg" >&2
    for key in $*; do
        sleep 0.06
        $TMUX send-keys "$key"
    done
}

$TMUX resize-window -x 100 -y 20
sleep 1
$TMUX send-keys "asciinema rec \"$tmpdir/demo.cast\"" ENTER
sleep 2

ty 0.03 ": After a command, press Ctrl+U to call up" 
pr ENTER
sleep 1

ty 0.03 "curl -s 'wttr.in/Auckland?format=j1' | "
sleep 1

pr C-u
sleep 3

ty 0.05 "jq 'keys'"
sleep 1

pr LEFT BSPACE BSPACE BSPACE BSPACE 
ty 0.05 ".weather"
sleep 1

ty 0.1 "[]"
sleep 1
ty 0.05 " | keys"
sleep 3

pr BSPACE BSPACE BSPACE BSPACE
ty 0.05 ".date"
sleep 1
pr LEFT LEFT LEFT LEFT LEFT
ty 0.3 '"\('
pr RIGHT RIGHT RIGHT RIGHT RIGHT
ty 0.3 ')"'

sleep 2

pr LEFT
ty 0.05 "\t\(.astronomy)"
sleep 2

pr RIGHT RIGHT
ty 0.1 " -r"
pr LEFT LEFT LEFT LEFT LEFT
sleep 1

pr LEFT
ty 0.1 "[]"
sleep 1

ty 0.05 ".sunrise"
sleep 1
pr RIGHT
ty 0.05 "\t\(.astronomy[].sunset)"
sleep 1

pr C-x
sleep 2

pr ENTER

sleep 5

ty 0.1 "exit" 
pr ENTER

$TMUX kill-session

asciinema upload "$tmpdir/demo.cast"