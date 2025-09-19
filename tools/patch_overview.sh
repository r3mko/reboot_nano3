#!/bin/sh
set -eu

FILE="/mnt/heater/www/html/overview.html"

# Backup before modifying
cp "$FILE" "$FILE.bak.$(date +%F_%H-%M-%S)"

# Apply sed replacements
sed -i \
  -e 's|<ul class="menu-ch">|<ul class="menu-ch" style="display: none;">|' \
  -e 's|<div class="switch"><span switchid="fan_all" onclick="fanSwitch(this);">RPM</span>&nbsp;/<span|<!-- <div class="switch"><span switchid="fan_all" onclick="fanSwitch(this);">RPM</span>&nbsp;/<span|' \
  -e 's|switchid="fan_speed" onclick="fanSwitch(this);">%</span></div>|switchid="fan_speed" onclick="fanSwitch(this);">%</span></div> -->|' \
  -e 's|<div id="temp_show" style="display: block;">|<div id="temp_show" style="height: 100%; width: 100%; display: flex; flex-direction: column; justify-content: center;">|' \
  -e 's|<div id="tempf_show" style="display: none;">|<div id="tempf_show" style="height: 100%; width: 100%; display: none; flex-direction: column; justify-content: center;">|' \
  -e 's|<div class="title">Elapsed</div>|<div class="title">Uptime</div>|' \
  -e 's|\$("temp_show").style.display = "block";|\$("temp_show").style.display = "flex";|' \
  -e 's|\$("tempf_show").style.display = "block"|\$("tempf_show").style.display = "flex"|' \
  -e 's|var fan2 = req.fan2;|var fan2 = req.fanr;|' \
  -e 's|\$("fan1").innerHTML = fan1;|\$("fan1").innerHTML = fan1 + " RPM";|' \
  -e 's|\$("fan2").innerHTML = fan2;|\$("fan2").innerHTML = fan2 + "%";|' \
  "$FILE"

echo "Changes applied. Backup saved as $FILE.bak.$(date +%F_%H-%M-%S)"
