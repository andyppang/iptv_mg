#!/usr/bin/env bash
set -e

URL="http://111.230.72.38:1234"
OUT_FILE="live.m3u"

# 下载完整源
CONTENT=$(curl -sS "$URL")

# 要保留的 group 关键词（直播）
KEEP_GROUPS=('央视' '卫视' '地方' '影视' '少儿' '教育' '纪实' '熊猫')

# 要丢弃的 group 关键词（回放/预告等）
DROP_GROUPS=('体育-昨天' '体育-明天')

echo '#EXTM3U x-tvg-url="http://111.230.72.38:1234/playback.xml" catchup="append" catchup-source="?playbackbegin=${(b)yyyyMMddHHmmss}&playbackend=${(e)yyyyMMddHHmmss}"' > "$OUT_FILE"

keep_pair=false
last_extinf=""

while IFS= read -r line; do
  # 跳过空行
  [[ -z "$line" ]] && continue

  # 跳过源里的原始 #EXTM3U 行
  if [[ "$line" == \#EXTM3U* ]]; then
    continue
  fi

  # 处理 EXTINF 行
  if [[ "$line" == \#EXTINF* ]]; then
    keep_pair=false

    # 先丢弃有 DROP_GROUPS 关键字的
    for g in "${DROP_GROUPS[@]}"; do
      if [[ "$line" == *"group-title=\"$g\""* ]]; then
        keep_pair=false
        last_extinf=""
        continue 2   # 直接读下一行
      fi
    done

    # 再判断是否属于 KEEP_GROUPS
    for g in "${KEEP_GROUPS[@]}"; do
      if [[ "$line" == *"group-title=\"$g\""* ]]; then
        keep_pair=true
        last_extinf="$line"
        break
      fi
    done

    continue
  fi

  # 如果当前行是 URL 且上一条 EXTINF 被标记为 keep，就写入
  if [[ "$line" == http* ]] && $keep_pair && [[ -n "$last_extinf" ]]; then
    echo "$last_extinf" >> "$OUT_FILE"
    echo "$line"       >> "$OUT_FILE"
    keep_pair=false
    last_extinf=""
    continue
  fi

done <<< "$CONTENT"
