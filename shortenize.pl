#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use Getopt::Long qw(:config auto_help);
use LWP::UserAgent;
use Pod::Usage;
use URI::Find;
use YAML::Tiny;

my $options = get_options();
my $provider = get_provider($options->{provider}) or die "Couldn't get provider $options->{provider}";

my $input = do { local $/; <STDIN> };
my $finder = URI::Find->new(\&shorten);

$finder->find(\$input);
print $input;

sub shorten {
	my (undef, $url) = @_;
	return $url if length($url) < $options->{length};

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
	my $provider_dir = "$Bin/.shortenizer.d/";
	return unless (-d $provider_dir);
	return unless (-f $provider_dir . $provider);

	my $provider_config = YAML::Tiny->read($provider_dir . $provider);
	return $provider_config->[0];
}

sub get_options {
	my %opts = (
		'provider' => 'gaw.sh',
		'length'   => 0,
	);
	GetOptions(\%opts,
		'provider|p:s',
		'length|l:i',
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
	  -p, --provider          provider to use for shortening urls
	  -l, --length            shorten urls over this length

=head1 OPTIONS

=over 4

=item B<-p> I<provider>, B<--provider>=I<provider>

Specify the URL shortener. By default, shortenizer uses 'gaw.sh'.

Shortenizer looks in its local '.shortenizer.d' directory for a
YAML file with the provider you specify.

=item B<-l> I<length>, B<--length>=I<length>

Shortens URLS over this length, defaults to 0/shorten every URL.

=back

=head1 DESCRIPTION

shortenize takes input on STDIN and replaces all URLs with short ones. I
use it to make my IRC channel of NYT feeds from being unreadable.

=head1 DEPENDENCIES

rss2text is written in perl and uses LWP::UserAgent to shorten links, and
URI::Find to locate the URLs on STDIN. It uses YAML::Tiny to parse its config
files.

These modules are packaged in Debian and can be installed by running:

    apt-get install libwww-perl liburi-find-perl libyaml-tiny-perl

=head1 AUTHOR

Stan Schwertly (http://www.schwertly.com)

