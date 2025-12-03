# ~/chipyard/sims/verilator/ws_os_sweep_by_header.sh

#!/usr/bin/env bash
set -euo pipefail

CONFIG=GemminiLargeBoomV4Config
MAXCYC=20000000000

SIMDIR=~/chipyard/sims/verilator
TESTDIR=~/chipyard/generators/gemmini/software/gemmini-rocc-tests
PARAM_H="${TESTDIR}/bareMetalC/include/ws_os_user_params.h"
BIN="${TESTDIR}/build/bareMetalC/ws_os_threshold-baremetal"

# 안전 체크
[[ -d "${TESTDIR}" ]] || { echo "ERR: TESTDIR missing: ${TESTDIR}"; exit 1; }
[[ -f "${TESTDIR}/build.sh" ]] || { echo "ERR: build.sh missing"; exit 1; }

# Chipyard env
if [ -f ~/chipyard/env.sh ]; then
  # shellcheck disable=SC1091
  source ~/chipyard/env.sh
fi

MN_LIST=("8x8")
K_LIST=(1 2 3 4 8)

mkdir -p "${SIMDIR}/out_wsos"
cd "${SIMDIR}"

for mn in "${MN_LIST[@]}"; do
  IFS='x' read -r M N <<< "${mn}"
  for K in "${K_LIST[@]}"; do
    echo "===== CASE M=${M} N=${N} K=${K} ====="

    # 1) 헤더 갱신 (빌드태그 포함)
    cat > "${PARAM_H}" <<EOF
#pragma once
#define USER_M ${M}
#define USER_N ${N}
#define USER_K ${K}
#define BUILD_TAG "M${M}N${N}K${K}"
EOF

    # 2) 반드시 bareMetalC에서 clean → 그 다음에 최상위에서 ./build.sh
    ( cd "${TESTDIR}/bareMetalC" && make clean || true )

    # 혹시 이전 산출물이 남아 재사용되는 걸 방지 (강제 재빌드)
    rm -rf "${TESTDIR}/build/bareMetalC/ws_os_threshold-baremetal"* || true

    # 요구사항대로: 최상위에서 build.sh 실행
    ( cd "${TESTDIR}" && echo "[CWD for build.sh] $(pwd)" && ./build.sh )

    # 3) 새 프로세스로 Verilator 실행
    OUT="${SIMDIR}/out_wsos/M${M}_N${N}_K${K}"
    mkdir -p "${OUT}"
    make CONFIG="${CONFIG}" run-binary-hex MAX_CYCLES="${MAXCYC}" \
         BINARY="${BIN}" | tee "${OUT}/run.log"

    # 4) 확인용 요약 (헤더가 반영됐는지 BUILD_TAG 체크)
    grep -E 'BUILD_TAG=|^\[M=' "${OUT}/run.log" || true
  done
done

echo "All done."

