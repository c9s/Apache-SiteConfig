package Apache::SiteConfig::Deploy;
use feature ':5.10';
use warnings;
use strict;
use File::Spec;
use File::Path qw(mkpath rmtree);
use Apache::SiteConfig::Template;

# require Exporter;
# our @ISA = qw(Exporter);
# our @EXPORT = qw(name domain domain_alias source webroot task);

our $Single;

# has tasks => ( is => 'rw' , default => sub { +{  } } );


END {
    $Single->execute_task( @ARGV ) if @ARGV;
}

sub import {
    my ($class) = @_;
    $Single = $class->new;
    $Single->{args} = {};
    $Single->{tasks} = {};

    # built-in tasks
    $Single->{tasks}->{deploy} = sub {
        $Single->deploy( @_ );
    };
    $Single->{tasks}->{update} = sub {
        $Single->update( @_ );
    };

    # setup accessors to main::
    no strict 'refs';
    for my $key ( qw(name domain domain_alias webroot source deploy task) ) {
        *{ 'main::' . $key } = sub { 
            ${ $class .'::'}{ $key }->( $Single , @_ );
        };
    }

    # Exporter->import( @_ );
    return 1;
}

sub new { bless {} , shift; }

sub execute_task {
    my ($self,$task_name,@args) = @_;
    my $task = $self->{tasks}->{ $task_name };
    if ( $task ) {
        $task->( $self , @args );
    } else {
        print "Task $task_name not found.\n";
    }
}

sub name ($) { 
    my $self = shift;
    $self->{args}->{name} = $_[0];
}

sub domain { 
    my $self = shift;
    $self->{args}->{domain} = $_[0]; 
}

sub domain_alias  { 
    my $self = shift;
    $self->{args}->{domain_alias} = $_[0]; 
}

sub source  { 
    my ($self,$type,$uri) = @_;
    $self->{args}->{ $type } = $uri;
}

sub webroot {
    my ($self,$path) = @_;
    $self->{args}->{webroot} = $path;
}

sub task ($&) {
    my ($self,$name,$closure) = @_;
    $self->{tasks}->{ $name } = $closure;
}

sub preprocess_meta {
    my $self = shift;
    my $args = { %{ $self->{args} } };  # copy args
    $args->{sites_dir} ||= File::Spec->join( '/var/sites' );
    $args->{site_dir} ||= File::Spec->join( $args->{sites_dir} , $args->{name} );
    $args->{document_root} = File::Spec->join( 
            $args->{site_dir} , $args->{webroot} );

    $args->{log_dir} ||= File::Spec->join( $args->{sites_dir} , 
        $args->{name} , 'apache2' , 'logs' );

    $args->{access_log} ||= File::Spec->join( $args->{log_dir} , 'access.log' );
    $args->{error_log}  ||= File::Spec->join( $args->{log_dir} , 'error.log' );
    return $args;
}

sub prepare_paths {
    my ($self,$args) = @_;
    for my $path ( qw(sites_dir site_dir log_dir document_root) ) {
        next unless $args->{ $path };
        mkpath [ $args->{ $path } ] unless -e $args->{ $path };
    }
}

sub update {
    my $self = shift;


}

sub deploy {
    my ($self) = @_;

    my $args = $self->preprocess_meta;
    my %args = %$args;

    $self->prepare_paths( $args );

    SKIP_SOURCE_CLONE:
    if( $args->{git} ) {
        last SKIP_SOURCE_CLONE if -e File::Spec->join( $args->{site_dir} , '.git' );

        say "Cloning git repository from $args->{git} to $args->{site_dir}";
        system("git clone $args->{git} $args->{site_dir}") == 0 or die($?);
    }
    elsif( $args->{hg} ) {
        last SKIP_SOURCE_CLONE if -e File::Spec->join( $args->{site_dir} , '.git' );

        say "Cloning hg repository from $args->{hg} to $args->{site_dir}";
        system("hg clone $args->{hg} $args->{site_dir}") == 0 or die($?);
    }

    # Default template
    my $template = Apache::SiteConfig::Template->new;  # apache site config template
    my $context = $template->build( 
        ServerName => $args->{domain},
        ServerAlias => $args->{domain_alias},
        DocumentRoot => $args->{document_root},
        CustomLog => $args->{access_log} , 
        ErrorLog => $args->{error_log} 
    );
    my $config_content = $context->to_string;

    # get site config directory
    my $apache_dir_debian = '/etc/apache2/sites-available';
    if( -e $apache_dir_debian ) {
        say "Apache Site Config Dir Found.";

        my $config_file = File::Spec->join( $apache_dir_debian , $args->{name} );

        if ( -e $config_file ) {
            say "$config_file exists, skipped.";
        } else {
            say "Writing site config to $config_file.";
            open my $fh , ">", $config_file;
            print $fh $config_content;
            close $fh;

            say "Enabling $args->{name}";
            system("a2ensite $args->{name}");

            say "Reloading apache";
            system("/etc/init.d/apache2 reload");
        }
    } 
    else {
        mkpath [ 'apache2' ];
        my $config_file = File::Spec->join(  'apache2' , $args->{name} . '.conf' );  # apache config
        open my $fh , ">", $config_file;
        print $fh $config_content;
        close $fh;
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

    domain_alias 'foo.com';

    source git => 'git@git.foo.com:projectA.git';
    source hg  => 'http://.........';

    # relative web document path of repository
    webroot 'webroot/';

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
