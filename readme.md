# Tastic

A static site generator in Prolog (mostly).

## What is this?

A few months ago I lost the source files I used to generate my static website. Fortunately there was no irreparable data loss because I still had the generated site up on my server. The problem was now I needed to write a script that would extract all the articles into source files again, and then reconfigure the site generator. Then I went, "Oh. This is a Prolog problem." I figured if I could write a Prolog program that described my HTML template then I could use the same code both to un-generate and re-generate the website, because a Prolog program is basically a set of rules and the logic can be run in either direction. (But then I love Prolog so every problem is a Prolog problem but I don't care. Fight me.)

So the skinny is I wound up writing my own static website generator in Prolog. Well, the main components are in Prolog. I also wrote a bash script to make use of a bunch of common \*nix utilities (find, sed, grep, etc.) and to pipe output to some third-party programs where I needed them (Smartypants, and it's still TBD but possibly Pandoc in the future). Weirdest bit was that I just couldn't find anything decent to generate RSS feeds. I considered dropping the RSS all together, but I've spent enough time haranguing people for not supporting interoperable standards that I didn't want to be a hypocrite. I wound up writing my own RSS generator too, also in Prolog.

It's pretty closely tailored to my specific needs, but it works, and IMHO it works better than my old site generator which injected a bunch of nonsense into my HTML. To make this work for your site, all you need to do is define the template of your website in "html.pl".

## Dependencies

* Bash. Used to run the script that automates everything else.
* A Prolog interpreter. Tested with [SWI-Prolog](https://www.swi-prolog.org/), but the syntax aims to be vanilla ISO Prolog and should work with any implementation.
* [Smartypants](https://github.com/leohemsted/smartypants.py). Used to smarten the punctuation in the HTML output.

## Assumptions

The website folder used in the second argument is expected to contain three things:

* a "source" folder containing the website's source;
* an "output" folder containing the website's static output;
* and a "site.pl" file containing site-specific definitions.

One or the other of the "source" and "output" folders must be populated, but not necessarily both. In the case of saving a website for which you'd lost the source code, you'd populate "output", ungenerate the site, then commit the contents of "source" to version control.

site.pl contains DCG definitions of this site's specifics, such as title, author, etc. An example site.pl file might look like this:

	site_title --> "My website name".

	site_subtitle --> "My website description/subtitle".

	site_url --> "https://www.example.com".

	user_email --> "webmaster@example.com".

	user_name --> "Harold Gruntfuttock".

## Use

Generate a static website from Markdown sources:

	./tastic.sh generate /home/user/website

Generate source files from a static website:

	./tastic.sh ungenerate /home/user/website

## Still to do

The source Markdown files are currently assumed to be plain HTML with a Markdown header containing metadata. I'm going to need something to convert proper Markdown to HTML, so I'll probably add Pandoc as a dependency to tastic.sh. I expect this will also replace Smartypants for doing smart punctuation.
