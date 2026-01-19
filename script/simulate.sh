#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "simulate.sh needs the name of a toplevel testbench module!"
    exit 1
fi

top_dir="${PWD##*/}"
cpu_dir="$(pwd)/cpu"

case "$top_dir" in
    script)
        cd ..
        ;;
    *)
        if [ -d "rtl" ]; then
            :
        else
            echo "simulate.sh needs to run from either the base dir or the script dir!"
            exit 1
        fi
        ;;
esac

tmp="$(pwd)/tmp"
traces="$(pwd)/traces"

rtl="$(pwd)/rtl"

mkdir -p "$tmp"
rm -rf "$tmp"/*

mkdir -p "$traces"
rm -rf "$traces"/*

# find testbench and other files
testbench_module="$1"
files_sv=$(find "$rtl" \( -name "*.sv" -o -name "*.v" \))

verilator_version=$(verilator --version)
printf "\n === %s ===\n\n" "$verilator_version"

# flags for verilator
verilator_flags="-O3 --trace --timing --binary --top-module $testbench_module -I$rtl"
warn_options="--assert -Wno-fatal -Werror-USERERROR -Werror-USERFATAL"

# run verilator
cd "$tmp"
verilator $verilator_flags $warn_options $files_sv > "$tmp/verilator.log"

# generate trace file
cd "$traces"
"$tmp/obj_dir/V$testbench_module"

# run gtkwave
cd ..
gtkwave -A --rcvar 'fontname_signals monaspace_xenon 13' --rcvar 'fontname_waves Monospace 12' "$traces/waveform.vcd"

exit 0
