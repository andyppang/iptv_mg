#!/usr/bin/env bash
set -e

URL="http://111.230.72.38:1234"
OUT_FILE="live.m3u"

# 抓取源数据
CONTENT=$(curl -sS "$URL")

# 简单假设：每行一个直播地址
echo "#EXTM3U" > "$OUT_FILE"

i=1
while IFS= read -r line; do
  [ -z "$line" ] && continue
  echo "#EXTINF:-1,Channel $i" >> "$OUT_FILE"
  echo "$line" >> "$OUT_FILE"
  i=$((i+1))
done <<< "$CONTENT"
