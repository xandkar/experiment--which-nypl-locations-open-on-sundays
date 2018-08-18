#! /bin/sh

set -e

# The loop and xargs call are just to remove the quotes from jq output - I
# could not think of a better way...
for x in $(cat uri-api-response.json \
| jq --raw-output '
    .locations
    | map([.images.exterior, .images.interior])
    | flatten
    | @sh
    ')
do
    echo $x
done \
| xargs -I % echo % \
| wget --wait 10 --random-wait -P images -i -
# Yes, this will take a while, but unless we wait - we'll start getting junk
# back after a few requests.
