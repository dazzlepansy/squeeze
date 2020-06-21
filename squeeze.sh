#!/usr/bin/env sh

SITE_PATH=$1

OUTPUT_PATH="$SITE_PATH/output"
SOURCE_PATH="$SITE_PATH/source"

# Copy everything that's not Markdown or HTML.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose --exclude "*.md" --exclude "*.html" --exclude "feeds" "$SOURCE_PATH/" "$OUTPUT_PATH/"

# Delete any HTML files for which the source was removed.
find "$OUTPUT_PATH" -type f -name "*.html" |
	while read -r file; do
		OLD_PATH=$(echo "$file" |
			sed "s|^$OUTPUT_PATH|$SOURCE_PATH|" |
			sed 's|.html$|.md|')
		[ ! -f "$OLD_PATH" ] && rm "$file"
	done

# Parse and create all the HTML files.
find "$SOURCE_PATH" -type f -name "*.md" |
	while read -r file; do
		NEW_PATH=$(echo "$file" |
			sed "s|^$SOURCE_PATH|$OUTPUT_PATH|" |
			sed 's|.md$|.html|')
		# Only process files whose destination doesn't exist, or which has been recently changed.
		[ ! -f "$NEW_PATH" ] || find "$file" -mtime -7 | grep -q . &&
			echo "$file" &&
			swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry('$file')." |
				# Smarten punctuation.
				smartypants \
				> "$NEW_PATH"
	done

# Generate the RSS feed.
mkdir -p "$OUTPUT_PATH/feeds"
# Grep the date of each article.
ARTICLES=$(grep --recursive --include=\*.md "^Date: " "$SOURCE_PATH" |
	# Sort articles by date (skipping the first field).
	sort +1 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Reformat to just the file names.
	cut --fields=1 --delimiter=: |
	# Convert paths so we operate on the generated HTML, not the unformatted Markdown.
	sed "s|^$SOURCE_PATH|$OUTPUT_PATH|" |
	sed 's|.md$|.html|' |
	# Glue the file names together to be passed to Prolog.
	paste --serial --delimiters=',' - |
	sed "s|,|','|g")
BUILD_DATE=$(date +"%Y-%m-%d %T")
# Parse the articles and generate the RSS.
swipl --traditional --quiet -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(\"$BUILD_DATE\", ['$ARTICLES'])." \
	> "$OUTPUT_PATH/feeds/rss.xml"
