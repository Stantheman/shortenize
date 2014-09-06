#!/usr/bin/env perl
use strict;
use warnings;

use LWP::UserAgent;
use URI::Find::Simple qw( list_uris );

my $shortener_url = 'http://gaw.sh';

for my $line (<>) {
	my $new_line = $line;
	for my $url (list_uris($line)) {
		$new_line =~ s/$url/shorten($url)/e;
	}
	print $new_line;
}

sub shorten {
	my $url = shift;
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
URL::Find::Simple to locate the URLs on STDIN.

=head1 AUTHOR

Stan Schwertly (http://www.schwertly.com)

