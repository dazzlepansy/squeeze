#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$1

# Create the directory structure.
find "$SITE_PATH"/"$SOURCE_DIR" -type d |
	sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" |
	xargs -0 -d '\n' mkdir -p --

# Parse and create all the HTML files.
find "$SITE_PATH"/"$SOURCE_DIR" -type f -name "*.md" -print0 |
	while IFS= read -r -d '' file; do
		echo $file
		NEW_PATH=`echo "$file" | sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" | sed 's|.md$|.html|'`
		# Only process files whose destination doesn't exist, or which has been recently changed.
		if [ ! -f $NEW_PATH ] || [[ $(find $file -mtime -7) ]]; then
			# Get everything after the metadata and feed it through Pandoc.
			sed "1,/^$/d" "$file" |
				pandoc --ascii --from markdown+smart --to html |
				# Recombine with the metadata and hand it to Prolog.
				(sed "/^$/q" "$file" && cat) |
				swipl --traditional -q -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry." \
				> "$NEW_PATH"
		fi
	done

# Copy anything else directly.
rsync --archive --delete --verbose --exclude "*.md" --exclude "*.html" --exclude "feeds" "$SITE_PATH/$SOURCE_DIR/" "$SITE_PATH/$OUTPUT_DIR/"

# Generate the RSS feed.
mkdir -p "$SITE_PATH"/"$OUTPUT_DIR"/feeds
# Grep the date of each article, sort them by date, then get a list of file names and take the most recent five.
ARTICLES=`grep -R --include=\*.md "^Date: " "$SITE_PATH"/"$SOURCE_DIR" | sed -rn 's/^([^:]+):(.+)$/\2\t\1/p' | sort | cut -f2 | tail -5 | paste -sd ',' - | sed "s|,|','|g"`
BUILD_DATE=`date +"%Y-%m-%d %T"`
swipl --traditional -q -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." \
	> "$SITE_PATH"/"$OUTPUT_DIR"/feeds/rss.xml