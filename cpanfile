requires 'perl', '5.008001';

requires 'CryptX',        '0.048';
requires 'Exporter',      '5.57';
requires 'Math::BigInt',  '0';
requires 'Sys::Hostname', '0';
requires 'Time::HiRes',   '0';

recommends 'Math::BigInt::GMP', '0';

on 'develop' => sub {
    requires 'IO::Async', '0.38';
    requires 'Sub::Util', '0';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
};

