#!/usr/bin/env bash
set -eo pipefail

CONFIG="GemminiLargeBoomV4Config"
MAXCYC="20000000000"

# 실험 조합
MN_LIST=("4x4" "6x6" "8x8" "10x10" "12x12" "4x8" "4x12" "6x10" "8x12" "8x4" "12x4" "10x6" "12x8")
K_LIST=(1 2 3 4 5 6 7 8)

# 경로들
SIMDIR=~/chipyard/sims/verilator
TESTDIR=~/chipyard/generators/gemmini/software/gemmini-rocc-tests
C_FILE="${TESTDIR}/bareMetalC/ws_os_threshold.c"
BIN_ABS="${TESTDIR}/build/bareMetalC/ws_os_threshold-baremetal"
OUTBASE="${SIMDIR}/out_wsos_editc"

# Chipyard env (필요시)
if [ -f ~/chipyard/env.sh ]; then source ~/chipyard/env.sh; fi

# 방어 체크
[[ -d "$TESTDIR" ]] || { echo "ERR: TESTDIR not found: $TESTDIR"; exit 1; }
[[ -f "$C_FILE"  ]] || { echo "ERR: C source not found: $C_FILE"; exit 1; }
[[ -f "${TESTDIR}/build.sh" ]] || { echo "ERR: build.sh missing in $TESTDIR"; exit 1; }

mkdir -p "$OUTBASE"
cd "$SIMDIR"

# ★ 추가: 전체 집계 CSV 두 개 초기화
SUMMARY_CSV="${OUTBASE}/summary.csv"
LINES_CSV="${OUTBASE}/lines.csv"
echo "M,N,K,CPU_cyc,ACC_flow,ACC_cyc,Speedup_x,Offload" > "$SUMMARY_CSV"
echo "HeaderLine,ResultLine" > "$LINES_CSV"

# 원본 백업/복구
BACKUP="${C_FILE}.bak.$(date +%s)"
cp "$C_FILE" "$BACKUP"
trap 'cp "$BACKUP" "$C_FILE" 2>/dev/null || true' EXIT

# M/N/K 교체 함수 (C 코드만 수정)
patch_defines() {
  local M="$1" N="$2" K="$3"
  sed -i -E "s|^#define[[:space:]]+M_FIXED[[:space:]]+.*$|#define M_FIXED ${M}|" "$C_FILE"
  sed -i -E "s|^#define[[:space:]]+N_FIXED[[:space:]]+.*$|#define N_FIXED ${N}|" "$C_FILE"
  sed -i -E "s|^static[[:space:]]+const[[:space:]]+int[[:space:]]+KSET\\[\\][[:space:]]*=\\s*\\{[^}]*\\};|static const int KSET[] = {${K}};|" "$C_FILE"
}

for mn in "${MN_LIST[@]}"; do
  IFS='x' read -r M N <<< "$mn"
  for K in "${K_LIST[@]}"; do
    # 1) C 파일 값 갱신
    patch_defines "$M" "$N" "$K"

    # 2) 빌드: 완전 조용히(로그 없음)
    ( cd "${TESTDIR}/bareMetalC" && make clean >/dev/null 2>&1 || true )
    rm -f "${BIN_ABS}"* >/dev/null 2>&1 || true
    ( cd "${TESTDIR}" && ./build.sh >/dev/null 2>&1 )
    [ -f "${BIN_ABS}" ] || { echo "ERR: build failed: ${BIN_ABS}"; exit 1; }

    # 3) 실행: 화면에는 헤더/결과 두 줄만, 전체 로그는 run.log 저장
    OUTDIR="${OUTBASE}/M${M}_N${N}_K${K}"
    mkdir -p "$OUTDIR"
    make CONFIG="${CONFIG}" run-binary-hex MAX_CYCLES="${MAXCYC}" \
         BINARY="${BIN_ABS}" \
    | tee "${OUTDIR}/run.log" \
    | awk '/^== Offloading threshold sweep|^\[K=/{print}'

    # ★ 추가: 케이스 결과를 CSV 두 개에 누적
    # summary.csv — 정형 데이터
    awk -v OFS=',' '
      BEGIN{M="";N="";k="";cpu="";flow="";acc="";sp="";off=0}
      /^== Offloading threshold sweep/ {
        if (match($0,/M=([0-9]+), N=([0-9]+)/, a)) { M=a[1]; N=a[2]; }
      }
      /^\[K=/ {
        if (match($0, /\[K=\s*([0-9]+)\]/, a)) k=a[1];
        if (match($0, /CPU:\s*([0-9]+)/, b)) cpu=b[1];
        if (match($0, /ACC\((WS|OS)\):\s*([0-9]+)/, c)) { flow=c[1]; acc=c[2]; }
        if (match($0, /speedup=\s*([0-9.]+)/, d)) sp=d[1];
        off = (/[<]- OFFLOAD/ ? 1 : 0);
      }
      END{ if (M!="") print M,N,k,cpu,flow,acc,sp,off; }
    ' "${OUTDIR}/run.log" >> "${SUMMARY_CSV}"

    # lines.csv — 원본 두 줄 그대로
    awk '
      BEGIN{hdr="";res=""}
      /^== Offloading threshold sweep/ { if (hdr=="") hdr=$0 }
      /^\[K=/ { if (res=="") res=$0 }
      END{
        gsub(/"/, "\"\"", hdr); gsub(/"/, "\"\"", res);
        print "\"" hdr "\",\"" res "\"";
      }
    ' "${OUTDIR}/run.log" >> "${LINES_CSV}"

  done
done

