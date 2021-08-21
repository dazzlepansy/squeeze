#!/usr/bin/env sh

# Generate a static website.

# Usage: squeeze.sh SITE_PATH

SITE_PATH=$1

OUTPUT_PATH="$SITE_PATH/output"
SOURCE_PATH="$SITE_PATH/source"

# Copy everything that's not Markdown.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose \
	--exclude "*.md" --exclude "feeds" \
	"$SOURCE_PATH/" "$OUTPUT_PATH/"

# Parse and create all the HTML files.
find "$SOURCE_PATH" -type f -name "*.md" |
	sed "s|$SITE_PATH/source/||g" |
	while IFS= read -r file; do
		echo "$file"

		swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), generate_entry('$SITE_PATH/source/$file')." |
			# Unwrap block-level elements that have erroneously been wrapped in <p> tags.
			sed "s|<p><details|<details|g" |
			sed "s|</summary></p>|</summary>|g" |
			sed "s|<p></details></p>|</details>|g" |
			sed "s|<p><figure|<figure|g" |
			sed "s|</figure></p>|</figure>|g" |
			# Smarten punctuation.
			smartypants \
			> "$SITE_PATH/output/${file%%.md}.html" &
	done

# Wait until all jobs have completed.
wait

# Generate the RSS feed.
mkdir -p "$OUTPUT_PATH/feeds"
# Grep the date of each article.
find "$OUTPUT_PATH" -type f -name "*.html" \
	-exec grep "id=\"article-date\"" {} + |
	# Sort articles by date (skipping the first field).
	sort -k 2 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Reformat to just the file names.
	cut -f 1 -d : |
	# Parse the articles and generate the RSS.
	swipl --traditional --quiet -l generate_rss.pl -g "consult('$SITE_PATH/site.pl'), generate_rss." \
	> "$OUTPUT_PATH/feeds/rss.xml"
