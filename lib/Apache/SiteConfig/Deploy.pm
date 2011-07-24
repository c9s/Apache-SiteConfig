package Apache::SiteConfig::Deploy;
use warnings;
use strict;
use Moose;
use File::Spec;
use File::Path qw(mkpath rmtree);

sub required {
    qw(name);
}

sub deploy {
    my ($self,%args) = @_;

    for( $self->required ) {
        die "Key $_ is required." unless $args{$_};
    }

    my $domain = $args{domain};
    my $domain_alias = $args{domain_alias};

    my $sites_dir = $args{sites_dir} || File::Spec->join( '/var/sites' );
    mkpath [ $sites_dir ];

    my $document_root = File::Spec->join( $sites_dir , $args{name} , $args{webroot} );
    mkpath [ $document_root ];

    my $log_dir = File::Spec->join( $args{sites_dir} , $args{name} , 'apache2' , 'logs' );
    my $access_log = File::Spec->join( $log_dir , 'access.log' );
    my $error_log = File::Spec->join( $log_dir , 'error.log' );


    # default template
    my $template = new Apache::SiteConfig::Template;
    my $context = $template->build( 
        ServerName => $domain,
        ServerAlias => $domain_alias,
        DocumentRoot => $document_root,
        AccessLog => $access_log , 
        ErrorLog => $error_log 
    );
    return $context;
}


1;
__END__

=head1 NAME

Apache::SiteConfig::Deploy

=head1 SYNOPSIS

    use Apache::SiteConfig::Deploy;

    name   'projectA';

    domain 'foo.com';

    git  'git@git.foo.com:projectA.git';

    hg   'http://.........';

    # relative web document path of repository
    webroot 'webroot/';

    prepare {

    };

    after {

    };

    task deploy => sub {

    };

    task dist => sub {

    };





    Deploy->new( 
        name => 'projectA',
        sites_dir => '/var/sites',  # optional
        git => 'git@foo.com:projectA.git',
        domain => 'foo.com',
        webroot => 'webroot/',
    );

=cut
