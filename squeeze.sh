#!/usr/bin/env sh

# Generate a static website.

# Usage: squeeze.sh [-f|--force] site_path

force=0

# Loop through all the arguments and set flags/options.
while [ "$#" -gt 0 ] ; do
	case "$1" in
		-f|--force)
			force=1
			shift
			;;
		*)
			site_path="$1"
			shift
			;;
	esac
done

output_path="$site_path/output"
source_path="$site_path/source"
feed_path="$output_path/feeds/rss.xml"

# A space-separated list of all the process IDs we've started.
proc_ids=""
# Max number of processes to run at once.
# There is no way to do `nproc` with only POSIX tools,
# so the best way to make this portable is with fallbacks.
max_processes="$(nproc 2>/dev/null ||
	sysctl -n hw.ncpu 2>/dev/null ||
	getconf _NPROCESSORS_ONLN 2>/dev/null)"

# Regenerate everything if the force flag has been used or there is
# no RSS file, but otherwise only regenerate Markdown files that have
# changed since the RSS feed was updated.
rsync_exclude=
find_test=
[ "$force" -eq 0 ] &&
	[ -f "$feed_path" ] &&
	# Don't delete already generated HTML files.
	rsync_exclude="--exclude *.html" &&
	# Only find Markdown files newer than the RSS feed.
	find_test="-newer $feed_path" &&
	# Find and delete any HTML files for which a source Markdown
	# no longer exists.
	find "$output_path" -type f -name "*.html" |
		sed "s|$output_path/||" |
		while IFS= read -r file ; do
			[ ! -f "$source_path/${file%.html}.md" ] &&
				echo "deleting orphaned $file" &&
				rm "$output_path/$file"
		done

# Copy everything that's not Markdown.
# This will also create the folder structure for the destination Markdown files.
rsync --archive --delete --verbose \
	--exclude "*.md" --exclude "feeds" $rsync_exclude \
	"$source_path/" "$output_path/"

# Parse and create all the HTML files.
find "$source_path" -type f -name "*.md" $find_test |
	sed "s|$source_path/||" |
	while IFS= read -r file ; do
		echo "$file"

		# Determine if this file has any metadata at the start.
		# Metadata are in the format Key: value, so it's easy to detect.
		head -n 1 "$source_path/$file" | grep -q "^[A-Za-z]*: " &&
			headers=1 ||
	       		headers=0

		# Get everything after the metadata.
		([ "$headers" -eq 1 ] && sed '1,/^$/d' || cat) < "$source_path/$file" |
			# Convert Markdown to HTML.
			markdown_py --extension footnotes --extension md_in_html --extension smarty --quiet --output_format xhtml |
			# Recombine with the metadata and hand it to Prolog.
			([ "$headers" -eq 1 ] && sed '/^$/q' "$source_path/$file" ; cat) |
			swipl --traditional --quiet -l parse_entry.pl -g "consult('$site_path/site.pl'), generate_entry." |
			# Unwrap block-level elements that have erroneously been wrapped in <p> tags.
			sed 's|<p><details|<details|g' |
			sed 's|</summary></p>|</summary>|g' |
			sed 's|<p></details></p>|</details>|g' |
			sed 's|<p><figure|<figure|g' |
			sed 's|</figure></p>|</figure>|g' |
			# Smarten punctuation.
			smartypants \
			> "$output_path/${file%.md}.html" &

		# Add the most recent process ID to the list.
		proc_ids="$! $proc_ids"
		# Pause while the number of created processes is greater than
		# or equal to the max processes. We have to subtract one
		# because the `ps` command always outputs a header that we
		# don't want to count.
		while [ "$(expr "$(ps -p "${proc_ids%% }" | wc -l)" - 1)" -ge "$max_processes" ] ; do
			true
		done
	done

# Wait until all jobs have completed.
wait
# The `wait` command doesn't seem to wait for all the running jobs.
# Maybe it's stopping after all `swipl` processes complete?
# This hack just checks to see if any sed or smartypants processes are running.
while [ $(ps -A | grep -c -e " sed$" -e " smartypants$") -gt 0 ]; do
	sleep 1
done

# Generate the RSS feed.
mkdir -p "${feed_path%/*}"
# Grep the date of each article.
find "$output_path" -type f -name "*.html" \
	-exec grep "id=\"article-date\"" {} + |
	# Sort articles by date (skipping the first field).
	sort -k 2 |
	# Get the last (i.e. most recent) posts for the RSS feed.
	tail -5 |
	# Reformat to just the file names.
	cut -f 1 -d : |
	# Parse the articles and generate the RSS.
	swipl --traditional --quiet -l generate_rss.pl -g "consult('$site_path/site.pl'), generate_rss(\"$(date '+%a, %d %b %Y %T %Z')\")." \
	> "$feed_path"
