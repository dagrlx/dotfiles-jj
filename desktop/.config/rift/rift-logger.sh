#!/bin/sh
# Loggea JSON sin interferir con sketchybar
echo "$RIFT_EVENT_JSON" | jq . > "/tmp/rift-last-$RIFT_EVENT_TYPE.json"
echo "$RIFT_EVENT_JSON" >> /tmp/rift-events.log
# echo "=== $(date) ===" >> /tmp/rift-debug.log
# echo "EVENT_TYPE: $RIFT_EVENT_TYPE" >> /tmp/rift-debug.log
# echo "WORKSPACE_NAME: $RIFT_WORKSPACE_NAME" >> /tmp/rift-debug.log
# echo "WORKSPACE_ID: $RIFT_WORKSPACE_ID" >> /tmp/rift-debug.log
# env | grep RIFT >> /tmp/rift-debug.log
# echo "----------------" >> /tmp/rift-debug.log

