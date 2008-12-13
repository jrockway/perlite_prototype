use strict;
use warnings;
use Test::More tests => 3;

use ok 'Perlite::Compiler';

my $compiler = Perlite::Compiler->new(
    lexicals     => ['$lexical'],
    declarations => ['declare'],
);

my $script = $compiler->compile('test', q{
return "$lexical, there";
declare 'OH HAI';
});

is my $d = $script->read_declaration('declare'), 'OH HAI';
$script->set_lexical( '$lexical' => $d );
is $script->run, 'OH HAI, there';
