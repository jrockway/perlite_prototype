use strict;
use warnings;
use Test::More tests => 8;

use Perlite::Compiled;
use ok 'Perlite::Cache';

my $called = 0;
my $c = Perlite::Cache->new(
    builder => sub {
        my ($file, $text) = @_;
        $called++;
        Perlite::Compiled->new( main_body => sub { eval $text } );
      },
);

ok $c;

my $p = $c->cache('foo.pl', 'return "foo"');
is $called, 1, 'called builder';
is $p->main_body->(), 'foo', 'build ok';

$p = $c->cache('foo.pl', 'return "foo"');
is $called, 1, 'used cache';
is $p->main_body->(), 'foo', 'got obj back';

$p = $c->cache('foo.pl', 'return "bar";');
is $called, 2, 'called builder';
is $p->main_body->(), 'bar', 'build ok';
