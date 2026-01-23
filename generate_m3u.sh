#!/usr/bin/env bash
set -e

URL="http://111.230.72.38:1234"
OUT_FILE="live.m3u"

# 直接把远端 m3u 原样保存到本地
curl -sS "$URL" -o "$OUT_FILE"
