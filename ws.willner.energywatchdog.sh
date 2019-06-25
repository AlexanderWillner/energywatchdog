#!/bin/bash

# setup ########################################################################
APPS=( 'suggestd' 'AppleSpell' 'Messages' 'Calendar' 'CalendarAgevnt' 'soagent' 'callservicesd' 'airportd' 'cloudphotosd')
SLEEP="30"
MAX="80.0"
BATTERY_ONLY="1"
################################################################################

# main #########################################################################
main() {
  cleanup

  while true; do
    echo "============================================"
    for APP in "${APPS[@]}"; do
      PID="$(ps u $(pgrep -x "$APP") | tail -1 | awk '{print $2}')"
      LOAD_NOW="$(ps u $(pgrep -x "$APP") | tail -1 | awk '{print $3}')"
      LOAD_LAST="$(cat $TMPDIR/EnergyWatchDog_$PID 2>/dev/null || echo 0)"
      STATUS="OK"
      POWER="$(pmset -g batt | awk '{printf "%s %s\n", $4,$5;exit}')"

      echo "$LOAD_NOW" >"$TMPDIR/EnergyWatchDog_$PID"

      if (("$(echo "$LOAD_NOW > $MAX" | bc -l)")); then
        STATUS="WATCHING"
        if (("$(echo "$LOAD_LAST > $MAX" | bc -l)")); then
          if [ "$BATTERY_ONLY" = "1" ] && [ "$POWER" != "'Battery Power'" ]; then
            STATUS="DRAINING"
          else
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
