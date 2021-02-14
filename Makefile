.PHONY: build
build:
	@swift run swiftlint --strict --quiet
	@swift build -c release
	
.PHONY: package
package: build
	@rm -rf "./.product"
	@mkdir -p "./.product/rugby/bin"
	@cp -p "./.build/release/rugby" "./.product/rugby/bin"
	@cd "./.product" && zip -r "./rugby.zip" "./"
	@rm -rf "./.product/rugby"
	@echo "Product path: product/rugby.zip"