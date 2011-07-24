#!/usr/bin/env perl
use feature ':5.10';
use Test::More;
use lib 'lib';
use Apache::SiteConfig;
use Apache::SiteConfig::Template;

# default template
my $deploy = Apache::SiteConfig::Deploy->new;
my $context = $deploy->build( site_id => 'foo' );
# my $context = $template->build( );
say $context->to_string;

done_testing;
