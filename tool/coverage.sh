#!/bin/sh

if [ -d "./lcov_report" ]; then
    rm -rf ./lcov_report
fi
if [ -f "./lcov_coverage.lcov" ]; then
    rm ./lcov_coverage.lcov
fi

./tool/test.sh --coverage