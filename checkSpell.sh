# It's a temporary solution to check the spelling of Docs/*.md and Sources/Rugby/*.swift files
# Need to install https://github.com/fromkk/SpellChecker
find Docs -type f -name '*.md' -exec SpellChecker --yml spell_checker_whitelist.yml -- {} \; | grep -v 'no typo'
find Sources/Rugby -type f -name '*.swift' -exec SpellChecker --yml spell_checker_whitelist.yml -- {} \; | grep -v 'no typo'