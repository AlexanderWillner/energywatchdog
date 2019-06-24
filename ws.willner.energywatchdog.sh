#!/bin/bash

SLEEP=30
APPS=( 'suggestd' 'AppleSpell' 'Messages' 'Calendar' 'CalendarAgent' 'soagent' 'callservicesd' 'airportd' 'cloudphotosd' )
MAX=80.0

rm "${TMPDIR}/EnergyWatchDog_*" 2>/dev/null

while true; do
  echo "============================================"
  for APP in "${APPS[@]}"; do
    PID="$(ps u $(pgrep -x "$APP")|tail -1 |awk '{print $2}')"
    LOAD_NOW="$(ps u $(pgrep -x "$APP")|tail -1 |awk '{print $3}')"
    LOAD_LAST="$(cat ${TMPDIR}/EnergyWatchDog_${PID} 2>/dev/null || echo 0)"
    STATUS="OK"

    echo "${LOAD_NOW}" > "${TMPDIR}/EnergyWatchDog_${PID}"
  
    if (( $(echo "${LOAD_NOW} > ${MAX}"|bc -l) )); then
      STATUS="WATCHING"
      if (( $(echo "${LOAD_LAST} > ${MAX}"|bc -l) )); then
        STATUS="KILLED"
        kill "${PID}" ; sleep 3; kill -9 "${PID}" 2>/dev/null
      fi
    fi
    echo "${APP}: (PID: ${PID}) (NOW: ${LOAD_NOW}) (LAST: ${LOAD_LAST}) (STATUS: ${STATUS})"
  done
  echo "============================================"
  sleep $SLEEP
done
