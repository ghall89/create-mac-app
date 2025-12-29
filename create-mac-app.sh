#!/bin/bash

DOWNLOAD_URL="https://github.com/ghall89/mac-app-template/archive/refs/heads/main.zip"
ZIP_FILENAME="mac-app-template-main.zip"
BUNDLE_NAME_PLACEHOLDER="{{bundle_name}}"
BUNDLE_ID_PLACEHOLDER="{{bundle_id}}"

# Get bundle_name from argument or prompt
if [ "$#" -eq 1 ]; then
    BUNDLE_NAME=$1
else
    read -p "Enter your project name (e.g. MyProject): " BUNDLE_NAME
    if [ -z "$BUNDLE_NAME" ]; then
        echo "Error: Project name cannot be empty"
        exit 1
    fi
fi

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
# Escape special characters for sed
ESCAPED_BUNDLE_NAME=$(printf '%s\n' "$BUNDLE_NAME" | sed -e 's/[][\/&]/\\&/g')

find . -type f -exec sh -c '
    for file do
        if file "$file" | grep -q "text"; then
            sed -i "" "s/{{bundle_name}}/$1/g" "$file"
        fi
    done
' sh "$ESCAPED_BUNDLE_NAME" {} + 2>/dev/null

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

cd $BUNDLE_NAME

# Set up ENV file

 mv ".env.example" ".env" || {
    echo "Failed to rename .env.example"
    exit 1
}

tail -n +3 ".env" > ".env.tmp" && mv ".env.tmp" ".env" || {
    echo "Failed to modify .env file"
    exit 1
}

# Initialize git

git init
git add -A && git commit -m "Initialize project"

echo "All done!"
