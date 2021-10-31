#!/usr/bin/env bash

echo 'Получаю tag'
tag=$(git tag --sort version:refname | tail -n 2 | head -n 1)

echo 'Получаю автора и дату'
header=$(git log -1 $tag | grep 'Author\|Date')

echo 'Получаю changelog'
if [ "$tag" ]; then
  changelog=$(git log --oneline --no-decorate $tag..HEAD)
else
  changelog=$(git log --oneline --no-decorate)
fi


changelog="${changelog//'%'/'%25'}"
changelog="${changelog//$'\n'/'%0A' - }"
changelog=" - ${changelog//$'\r'/'%0D'}"

result="
$header
Version: $tag

Changelog:
$changelog
"

# echo "$result"
echo 'Возвращаю summary'

echo "::set-output name=summary::$result"
