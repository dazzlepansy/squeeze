#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$1

# Copy everything that's not Markdown or HTML.
# Excludes the RSS folder, which we create ourselves upon generation.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose --exclude "*.html" --exclude "*.md" --exclude "feeds" "$SITE_PATH/$OUTPUT_DIR/" "$SITE_PATH/$SOURCE_DIR/"

# Parse and create all the markdown files.
find "$SITE_PATH/$OUTPUT_DIR" -type f -name "*.html" -print0 |
	while IFS= read -r -d '' file; do
		NEW_PATH=`echo "$file" | sed "s|^$SITE_PATH/$OUTPUT_DIR|$SITE_PATH/$SOURCE_DIR|" | sed 's|.html$|.md|'`
		cat "$file" |
			swipl --traditional -q -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), parse_entry." |
			# Unsmarten the punctuation.
			sed "s|&nbsp;| |g" |
			sed "s|&#8216;|'|g" |
			sed "s|&#8217;|'|g" |
			sed "s|&#8220;|\"|g" |
			sed "s|&#8221;|\"|g" \
			> "$NEW_PATH"
	done

