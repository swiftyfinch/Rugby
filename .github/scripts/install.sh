#!/bin/bash

success() {
	printf "\e[32m$1\e[m\n"
}
error() {
	printf "\e[31m$1\e[m\n"
}
warning() {
	printf "\e[33m$1\e[m\n"
}

if command -v rugby &> /dev/null; then
	warning "🏈 Rugby has already been installed."; exit
fi

# Get the latest version of Rugby
RUGBY_GIT='https://github.com/swiftyfinch/Rugby'
LATEST_VERSION=$(git ls-remote -t --sort=v:refname $RUGBY_GIT | sed -ne '$s/.*tags\/\(.*\)/\1/p')

# Get the current machine architecture
if [[ `arch` = arm64* ]]; then
	ARCH='arm64'
else
	ARCH='x86_64'
fi

# Download the latest Rugby version for the current machine architecture
RUGBY_CLT_PATH="$HOME/.rugby/clt"
rm -rf "$RUGBY_CLT_PATH/downloads" && mkdir -p "$RUGBY_CLT_PATH/downloads" && cd "$RUGBY_CLT_PATH/downloads"
curl -sSLO "https://github.com/swiftyfinch/Rugby/releases/download/$LATEST_VERSION/$ARCH.zip"
unzip -q "$ARCH.zip"
cp rugby $RUGBY_CLT_PATH && rm -rf "$RUGBY_CLT_PATH/downloads"
success "🏈 Rugby has been installed ✓"

# Check if Rugby is in $PATH
if [[ ":${PATH}:" != *":$RUGBY_CLT_PATH:"* ]]; then
	error "\n$RUGBY_CLT_PATH is not in your \$PATH"
	warning "Add it manually to your shell profile."
	warning "For example, if you use zsh, run this command:"
	echo "\$ echo '\nexport PATH=\$PATH:~/.rugby/clt' >> ~/.zshrc"
	warning "Than open a new window or tab in the terminal for applying changes."
fi
