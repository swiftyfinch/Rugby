.PHONY: debug
debug:
	@swiftlint --strict --quiet
	@swift build

.PHONY: patch
patch:
	@ruby Scripts/Bump.rb patch

.PHONY: minor
minor:
	@ruby Scripts/Bump.rb minor

.PHONY: major
major:
	@ruby Scripts/Bump.rb major
