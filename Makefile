.PHONY: debug
debug:
	@swiftlint --strict --quiet
	@swift build
	
.PHONY: release
release:
	@swiftlint --strict --quiet
	@swift build -c release --arch arm64 --arch x86_64
	
.PHONY: package
package: release
	@rm -rf "./.product"
	@mkdir -p "./.product/rugby/bin"
	@cp -p "./.build/apple/Products/Release/rugby" "./.product/rugby/bin"
	@cd "./.product" && zip -r "./rugby.zip" "./"
	@rm -rf "./.product/rugby"
	@echo "Product path: product/rugby.zip"