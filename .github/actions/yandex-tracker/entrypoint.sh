#!/bin/bash

TAG=$(git tag --sort version:refname | tail -n 2 | head -n 1)

echo 'Check if task exists'


response=$(curl -sS -X POST https://api.tracker.yandex.net/v2/issues/_search \
            -H "Content-Type: application/json" \
            -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
            -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
            -d "{\"filter\": {\"unique\": \"$TAG\"} }")

existing=$(echo $response | jq -r '.[0].key')



echo 'Получаю автора и дату'
header=$(git log -1 $TAG | grep 'Author\|Date')

echo 'Получаю changelog'
if [ "$TAG" ]; then
  changelog=$(git log --oneline --no-decorate $TAG..HEAD)
else
  changelog=$(git log --oneline --no-decorate)
fi


changelog="${changelog//'%'/'%25'}"
changelog="${changelog//$'\n'/'%0A' - }"
changelog=" - ${changelog//$'\r'/'%0D'}"

DESCRIPTION="$header\nVersion: $TAG\nChangelog:\n$changelog"
echo $DESCRIPTION

npm install
TEST_RESULTS=$(npm test)

TITLE="Version $TAG"

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
