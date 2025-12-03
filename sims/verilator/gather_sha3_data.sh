#!/usr/bin/env bash
set -euo pipefail

OUT="combined_sha3_speed.csv"

# 136 × 2^0 .. 136 × 2^12 (마지막 557056)
# 첫 번째로 존재하는 파일에서 헤더(1행)를 가져와 출력 파일 헤더 생성
: > "$OUT"
for p in {0..12}; do
  dir=$((136 << p))
  f="${dir}/sha3_speed.csv"
  if [[ -f "$f" ]]; then
    header=$(sed -n '1p' "$f")
    echo "size,${header}" > "$OUT"
    break
  fi
done

# 각 폴더의 2행 데이터를 모아 size 컬럼과 함께 기록
for p in {0..12}; do
  dir=$((136 << p))
  f="${dir}/sha3_speed.csv"
  if [[ -f "$f" ]]; then
    line=$(sed -n '2p' "$f")
    # CRLF 대비 (\r 제거)
    line=${line%%$'\r'}
    echo "${dir},${line}" >> "$OUT"
  else
    echo "WARN: missing file: $f" >&2
  fi
done

echo "✅ Saved: ${OUT}"

