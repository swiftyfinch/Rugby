.PHONY: debug
debug:
	@swiftlint --strict --quiet
	@swift build

.PHONY: spell
spell:
	sh .github/scripts/checkSpell.sh
