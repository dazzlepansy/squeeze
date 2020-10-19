#!/usr/bin/env sh

echo "$1"

swipl --traditional --quiet -l parse_entry.pl -g "consult('$2/site.pl'), generate_entry('$2/source/$1')." |
	# Unwrap block-level elements that have erroneously been wrapped in <p> tags.
	sed "s|<p><details|<details|g" |
	sed "s|</summary></p>|</summary>|g" |
	sed "s|<p></details></p>|</details>|g" |
	sed "s|<p><figure|<figure|g" |
	sed "s|</figure></p>|</figure>|g" |
	# Smarten punctuation.
	smartypants \
	> "$2/output/${1%%.md}.html"
