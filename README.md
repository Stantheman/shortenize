# shortenize

Takes STDIN, replaces any URLs with shortened ones, prints back out.

# USAGE

        echo "my website is http://schwertly.com" | ./shortenize  
        ./shortenize <file_with_long_urls >file_with_short_ones 

# SYNOPSIS

        ./shortenize 

        Options:
          -p, --provider          provider to use for shortening urls
          -l, --length            shorten urls over this length

# OPTIONS

- **-p** _provider_, **--provider**=_provider_

    Specify the URL shortener. By default, shortenizer uses 'gaw.sh'.

    Shortenizer looks in its local '.shortenizer.d' directory for a
    YAML file with the provider you specify.

- **-l** _length_, **--length**=_length_

    Shortens URLS over this length, defaults to 0/shorten every URL.

# DESCRIPTION

shortenize takes input on STDIN and replaces all URLs with short ones. I
use it to make my IRC channel of NYT feeds from being unreadable.

# DEPENDENCIES

rss2text is written in perl and uses LWP::UserAgent to shorten links, and
URI::Find to locate the URLs on STDIN. It uses YAML::Tiny to parse its config
files.

These modules are packaged in Debian and can be installed by running:

    apt-get install libwww-perl liburi-find-perl libyaml-tiny-perl

# AUTHOR

Stan Schwertly (http://www.schwertly.com)
