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
    mkpath [ $sites_dir ] unless -e $sites_dir;

    my $site_dir = File::Spec->join( $sites_dir , $args{name} );
    mkpath [ $site_dir ] unless -e $site_dir ;

    if( $args{git} ) {
        system("git clone $args{git} $site_dir");
    }
    elsif( $args{hg} ) {
        system("hg clone $args{hg} $site_dir");
    }

    my $document_root = File::Spec->join( $site_dir , $args{webroot} );
    mkpath [ $document_root ];

    my $log_dir = File::Spec->join( $args{sites_dir} , $args{name} , 'apache2' , 'logs' );
    my $access_log = File::Spec->join( $log_dir , 'access.log' );
    my $error_log = File::Spec->join( $log_dir , 'error.log' );

    # Default template
    my $template = new Apache::SiteConfig::Template;  # apache site config template
    my $context = $template->build( 
        ServerName => $domain,
        ServerAlias => $domain_alias,
        DocumentRoot => $document_root,
        AccessLog => $access_log , 
        ErrorLog => $error_log 
    );
    my $config_content = $context->to_string;

    # get site config directory
    my $apache_dir_debian = '/etc/apache2/sites-available';
    if( -e $apache_dir_debian ) {
        my $config_file = File::Spec->join( $apache_dir_debian , $args{name} );

        if ( -e $config_file ) {
            say "$config_file exists, skipped.";
        } else {
            say "Writing site config to $config_file";
            open my $fh , ">", $config_file;
            print $fh $config_content;
            close $fh;

            say "Enabling $args{name}";
            system("a2ensite $args{name}");

            say "Reloading apache";
            system("/etc/init.d/apache2 reload");
        }
    } 
    else {
        mkpath [ 'apache2' ];
        my $config_file = File::Spec->join(  'apache2' , $args{name} . '.conf' );  # apache config
        open my $fh , ">", $config_file;
        print $fh $config_content;
        close my $fh;
    }

}


1;
__END__

=head1 NAME

Apache::SiteConfig::Deploy

=head1 SYNOPSIS

    use Apache::SiteConfig::Deploy;

    name   'projectA';

    domain 'foo.com';


    source git => 'git@git.foo.com:projectA.git';
    source hg  => 'http://.........';

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
