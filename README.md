# cbir-demo
Demo repo for custom base image recommendations

### Usage

Use the golden-image.sh script to add base images to the UI before marking them as custom base images with the given versioning Schema

`chmod +x golden-image.sh && bash ./golden-image.sh`

Import the repo to a Snyk org, once you've marked the first batch of images as custom base images with the correct version schema in order to raise a fix PR

### Reqs and Limitations

requires docker daemon and snyk cli (authenticated)
