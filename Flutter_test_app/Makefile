.PHONY: setup_flutter
setup_flutter:
#	make submodule
	brew tap leoafarias/fvm
	brew install fvm
	fvm flutter create --template module my_flutter
	make move_file
	cd ./my_flutter && \
	fvm install && \
	fvm flutter precache --ios && \
	fvm flutter pub get

.PHONY: move_file
move_file:
	cp -R ./.fvm ./my_flutter/.fvm
	cp -R ./pubspec.yaml ./my_flutter/pubspec.yaml
