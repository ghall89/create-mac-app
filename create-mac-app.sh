#!/bin/bash

DOWNLOAD_URL="https://github.com/ghall89/mac-app-template/archive/refs/heads/main.zip"
ZIP_FILENAME="mac-app-template-main.zip"
BUNDLE_NAME_PLACEHOLDER="{{bundle_name}}"
BUNDLE_ID_PLACEHOLDER="{{bundle_id}}"

# Check if bundle_name argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bundle_name>"
    echo "Example: $0 MyProject"
    exit 1
fi

BUNDLE_NAME=$1
EXTRACTED_DIR="${ZIP_FILENAME%.zip}"
BUNDLE_ID="com.${USER}.${BUNDLE_NAME}"

# Download the zip file
echo "Downloading $ZIP_FILENAME from $DOWNLOAD_URL..."
curl -L -o "$ZIP_FILENAME" "$DOWNLOAD_URL" || {
    echo "Failed to download the file."
    exit 1
}

# Unzip the file
echo "Unzipping $ZIP_FILENAME..."
unzip -q "$ZIP_FILENAME" || {
    echo "Failed to unzip the file."
    exit 1
}

# Remove the zip file after extraction
rm "$ZIP_FILENAME"

if [ -z "$EXTRACTED_DIR" ]; then
    echo "Could not determine the extracted directory name."
    exit 1
fi

# Rename the extracted directory
echo "Renaming $EXTRACTED_DIR to $BUNDLE_NAME..."
mv "$EXTRACTED_DIR" "$BUNDLE_NAME" || {
    echo "Failed to rename the directory."
    exit 1
}

# Change into the renamed directory
cd "$BUNDLE_NAME" || {
    echo "Failed to enter the directory $BUNDLE_NAME."
    exit 1
}

# Replace {{bundle_name}} in file contents
echo "Replacing $BUNDLE_NAME_PLACEHOLDER in file contents with $BUNDLE_NAME..."
find . -type f -exec sed -i '' -e "s/$BUNDLE_NAME_PLACEHOLDER/$BUNDLE_NAME/g" {} + 2>/dev/null

# Replace {{bundle_id}} in file contents
echo "Replacing $BUNDLE_ID_PLACEHOLDER in file contents with $BUNDLE_ID..."
find . -type f -exec sed -i '' -e "s/$BUNDLE_ID_PLACEHOLDER/$BUNDLE_ID/g" {} + 2>/dev/null

# 1. Rename the folder in Sources/
OLD_FOLDER="Sources/{{bundle_name}}"
NEW_FOLDER="Sources/$BUNDLE_NAME"

if [ -d "$OLD_FOLDER" ]; then
    echo "Renaming folder $OLD_FOLDER to $NEW_FOLDER..."
    mv "$OLD_FOLDER" "$NEW_FOLDER" || {
        echo "Failed to rename folder $OLD_FOLDER"
        exit 1
    }
else
    echo "Warning: Expected folder $OLD_FOLDER not found"
fi

# 2. Rename the Swift file
OLD_FILE="$NEW_FOLDER/{{bundle_name}}.swift"
NEW_FILE="$NEW_FOLDER/$BUNDLE_NAME.swift"

if [ -f "$OLD_FILE" ]; then
    echo "Renaming file $OLD_FILE to $NEW_FILE..."
    mv "$OLD_FILE" "$NEW_FILE" || {
        echo "Failed to rename file $OLD_FILE"
        exit 1
    }
else
    echo "Warning: Expected file $OLD_FILE not found"
fi


echo "All done!"
