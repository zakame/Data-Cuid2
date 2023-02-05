package Data::Cuid2;
use 5.008001;
use strict;
use warnings;

our @EXPORT_OK;

BEGIN {
    use Exporter 'import';
    @EXPORT_OK = qw(createId);
}

use Crypt::Digest::SHA3_512 ();
use Math::BigInt try => 'GMP';
use POSIX 'floor';
use Sys::Hostname ();
use Time::HiRes   ();

our $defaultLength = 24;
our $bigLength     = 32;

our @primes = (
    109717, 109721, 109741, 109751, 109789, 109793,
    109807, 109819, 109829, 109831
);

our $VERSION = "0.01";

sub _createEntropy {
    my ( $length, $random ) = @_;
    $length ||= 4;
    $random ||= rand();

    my $entropy = '';
    while ( length $entropy < $length ) {
        my $randomPrime = $primes[ floor( rand() * @primes ) ];
        $entropy = join '' => $entropy,
          _encode_base36( floor( rand() * $randomPrime ) );
    }

    substr $entropy, 0, $length;
}

sub _createFingerprint {
    my $random = shift;
    _hash(
        join '' => floor( ( $random + 1 ) * 2063 ),
        $$, Sys::Hostname::hostname, keys %INC, keys %ENV
    );
}

# from Math::Base36
sub _encode_base36 {
    my ( $n, $max ) = ( @_, 1 );

    $n = Math::BigInt->new($n);
    my @res;
    while ($n) {
        my $remainder = $n % 36;
        unshift @res, $remainder <= 9 ? $remainder : lc chr( 55 + $remainder );
        $n = int $n / 36;
    }

    # unshift @res, '0' while @res < $max;
    join '' => @res;
}

sub _hash {
    my ( $input, $length ) = @_;
    $input  ||= '';
    $length ||= $bigLength;

    my $salt = _createEntropy($length);
    my $text = join '' => $input, $salt;

    substr _encode_base36(
        join '' => '0x',
        Crypt::Digest::SHA3_512::sha3_512_hex($text)
      ),
      1;
}

sub _randomLetter {
    my @alphabet = ( 'a' .. 'z' );
    $alphabet[ floor( shift() * @alphabet ) ];
}

sub _timestamp {
    _encode_base36 sprintf( '%.0f' => Time::HiRes::time * 1000 );
}

sub createCounter {
    my $c = shift || 0;
    sub { $c++ };
}

sub createId { init() }

sub init {
    my %args = @_;

    $args{random}      ||= rand();
    $args{counter}     ||= createCounter floor( $args{random} * 2057 );
    $args{length}      ||= $defaultLength;
    $args{fingerprint} ||= _createFingerprint $args{random};

    sub {
        my $time          = _timestamp;
        my $randomEntropy = _createEntropy @args{qw(length random)};
        my $count         = _encode_base36 $args{counter}->();
        my $firstLetter   = _randomLetter $args{random};
        my $hashInput     = join '' => $time,
          $randomEntropy, $count, $args{fingerprint};

        join '' => $firstLetter,
          substr( _hash( $hashInput, $args{length} ), 1, $args{length} - 1 );
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Data::Cuid2 - It's new $module

=head1 SYNOPSIS

    use Data::Cuid2;

=head1 DESCRIPTION

Data::Cuid2 is ...

=head1 LICENSE

Copyright (C) Zak B. Elep.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Zak B. Elep E<lt>zakame@zakame.netE<gt>

=cut

