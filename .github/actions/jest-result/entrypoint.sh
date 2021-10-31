#!/bin/sh -l

result=$(npm test)

echo 'Возвращаю summary'
echo "$result"


echo "::set-output name=result::$result"
