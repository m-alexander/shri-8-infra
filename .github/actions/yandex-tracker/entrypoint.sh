#!/bin/sh -l

echo 'Check if task exists'

existing=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/_search" \
   -H "Content-Type: application/json" \
   -H "Authorization: OAuth ${YANDEX_TRACKER_OAUTH}" \
   -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
   -d "{\"filter\": {\"unique\": \"$TAG\"} }" \
   | jq -r '.[0].key')

if test $existing = "null"; then
  echo 'Create new task'
  existing=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/" \
     -H "Content-Type: application/json" \
     -H "Authorization: OAuth ${YANDEX_TRACKER_OAUTH}" \
     -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
     -d "{\"summary\": \"$TITLE\", \"queue\": \"$YANDEX_TRACKER_QUEUE\", \"description\": \"$DESCRIPTION\", \"unique\": \"$TAG\" }" \
     | jq -r '.key')
else
  echo 'Update task'
  existing=$(curl -sS -X PATCH "https://api.tracker.yandex.net/v2/issues/$existing" \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth ${YANDEX_TRACKER_OAUTH}" \
    -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
    -d "{\"summary\": \"$TITLE\", \"queue\": \"$YANDEX_TRACKER_QUEUE\", \"description\": \"$DESCRIPTION\", \"unique\": \"$TAG\" }" \
    | jq -r '.key')
fi

echo 'Add tests result'
commentId=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/$existing/comments" \
     -H "Content-Type: application/json" \
     -H "Authorization: OAuth ${YANDEX_TRACKER_OAUTH}" \
     -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
     -d "{\"text\": \"$TEST_RESULTS\" }" \
     | jq -r '.id')

echo 'Complete'
