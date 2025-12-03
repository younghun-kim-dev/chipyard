#!/usr/bin/env bash
set -euo pipefail

# 실행 디렉터리: ~/chipyard/sims/verilator (가정)
BIN_HW=~/chipyard/generators/sha3/software/tests/bare/sha3-rocc.riscv
BIN_SW=~/chipyard/generators/sha3/software/tests/bare/sha3-sw.riscv

TS=$(date +%Y%m%d-%H%M%S)
OUT=./sha3_compare_$TS
mkdir -p "$OUT"

echo "[1/3] HW(RoCC) 실행..."
make run-binary CONFIG=Sha3RocketL2TuneConfig BINARY="$BIN_HW" | tee "$OUT/hw.log"

echo "[2/3] SW(가속기 미사용) 실행..."
make run-binary CONFIG=Sha3RocketL2TuneConfig BINARY="$BIN_SW" | tee "$OUT/sw.log"

echo "[3/3] 사이클/속도비 계산 → CSV"
awk '/SHA execution took/{print $4; exit}' "$OUT/hw.log" > "$OUT/hw.cycs"
awk '/SHA execution took/{print $4; exit}' "$OUT/sw.log" > "$OUT/sw.cycs"

hw=$(cat "$OUT/hw.cycs")
sw=$(cat "$OUT/sw.cycs")

if command -v bc >/dev/null 2>&1; then
  ratio=$(echo "scale=6; $sw / $hw" | bc)
else
  ratio=$(awk -v s="$sw" -v h="$hw" 'BEGIN{if(h>0) printf "%.6f", s/h; else print "NaN"}')
fi

printf "hw_cycles,sw_cycles,speedup_sw_over_hw\n%s,%s,%s\n" "$hw" "$sw" "$ratio" > "$OUT/sha3_speed.csv"

echo "완료. 로그: $OUT/hw.log , $OUT/sw.log"
echo "CSV : $OUT/sha3_speed.csv"

