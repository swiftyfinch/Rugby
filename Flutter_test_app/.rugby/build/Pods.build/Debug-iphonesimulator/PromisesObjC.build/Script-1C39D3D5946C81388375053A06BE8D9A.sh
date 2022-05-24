#!/bin/sh
cd "$CONFIGURATION_BUILD_DIR/$WRAPPER_NAME" || exit 1
if [ ! -d Versions ]; then
  # Not a versioned framework, so no need to do anything
  exit 0
fi

public_path="${PUBLIC_HEADERS_FOLDER_PATH#$CONTENTS_FOLDER_PATH/}"
if [ ! -f "$public_path" ]; then
  ln -fs "${PUBLIC_HEADERS_FOLDER_PATH#$WRAPPER_NAME/}" "$public_path"
fi

private_path="${PRIVATE_HEADERS_FOLDER_PATH#$CONTENTS_FOLDER_PATH/}"
if [ ! -f "$private_path" ]; then
  ln -fs "${PRIVATE_HEADERS_FOLDER_PATH#$WRAPPER_NAME/}" "$private_path"
fi

