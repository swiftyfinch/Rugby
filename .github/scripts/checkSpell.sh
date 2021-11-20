# It's a temporary solution to check the spelling of Docs/*.md and Sources/Rugby/*.swift files
# Need to install https://github.com/fromkk/SpellChecker

docs_output=`find Docs -type f -name '*.md' -exec ~/.mint/bin/SpellChecker --yml .github/scripts/spell_checker_whitelist.yml -- {} \; | grep -v 'no typo'`
if [[ $docs_output ]]; then echo $docs_output; fi

source_output=`find Sources/Rugby -type f -name '*.swift' -exec ~/.mint/bin/SpellChecker --yml .github/scripts/spell_checker_whitelist.yml -- {} \; | grep -v 'no typo'`
if [[ $source_output ]]; then echo $source_output; fi

if [[ $docs_output || $source_output ]]; then exit 1; fi