#!/usr/bin/env bash
set -e

URL="http://111.230.72.38:1234"
OUT_FILE="live.m3u"
MAP_FILE="channels.txt"

CONTENT=$(curl -sS "$URL")

echo "#EXTM3U" > "$OUT_FILE"

get_name() {
  local url="$1"
  local name="未命名频道"

  while IFS='|' read -r cname key; do
    # 跳过空行和注释
    [[ -z "$cname" || "$cname" =~ ^# ]] && continue
    if [[ "$url" == *"$key"* ]]; then
      name="$cname"
      break
    fi
  done < "$MAP_FILE"

  echo "$name"
}

while IFS= read -r line; do
  [ -z "$line" ] && continue
  cname=$(get_name "$line")
  echo "#EXTINF:-1,${cname}" >> "$OUT_FILE"
  echo "$line" >> "$OUT_FILE"
done <<< "$CONTENT"
