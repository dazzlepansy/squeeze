#!/bin/bash

OUTPUT_DIR=output
SOURCE_DIR=source

SITE_PATH=$1

# Copy everything that's not Markdown or HTML.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose --exclude "*.md" --exclude "*.html" --exclude "feeds" "$SITE_PATH/$SOURCE_DIR/" "$SITE_PATH/$OUTPUT_DIR/"

# Delete any HTML files for which the source was removed.
find "$SITE_PATH/$OUTPUT_DIR" -type f -name "*.html" -print0 |
	while IFS= read -r -d '' file; do
		OLD_PATH=`echo "$file" |
			sed "s|^$SITE_PATH/$OUTPUT_DIR|$SITE_PATH/$SOURCE_DIR|" |
			sed 's|.html$|.md|'`
		if [ ! -f $OLD_PATH ]; then
			rm $file
		fi
	done

# Parse and create all the HTML files.
find "$SITE_PATH/$SOURCE_DIR" -type f -name "*.md" -print0 |
	while IFS= read -r -d '' file; do
		echo $file
		NEW_PATH=`echo "$file" |
			sed "s|^$SITE_PATH/$SOURCE_DIR|$SITE_PATH/$OUTPUT_DIR|" |
			sed 's|.md$|.html|'`
		# Only process files whose destination doesn't exist, or which has been recently changed.
		if [ ! -f $NEW_PATH ] || [[ $(find $file -mtime -7) ]]; then
			# Get everything after the metadata and feed it through Pandoc.
			sed "1,/^$/d" "$file" |
				# Convert Markdown to HTML and smarten punctuation.
				pandoc --ascii --from markdown+smart --to html |
				# Recombine with the metadata and hand it to Prolog.
				(sed "/^$/q" "$file" && cat) |
				swipl --traditional -q -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry." \
				> "$NEW_PATH"
		fi
	done

# Generate the RSS feed.
mkdir -p "$SITE_PATH/$OUTPUT_DIR/feeds"
# Grep the date of each article.
ARTICLES=`grep -R --include=\*.md "^Date: " "$SITE_PATH/$SOURCE_DIR" |
	# Reformat the output so the date comes first, then the file name.
	sed -rn 's/^([^:]+):(.+)$/\2\t\1/p' |
	# Sort articles by date.
	sort |
	# Reformat to just the file names.
	cut -f2 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Glue the file names together to be passed to Prolog.
	paste -sd ',' - |
	sed "s|,|','|g"`
BUILD_DATE=`date +"%Y-%m-%d %T"`
# Parse the articles and generate the RSS.
swipl --traditional -q -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." \
	> "$SITE_PATH/$OUTPUT_DIR/feeds/rss.xml"