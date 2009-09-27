#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use SDL::Tutorial::Tetris;

SDL::Tutorial::Tetris->play(@ARGV);
