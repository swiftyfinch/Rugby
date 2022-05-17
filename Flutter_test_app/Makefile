#.PHONY: setup_flutter
#setup_flutter:
##	make submodule
#	brew tap leoafarias/fvm
#	brew install fvm
#	fvm flutter create --template module my_flutter
#	make move_file
#	cd ./my_flutter && \
#	fvm install && \
#	fvm flutter precache --ios && \
#	fvm flutter pub get

.PHONY: move_file
move_file:
#	cp -R ./.fvm ./my_flutter/.fvm
	cp -R ./pubspec.yaml ./my_flutter/pubspec.yaml

.PHONY: setup_flutter
setup_flutter:
	flutter create --template module my_flutter
	make sync_flutter
	
.PHONY: sync_flutter
sync_flutter:
	cd ./my_flutter && \
	flutter precache --ios
	flutter pub get
