package Apache::SiteConfig::Template;
use warnings;
use strict;
use Moose;





1;
__END__


    $ git clone git@foo.com:projectA.git /var/sites/projectA

and will build site config args for template class:

    ServerName => 'foo.com',
    ServerAlias => 'bar.com',
    DocumentRoot => '/var/sites/projectA/webroot/'
    AccessLog => '/var/sites/projectA/apache2/logs/access.log',
    ErrorLog => '/var/sites/projectA/apache2/logs/error.log',

