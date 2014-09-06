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
