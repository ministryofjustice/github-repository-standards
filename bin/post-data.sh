#!/bin/sh

bin/repository-checker > repositories.json

curl \
  --http1.1 \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: ${OPERATIONS_ENGINEERING_REPORTS_API_KEY}" \
  -d @repositories.json \
  ${OPERATIONS_ENGINEERING_REPORTS_HOST}/github_repositories
