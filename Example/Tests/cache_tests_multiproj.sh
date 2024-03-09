#!/bin/bash

set -e

header() {
	printf "\e[33m>\e[m \e[32mStep: $1\e[m\n"
}

header "CocoaPods"
MULTIPLE_PROJECTS=true pod install --repo-update

header "Rugby Test"
rugby _test -g framework \
            -n 'iPhone 15' \
            -p ExampleFrameworks \
            --strip \
            --skip-signing
