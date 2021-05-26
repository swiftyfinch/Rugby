.PHONY: debug
debug:
	@swiftlint --strict --quiet
	@swift build