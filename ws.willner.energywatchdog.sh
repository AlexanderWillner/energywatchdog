#!/bin/bash

# setup ########################################################################
readonly APPS=( 'suggestd' 'AppleSpell' 'Messages' 'Calendar' 'CalendarAgevnt' 'soagent' 'callservicesd' 'airportd' 'cloudphotosd')
readonly SLEEP="${DEBUG_SLEEP:-30}"
readonly MAX="${DEBUG_MAX:-80}"
readonly BATTERY_ONLY="${DEBUG_BATTERY:-1}"
readonly NOTIFY="1"
################################################################################

# main #########################################################################
main() {
  cleanup

  while true; do
    echo "============================================"
    for APP in "${APPS[@]}"; do
      local PID="$(ps u $(pgrep -x "$APP") | tail -1 | awk '{print $2}')"
      local LOAD_NOW="$(ps u $(pgrep -x "$APP") | tail -1 | awk '{print $3}')"
      local LOAD_LAST="$(cat $TMPDIR/EnergyWatchDog_$PID 2>/dev/null || echo 0)"
      local STATUS="OK"
      local POWER="$(pmset -g batt | awk '{printf "%s %s\n", $4,$5;exit}')"

      echo "$LOAD_NOW" >"$TMPDIR/EnergyWatchDog_$PID"

      if (("$(echo "$LOAD_NOW > $MAX" | bc -l)")); then
        STATUS="WATCHING"
        # todo: calculate average load of process over time using multiple measures
        if (("$(echo "$LOAD_LAST > $MAX" | bc -l)")); then
          if [ "$BATTERY_ONLY" = "1" ] && [ "$POWER" != "'Battery Power'" ]; then
            STATUS="DRAINING"
          else
            if [ "$NOTIFY" = "1" ]; then
              osascript -e 'display notification "\"'"$APP"'\" is using significant power. Killing it now..." with title "Energy Watchdog"'
            fi
            kill "$PID"
            sleep 3
            kill -9 "$PID" 2>/dev/null
            STATUS="KILLED"
          fi
        fi
      fi
      echo "$APP: (PID: $PID) (NOW: $LOAD_NOW) (LAST: $LOAD_LAST) (STATUS: $STATUS)"
    done
    echo "============================================"
    sleep "$SLEEP"
  done
}
################################################################################

# cleanup ######################################################################
cleanup() {
  rm "$TMPDIR/"EnergyWatchDog_* 2>/dev/null
}
###############################################################################

# Run script ##################################################################
[[ ${BASH_SOURCE[0]} == "${0}" ]] && trap 'cleanup' EXIT && main "${@:-}"
###############################################################################
