#!/usr/bin/env sh

SITE_PATH=$1

OUTPUT_PATH="$SITE_PATH/output"
SOURCE_PATH="$SITE_PATH/source"

# Copy everything that's not Markdown or HTML.
# Excludes the RSS folder, which we create ourselves upon generation.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose --exclude "*.html" --exclude "*.md" --exclude "feeds" "$OUTPUT_PATH/" "$SOURCE_PATH/"

# Delete any Markdown files for which the output was removed.
find "$SOURCE_PATH" -type f -name "*.md" |
	while read -r file; do
		OLD_PATH=$(echo "$file" |
			sed "s|^$SOURCE_PATH|$OUTPUT_PATH|" |
			sed 's|.md$|.html|')
		[ ! -f "$OLD_PATH" ] && rm "$file"
	done

# Parse and create all the markdown files.
find "$OUTPUT_PATH" -type f -name "*.html" |
	while read -r file; do
		NEW_PATH=$(echo "$file" |
			sed "s|^$OUTPUT_PATH|$SOURCE_PATH|" |
			sed 's|.html$|.md|')
		swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), parse_entry('$file')." |
			# Unsmarten the punctuation.
			sed "s|&nbsp;| |g" |
			sed "s|&#8216;|'|g" |
			sed "s|&#8217;|'|g" |
			sed "s|&#8220;|\"|g" |
			sed "s|&#8221;|\"|g" \
			> "$NEW_PATH"
	done

