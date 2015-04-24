#!/bin/sh

pub get
dart --checked test/run_tests.dart "$@"