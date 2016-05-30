#!/bin/bash

set -o errexit
set -o pipefail

for arch in $ARCHS; do
	cp -f Dockerfile.$arch Dockerfile

	mkdir -p output
	docker build --no-cache=true -t swarm-builder:$arch .
	docker run --rm --privileged -v `pwd`/output:/output swarm-builder:$arch

	version="$(grep -m1 'ENV VERSION ' "Dockerfile" | cut -d' ' -f3)"
	dirName=swarm-linux-$arch-$version

	mkdir $dirName
	chmod +x output/swarm
	cp output/swarm $dirName/
	tar -cvzf $dirName.tar.gz $dirName
	sha256sum $dirName.tar.gz > $dirName.tar.gz.sha256

	# Upload to S3 (using AWS CLI)
	printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
	aws s3 cp $dirName.tar.gz s3://$BUCKET_NAME/swarm/$version/
	aws s3 cp $dirName.tar.gz.sha256 s3://$BUCKET_NAME/swarm/$version/
	rm -rf $dirName*
	rm -rf output
done
