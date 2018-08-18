#! /bin/sh

set -e

cat uri-api-response.json | json_pp > uri-api-response-pretty.json
