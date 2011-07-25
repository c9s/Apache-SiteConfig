use inc::Module::Install;
name 'Apache-SiteConfig';
all_from 'lib/Apache/SiteConfig.pm';

requires 'Moose';

readme_markdown_from 'lib/Apache/SiteConfig.pm';
tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';

auto_set_repository;
auto_include;
WriteAll;
