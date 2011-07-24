package Apache::SiteConfig::Directive;
use Moose;

extends 'Apache::SiteConfig::Statement';

has name => ( is => 'rw' );
has values => ( is => 'rw' , isa => 'ArrayRef' , default => sub { [ ] } );

sub to_string {
    my ($self) = @_;
    my $indent = ' ' x 4 x $self->get_level;
    return $indent . join(' ' , $self->name, @{ $self->values } );
}




package Apache::SiteConfig::Section;
use Moose;
extends 'Apache::SiteConfig::Root';

has name => ( is => 'rw' );
has value => ( is => 'rw' );

sub to_string {
    my ($self) = @_;
    my $level = $self->get_level;
    my $indent = " " x ($level * 4);
    return join "\n" ,"$indent<@{[$self->name]} @{[ $self->value ]}>",
        (map { $_->to_string } @{ $self->statements }),
        "$indent</@{[ $self->name ]}>\n";
}


package Apache::SiteConfig;
use strict;
use warnings;
our $VERSION = '0.01';


1;
__END__

=head1 NAME

Apache::SiteConfig -

=head1 SYNOPSIS

    use Apache::SiteConfig;
    $config = Apache::SiteConfig->new(
        SiteId => 'foo',
        LogDir => 
        Apache => {
            ServerName =>  ...
            ServerAlias =>  ...
            ErrorLog =>  ...
            CustomLog =>  ...
        }
    );


=head1 DESCRIPTION

Apache::SiteConfig is

=head1 AUTHOR

Yo-An Lin E<lt>cornelius.howl {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
