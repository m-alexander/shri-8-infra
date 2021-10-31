#!/bin/sh -l

echo 'Check if task exists'


echo "Authorization: OAuth $YANDEX_TRACKER_OAUTH"
echo  "X-Org-Id: $YANDEX_TRACKER_ORG_ID"
echo "{\"filter\": {\"unique\": \"$TAG\"} }"

response=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/_search" \
   -H "Content-Type: application/json" \
   -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
   -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
   -d "{\"filter\": {\"unique\": \"$TAG\"} }")

echo $response

existing=$(echo $response | jq -r '.[0].key')

if test "$existing" = "null"; then
  echo 'Create new task'
  response=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/" \
       -H "Content-Type: application/json" \
       -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
       -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
       -d "{\"summary\": \"$TITLE\", \"queue\": \"$YANDEX_TRACKER_QUEUE\", \"description\": \"$DESCRIPTION\", \"unique\": \"$TAG\" }")

  echo $response

  existing=$(echo $response | jq -r '.key')
else
  echo 'Update task'
  response=$(curl -sS -X PATCH "https://api.tracker.yandex.net/v2/issues/$existing" \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
    -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
    -d "{\"summary\": \"$TITLE\", \"queue\": \"$YANDEX_TRACKER_QUEUE\", \"description\": \"$DESCRIPTION\", \"unique\": \"$TAG\" }")

  echo $response
fi

echo 'Add tests result'
response=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/$existing/comments" \
     -H "Content-Type: application/json" \
     -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
     -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
     -d "{\"text\": \"$TEST_RESULTS\" }")

echo $response

echo 'Complete'
