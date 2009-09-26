#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my @tests = (
    {
        params => [ 0, 0, 0, 0 ],
        expected_type => 0,
    },
    {
        params => [ 0, 0, 1, 1 ],
        expected_type => 0,
    },
    {
        params => [ 0, 0, 2, 2 ],
        expected_type => 2,
    },
    {
        params => [ 0, 0, 3, 3 ],
        expected_type => 1,
    },
    {
        params => [ 0, 0, 4, 4 ],
        expected_type => 0,
    },
);


plan tests => 1 + scalar @tests;

use_ok('SDL::Tutorial::Tetris::Model::Blocks');

for my $test ( @tests ) {
    my $type = SDL::Tutorial::Tetris::Model::Blocks::get_block_type(@{$test->{params}});
    is ( $type, $test->{expected_type} );
}
