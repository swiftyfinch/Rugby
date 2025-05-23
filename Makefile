.PHONY: debug
debug: lint
	swift build --arch x86_64

.PHONY: lint
lint:
	@which swiftformat || \
	(printf '\e[31m⛔️ Could not find SwiftFormat.\e[m\n\e[33m🚑 Run: brew install swiftformat\e[m\n' && exit 1)
	@which swiftlint || \
	(printf '\e[31m⛔️ Could not find SwiftLint.\e[m\n\e[33m🚑 Run: brew install swiftlint\e[m\n' && exit 1)
	swiftformat --quiet .
	swiftlint --fix --quiet
	swiftlint --strict --quiet

.PHONY: install
install:
	swift build --arch arm64 -c release
	cp -f `swift build --arch arm64 -c release --show-bin-path`/rugby ~/.rugby/clt/rugby
	strip -rSTx ~/.rugby/clt/rugby

.PHONY: release
release:
	rm -rf Release
	mkdir -p Release

	swift package clean
	swift build -c release --arch x86_64 -Xcc -Os
	cp -f `swift build -c release --arch x86_64 -Xcc -Os --show-bin-path`/rugby Release/rugby
	strip -rSTx Release/rugby
	cd Release && zip -r x86_64.zip rugby
	cd Release && mv rugby rugby-x86_64
	@echo

	swift package clean
	swift build --arch arm64 -c release -Xcc -Os
	cp -f `swift build -c release --arch arm64 -Xcc -Os --show-bin-path`/rugby Release/rugby
	strip -rSTx Release/rugby
	cd Release && zip -r arm64.zip rugby
	cd Release && mv rugby rugby-arm64
	@echo

	cd Release && lipo -create rugby-x86_64 rugby-arm64 -output rugby
	cd Release && zip -r universal.zip rugby

.PHONY: mocks
mocks:
	sourcery --sources Sources/RugbyFoundation \
			 --sources Tests/FoundationTests \
			 --templates Tests/Sourcery/AutoMockable.stencil \
			 --output Tests/FoundationTests
	sourcery --sources Sources/RugbyFoundation \
			 --sources Sources/Rugby \
			 --sources Tests/RugbyTests \
			 --templates Tests/Sourcery/AutoMockable.stencil \
			 --output Tests/RugbyTests

.PHONY: test
test:
	set -o pipefail && swift test 2>&1 | xcbeautify

.PHONY: smoke
smoke:
	cd Example && Tests/cache_tests.sh

.PHONY: docs
docs:
	ruby .github/scripts/update_docs.rb
