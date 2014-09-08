#!/bin/bash

set -ex

cd ./test/local-runner/
./local-runner-sync.sh

cd ../..
ruby runner.rb
