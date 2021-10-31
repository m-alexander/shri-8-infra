#!/usr/bin/env bash

result=$(npm test)

echo 'Возвращаю summary'
echo "$result"


echo "::set-output name=result::$result"
