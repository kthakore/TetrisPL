package SDL::Tutorial::Tetris::View::Game;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Base';

use Class::XSAccessor accessors => {
    app => 'app'
};

use SDL::Tutorial::Tetris::Model::Blocks;

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
    my ($class, %params) = (@_);

    my $self  = $class->SUPER::new(%params);

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
            my $type = SDL::Tutorial::Tetris::Model::Blocks::get_block_type($piece, $rotation, $j, $i);
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
my $frame_rate = 0;
my $time       = time;

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
    my ($self, $event) = (@_);

    print "Notify in View Game \n" if $self->EDEBUG;

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
    return if !defined $event;

    my %event_action = (
        'Tick' => sub {
            frame_rate(1) if $self->FPS;
        },
        'GridBuilt' => sub {
            $self->{grid} = $event->{grid};
        },
        'GameStart' => sub {
            $self->{game} = $event->{game};
            $self->draw_scene() if $self->{grid};
            $self->app->sync();
        },
        'CharactorMove' => sub {
            $self->clear();
            $self->draw_scene() if ($self->{grid} && $self->{grid});
            $self->app->sync();
        },
    );

    my $action = $event_action{$event->{name}};
    if (defined $action) {
        print "Event $event->{name}\n" if $self->GDEBUG;
        $action->();
    }

}

1;
