#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Test::More;
use Data::Cuid2;

subtest 'Cuid2' => sub {
    can_ok 'Data::Cuid2', qw(init createId createCounter);

    my $id = Data::Cuid2::createId;
    note my $cuid = $id->();
    ok $cuid, 'createId returns a value';

    subtest 'lengths' => sub {
        my $default = Data::Cuid2::createId;
        note my $cuid = $default->();
        is length($cuid), $Data::Cuid2::defaultLength,
          'returns a cuid of the default length';

        my $customLength = 10;
        my $custom       = Data::Cuid2::init( length => $customLength );
        note my $id2 = $custom->();
        is length($id2), $customLength,
          'returns a cuid with the specified length';

        my $bigLength = 32;
        my $big       = Data::Cuid2::init( length => $bigLength );
        note my $id3 = $big->();
        is length($id3), $bigLength, 'returns a cuid with the specified length';

        done_testing;
    };

    done_testing;
};

done_testing;
