#!/usr/bin/env sh

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
find "$OUTPUT_PATH" -type f -name "*.html" -printf "%P\0" |
	xargs --null --max-procs 99 -I % sh generate_markdown.sh "%" "$SITE_PATH"

# Unsmarten the punctuation.
find "$SOURCE_PATH" -type f -name "*.md" \
	-exec sed -i "s/&nbsp;/ /g" {} + \
	-exec sed -E -i "s/(&#39;|&#8216;|&#8217;|&rsquo;|&lsquo;)/'/g" {} + \
	-exec sed -E -i "s/(&#8220;|&#8221;|&rdquo;|&ldquo;|&quot;)/\"/g" {} +
