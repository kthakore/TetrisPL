#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

plan tests => 4;

use SDL::Tutorial::Tetris::EventManager;

use_ok('SDL::Tutorial::Tetris::Model::Grid');

my $evt_manager = SDL::Tutorial::Tetris::EventManager->new();

my $grid = SDL::Tutorial::Tetris::Model::Grid->new($evt_manager);

# is it correctly registered?
ok( defined $evt_manager->listeners->{$grid} );

ok( defined $grid->{width}  );
ok( defined $grid->{height} );
