#!/bin/bash

TAG=$(git tag --sort version:refname | tail -n 1)

echo 'Check if task exists'

############ CHECK TASK EXISTS
response=$(curl -sS -X POST https://api.tracker.yandex.net/v2/issues/_search \
            -H "Content-Type: application/json" \
            -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
            -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
            -d "{\"filter\": {\"unique\": \"$TAG\"} }")

existing=$(echo $response | jq -r '.[0].key')


############ GET TASK DESCRIPTION
PREV_TAG=$(git tag --sort version:refname | tail -n 2 | head -n 1)
DESCRIPTION="
$(git log -1 $TAG | grep 'Author\|Date')
Version: $TAG

Changelog:
$(git log --oneline --no-decorate $PREV_TAG..$TAG)
"


TITLE="Version $TAG"

BODY=$(jq -n \
          --arg summary "$TITLE" \
          --arg queue "$YANDEX_TRACKER_QUEUE" \
          --arg unique "$TAG" \
          --arg description "$DESCRIPTION" \
           '$ARGS.named')


if test "$existing" = "null"; then
  ############ CREATE NEW TASK
  echo 'Create new task'
  response=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/" \
       -H "Content-Type: application/json" \
       -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
       -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
       -d "$BODY")

  echo $response

  existing=$(echo $response | jq -r '.key')
else
  ############ UPDATE TASK
  echo 'Update task'
  response=$(curl -sS -X PATCH "https://api.tracker.yandex.net/v2/issues/$existing" \
    -H "Content-Type: application/json" \
    -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
    -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
    -d "$BODY")

  echo $response
fi

############ RUN TESTS AND ADD COMMENT
echo 'Add tests result'

npm install
TEST_RESULTS=$(npm test | sed '/^>/d')

BODY=$(jq -n  --arg text "$TEST_RESULTS" '$ARGS.named')

response=$(curl -sS -X POST "https://api.tracker.yandex.net/v2/issues/$existing/comments" \
     -H "Content-Type: application/json" \
     -H "Authorization: OAuth $YANDEX_TRACKER_OAUTH" \
     -H "X-Org-Id: $YANDEX_TRACKER_ORG_ID" \
     -d "$BODY")

echo $response

echo 'Complete'
