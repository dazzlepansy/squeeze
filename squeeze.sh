#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$1

combine_headers () {
	read -d "" HTML

	if [ "$1" = "" ]; then
		echo "$HTML"
	else
		echo "$1"
		echo ""
		echo "$HTML"
	fi
}

# Copy everything that's not Markdown or HTML.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose --exclude "*.md" --exclude "*.html" --exclude "feeds" "$SITE_PATH/$SOURCE_DIR/" "$SITE_PATH/$OUTPUT_DIR/"

# Delete any HTML files for which the source was removed.
find "$SITE_PATH/$OUTPUT_DIR" -type f -name "*.html" |
	while read -r file; do
		OLD_PATH=$(echo "$file" |
			sed "s|^$SITE_PATH/$OUTPUT_DIR|$SITE_PATH/$SOURCE_DIR|" |
			sed 's|.html$|.md|')
		if [ ! -f "$OLD_PATH" ]; then
			rm "$file"
		fi
	done

# Parse and create all the HTML files.
find "$SITE_PATH/$SOURCE_DIR" -type f -name "*.md" |
	while read -r file; do
		NEW_PATH=$(echo "$file" |
			sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" |
			sed 's|.md$|.html|')
		# Only process files whose destination doesn't exist, or which has been recently changed.
		if [ ! -f "$NEW_PATH" ] || [[ $(find "$file" -mtime -7) ]]; then
			echo "$file"

			# Get everything after the metadata.
			if grep -q "^Title: " "$file"; then
				HEADERS=$(sed "/^$/q" "$file")
				MARKDOWN=$(sed "1,/^$/d" "$file")
			else
				HEADERS=""
				MARKDOWN=$(cat "$file")
			fi

			echo "$MARKDOWN" |
				# Convert Markdown to HTML.
				markdown |
				# Recombine with the metadata and hand it to Prolog.
				combine_headers "$HEADERS" |
				#gprolog --consult-file parse_entry.pl --consult-file "$SITE_PATH/site.pl" --entry-goal "generate_entry" |
				swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry." |
				# Some Prolog variants will output banners and "compiling" output no matter how nicely you ask them not to.
				# Strip everything before the doctype declaration.
				awk "/<!DOCTYPE/{i++}i" |
				# Smarten punctuation.
				smartypants \
				> "$NEW_PATH"
		fi
	done

# Generate the RSS feed.
mkdir -p "$SITE_PATH/$OUTPUT_DIR/feeds"
# Grep the date of each article.
ARTICLES=$(grep --recursive --include=\*.md "^Date: " "$SITE_PATH/$SOURCE_DIR" |
	# Reformat the output so the date comes first, then the file name.
	sed --quiet --regexp-extended 's/^([^:]+):(.+)$/\2\t\1/p' |
	# Sort articles by date.
	sort |
	# Reformat to just the file names.
	cut --fields=2 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Convert paths so we operate on the generated HTML, not the unformatted Markdown.
	sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" |
	sed 's|.md$|.html|' |
	# Glue the file names together to be passed to Prolog.
	paste --serial --delimiters=',' - |
	sed "s|,|','|g")
BUILD_DATE=$(date +"%Y-%m-%d %T")
# Parse the articles and generate the RSS.
#gprolog --consult-file generate_rss.pl --consult-file "$SITE_PATH/site.pl" --entry-goal "generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])" |
swipl --traditional --quiet -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." |
	# Strip everything before the XML declaration.
	awk "/<?xml/{i++}i" \
	> "$SITE_PATH/$OUTPUT_DIR/feeds/rss.xml"
