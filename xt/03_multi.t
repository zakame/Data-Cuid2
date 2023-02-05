#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

BEGIN {
    plan skip_all => 'Testing multi-process collisions only upon release'
        unless $ENV{RELEASE_TESTING};
}

use IO::Async::Loop;
use IO::Async::Function;

use Data::Cuid2;

my $loop = IO::Async::Loop->new;

my $proc = 3;
my $max  = 100_000;

plan tests => 1;

my @func;
my $test = sub {
    my ( $fn, $ids ) = @_;

    for ( 1 .. $proc ) {
        my $func = IO::Async::Function->new(
            code => sub {
                map { $fn->() } 1 .. $max;
            }
        );
        $loop->add($func);
        my $f = $func->call( args => [] );
        $f->on_done( sub { $ids->{$_}++ for @_ } );
        push @func, $f;
    }
};

diag "Testing @{[ $max * $proc ]} unique IDs...";
$test->( \&Data::Cuid2::createId, \my %cuids );

$loop->await_all(@func);

is keys %cuids, $max * $proc, 'got all unique cuids';
