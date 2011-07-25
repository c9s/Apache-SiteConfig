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
__END__
=head1 NAME

Tasky - Extendable Simple Task DSL

=head1 SYNOPSIS

The ruby rake style task:

    use Tasky;


    meta name => 'your name',
         email => 'cornelius.howl@gmail.com',
         company => 'company name';

    desc 'do something',
    task 'something' => sub {
        my $self = shift;

        print $self->{name}  # get name

    };

    desc 'do something',
    task 'something' => sub {

    };

To run the task "something", you can run:

    perl Taskfile something

Tasky also provides tasky shell script, tasky will look for a file named C<Taskfile>:

    tasky something

    tasky deploy

    tasky install

=head1 DESCRIPTION

This module ... 

=head1 IMPORT

=head1 AUTHOR

Yo-An Lin cornelius.howl {at} gmail.com

=head1 COPYRIGHT AND LICENSE

Copyright 2009-2010 by {company}, Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

