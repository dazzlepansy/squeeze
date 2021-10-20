#!/usr/bin/env sh

# Ungenerate a static website.

# Usage: unsqueeze.sh site_path

export site_path=$1

export output_path="$site_path/output"
export source_path="$site_path/source"

# Copy everything that's not HTML.
# Excludes the RSS folder, which we create ourselves upon generation.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose \
       --exclude "*.html" --exclude "feeds" \
       "$output_path/" "$source_path/"

# Parse and create all the Markdown files.
html_files="$(find "$output_path" -type f -name "*.html")"
line_count="$(echo "$html_files" | wc -l | tr -d -c '[:digit:]')"
index=0

echo "$html_files" |
	sed "s|$output_path/||" |
	while IFS= read -r file ; do
		echo "$file"
		index="$(expr "$index" + 1)"
	
		swipl --traditional --quiet -l parse_entry.pl -g "consult('$site_path/site.pl'), parse_entry('$output_path/$file')." |
			# Unsmarten the punctuation.
			sed 's/&nbsp;/ /g' |
			# Replace single quotes.
			sed "s/&#39;/'/g" |
			sed "s/&#8216;/'/g" |
			sed "s/&#8217;/'/g" |
			sed "s/&rsquo;/'/g" |
			sed "s/&lsquo;/'/g" |
			# Replace double quotes.
			sed 's/&#8220;/"/g' |
			sed 's/&#8221;/"/g' |
			sed 's/&rdquo;/"/g' |
			sed 's/&ldquo;/"/g' |
			sed 's/&quot;/"/g' \
			> "$source_path/${file%.html}.md" &

		# Wait until all jobs have completed.
		[ "$index" -eq "$line_count" ] &&
			wait
	done
