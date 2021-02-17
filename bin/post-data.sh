#!/bin/sh

cloud-platform-repository-checker > repositories.json

curl \
  --http1.1 \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: ${HOODAW_API_KEY}" \
  -d @repositories.json \
  ${HOODAW_HOST}/repositories
