#!/bin/sh

# Hint:
# cpio -idmv < ../heater_nano3_all_2025103101_151231.swu
# ubireader_extract_files app_a.ubi

echo "$(date) Updating K210..."
cp APP_25103101_b906c52_1733f44.aup /data/upgrade_aup
killall -10 btcminer
sleep 60

echo "$(date) Update in progress..."
# Wait for the K210 microcontroller to finish writing its flash
sleep 30

echo "$(date) OK!"
exit 0
