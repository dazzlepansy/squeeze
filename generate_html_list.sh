#!/usr/bin/env sh

# Loop through a list of Markdown files and generate the corresponding HTML,
# launching a background job for each process.

# Usage: generate_html_list SITE_PATH MARKDOWN_FILE...

# The site path will be the first argument.
# Save its value and shift it down so we can take the rest together.
SITE_PATH="$1"
shift

# Get all the remaining arguments. These will be the file names.
# Remove the start of the path.
ARGS="$(echo "$@" | sed "s|$SITE_PATH/source/||g")"

for arg in $ARGS; do
	./generate_html.sh "$SITE_PATH" $arg &
done

# Wait until all jobs have completed.
wait
