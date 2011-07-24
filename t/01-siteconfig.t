#!/usr/bin/env perl
use feature ':5.10';
use Test::More;
use lib 'lib';
use Apache::SiteConfig;

my $sect = Apache::SiteConfig::Section->new( name => 'VirtualHost' , value => '*:80' );
ok( $sect );
is( $sect->name , 'VirtualHost' );
is( $sect->value , '*:80' );

$sect->add_directive( 'ServerName' , ['localhost'] );

is( $sect->to_string , <<'END' );
<VirtualHost *:80>
    ServerName localhost
</VirtualHost>
END

my $sub_sect = $sect->add_section( 'Location' , '/' );
ok( $sub_sect );


say $sect->to_string;

is( $sect->to_string , <<'END' );
<VirtualHost *:80>
    ServerName localhost
    <Location />
    </Location>

</VirtualHost>
END



my $dt = Apache::SiteConfig::Directive->new( name => 'ServerName' , values => [ 'localhost' ] );
is( $dt->name , 'ServerName' );
is_deeply( $dt->values, ['localhost'] );
is( $dt->to_string , 'ServerName localhost' );

my $config = Apache::SiteConfig->new();
ok( $config );

$config->context->add_section( 'Location' , '/' );
$config->context->add_section( 'Location' , '/foo' );
$config->context->add_section( 'Location' , '/bar' );
ok( $config->context->to_string() );

done_testing;
