#!/bin/bash

LOG="/var/log/clamav/scan.log"


TARGET=()
{% if pillar['clamav'] is defined %}
{%- for path in pillar['clamav']['paths'] %}
TARGET+=("{{ path }}")
{% endfor -%}
{% endif %}

SUMMARY_FILE=$(mktemp)

SCAN_STATUS=""

INFECTED_SUMMARY=""

MAILADDR="{{ pillar['clamav']['email'] }}"


echo "------------ SCAN START ------------" >> "$LOG"

echo "Running scan on `date`" >> "$LOG"

echo "" > $SUMMARY_FILE


for TARGET_PATH in ${TARGET[@]}; do

  clamdscan --log "$LOG" --infected --multiscan --fdpass "$TARGET_PATH" >> "$SUMMARY_FILE"
  
done


SCAN_STATUS="$?"

INFECTED_SUMMARY=$(cat $SUMMARY_FILE | grep FOUND)


rm "$SUMMARY_FILE"


if [[ "$SCAN_STATUS" -ne "0" ]] ; then

  mailx -s "Malware/Virus signature found" $MAILADDR < $SUMMARY_FILE

fi