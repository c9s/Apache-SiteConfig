package Apache::SiteConfig;
use strict;
use warnings;
our $VERSION = '0.01';
use Apache::SiteConfig::Statement;
use Apache::SiteConfig::Section;
use Apache::SiteConfig::Directive;
use Apache::SiteConfig::Root;


1;
__END__

=head1 NAME

Apache::SiteConfig - apache site deployment tool

=head1 SYNOPSIS

    use Apache::SiteConfig::Deploy;

    name 'projectA';

    domain 'foo.com';

    domain_alias 'foo.com';

    source git => 'git@git.foo.com:projectA.git';

    source hg  => 'http://.........';

    # relative web document path of repository
    webroot 'webroot/';

    deploy;



    # do deploy

    $ perl siteA.PL


=head1 DESCRIPTION

Apache::SiteConfig is

=head1 AUTHOR

Yo-An Lin E<lt>cornelius.howl {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
