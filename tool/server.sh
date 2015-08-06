#!/bin/sh

pub get
dart --checked tool/server/run.dart "$@"