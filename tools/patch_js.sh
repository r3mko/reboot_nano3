#!/bin/sh
set -eu

# Function to update a file and create a backup
update_file() {
  local file="$1"
  shift
  cp "$file" "$file.bak"
  sed -i "$@" "$file"
}

# File paths
OVERVIEW="/mnt/heater/www/html/overview.html"
UPGRADE="/mnt/heater/www/html/upgrade.html"

##############################
# Substitutions for overview.html
##############################

# Chart.js substitution
OLD_CHART_JS='https://cdn.jsdelivr.net/npm/chart.js@4.2.1/dist/chart.umd.min.js'
NEW_CHART_JS='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.2.1/chart.umd.min.js'
CHART_JS_INTEGRITY='sha512-GCiwmzA0bNGVsp1otzTJ4LWQT2jjGJENLGyLlerlzckNI30moi2EQT0AfRI7fLYYYDKR+7hnuh35r3y1uJzugw=='
sub_chart_js="s#\"$OLD_CHART_JS\"#\"$NEW_CHART_JS\" integrity=\"$CHART_JS_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Chartjs Plugin Datalabels substitution
OLD_CHARTJS_PLUGIN='https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2'
NEW_CHARTJS_PLUGIN='https://cdnjs.cloudflare.com/ajax/libs/chartjs-plugin-datalabels/2.2.0/chartjs-plugin-datalabels.min.js'
CHARTJS_PLUGIN_INTEGRITY='sha512-JPcRR8yFa8mmCsfrw4TNte1ZvF1e3+1SdGMslZvmrzDYxS69J7J49vkFL8u6u8PlPJK+H3voElBtUCzaXj+6ig=='
sub_chartjs_plugin="s#\"$OLD_CHARTJS_PLUGIN\"#\"$NEW_CHARTJS_PLUGIN\" integrity=\"$CHARTJS_PLUGIN_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Luxon substitution
OLD_LUXON='https://cdn.jsdelivr.net/npm/luxon@^2'
NEW_LUXON='https://cdnjs.cloudflare.com/ajax/libs/luxon/2.5.2/luxon.min.js'
LUXON_INTEGRITY='sha512-a1S2Hm5CJEfm+1dEJFoFXfvE4Q9D3CiHSF/GBR02ZMkiz40aRXRti0Ht+nMm2nyVpl5AFatAxsBzgvOchLnQ5g=='
sub_luxon="s#\"$OLD_LUXON\"#\"$NEW_LUXON\" integrity=\"$LUXON_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Chartjs Adapter substitution
OLD_CHARTJS_ADAPTER='https://cdn.jsdelivr.net/npm/chartjs-adapter-luxon@^1'
NEW_CHARTJS_ADAPTER='https://cdnjs.cloudflare.com/ajax/libs/chartjs-adapter-luxon/1.3.1/chartjs-adapter-luxon.umd.min.js'
CHARTJS_ADAPTER_INTEGRITY='sha512-I8SeDoNxRKOuQMhqHmx95hydiG/LCY9SFCs3cqAf+f1kIZbAyXXIXIIwgx32ZIgZpOVrEOHSfyjeKxRNIuBvWQ=='
sub_chartjs_adapter="s#\"$OLD_CHARTJS_ADAPTER\"#\"$NEW_CHARTJS_ADAPTER\" integrity=\"$CHARTJS_ADAPTER_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Update overview.html with all substitutions
update_file "$OVERVIEW" \
  -e "$sub_chart_js" \
  -e "$sub_chartjs_plugin" \
  -e "$sub_luxon" \
  -e "$sub_chartjs_adapter"

##############################
# Substitutions for upgrade.html
##############################

# jQuery substitution
OLD_JQUERY='https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js'
NEW_JQUERY='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.slim.min.js'
JQUERY_INTEGRITY='sha512-/DXTXr6nQodMUiq+IUJYCt2PPOUjrHJ9wFrqpJ3XkgPNOZVfMok7cRw6CSxyCQxXn6ozlESsSh1/sMCTF1rL/g=='
sub_jquery="s#\"$OLD_JQUERY\"#\"$NEW_JQUERY\" integrity=\"$JQUERY_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Bootstrap substitution
OLD_BOOTSTRAP='https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js'
NEW_BOOTSTRAP='https://cdnjs.cloudflare.com/ajax/libs/bootstrap/4.6.2/js/bootstrap.bundle.min.js'
BOOTSTRAP_INTEGRITY='sha512-igl8WEUuas9k5dtnhKqyyld6TzzRjvMqLC79jkgT3z02FvJyHAuUtyemm/P/jYSne1xwFI06ezQxEwweaiV7VA=='
sub_bootstrap="s#\"$OLD_BOOTSTRAP\"#\"$NEW_BOOTSTRAP\" integrity=\"$BOOTSTRAP_INTEGRITY\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"#"

# Update upgrade.html with substitutions
update_file "$UPGRADE" \
  -e "$sub_jquery" \
  -e "$sub_bootstrap"
