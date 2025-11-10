#!/bin/sh

TMP_LOG_DIR="/tmp/zlog"
LOG_DIR="/data/log"
CONF="/mnt/heater/confiles/zlog.conf"

# Ensure /tmp/zlog exists before creating the symlink
mkdir -p "$TMP_LOG_DIR"

# Check if /data/log is not a symlink
if [ ! -L "$LOG_DIR" ]; then
  rm -rf "$LOG_DIR"
  ln -s "$TMP_LOG_DIR" "$LOG_DIR"
fi

# Comment the old line
sed -i 's|^\(my_cat.INFO[[:space:]]\+"/data/log/run.log".*\)|#\1|' "$CONF"

# Add the new line
grep -q '/tmp/zlog/run.log' "$CONF" || echo 'my_cat.INFO    "/tmp/zlog/run.log",2MB*2; simple' >> "$CONF"
