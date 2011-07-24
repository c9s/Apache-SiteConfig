package Apache::SiteConfig::Deploy;
use warnings;
use strict;
use Moose;
use File::Spec;
use File::Path qw(mkpath rmtree);

has dirs => ( is => 'rw' );


sub new_context {
    return Apache::SiteConfig::Root->new;
}

sub required {
    qw(site_id);
}

sub build {
    my ($self,%args) = @_;
    my $args = \%args;

    for( $self->required ) {
        die "Key $_ is required" unless $args{$_};
    }

    my $init = $args{init};
    my $root = $self->new_context;

    my $site_dir = $args->{site_dir} || File::Spec->join( '/var/sites' );
    mkpath [ $site_dir ] if $init;

    my $document_root = $args->{DocumentRoot} || File::Spec->join( $args->{site_dir} , $args->{site_id} , $args->{site_webpath} );
    mkpath [ $document_root ] if $init;

    my $log_dir = File::Spec->join( $args->{site_dir} , $args->{site_id} , 'apache2' , 'logs' );
    my $access_log = File::Spec->join( $log_dir , 'access.log' );
    my $error_log = File::Spec->join( $log_dir , 'error.log' );




    my $vir = $root->add_section( 'VirtualHost' , '*:80' );
    $vir->add_directive( 'DocumentRoot' , $document_root );

    for( grep { $args->{$_} } qw(ServerName ServerAlias)) {
        $vir->add_directive( $_ , $args->{$_} );
    }

    my $root_dir = $vir->add_section('Directory' , '/');
    $root_dir->add_directive( 'Options' , 'FollowSymLinks' );
    $root_dir->add_directive( 'AllowOverride' , 'None' );

    my $doc_root = $vir->add_section('Directory', $document_root );
    $doc_root->add_directive( 'Options' , 'Indexes FollowSymLinks MultiViews' );
    $doc_root->add_directive( 'AllowOverride' , 'None' );
    $doc_root->add_directive( 'Order' , 'allow,deny' );
    $doc_root->add_directive( 'Allow' , 'from all' );

    return $root;
}



1;
__END__


    Deploy->new( 
        site_id => 'projectA',
        site_dir => '/var/sites',  # optional
        site_git => 'git@foo.com:projectA.git',
        site_domain => 'foo.com',
        site_web => 'webroot/',
    );

