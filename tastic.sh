#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$2

if [ "$1" == "ungenerate" ]
then
	# Create the directory structure.
	rm -rf "$SITE_PATH"/"$SOURCE_DIR"/*
	find "$SITE_PATH"/"$OUTPUT_DIR" -type d |
		sed "s|^$SITE_PATH/$OUTPUT_DIR|$SITE_PATH/$SOURCE_DIR|" |
		xargs -0 -d '\n' mkdir -p --

	# Parse and create all the markdown files.
	find "$SITE_PATH"/"$OUTPUT_DIR" -type f -name "*.html" -print0 |
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

	# Copy anything else directly.
	find "$SITE_PATH"/"$OUTPUT_DIR" -type f -not -name "*.html" -print0 |
		while IFS= read -r -d '' file; do
			NEW_PATH=`echo "$file" | sed "s|^$SITE_PATH/$OUTPUT_DIR|$SITE_PATH/$SOURCE_DIR|"`
			cp "$file" "$NEW_PATH"
		done
elif [ "$1" == "generate" ]
then
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
				tidy -quiet --indent auto --indent-with-tabs yes --wrap 0 -asxml --tidy-mark no |
				~/.local/bin/smartypants \
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
	swipl --traditional -q -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." |
		tidy -quiet --indent auto --indent-with-tabs yes --wrap 0 -xml --tidy-mark no \
		> "$SITE_PATH"/"$OUTPUT_DIR"/feeds/rss.xml
else
	echo "Invalid argument."
	exit 1
fi
