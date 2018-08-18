#! /bin/sh

set -e

cat uri-api-response.json \
| jq --raw-output \
    '
    .locations
    | map(select(
            ( .hours.regular
            | map(select(
                   .day == "Sun." and .open != null
               ))
            | length
            ) > 0
        ))
    '
