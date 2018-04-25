#!/bin/bash

# Fast fail the script on failures.
set -e

# Check arguments.
TASK=$1

if [ -z "$TASK" ]; then
  echo -e '\033[31mTASK argument must be set!\033[0m'
  echo -e '\033[31mExample: tool/travis.sh test:unit\033[0m'
  exit 1
fi

DART_VERSION=$(dart --version 2>&1)
DART_2_PREFIX="Dart VM version: 2"

# Run the correct task type.
case $TASK in
  test:unit)
    echo -e '\033[1mTASK: Testing [test]\033[22m'

    echo -e 'pub build test --mode=debug --web-compiler=dartdevc'
    # Precompile tests to avoid timeouts/hung builds.
    pub build test --mode=debug --web-compiler=dartdevc
    # The --precompile option requires that it be given a merged output dir with
    # both compiled JS files and the source .dart files.
    # NOTE: Once we're on Dart 2 for good, we can switch to build_runner which
    # does all of this for us.
    cp -r test/ build/test/
    cp .packages build/
    sed 's/w_transport:lib/w_transport:..\/lib/' build/.packages > build/.packages.tmp && mv build/.packages.tmp build/.packages

    if [[ $DART_VERSION = $DART_2_PREFIX* ]]; then
      echo -e 'pub run test -P travis -P dart2 --precompiled=build/'
      pub run test -P travis -P dart2 --precompiled=build/
    else
      echo -e 'pub run test -P travis --precompiled=build/'
      pub run test -P travis --precompiled=build/
    fi

    ;;

  test:integration)
    echo -e '\033[1mTASK: Testing [test]\033[22m'

    echo -e 'pub build test --mode=debug --web-compiler=dartdevc'
    # Precompile tests to avoid timeouts/hung builds.
    pub build test --mode=debug --web-compiler=dartdevc
    # The --precompile option requires that it be given a merged output dir with
    # both compiled JS files and the source .dart files.
    # NOTE: Once we're on Dart 2 for good, we can switch to build_runner which
    # does all of this for us.
    cp -R test/** build/test/
    cp .packages build/
    sed 's/w_transport:lib/w_transport:..\/lib/' build/.packages > build/.packages.tmp && mv build/.packages.tmp build/.packages

    dart tool/server/server.dart &
    DART_SERVER=$!

    node tool/server/sockjs.js &
    SOCKJS_SERVER=$!

    sleep 2

    if [[ $DART_VERSION = $DART_2_PREFIX* ]]; then
      echo -e 'pub run test -P travis -P integration -P dart2 --precompiled=build/'
      pub run test -P travis -P integration -P dart2 --precompiled=build/
    else
      echo -e 'pub run test -P travis -P integration --precompiled=build/'
      pub run test -P travis -P integration --precompiled=build/
    fi

    kill $DART_SERVER
    kill $SOCKJS_SERVER
    sleep 2

    ;;

  *)
    echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    exit 1
    ;;
esac
