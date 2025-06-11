!/usr/bin/env bash
source ./ansi-lib/ansi-lib.sh
onKey() {
    setupfn="$1";    shift;
    stepfn="$1";     shift;
    exitfn="$1";     shift;
    initRenderfn="$1"; shift;
    renderfn="$1";   shift;
    initState="$1";  shift;
    [[ -z $setupfn ]] && state="$initState" || state="$($setupfn "initState")"
    readCursorPosition pos; printf "\e[1;1$CUP""\e[$ELA""State"": $state""\e[$pos$CUP";
    [[ -z $initRenderfn ]] || $initRenderfn "$state"
    while ! $exitfn "$state"; do
        $renderfn "$state"
        read -s -n 1 input
        state=$($stepfn "$state" "$input")
        readCursorPosition pos; printf "\e[1;1$CUP""\e[$ELA""State"": \"$state\"""\e[$pos$CUP";
    done
}
chooseStep() {
    eval $1;
    case $2 in
        ${state[2]}) state[1]="$((${state[1]} - 1))"; echo "$(declare -p state)";;
        ${state[3]}) state[1]="$((${state[1]} + 1))"; echo "$(declare -p state)";;
        "") printf "${state[1]}";;
    esac;
    }
chooseExit() { [[ $1 =~ ^[0-9]+$ ]]; finished="$?"; [[ $finished == 0 ]] && clear && echo $1; return $finished; }
chooseRender() {
    eval $1;
    printf "\e[3;0$CUP";
    i=0;
    for c in ${state[0]}; do
        printf "\e[$ELE";
        [[ $i == ${state[1]} ]] && printf '* ';
        echo $c; i=$((i + 1));
    done
}
chooseRenderInit() { clear; }
state=( 'a b c' 0 r n )
onKey "" chooseStep chooseExit chooseRenderInit chooseRender "$(declare -p state)"
