package Apache::SiteConfig::Statement;
use Moose;
has parent => ( is => 'rw' );

sub get_level {
    my ($self) = @_;
    my $cnt = 0;
    my $p = $self->parent;
    $cnt++ if $p;
    while( $p && $p->parent ) {
        $p = $p->parent;
        $cnt++;
    }

    return $cnt;
}

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



package Apache::SiteConfig::Root;
use Moose;
extends 'Apache::SiteConfig::Statement';

has statements => ( is => 'rw' , isa => 'ArrayRef' , default => sub { [ ] } );

sub add_directive {
    my ($self,$name,$values) = @_;
    $values = ref($values) ? $values : [ $values ];
    my $dt = Apache::SiteConfig::Directive->new( 
        name => $name,
        values => $values,
        parent => $self,
    );
    push @{$self->statements} , $dt;
    return $dt;
}

sub add_section {
    my ($self,$name,$value) = @_;
    my $section = Apache::SiteConfig::Section->new( 
        name => $name, 
        value => $value,
        parent => $self,
    );
    push @{$self->statements} , $section;
    return $section;
}

sub to_string {
    my ($self) = @_;
    return join "\n",
        (map { $_->to_string } @{ $self->statements });
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
use Moose;

has options => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    my $args = shift;
    $self->options( $args );
    my $root = Apache::SiteConfig::Root->new;
    $self->context( $root );
}

sub build {
    my ($self,$template,%args) = @_;
    my $context = $template->new( %args );
    return $context;
}

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
