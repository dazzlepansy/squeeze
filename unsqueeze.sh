#!/usr/bin/env sh

# Ungenerate a static website.

# Usage: unsqueeze.sh SITE_PATH

export SITE_PATH=$1

export OUTPUT_PATH="$SITE_PATH/output"
export SOURCE_PATH="$SITE_PATH/source"

# Copy everything that's not HTML.
# Excludes the RSS folder, which we create ourselves upon generation.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose \
       --exclude "*.html" --exclude "feeds" \
       "$OUTPUT_PATH/" "$SOURCE_PATH/"

# Parse and create all the Markdown files.
find "$OUTPUT_PATH" -type f -name "*.html" |
	sed "s|$SITE_PATH/output/||g" |
	while IFS= read -r file; do
		echo "$file"
	
		swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), parse_entry('$SITE_PATH/output/$file')." \
			> "$SITE_PATH/source/${file%%.html}.md" &
	done

# Wait until all jobs have completed.
wait

# Unsmarten the punctuation.
MARKDOWN_FILES="$(find "$SOURCE_PATH" -type f -name "*.md")"
for markdown_file in $MARKDOWN_FILES; do
	sed "s/&nbsp;/ /g" "$markdown_file" |
	# Replace single quotes.
	sed "s/&#39;/'/g" |
	sed "s/&#8216;/'/g" |
	sed "s/&#8217;/'/g" |
	sed "s/&rsquo;/'/g" |
	sed "s/&lsquo;/'/g" |
	# Replace double quotes.
	sed "s/&#8220;/\"/g" |
	sed "s/&#8221;/\"/g" |
	sed "s/&rdquo;/\"/g" |
	sed "s/&ldquo;/\"/g" |
	sed "s/&quot;/\"/g" \
	> "$markdown_file"
done
