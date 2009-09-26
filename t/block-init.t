#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my @tests = (
    {
        params => [ 1, 0 ],
        expected_x => -2,
        expected_y => -2,
    },
    {
        params => [ 1, 1 ],
        expected_x => -2,
        expected_y => -3,
    },
    {
        params => [ 2, 0 ],
        expected_x => -2,
        expected_y => -3,
    },
    {
        params => [ 2, 1 ],
        expected_x => -2,
        expected_y => -3,
    },
);


plan tests => 1 + 2 * scalar @tests;

use_ok('SDL::Tutorial::Tetris::Model::Blocks');

for my $test ( @tests ) {
    my $x_init_pos = SDL::Tutorial::Tetris::Model::Blocks::get_x_init_pos(@{$test->{params}});
    my $y_init_pos = SDL::Tutorial::Tetris::Model::Blocks::get_y_init_pos(@{$test->{params}});
    
    is ( $x_init_pos, $test->{expected_x} );
    is ( $y_init_pos, $test->{expected_y} );
}
