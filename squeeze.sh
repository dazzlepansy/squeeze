#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$1

# Create the directory structure.
rm -rf "$SITE_PATH"/"$OUTPUT_DIR"/*
find "$SITE_PATH"/"$SOURCE_DIR" -type d |
	sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" |
	xargs -0 -d '\n' mkdir -p --

# Parse and create all the HTML files.
find "$SITE_PATH"/"$SOURCE_DIR" -type f -name "*.md" -print0 |
	while IFS= read -r -d '' file; do
		echo $file
		NEW_PATH=`echo "$file" | sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" | sed 's|.md$|.html|'`
		cat "$file" |
			swipl --traditional -q -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry." |
			smartypants \
			> "$NEW_PATH"
	done

# Copy anything else directly.
find "$SITE_PATH"/"$SOURCE_DIR" -type f -not -name "*.md" -print0 |
	while IFS= read -r -d '' file; do
		NEW_PATH=`echo "$file" | sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|"`
		cp "$file" "$NEW_PATH"
	done

# Generate the RSS feed.
mkdir -p "$SITE_PATH"/"$OUTPUT_DIR"/feeds
ARTICLES=`grep -Rl --include=\*.md "^Date: " "$SITE_PATH"/"$SOURCE_DIR" | paste -sd ',' - | sed "s|,|','|g"`
BUILD_DATE=`date +"%Y-%m-%d %T"`
swipl --traditional -q -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." \
	> "$SITE_PATH"/"$OUTPUT_DIR"/feeds/rss.xml