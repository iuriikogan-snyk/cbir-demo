#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
# developed with shellcheck extension enabled

function print_usage {
    echo "Usage: bash cicd-golden-images.sh"
    echo "$*"
    exit 1
}

[ -z "$SNYK_TOKEN" ] && print_usage "SNYK_TOKEN is required"
[ -z "$SNYK_CFG_ORG" ] && print_usage "SNYK_CFG_ORG is required"
[ -z "$SNYK_CFG_ORG_ID" ] && print_usage "SNYK_CFG_ORG_ID is required"

# from a clean Snyk Organization (no CBIs, no Projects)
# 201 on 1st run: do not alter vars, goldenimage registration is successful
# 400 on 2nd run: do not alter vars, goldenimage registration is unsuccessful (already exists!)
# 201 on 3rd run: update tag variable, registration is successful
# 201 on 4th run: update tag variable, registration is successful

registry=registry.io
repo=repo/goldenimage
tag=20230122
dockerfile=/tmp/dockerfile

touch "${dockerfile}" && rm "${dockerfile}"
echo "FROM alpine:3.7" >> "${dockerfile}"

# Build golden image
docker build --tag "${registry}"/"${repo}":"${tag}" --file "${dockerfile}" .

# Create Snyk Project for golden image
snyk container monitor --org="${SNYK_CFG_ORG}" \
 "${registry}"/"${repo}":"${tag}" --file="${dockerfile}" --project-name="${tag}" \
  --exclude-app-vulns --json > /tmp/monitor-output.json
echo "Successfully monitored ${registry}/${repo}:${tag}"

# Capture Project ID (required for CBIR API)
snyk_project_id=$(jq '.uri' /tmp/monitor-output.json | cut -d'/' -f 7)
echo "${snyk_project_id} is Snyk Project ID"

echo "Attempting to register image without defining custom schema"
# Register golden image, excluding schema, using API
 response=$(curl \
 --location "https://api.snyk.io/rest/custom_base_images?version=2023-11-06%7Ebeta" \
 --header "Content-Type: application/vnd.api+json" \
 --header "Authorization: Token ${SNYK_TOKEN}" \
 --write-out '%{http_code}' --silent --output /dev/null \
 --include \
 -d "{
       \"data\": {
         \"attributes\": {
           \"project_id\": \"${snyk_project_id}\",
           \"include_in_recommendations\": true
         },
         \"type\": \"custom_base_image\"
       }
     }")

if [ "${response}" == 400 ]
then
echo "${response} response"
echo "Bad Request: A parameter provided as a part of the request was invalid"
echo "This may be because a custom schema has not yet been set"
echo "Attempting to register image while defining custom schema"

response=$(curl \
 --location "https://api.snyk.io/rest/custom_base_images?version=2023-11-06%7Ebeta" \
 --header "Content-Type: application/vnd.api+json" \
 --header "Authorization: Token ${SNYK_TOKEN}" \
 --write-out '%{http_code}' --silent --output /dev/null \
 --include \
 -d "{
       \"data\": {
         \"attributes\": {
           \"project_id\": \"${snyk_project_id}\",
           \"include_in_recommendations\": true,
           \"versioning_schema\": {
             \"type\": \"custom\",
             \"label\": \"Schema for YYYYMMDD\",
             \"expression\": \"(?<C0>\\\d{4})(?<C1>\\\d{2})(?<C2>\\\d{2})\"
           }
         },
         \"type\": \"custom_base_image\"
       }
     }")
echo "${response} response"
else
echo "${response} response"
fi