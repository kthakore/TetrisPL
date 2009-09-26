#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use SDL::Tutorial::Tetris::EventManager;
use SDL::Tutorial::Tetris::View;
use SDL::Tutorial::Tetris::Controller::Keyboard;
use SDL::Tutorial::Tetris::Controller::CPUSpinner;
use SDL::Tutorial::Tetris::Controller::Game;

use Data::Dumper;

our ($EDEBUG, $KEYDEBUG, $GDEBUG, $FPS) = @ARGV;

my $keybd    = SDL::Tutorial::Tetris::Controller::Keyboard->new();
my $spinner  = SDL::Tutorial::Tetris::Controller::CPUSpinner->new();
my $gameView = SDL::Tutorial::Tetris::View::Game->new();

my $game     = SDL::Tutorial::Tetris::Controller::Game->new(
    EDEBUG      => $EDEBUG,
    GDEBUG      => $GDEBUG,
    KEYDEBUG    => $KEYDEBUG,
    FPS         => $FPS,
);

$spinner->run;
