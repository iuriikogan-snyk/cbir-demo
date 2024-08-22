# cbir-demo
 Demo repo for custom base image recommendations

### Usage

 Use the golden-image.sh script to add base images to the UI before marking them as custom base images with the given versioning Schema

Clone the repo, cd into the repo and run the following.

`chmod +x golden-image.sh && bash ./golden-image.sh`

 Import the repo to a Snyk org, once you've marked the first batch of images as custom base images with the correct version schema in order to raise a fix PR

### Reqs and Limitations

 Requires Docker Daemon (greater than 18.0), Snyk ClI (Authenticated), Bash (min version 3.2)
