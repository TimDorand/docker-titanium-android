#!/bin/bash
#

set -euo pipefail

docker stop titanium-dev || true && docker rm titanium-dev || true

# run titanium container
echo "***BUILD TITANIUM DOCKER****"
docker build -t titanium .
echo "***TITANIUM DOCKER BUILDED. RUNNING TITANIUM-DEV...****"
docker run --name titanium-dev titanium
echo "***SUCCESS***"
echo "***COPYING THE APK...****"
docker cp titanium-dev:/home/root/build/android/bin/app-unsigned.apk .
echo "***CLEANING DOCKER...****"
docker rm titanium-dev
echo "You can now use this apk: 'app-unsigned.apk'"
