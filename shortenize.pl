#!/usr/bin/env perl
use strict;
use warnings;

use LWP::UserAgent;
use URI::Find;

my $shortener_url = 'http://gaw.sh';
my $input = do { local $/; <STDIN> };
my $finder = URI::Find->new(\&shorten);

$finder->find(\$input);
print $input;

sub shorten {
	my (undef, $url) = @_;
	my $ua = LWP::UserAgent->new(agent=>'https://github.com/Stantheman/shortenize');
	my $response = $ua->post(
		$shortener_url,
		{
			'url' => $url
		}
	);

	return if ($response->is_error);
	return if ($response->decoded_content =~ m|span id="error">.*?</span>|);
	
	my $alias = ($response->decoded_content =~ m|id="url" href="(.*?)"|)[0];
	return unless $alias;

	return $shortener_url . $alias;
}

__END__

=head1 shortenize

Takes STDIN, replaces any URLs with shortened ones, prints back out.

=head1 USAGE

	echo "my website is http://schwertly.com" | ./shortenize  
	./shortenize <file_with_long_urls >file_with_short_ones 

=head1 SYNOPSIS

	./shortenize 

	Options:
		none

=head1 DESCRIPTION

shortenize takes input on STDIN and replaces all URLs with short ones. I
use it to make my IRC channel of NYT feeds from being unreadable.

=head1 DEPENDENCIES

rss2text is written in perl and uses LWP::UserAgent to shorten links, and
URL::Find to locate the URLs on STDIN.

These modules are packaged in Debian and can be installed by running:

    apt-get install libwww-perl liburi-find-perl

=head1 AUTHOR

Stan Schwertly (http://www.schwertly.com)

