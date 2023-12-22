#!/usr/bin/env bash

VERSION=1.0

usage() {
    cat<<EOF
Usage: ${0} [OPTION]... [PATH]
Renames files under PATH

PATH can be a single FILE. If that is the case
then only that FILE is renamed and the --recursive
OPTION makes no sense.
If no PATH is provided, use the working directory.

If the script is not performing a --dry-run and there are
renames, then the program outputs a log of the operation
in the working directory named: normief.log

   -d, --dry-run        Do not perform the renaming, but print out the
                        files that will be renamed.

   -r, --recursive      Rename all files in all directories under PATH

   -h, --help           display this help and exit

   -f, --files-from=*   Mostly for testing purposes for now, DO NOT USE

   -v, --version        Output version information and exit

EOF
}

# Options
recursive=false
dryrun=false
filesfrom=
# Positional arguments
filepath=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"
    parse_posargs "$@"

    outd=$(mktemp -d)

    if [ -n "$filesfrom" ]; then
        cat "$filesfrom" > ${outd}/input
    elif [ -f "$filepath" ]; then
        find "$filepath" -type f -fprint ${outd}/input
    elif [ "$recursive" == "true" ]; then
        find "$filepath" -mindepth 1 -type f -fprint ${outd}/input
    else
        find "$filepath" -mindepth 1 -maxdepth 1 -type f -fprint ${outd}/input
    fi

    sed 's/\/[][^[:blank:]\/,#!$%&*;:{}|()~`"=]/_/g' ${outd}/input \
        | tr [:upper:] [:lower:] \
        | tr -s \' _ \
        | sed 's/[._+-]\{2,\}/_/g' \
        | sed 's/^[^[:alnum:]/]*//' \
        | sed 's/[^[:alnum:]/]*$//' \
        | sed '/^[[:space:]]*$/d' > ${outd}/out

    total_input=$(wc -l ${outd}/input | cut -d' ' -f1)
    total_out=$(wc -l ${outd}/out | cut -d' ' -f1)

    if [ $total_input -gt $total_out ]; then
        echo "$0: Refusing to procceed as filenames got truncated"
        echo "$0: input -> $(quote $total_input)"
        fatal "output -> $(quote $total_out)"
    fi

    readarray -t outs < ${outd}/out
    declare -i i=0

    if [ $dryrun == "true" ]; then
        while read -r line; do
            if [ ! -f "${outs[i]}" ]; then
                echo from: "$line"
                echo to: "${outs[i]}"
            fi
            ((i++))
        done < ${outd}/input
    else
        while read -r line; do
            if [ ! -f "${outs[i]}" ]; then
                echo from: "$line" >> normief.log
                echo to: "${outs[i]}" >> normief.log
                mv "$line" "${outs[i]}"
            fi
            ((i++))
        done < ${outd}/input
    fi

    rm -rf $outd
}

parse_posargs() {
    local _filepath="${1:-$(pwd)}"
    filepath="$(realpath -e "$_filepath" 2>/dev/null)"

    if [ -z "$filepath" ]; then
        fatal "Could not locate filepath $(quote $_filepath)"
    fi
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -f* | --files-from=* | --files-from*)
                filesfrom="$(parse_param "$@")" || shift $?
                ;;
            -r | --recursive)
                recursive=true
                ;;
            -d | --dry-run)
                dryrun=true
                ;;
            -D | --debug)
                DEBUG=1
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -v | --version)
                echo $VERSION
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="${1:-}"
                shift
                local rest="$@"
                set --
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "$@" "-$i"
                done
                set -- $@ $rest
                continue
                ;;
            --)
                shift
                POSARGS+=("$@")
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                fatal "Unrecognized argument ${1:-}"
                ;;
            *)
                POSARGS+=("${1:-}")
                ;;
        esac
        shift
    done
}

parse_param() {
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi

    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        fatal "${param:-$1} requires an argument"
    fi

    echo "${arg:-}"
    return $toshift
}

quote() {
    echo \'"$@"\'
}

debug() {
    [ ! $DEBUG ] && return
    echo "$@" >&2
}

fatal() {
    echo $0: "$@" >&2
    exit 1
}

main "$@"
