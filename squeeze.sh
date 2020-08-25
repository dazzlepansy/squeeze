#!/usr/bin/env sh

export SITE_PATH=$1

export OUTPUT_PATH="$SITE_PATH/output"
export SOURCE_PATH="$SITE_PATH/source"

# Copy everything that's not Markdown.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose \
	--exclude "*.md" --exclude "feeds" \
	"$SOURCE_PATH/" "$OUTPUT_PATH/"

# Parse and create all the HTML files.
find "$SOURCE_PATH" -type f -name "*.md" -printf "%P\0" |
	xargs --null --max-procs 99 -I % sh generate_html.sh "%" "$SITE_PATH"

# Generate the RSS feed.
mkdir -p "$OUTPUT_PATH/feeds"
# Grep the date of each article.
ARTICLES=$(grep --recursive --include "*.md" "^Date: " "$SOURCE_PATH" |
	# Sort articles by date (skipping the first field).
	sort +1 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Reformat to just the file names.
	cut --fields 1 --delimiter : |
	# Convert paths so we operate on the generated HTML, not the unformatted Markdown.
	sed "s|^$SOURCE_PATH|$OUTPUT_PATH|" |
	sed 's|.md$|.html|' |
	# Glue the file names together to be passed to Prolog.
	paste --serial --delimiters ',' - |
	sed "s|,|','|g")
# Parse the articles and generate the RSS.
swipl --traditional --quiet -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss(['$ARTICLES'])." \
	> "$OUTPUT_PATH/feeds/rss.xml"
