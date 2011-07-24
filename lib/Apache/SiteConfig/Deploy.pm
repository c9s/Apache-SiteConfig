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


sub new {  bless {} , shift; }

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




sub deploy {
    my ($self) = @_;
    my %args = %{ $self->{args} };
    
#     for( $self->required ) {
#         die "Key $_ is required." unless $args{$_};
#     }

    my $domain = $args{domain};
    my $domain_alias = $args{domain_alias};

    my $sites_dir = $args{sites_dir} || File::Spec->join( '/var/sites' );
    mkpath [ $sites_dir ] unless -e $sites_dir;

    my $site_dir = File::Spec->join( $sites_dir , $args{name} );

    unless ( -e $site_dir ) {
        mkpath [ $site_dir ] unless -e $site_dir ;
        if( $args{git} ) {
            say "Cloning git repository from $args{git}";
            system("git clone $args{git} $site_dir") == 0 or die($?);
        }
        elsif( $args{hg} ) {
            say "Cloning hg repository from $args{hg}";
            system("hg clone $args{hg} $site_dir") == 0 or die($?);
        }
    }

    my $document_root = File::Spec->join( $site_dir , $args{webroot} );
    mkpath [ $document_root ];

    my $log_dir = File::Spec->join( $args{sites_dir} , $args{name} , 'apache2' , 'logs' );
    my $access_log = File::Spec->join( $log_dir , 'access.log' );
    my $error_log = File::Spec->join( $log_dir , 'error.log' );

    # Default template
    my $template = Apache::SiteConfig::Template->new;  # apache site config template
    my $context = $template->build( 
        ServerName => $domain,
        ServerAlias => $domain_alias,
        DocumentRoot => $document_root,
        CustomLog => $access_log , 
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
