#!/usr/bin/env sh

# Convert a Markdown file to HTML using a site's template.

# Usage: generate_html.sh SITE_PATH MARKDOWN_FILE
#
# MARKDOWN_FILE is expected to be found at SITE_PATH/source/MARKDOWN_FILE.
# The resulting HTML will be saved to SITE_PATH/output/HTML_FILE, where
# HTML_FILE is the same filename as MARKDOWN_FILE but with a .html extension.

echo "$2"

swipl --traditional --quiet -l parse_entry.pl -g "consult('$1/site.pl'), generate_entry('$1/source/$2')." |
	# Unwrap block-level elements that have erroneously been wrapped in <p> tags.
	sed "s|<p><details|<details|g" |
	sed "s|</summary></p>|</summary>|g" |
	sed "s|<p></details></p>|</details>|g" |
	sed "s|<p><figure|<figure|g" |
	sed "s|</figure></p>|</figure>|g" |
	# Smarten punctuation.
	smartypants \
	> "$1/output/${2%%.md}.html"
