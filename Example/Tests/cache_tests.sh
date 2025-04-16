#!/bin/bash

set -e

header() {
	printf "\e[33m>\e[m \e[32mStep: $1\e[m\n"
}

header "CocoaPods"
pod install --repo-update

header "Rugby"
rugby build -t Pods-ExampleFrameworks --output multiline
rugby build -t Pods-ExampleLibs --output multiline
rugby use -t Pods-ExampleFrameworks Pods-ExampleLibs --output multiline

header "Test"
set -o pipefail && env NSUnbufferedIO=YES arch -arm64 xcodebuild test \
  -workspace Example.xcworkspace \
  -scheme ExampleFrameworks \
  -testPlan ExampleFrameworks \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  CODE_SIGNING_ALLOWED=NO \
  | xcbeautify
set -o pipefail && env NSUnbufferedIO=YES arch -arm64 xcodebuild test \
  -workspace Example.xcworkspace \
  -scheme ExampleLibs \
  -testPlan ExampleLibs \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  CODE_SIGNING_ALLOWED=NO \
  | xcbeautify
