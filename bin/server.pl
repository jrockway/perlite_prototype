#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Perlite::Server;

my $dir = shift || die 'need path';
Perlite::Server->new( directory => $dir )->engine->run;

