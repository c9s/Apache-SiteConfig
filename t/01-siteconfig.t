#!/usr/bin/env perl
use Test::More;
use lib 'lib';
use Apache::SiteConfig;


my $sect = Apache::SiteConfig::Section->new( name => 'VirtualHost' , value => '*:80' );
ok( $sect );
is( $sect->name , 'VirtualHost' );
is( $sect->value , '*:80' );


my $dt = Apache::SiteConfig::Directive->new( name => 'ServerName' , values => [ 'localhost' ] );
is( $dt->name , 'ServerName' );
is_deeply( $dt->values, ['localhost'] );
is( $dt->to_string , 'ServerName localhost' );


$config = Apache::SiteConfig->new(
    SiteId => 'foo',
    VirtualHost => '*:80',
    LogDir => '/var/log/apache2/sites',
    ServerName => 'foo.com',
    ServerAlias => 'test.com',
    Port => ''
);

ok( $config );
ok( $config->options );
ok( $config->options->{SiteId} );


done_testing;
