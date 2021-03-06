#!/bin/sh

# Description:
#   This script generates SVG plots for a specified TestRun by calling
#   fio_generate_plots.sh

function show_usage() {
    echo "Generates SVG plots for a specified TestRun."
    echo "$(basename $0) [-h] [-d logdir]"
    echo "Note: provide '-d' or run directly from it."
}

while getopts :hd: ARGS; do
    case $ARGS in
    h)
        # Help option
        show_usage
        exit 0
        ;;
    d)
        # logdir
        logdir=$OPTARG
        ;;
    "?")
        echo "$(basename $0): unknown option: $OPTARG" >&2
        ;;
    ":")
        echo "$(basename $0): option requires an argument -- '$OPTARG'" >&2
        echo "Try '$(basename $0) -h' for more information." >&2
        exit 1
        ;;
    *)
        # Unexpected errors
        echo "$(basename $0): unexpected error -- $ARGS" >&2
        echo "Try '$(basename $0) -h' for more information." >&2
        exit 1
        ;;
    esac
done

# Use current directory if not specified
: ${logdir:=.}

fio_generate_plots="$(dirname $(which $0))/fio_generate_plots.sh"

# Get paths containing source data
echo "Analyze the directory structure..."
paths=$(ls -d $logdir/*/*/sample*/clients/*/)

# Lock
lockfile=$logdir/generate_pbench_fio_plots.lock
if [ ! -e $lockfile ]; then
    echo $$ >$lockfile || exit 1
    echo "$(basename $0): INFO: Locked with: $lockfile" >&2
else
    echo "$(basename $0): ERROR: Lockfile exists: $lockfile" >&2
    exit 1
fi

# Generate plots
for path in $paths; do
    pushd $path &>/dev/null
    echo -e "\nGenerating plots in $(pwd)..."
    $fio_generate_plots fio 2>/dev/null
    popd &>/dev/null
done

# Unlock
rm -rf $lockfile && echo "$(basename $0): INFO: Unlocked: $lockfile" >&2

exit 0
