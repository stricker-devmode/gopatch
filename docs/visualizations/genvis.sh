#!/usr/bin/env bash

log() {
    # $1: loglevel
    # $2: message
    local level msg
    if [ $# -eq 0 ]; then
        level="ERROR"
        msg="Unknown error"
    elif [ $# -eq 1 ]; then
        level="INFO"
        msg="$1"
    else
        case "$1" in
            e|err|error) level="ERROR";;
            w|warn|warning) level="WARNING";;
            i|info) level="INFO";;
            d|debug) level="DEBUG";;
            *) level="$1";;
        esac
        shift
        msg="$*"
    fi
    printf "$0 | %7s :: %s\n" "$level" "$msg"
}

main() {
    # $1: structure to generate a visualization for
    # $2: output file
    if [ $# -ne 2 ]; then
        log e "This program requires exactly 2 arguments."
        exit 1
    fi

    local struct element output line replacement
    declare -A arr_helptxt
    struct="$1"
    output="$2"
    if [ -f "$output" ]; then
        rm "$output"
    fi
    
    log "Analyzing structure"
    while read -r f; do
        if [ -f "$f" ]; then
            arr_helptxt["$f"]="$(cat "$f")"
        elif [ -d "$f" ]; then
            [ -f "$f/.help.txt" ] && arr_helptxt["$f"]="$(cat "$f/.help.txt")"
        fi
    done < <(find "$struct" ! -iname ".*")

    log "Generating tree view"
    while IFS= read -r line; do
        element="$(awk '{print $NF}' <<<"$line")"
        if [ -n "${arr_helptxt["$element"]}" ]; then
            # Can't use / as expression delimiter sinde we're working on fs paths
            replacement="$(sed -E "s|^(.*)\.(.*)$|\1 \`(\2)\`: ${arr_helptxt["$element"]}|g" <<<"${element##*/}")"
        else
            replacement="$(sed -E "s|^(.*)\.(.*)$|\1 \`(\2)\`|g" <<<"${element##*/}")"
        fi
        sed -E "s|${element}|${replacement}|g" <<<"$line" >> "$output"
    done < <(tree --filesfirst -f "$struct" | head -n-2)
    log "Output can be found here: $output"
}

main "$@"
