#!/usr/bin/env bash
set -euo pipefail

# 실행 디렉터리: ~/chipyard/sims/verilator (가정)
BIN_SW=~/chipyard/generators/sha3/software/tests/bare/sha3-sw.riscv

TS=$(date +%Y%m%d-%H%M%S)
OUT=./sha3_compare_$TS
mkdir -p "$OUT"


make run-binary CONFIG=RocketConfig BINARY="$BIN_SW" | tee "$OUT/sw.log"

sw=$(cat "$OUT/sw.cycs")

echo "완료. 로그: $OUT/sw.log"
