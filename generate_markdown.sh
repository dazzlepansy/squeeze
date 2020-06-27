#!/usr/bin/env sh

echo "$1"

swipl --traditional --quiet -l parse_entry.pl -g "consult('$2/site.pl'), parse_entry('$2/output/$1')." \
	> "$2/source/${1%%.html}.md"
