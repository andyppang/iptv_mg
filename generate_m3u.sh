#!/usr/bin/env bash
set -e

URL="http://111.230.72.38:1234"
OUT_FILE="live.m3u"

# 抓取完整 m3u 内容
CONTENT=$(curl -sS "$URL")

# 写入带 EPG 的头部（从源文件第一行抄过来）
echo '#EXTM3U x-tvg-url="http://111.230.72.38:1234/playback.xml" catchup="append" catchup-source="?playbackbegin=${(b)yyyyMMddHHmmss}&playbackend=${(e)yyyyMMddHHmmss}"' > "$OUT_FILE"

# 标记：上一行是否是我们要的 EXTINF
last_extinf=""

while IFS= read -r line; do
  # 去掉两侧空白
  line="${line%%[[:space:]]*}"
  [ -z "$line" ] && continue

  # 跳过原文件里的第一个 #EXTM3U（我们已经自己写过头了）
  if [[ "$line" == \#EXTM3U* ]]; then
    continue
  fi

  # 如果是带 tvg-id/tvg-name 的 EXTINF 行，就记录下来，等下一行 URL 用
  if [[ "$line" == \#EXTINF* ]]; then
    # 只保留带 tvg-id 的那种行，避免像 "#EXTINF:-1,CCTV1综合" 这种重复
    if [[ "$line" == *'tvg-id='* ]]; then
      last_extinf="$line"
    else
      # 不带 tvg-id 的简单 EXTINF 直接忽略，由带元数据的那行负责
      continue
    fi
    continue
  fi

  # 如果是 URL 且有上一次记录的 EXTINF，就输出成一对
  if [[ "$line" == http* ]] && [[ -n "$last_extinf" ]]; then
    echo "$last_extinf" >> "$OUT_FILE"
    echo "$line"       >> "$OUT_FILE"
    last_extinf=""
    continue
  fi

done <<< "$CONTENT"
