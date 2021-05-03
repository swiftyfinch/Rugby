.PHONY: debug
debug:
	@swiftlint --strict --quiet
	@swift build
	
.PHONY: release
release:
	@swift run swiftlint --strict --quiet
	@swift build -c release
	
.PHONY: test
test:
	@cd "Tests/TestProject" && bundle
	@cd "Tests/TestProject" && bundle exec pod install
	@cd "Tests/TestProject" && bundle exec ruby Scripts/exclude_arm64.rb
	@cd "Tests/TestProject" && swift run rugby
	@cd "Tests/TestProject" && set -o pipefail && env NSUnbufferedIO=YES xcodebuild -workspace TestProject.xcworkspace -scheme TestProject -sdk iphonesimulator | bundle exec xcpretty
	
.PHONY: package
package: release
	@rm -rf "./.product"
	@mkdir -p "./.product/rugby/bin"
	@cp -p "./.build/release/rugby" "./.product/rugby/bin"
	@cd "./.product" && zip -r "./rugby.zip" "./"
	@rm -rf "./.product/rugby"
	@echo "Product path: product/rugby.zip"