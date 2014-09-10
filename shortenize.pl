#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long qw(:config auto_help);
use LWP::UserAgent;
use Pod::Usage;
use URI::Find;
use YAML::Tiny;

my $options = get_options();
my $provider = get_provider($options->{provider}) or die "Couldn't get provider";

my $input = do { local $/; <STDIN> };
my $finder = URI::Find->new(\&shorten);

$finder->find(\$input);
print $input;

sub shorten {
	my (undef, $url) = @_;
	my $ua = LWP::UserAgent->new(agent=>'https://github.com/Stantheman/shortenize');
	my $response = $ua->post(
		$provider->{url} . $provider->{postpoint},
		{
			$provider->{form}->{url} => $url
		}
	);

	return if ($response->is_error);
	my $shortened = ($response->decoded_content =~ m/$provider->{answer_regex}/m)[0];
	return $shortened;
}

sub get_provider {
	my $provider = shift;
	# look in .shortenize.d/
	my $provider_dir = '.shortenizer.d/';
	return unless (-d $provider_dir);
	return unless (-f $provider_dir . $provider);

	my $provider_config = YAML::Tiny->read($provider_dir . $provider);
	return $provider_config->[0];
}

sub get_options {
	my %opts = (
		'provider' => 'gaw.sh',
	);
	GetOptions(\%opts,
		'provider|p:s',
	) or pod2usage(2);

	return \%opts;
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
URI::Find to locate the URLs on STDIN.

These modules are packaged in Debian and can be installed by running:

    apt-get install libwww-perl liburi-find-perl

=head1 AUTHOR

Stan Schwertly (http://www.schwertly.com)

