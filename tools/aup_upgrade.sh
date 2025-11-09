#!/bin/sh

# Hint:
# cpio -idmv < ../heater_nano3_all_2025103101_151231.swu
# ubireader_extract_files app_a.ubi

# Trigger btcminer
echo "Updating K210..."
cp APP_25103101_b906c52_1733f44.aup /data/upgrade_aup && killall -USR1 btcminer
sleep 60

# Wait for the K210 microcontroller to finish writing its flash
echo "Update in progress..."
sleep 30

printf "[ OK ]\n\n"
(
  echo '{"command":"version"}'
  sleep 1
) | telnet 127.0.0.1 4028 2>/dev/null \
  | grep -E '^\{|\[|[A-Za-z0-9]:' \
  | tr -d '\r' \
  | sed -e 's/\[/\n[/g' \
        -e 's/\]/]\n/g' \
        -e 's/,/,\n/g'

exit 0
