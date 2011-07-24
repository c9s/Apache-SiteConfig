#!/usr/bin/env perl
use feature ':5.10';
use Test::More;
use lib 'lib';
use File::Path qw(rmtree mkpath);
use Apache::SiteConfig;
use Apache::SiteConfig::Template;
use Apache::SiteConfig::Deploy;

# default template
my $deploy = Apache::SiteConfig::Deploy->new;
my $context = $deploy->deploy(
    name         => 'foo',
    domain       => 'foo.com',
    domain_alias => 'bar.com',
    sites_dir => 'testing_root',
);
# my $context = $template->build( );
say $context->to_string;


ok( -e 'testing_root/foo' );
rmtree 'testing_root';


done_testing;
