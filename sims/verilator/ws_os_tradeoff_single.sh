#!/usr/bin/env bash
set -euo pipefail

# 경로
ROOT="${HOME}/chipyard/generators/gemmini/software/gemmini-rocc-tests"
SRC="${ROOT}/bareMetalC/ws_os_single.c"
BIN="${ROOT}/build/bareMetalC/ws_os_single-baremetal"
SIM="${HOME}/chipyard/sims/verilator"

# 돌릴 값들(원하는 값으로 수정)
DFSET=(WS OS)     # 예: (OS) 만 돌리려면 DFSET=(OS)
MSET=(8 16 24 32 64 128)
NSET=(8 16 24 32 64 128 256)
KSET=(16 64 256 512)

# 로그/CSV
OUT_DIR="${SIM}/out-sweep-$(date +%Y%m%d-%H%M%S)"
mkdir -p "${OUT_DIR}"
CSV="${OUT_DIR}/results.csv"
echo "DF,M,N,K,cycles,MACper100,sumC" > "${CSV}"

for DF in "${DFSET[@]}"; do
  for M in "${MSET[@]}"; do
    for N in "${NSET[@]}"; do
      for K in "${KSET[@]}"; do
        TAG="${DF}_${M}x${N}x${K}"
        echo "[CASE] ${TAG}"

        # 1) single.c의 ONE_M/N/K/DATAFLOW 정의를 직접 수정
        sed -i -E "s/^[[:space:]]*#define[[:space:]]+ONE_M[[:space:]]+[0-9]+/#define ONE_M ${M}/" "${SRC}"
        sed -i -E "s/^[[:space:]]*#define[[:space:]]+ONE_N[[:space:]]+[0-9]+/#define ONE_N ${N}/" "${SRC}"
        sed -i -E "s/^[[:space:]]*#define[[:space:]]+ONE_K[[:space:]]+[0-9]+/#define ONE_K ${K}/" "${SRC}"
        sed -i -E "s/^[[:space:]]*#define[[:space:]]+DATAFLOW[[:space:]]+(WS|OS)/#define DATAFLOW ${DF}/" "${SRC}"

        # 2) 빌드 (build.sh만 호출)
        ( cd "${ROOT}" && ./build.sh > "${OUT_DIR}/build_${TAG}.log" 2>&1 )

        # 3) Verilator 실행
        LOG="${OUT_DIR}/run_${TAG}.log"
        make -C "${SIM}" CONFIG=GemminiRocketConfig run-binary-hex \
          BINARY=../../generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/ws_os_single-baremetal \
          > "${LOG}" 2>&1 || true

        # 4) 결과 파싱 → CSV
        line="$(grep -E 'warmups=.*\| cycles=' "${LOG}" || true)"
        if [[ -n "${line}" ]]; then
          cyc="$(sed -nE 's/.*cycles=([0-9]+).*/\1/p' <<<"${line}")"
          mac100="$(sed -nE 's/.*MAC\/100cyc=([0-9]+).*/\1/p' <<<"${line}")"
          sumC="$(sed -nE 's/.*sum\(C\)=(-?[0-9]+).*/\1/p' <<<"${line}")"
          echo "${DF},${M},${N},${K},${cyc},${mac100},${sumC}" | tee -a "${CSV}" >/dev/null
        else
          echo "${DF},${M},${N},${K},,,," | tee -a "${CSV}" >/devnull
          echo "  ↳ 로그 확인: ${LOG}"
        fi
      done
    done
  done
done

echo "CSV: ${CSV}"

