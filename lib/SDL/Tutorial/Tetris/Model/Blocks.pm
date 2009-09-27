package SDL::Tutorial::Tetris::Model::Blocks;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Base';

use Data::Dumper;
require Exporter;

our @ISA    = qw/Exporter/;
our @EXPORT = qw/
  $SQUARE $LINE $L_SHAPE $L_MIRROR $N_SHAPE $N_MIRROR $T_SHAPE
  get_block_type get_x_init_pos get_y_init_pos
  /;

use SDL::Tutorial::Tetris::Model::Pieces qw/@pieces/;
use Readonly;

Readonly our $SQUARE   => 0;
Readonly our $LINE     => 1;
Readonly our $L_SHAPE  => 2;
Readonly our $L_MIRROR => 3;
Readonly our $N_SHAPE  => 4;
Readonly our $N_MIRROR => 5;
Readonly our $T_SHAPE  => 6;

sub get_block_type {
    die 'Expecting 4 arguments' if ($#_ != 3);
    my ($piece, $rotation, $x, $y) = @_;
    return $SDL::Tutorial::Tetris::Model::Pieces::pieces[$piece][$rotation][$x][$y];
}

sub get_x_init_pos {
    die 'expecting 2 arguments got: ' if ($#_ != 1);
    my ($piece, $rotation) = @_;
    return $SDL::Tutorial::Tetris::Model::Pieces::pieces_init[$piece][$rotation][0];
}

sub get_y_init_pos {
    die 'expecting 2 arguments' if ($#_ != 1);
    my ($piece, $rotation) = @_;
    return $SDL::Tutorial::Tetris::Model::Pieces::pieces_init[$piece][$rotation][1];

}

1;
