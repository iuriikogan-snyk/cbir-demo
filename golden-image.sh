#!/usr/bin/env bash
set -eou pipefail

# run this to create the base image and then follow the instructions to mark as a base image in the UI

# **SET org1 and org2 as necessary
org1='cbir-techops'
org2='custom-base-image-Jrqnane4CCeFmGpSHMDPxn'

docker build -f ./docker/base/Dockerfile . -t 'registry.io/repo/goldenimage:20240820'

snyk container monitor 'registry.io/repo/goldenimage:20240820' --project-name="20240820" --exlude-app-vulns --platform=linux/arm64 --file=./docker/base/Dockerfile --org="$org1"

docker build -f ./docker/base2/Dockerfile . -t 'registry.io/repo/goldenimage:20240821'

snyk container monitor 'registry.io/repo/goldenimage:20240821' --project-name="20240821" --exlude-app-vulns --platform=linux/arm64 --file=./docker/base2/Dockerfile --org="$org1"

## Now head to the UI and mark this image as a custom base image 20240820 and 20240821 with custom versioning schema: (?<C3>\d{4})(?<C4>\d{2})(?<C5>\d{2})

echo " custom schema: (?<C3>\d{4})(?<C4>\d{2})(?<C5>\d{2})" 

read -r -p "Press enter once you have marked the base image as a custom image in the UI and applied the custom schema"

docker build -f ./docker/cbi/Dockerfile . -t 'registry.io/repo/internalapp:20240821'

snyk container monitor 'registry.io/repo/internalapp:20240821' --project-name="20240821" --exlude-app-vulns --platform=linux/arm64 --file=./docker/cbi/Dockerfile --org="$org2"
