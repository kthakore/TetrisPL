#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use SDL::Tutorial::Tetris::Event;
use SDL::Tutorial::Tetris::Controller;

use Data::Dumper;
use Readonly;

our ($EDEBUG, $KEYDEBUG, $GDEBUG, $FPS) = @ARGV;

our $frame_rate = 0;
our $time       = time;

package SDL::Tutorial::Tetris::Event::Manager;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self  = {
        listeners => {},
        evt_queue => [],
    };
    bless $self, $class;
    return $self;
}

sub listeners : lvalue {
    return shift->{listeners};
}

sub evt_queue : lvalue {
    return shift->{evt_queue};
}

sub reg_listener {
    my ($self, $listener) = (@_);
    $self->listeners->{$listener} = $listener
      if defined $listener;

    return $self->listeners->{$listener};
}

sub un_reg_listener {
    my ($self, $listener) = (@_);

    if (defined $listener) {
        return delete $self->listeners->{\$listener};
    }
    else {
        return;
    }
}

sub post {
    my $self = shift;
    my $event = shift if (@_) or die "Post needs a TickEvent";
    print 'Event' . $event->name . "notified\n" if $EDEBUG;
    die "Post needs a Event as parameter"
      unless $event->isa('SDL::Tutorial::Tetris::Event');

#print 'Event' . $event->name ." called \n" if (!$event->isa('SDL::Tutorial::Tetris::Event::Tick') && $EFDEBUG);

    foreach my $listener (values %{$self->listeners}) {
        $listener->notify($event);
    }


}

##################################################
#Here comes the code for the actual game objects #
##################################################

package SDL::Tutorial::Tetris::View::Game;
use Class::XSAccessor accessors =>
  {evt_manager => 'evt_manager', app => 'app'};
use Data::Dumper;
use SDL;
use SDL::App;

#http://www.colourlovers.com/palette/959495/Toothpaste_Face
our @palette = (
    (SDL::Color->new(-r => 50,  -g => 50,  -b => 60)),
    (SDL::Color->new(-r => 70,  -g => 191, -b => 247)),
    (SDL::Color->new(-r => 0,   -g => 148, -b => 217)),
    (SDL::Color->new(-r => 247, -g => 202, -b => 0)),
    (SDL::Color->new(-r => 0,   -g => 214, -b => 46)),
    (SDL::Color->new(-r => 237, -g => 0,   -b => 142)),
    (SDL::Color->new(-r => 50,  -g => 60,  -b => 50)),
);

sub new {
    my ($class, $event) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an SDL::Tutorial::Tetris::Event::Manager'
      unless defined $event and $event->isa('SDL::Tutorial::Tetris::Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->init;
    return $self;
}

sub init {
    my $self = shift;
    $self->app(
        SDL::App->new(
            -width  => 640,
            -height => 480,
            -depth  => 16,
            -title  => 'Tetris',
            -init   => SDL_INIT_VIDEO
        )
    );
    $self->clear();
}

sub clear {
    my $self = shift;
    $self->draw_rectangle(0, 0, $self->app->width, $self->app->height,
        $palette[0]);
}

sub show_grid {
    my $self = shift;

#     // Calculate the limits of the board in pixels
    my $x1 = $self->{grid}->get_x_pos_in_pixels(0);
    my $x2 = $self->{grid}->get_x_pos_in_pixels($self->{grid}->{width});
    my $y =
      $self->{app}->height
      - ($self->{grid}->{block_size} * $self->{grid}->{height});

    $self->draw_rectangle(
        $x1 - $self->{grid}->{board_line_width},
        $y,
        $self->{grid}->{board_line_width},
        $self->app->height - 1,
        $palette[3]
    );

#
    $self->draw_rectangle(
        $x2, $y,
        $self->{grid}->{board_line_width},
        $self->app->height - 1,
        $palette[3]
    );

    my $color = $palette[4];
    for (my $i = 0; $i < ($self->{grid}->{width}); $i++) {
        for (my $j = 0; $j < $self->{grid}->{height}; $j++) {

#             // Check if the block is filled, if so, draw it
            if (!$self->{grid}->is_free_loc($i, $j)) {
                $color = $palette[5];
            }
            else {
                $color = $palette[6];
            }
            $self->draw_rectangle(
                $self->{grid}->get_x_pos_in_pixels($i),
                $self->{grid}->get_y_pos_in_pixels($j),
                $self->{grid}->{block_size} - 1,
                $self->{grid}->{block_size} - 1,
                $color
            );

        }
    }


}

#needs the charactor now
sub show_charactor    # peice
{
    my $self = shift;
    die 'Expecting 4 arguments' if ($#_ != 3);
    my $piece_color = $palette[1];
    my ($x, $y, $piece, $rotation) = @_;
    my $pixels_x = $self->{grid}->get_x_pos_in_pixels($x);
    my $pixels_y = $self->{grid}->get_y_pos_in_pixels($y);

    for (my $i = 0; $i < 5; $i++) {
        for (my $j = 0; $j < 5; $j++) {

#             // Get the type of the block and draw it with the correct color
            my $type = SDL::Tutorial::Tetris::Blocks::get_block_type($piece, $rotation, $j, $i);
            if (defined $type) {
                $piece_color = $palette[2] if ($type == 1);
                $piece_color = $palette[3] if ($type == 2);
            }
            if ($type != 0) {
                my $block_size = $self->{grid}->{block_size};
                $self->draw_rectangle(
                    $pixels_x + $i * $block_size,
                    $pixels_y + $j * $block_size,
                    $block_size - 1,
                    $block_size - 1, $piece_color
                );
            }
        }
    }

}

sub draw_scene {
    my $self = shift;
    my $game = $self->{game};

    $self->show_grid();
    $self->show_charactor(
        $game->{posx},  $game->{posy},
        $game->{piece}, $game->{pieceRotation}
    );
    $self->show_charactor(
        $game->{next_posx},  $game->{next_posy},
        $game->{next_piece}, $game->{next_rotation}
    );
}

sub draw_rectangle {
    my $self = shift;
    die 'Expecting 5 parameters got: ' . $#_ if ($#_ != 4);
    my ($x, $y, $w, $h, $color) = @_;
    my $box = SDL::Rect->new(-x => $x, -y => $y, -w => $w, -h => $h);
    $self->app->fill($box, $color);

    #print "Drew rect at ( $x $y $w $h ) \n";
}


# Should be in Game::Utility
sub frame_rate {
    my $secs = shift;
    $secs = 2 unless defined $secs;
    my $fps = 0;
    $frame_rate++;

    my $elapsed_time = time - $time;
    if ($elapsed_time > $secs) {
        $fps = ($frame_rate / $secs);
        print "Frames per second: $frame_rate\n";
        $frame_rate = 0;
        $time       = time;
    }
    return $fps;
}

sub notify {
    print "Notify in View Game \n" if $EDEBUG;
    my ($self, $event) = (@_);

    if (defined $event) {
        if ($event->isa('SDL::Tutorial::Tetris::Event::Tick')) {
            print "Update Game View \n" if $GDEBUG;
            frame_rate(1) if $FPS;

            #if we got a quit event that means we can stop running the game
        }
        if ($event->isa('SDL::Tutorial::Tetris::Event::GridBuilt')) {
            print "Showing Grid \n" if $GDEBUG;
            $self->{grid} = $event->grid;
        }
        if ($event->isa('SDL::Tutorial::Tetris::Event::GameStart')) {
            print "Starting Game \n" if $GDEBUG;

            $self->{game} = $event->game;
            $self->draw_scene() if $self->{grid};

            #die;
            $self->app->sync();
        }

        if ($event->isa('SDL::Tutorial::Tetris::Event::CharactorMove')) {
            print "Moving charactor sprite in view\n" if $GDEBUG;
            $self->clear();
            $self->draw_scene() if ($self->{grid} && $self->{grid});
            $self->app->sync();
        }
    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}


#
#Game Objects
#

package SDL::Tutorial::Tetris::Blocks;
use Data::Dumper;
require Exporter;
our @ISA    = qw/Exporter/;
our @EXPORT = qw/
  $SQUARE $LINE $L_SHAPE $L_MIRROR $N_SHAPE $N_MIRROR $T_SHAPE
  get_block_type get_x_init_pos get_y_init_pos
  /;
use SDL::Tutorial::Tetris::Pieces qw/@pieces/;
use Readonly;
Readonly our $SQUARE   => 0;
Readonly our $LINE     => 1;
Readonly our $L_SHAPE  => 2;
Readonly our $L_MIRROR => 3;
Readonly our $N_SHAPE  => 4;
Readonly our $N_MIRROR => 5;
Readonly our $T_SHAPE  => 6;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub get_block_type {
    die 'Expecting 4 arguments' if ($#_ != 3);
    my ($piece, $rotation, $x, $y) = @_;
    return $SDL::Tutorial::Tetris::Pieces::pieces[$piece][$rotation][$x][$y];
}

sub get_x_init_pos {
    die 'expecting 2 arguments got: ' if ($#_ != 1);
    my ($piece, $rotation) = @_;
    return $SDL::Tutorial::Tetris::Pieces::pieces_init[$piece][$rotation][0];
}

sub get_y_init_pos {
    die 'expecting 2 arguments' if ($#_ != 1);
    my ($piece, $rotation) = @_;
    return $SDL::Tutorial::Tetris::Pieces::pieces_init[$piece][$rotation][1];

}

package SDL::Tutorial::Tetris::Grid;
use Data::Dumper;
use Class::XSAccessor accessors =>
  {evt_manager => 'evt_manager', blocks => 'blocks', grid => 'grid'};

BEGIN {
    Blocks->import;
}

sub new {
    my ($class, $event) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an SDL::Tutorial::Tetris::Event::Manager'
      unless defined $event and $event->isa('SDL::Tutorial::Tetris::Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->init(@_);
    return $self;
}

sub init {
    my $self = shift;

    #TODO: Get the following from @_
    $self->{board_line_width} = 6;
    $self->{block_size}       = 20;
    $self->{board_position}   = 300;
    $self->{screen_height}    = 480;

    $self->{width}  = 10;
    $self->{height} = 23;
    my $arr_ref = [];

    # used to test delete_line
    # for my $x (0..18)
    # {
    #		$arr_ref->[$x][19] = 1;
    #  }
    $self->grid($arr_ref);

}

sub store_piece {
    my $self = shift;
    die 'Expecting 4 parameters' if ($#_ != 3);
    my ($x, $y, $piece, $rotation) = @_;

    for (my $i1 = $x, my $i2 = 0; $i1 < $x + 5; $i1++, $i2++) {
        for (my $j1 = $y, my $j2 = 0; $j1 < $y + 5; $j1++, $j2++) {
            if (!($i1 < 0 || $j1 < 0)) {
                $self->grid->[$i1][$j1] = 1
                  if (
                    SDL::Tutorial::Tetris::Blocks::get_block_type($piece, $rotation, $j2, $i2) != 0);
            }
        }
    }
}

sub is_game_over {
    my $self = shift;
    for (my $i = 0; $i < $self->{width}; $i++) {
        if (defined $self->grid->[$i][0]) {
            return 1 if ($self->grid->[$i][0] == 1);
        }
    }
    return 0;
}

#removes a line and moves everything one row down
sub delete_line {
    my $self  = shift;
    my $dline = shift;
    for (my $j = $dline; $j > 0; $j--) {

        for (my $i = 0; $i < $self->{width}; $i++) {
            $self->grid->[$i][$j] = $self->grid->[$i][$j - 1];
        }
    }
    return 1;
}

sub delete_possible_lines {

    my $self          = shift;
    my $deleted_lines = 0;
    for (my $j = 0; $j < $self->{height}; $j++) {


        my $i = 0;
        while ($i < $self->{width}) {
            last if !(defined($self->grid->[$i][$j]));
            $i++;
        }
        $deleted_lines += $self->delete_line($j) if $i == $self->{width};
    }
    return $deleted_lines;
}

sub is_free_loc {
    my $self = shift;
    die 'Expecting 2 parameters' if $#_ != 1;

    #die 'got '.$_[0].' '.$_[1];
    my $grid = $self->grid();

    #die Dumper $grid;
    return 1 if !defined($grid->[$_[0]][$_[1]]);
    return 0 if ($grid->[$_[0]][$_[1]] == 1);

}

sub get_x_pos_in_pixels {
    my $self = shift;
    die 'Expecting 1 parameter got ' . $_[0] if (!defined($_[0]));
    return (
        (   $self->{board_position}
              - ($self->{block_size} * ($self->{width} / 2))
        ) + ($_[0] * $self->{block_size}) + 3
    );
}

sub get_y_pos_in_pixels {
    my $self = shift;
    die 'Expecting 1 parameter got ' . $_[0] if (!defined($_[0]));
    return (($self->{screen_height} - ($self->{block_size} * $self->{height}))
        + ($_[0] * $self->{block_size}));

}

sub is_possible_movement {
    my $self = shift;
    die 'Expecting 4 parameters' if $#_ != 3;
    my ($x, $y, $piece, $rotation) = @_;

    for (my $i1 = $x, my $i2 = 0; $i1 < $x + 5; $i1++, $i2++) {
        for (my $j1 = $y, my $j2 = 0; $j1 < $y + 5; $j1++, $j2++) {

            #check if block goes outside limits
            if (   $i1 < 0
                || $i1 > ($self->{width} - 1)
                || $j1 > ($self->{height} - 1))
            {
                return 0
                  if (
                    SDL::Tutorial::Tetris::Blocks::get_block_type($piece, $rotation, $j2, $i2) != 0);
            }

            #check collision with blocks already on board
            if ($j1 >= 0) {
                return 0
                  if (
                    (SDL::Tutorial::Tetris::Blocks::get_block_type($piece, $rotation, $j2, $i2) != 0)
                    && !($self->is_free_loc($i1, $j1)));
            }
        }
    }

    #no collision
    return 1;
}

sub notify {
    print "Notify in Grid \n" if $EDEBUG;
    my ($self, $event) = (@_);

    if (defined $event && $event->isa('SDL::Tutorial::Tetris::Event::Tick')) {

        #do checks

    }
}


package main;    #On the go testing

my $manager  = SDL::Tutorial::Tetris::Event::Manager->new;
my $keybd    = SDL::Tutorial::Tetris::Controller::Keyboard->new($manager);
my $spinner  = SDL::Tutorial::Tetris::Controller::CPUSpinner->new($manager);
my $gameView = SDL::Tutorial::Tetris::View::Game->new($manager);
my $game     = SDL::Tutorial::Tetris::Controller::Game->new($manager);

$spinner->run;
