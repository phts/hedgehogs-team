#!/bin/bash

set -ex

cd ./test/local-runner/
./local-runner-sync.sh

sleep 3s

cd ../..
ruby runner.rb
