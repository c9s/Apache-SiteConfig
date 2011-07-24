package Tasky;
use warnings;
use strict;

sub import {
    my ($class,$args) = @_;


    no strict 'refs';
    for my $key ( qw(name domain domain_alias webroot source task) ) {
        *{ 'main::' . $key } = sub { 
            ${ $class .'::'}{ $key }->( $Single , @_ );
        };
    }

}

1;
