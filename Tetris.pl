use strict;
use warnings;
use Data::Dumper;
use Readonly;
Readonly my $ROTATE_C   => 0;         # rotates blocks ClockWise
Readonly my $ROTATE_CC   => 1;        # rotates blocks CounterClockWise
Readonly my $DIRECTION_DOWN  => 2;    # Drops the block
Readonly my $DIRECTION_LEFT  => 3;    # move left
Readonly my $DIRECTION_RIGHT => 4;    # move right

our ( $EDEBUG, $KEYDEBUG, $GDEBUG, $FPS ) = @ARGV; 


our $frame_rate = 0;
our $time       = time;


#Event Super Class
package Event;
use Class::XSAccessor accessors => { name => 'name', };

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->name("Generic Event");
    return $self;
}

package Event::Tick;
use base 'Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('CPU Tick Event');
    return $self;
}

package Event::Quit;
use base 'Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Program Close Event');
    return $self;
}

package Event::GridBuilt;    #Tetris has a grid
use base 'Event';
use Data::Dumper;
use Class::XSAccessor accessors => { grid => 'grid' };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('Grid Built Event');
	$self->grid($_[0]);
    return $self;
}

package Event::GameStart;
use base 'Event';
use Class::XSAccessor accessors => { game => 'game', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Game Start Event');
	$self->game($_[0]);
    return $self;
}

package Event::CharactorMove;
use base 'Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Charactor is Moving');
    return $self;
}

package Request::CharactorMove;
use base 'Event';
use Class::XSAccessor accessors => { direction => 'direction', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
	$self->direction( $_[0] );
    $self->name('Charactor Move Request');
    return $self;
}

#---------------------------
package Event::Manager;
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
    my ( $self, $listener ) = (@_);
    $self->listeners->{$listener} = $listener
      if defined $listener;

    return $self->listeners->{$listener};
}

sub un_reg_listener {
    my ( $self, $listener ) = (@_);

    if ( defined $listener ) {
        return delete $self->listeners->{ \$listener };
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
      unless $event->isa('Event');
	#print 'Event' . $event->name ." called \n" if (!$event->isa('Event::Tick') && $EFDEBUG);

    foreach my $listener ( values %{ $self->listeners } ) {
        $listener->notify($event);
    }

	

}

package Controller::Keyboard;
use Class::XSAccessor accessors =>
  { event => 'event', evt_manager => 'evt_manager' };
use SDL;
use SDL::Event;

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event && $event->isa('Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    return $self;
}

sub notify {
    print "Notify in C::KB \n" if $EDEBUG;
    my ( $self, $event ) = (@_);

    if ( defined $event and $event->isa('Event::Tick') ) {

        #if we got a tick event that means we are starting
        #a new iteration of game loop
        #so we can check input now
        my $event_to_process = undef;
        $self->event( SDL::Event->new );
        $self->event->pump;    #get events from SDL queue
        $self->event->poll;    #get the first one
        my $event_type = $self->event->type;
        $event_to_process = Event::Quit->new if $event_type == SDL_QUIT;
        if ( $event_type == SDL_KEYDOWN ) {

            my $key = $self->event->key_name;
            print $key. " pressed \n" if $KEYDEBUG;

            #This process the only keys we care about right now
            #later on we will add more stuff
            $event_to_process = Event::Quit->new
              if $key =~ 'escape';
            $event_to_process = Request::CharactorMove->new($ROTATE_C)
              if $key =~ 'up';
            $event_to_process = Request::CharactorMove->new($ROTATE_CC)
              if $key =~ 'space';
			$event_to_process = Request::CharactorMove->new($DIRECTION_DOWN)
              if $key =~ 'down';
            $event_to_process = Request::CharactorMove->new($DIRECTION_LEFT)
              if $key =~ 'left';
            $event_to_process = Request::CharactorMove->new($DIRECTION_RIGHT)
              if $key =~ 'right';
        }

        #lets send the new events to be process back the event manager
        $self->evt_manager->post($event_to_process)
          if defined $event_to_process;

    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

package Controller::CPUSpinner;
use Class::XSAccessor accessors => { evt_manager => 'evt_manager'};

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->{keep_going} = 1;
    return $self;
}

sub run {
    my $self = shift;
    while ( $self->{keep_going} == 1 ) {
        my $tick = Event::Tick->new;
        $self->evt_manager->post($tick);
    }
}

sub notify {
    print "Notify in CPU Spinner \n" if $EDEBUG;
    my ( $self, $event ) = (@_);

    if ( defined $event && $event->isa('Event::Quit') ) {
        print "Stopping to pump ticks \n" if $EDEBUG;

        #if we got a quit event that means we can stop running the game
        $self->{keep_going} = 0;
    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

##################################################
#Here comes the code for the actual game objects #
##################################################

package View::Game;
use Class::XSAccessor accessors => { evt_manager => 'evt_manager', app => 'app'};
use Data::Dumper;
use SDL;
use SDL::App;
#http://www.colourlovers.com/palette/959495/Toothpaste_Face
our @palette =
(
	(SDL::Color->new( -r => 50,  -g =>50,   -b =>60 )),
	(SDL::Color->new( -r => 70,   -g =>191, -b =>247)),
	(SDL::Color->new( -r => 0,   -g =>148,  -b =>217)),
	(SDL::Color->new( -r => 247, -g =>202,  -b =>0  )),
	(SDL::Color->new( -r => 0,   -g =>214,  -b =>46 )),
	(SDL::Color->new( -r => 237, -g =>0,    -b =>142)),
	(SDL::Color->new( -r => 50,  -g =>60,   -b =>50 )),
);

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->init;
    return $self;
}

sub init {
    my $self = shift;
    $self->app( SDL::App->new(
        -width  => 640,
        -height => 480,
        -depth  => 16,
        -title  => 'Tetris',
	-init   => SDL_INIT_VIDEO 
    ));
	$self->clear();
}

sub clear
{
	my $self = shift;
	$self->draw_rectangle ( 0, 0, $self->app->width, $self->app->height, $palette[0]);
}

sub show_grid
{
	my $self = shift;

#     // Calculate the limits of the board in pixels  
     my $x1 = $self->{grid}->get_x_pos_in_pixels(0);  
     my $x2 = $self->{grid}->get_x_pos_in_pixels($self->{grid}->{width});  
     my $y = $self->{app}->height - ($self->{grid}->{block_size}* $self->{grid}->{height});  

     $self->draw_rectangle ($x1 - $self->{grid}->{board_line_width},$y, $self->{grid}->{board_line_width}, $self->app->height - 1, $palette[3]);  
#   
     $self->draw_rectangle ($x2 ,$y, $self->{grid}->{board_line_width}, $self->app->height - 1, $palette[3]);  

	my $color = $palette[4];
     for (my $i = 0; $i < ($self->{grid}->{width}); $i++)  
     {  
         for (my $j = 0; $j < $self->{grid}->{height}; $j++)  
         {  
#             // Check if the block is filled, if so, draw it  
             if (!$self->{grid}->is_free_loc($i, $j))  
			 {  
				$color = $palette[5];
			 }
			 else
			 {
				$color = $palette[6];
			 }
                 $self->draw_rectangle ($self->{grid}->get_x_pos_in_pixels($i),  
                                        $self->{grid}->get_y_pos_in_pixels($j),  
                                         $self->{grid}->{block_size}- 1,  
                                         $self->{grid}->{block_size}- 1,  
                                         $color);  
			 
         }  
     }  
	
	
}

#needs the charactor now
sub show_charactor  # peice
{
    my $self = shift;
	die 'Expecting 4 arguments' if ($#_ != 3); 
	my $piece_color = $palette[1];
	my($x, $y, $piece, $rotation) = @_;
	my $pixels_x = $self->{grid}->get_x_pos_in_pixels($x);  
    my $pixels_y = $self->{grid}->get_y_pos_in_pixels($y);  
	
     for (my $i = 0; $i < 5; $i++)  
     {  
         for (my $j = 0; $j < 5; $j++)  
        {  
#             // Get the type of the block and draw it with the correct color  
			my $type = Blocks::get_block_type ($piece, $rotation, $j, $i);
			if ( defined $type )
			{
              $piece_color = $palette[2] if($type == 1);
			  $piece_color = $palette[3] if($type == 2);
			  }
             if ($type != 0)  
				{	my $block_size = $self->{grid}->{block_size};
					$self->draw_rectangle ( $pixels_x + $i * $block_size,  
                                     $pixels_y + $j * $block_size,  
                                     $block_size - 1,  
                                     $block_size - 1,  
                                     $piece_color);  
				}  
		}
	}	 
	
}

sub draw_scene
{
	my $self = shift;
	my $game = $self->{game};
	
	$self->show_grid();
	$self->show_charactor($game->{posx}, $game->{posy}, $game->{piece}, $game->{pieceRotation});
	$self->show_charactor($game->{next_posx}, $game->{next_posy}, $game->{next_piece}, $game->{next_rotation});
}

sub draw_rectangle
{
   my $self = shift;
   die 'Expecting 5 parameters got: '.$#_  if ($#_ != 4);
   my ($x, $y, $w, $h, $color) = @_;
   my $box = SDL::Rect->new( -x => $x, -y =>$y, -w => $w, -h => $h);
	$self->app->fill($box,  $color );
	#print "Drew rect at ( $x $y $w $h ) \n";
}


# Should be in Game::Utility
sub frame_rate
{
	my $secs = shift;
	$secs = 2 unless defined $secs;
	my $fps = 0;
    $frame_rate++;
	
    my $elapsed_time = time - $time;    
    if ( $elapsed_time > $secs ) {
	$fps = ($frame_rate/$secs);
        print "Frames per second: $frame_rate\n";
        $frame_rate = 0;
        $time       = time;
    }
	return $fps;
}

sub notify {
    print "Notify in View Game \n" if $EDEBUG;
    my ( $self, $event ) = (@_);
	
    if ( defined $event ) {
        if ( $event->isa('Event::Tick') ) {
            print "Update Game View \n" if $GDEBUG;
			frame_rate(1) if $FPS;
            #if we got a quit event that means we can stop running the game
        }
        if ( $event->isa('Event::GridBuilt') ) {
            print "Showing Grid \n" if $GDEBUG;
			$self->{grid} = $event->grid;
		}
        if ( $event->isa('Event::GameStart') ) {
            print "Starting Game \n" if $GDEBUG;
			
			$self->{game} = $event->game;
		    $self->draw_scene() if $self->{grid};
		    #die;
			$self->app->sync();
        }
      
        if ( $event->isa('Event::CharactorMove') ) {
            print "Moving charactor sprite in view\n" if $GDEBUG;
			$self->clear();
			$self->draw_scene() if ($self->{grid} && $self->{grid} );
			$self->app->sync();
        }
    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

###########################
#Here is the Tetris logic #
###########################

package Controller::Game;
use Class::XSAccessor accessors => { evt_manager => 'evt_manager', grid => 'grid' };
use Data::Dumper;
use Time::HiRes qw/time/;
use Readonly;
BEGIN
{
	Grid->import;
	Blocks->import
}

Readonly my $STATE_PREPARING => 0;
Readonly my $STATE_RUNNING   => 1;
Readonly my $STATE_PAUSED    => 2;

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');
	$self->{level} = 0.5; 
    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->{state} = $STATE_PREPARING;
    print "Game PREPARING ... \n" if $GDEBUG;
    $self->init_grid;
    $self->evt_manager->post(Event::GridBuilt->new($self->grid) );
    #$self->{player} =; For points, level so on
    return $self;
}

sub start {
    my $self = shift;
   
    $self->{state} = $STATE_RUNNING;
    print "Game RUNNING \n" if $GDEBUG;
    my $event = Event::GameStart->new($self);
    $self->evt_manager->post($event);
	$self->{wait} = time;
}

sub init_grid
{
	my $self = shift;
	$self->grid ( Grid->new($self->evt_manager));
	$self->{piece} = int(rand(6)); # 0 1 2 3 4 5 6 Pieces
	$self->{pieceRotation} = int(rand(3)); # 0 1 2 3 rotations
	$self->{posx} = $self->grid->{width}/2 + Blocks::get_x_init_pos($self->{piece}, $self->{pieceRotation});
	$self->{posy} = Blocks::get_y_init_pos($self->{piece}, $self->{pieceRotation});

	#     //  Next piece  
     $self->{next_piece} = int(rand(6));   
     $self->{next_rotation}   = int(rand(3));
     $self->{next_posx} = ($self->grid->{width}) + 5;
     $self->{next_posy} = 5;
}

sub create_new_piece
{
	my $self = shift;
	$self->{piece} = $self->{next_piece};
	$self->{pieceRotation} = $self->{next_rotation};
	$self->{posx} = $self->grid->{width}/2 + Blocks::get_x_init_pos( $self->{piece}, $self->{pieceRotation} );
	$self->{posy} = Blocks::get_y_init_pos($self->{piece}, $self->{pieceRotation});
	
	#     //  Next piece  
     $self->{next_piece} = int(rand(6));   
     $self->{next_rotation}   = int(rand(3));
}

sub notify {
    print "Notify in GAME \n" if $EDEBUG;
    my ( $self, $event ) = (@_);
	
    if ( defined $event && $event->isa('Event') && !$event->isa('Event::GridBuilt') ) {
        if ( $self->{state} == $STATE_PREPARING ) {
            print "Event " . $event->name . "caught to start Game  \n"
              if $GDEBUG;
	       $self->start;
        }
	if ( $self->{state} == $STATE_RUNNING )
	{
	   #lets grab those move requests events
	   if (  $event->isa('Request::CharactorMove') ) {
            print "Move charactor sprite \n" if $GDEBUG;
			my ($mx, $my, $rot) = ($self->{posx}, $self->{posy}, $self->{pieceRotation});
			if ($event->direction == $ROTATE_C) { $rot++; $rot = $rot%4 };
			if ($event->direction == $ROTATE_CC) { $rot--; $rot = $rot%4 };
			$my++ if ($event->direction == $DIRECTION_DOWN);
			$mx-- if ($event->direction == $DIRECTION_LEFT);
			$mx++ if ($event->direction == $DIRECTION_RIGHT);
			
			if($self->grid->is_possible_movement($mx, $my, $self->{piece}, $rot))
			{
			  ($self->{posx}, $self->{posy}, $self->{pieceRotation}) = ($mx, $my, $rot);
				
			$self->evt_manager->post(Event::CharactorMove->new());
			}			
        }
		if ( $event->isa('Event::Tick') && ((time - $self->{wait}) > $self->{level}))
		{
		    $self->{wait} = time;
			
			if ($self->grid->is_possible_movement($self->{posx}, $self->{posy} + 1, $self->{piece}, $self->{pieceRotation}))
			{
			$self->{posy}++;
			$self->evt_manager->post(Event::CharactorMove->new());
			}
			else  
			{  
				
			 $self->grid->store_piece( $self->{posx}, $self->{posy}, $self->{piece}, $self->{pieceRotation});
             $self->create_new_piece();  
			 
			 $self->{level} -= (0.01)*$self->grid->delete_possible_lines;
			 if($self->grid->is_game_over())
			 {
				#make this Event::GameOver
				$self->evt_manager->post(Event::Quit->new());
			 }
			}  
		 }
	   
	}
    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

#
#Game Objects
#

package Blocks;
use Data::Dumper;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/
		$SQUARE $LINE $L_SHAPE $L_MIRROR $N_SHAPE $N_MIRROR $T_SHAPE
		get_block_type get_x_init_pos get_y_init_pos
	    /;
use Pieces qw/@pieces/; 
use Readonly;
Readonly our $SQUARE   => 0;
Readonly our $LINE     => 1;
Readonly our $L_SHAPE  => 2;
Readonly our $L_MIRROR => 3;
Readonly our $N_SHAPE  => 4;
Readonly our $N_MIRROR => 5;
Readonly our $T_SHAPE  => 6;

sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub get_block_type
{
	die 'Expecting 4 arguments' if ($#_ != 3); 
	my($piece, $rotation, $x, $y) = @_;
	return $Pieces::pieces[$piece][$rotation][$x][$y];
}
sub get_x_init_pos {
	die 'expecting 2 arguments got: ' if ($#_ != 1);
	my($piece, $rotation) = @_;
	return $Pieces::pieces_init[$piece][$rotation][0];
}
sub get_y_init_pos {
	die 'expecting 2 arguments' if ($#_ != 1);
	my($piece, $rotation) = @_;
	return $Pieces::pieces_init[$piece][$rotation][1];
	
}

package Grid;
use Data::Dumper;
use Class::XSAccessor accessors => { evt_manager => 'evt_manager', blocks => 'blocks', grid => 'grid' };
BEGIN
{
	Blocks->import;
}

sub new
{
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->init(@_);
    return $self;   
}

sub init
{
  my $self = shift;
  #TODO: Get the following from @_
   $self->{board_line_width} = 6;
   $self->{block_size} = 16;
   $self->{board_position} = 300;
   $self->{screen_height} = 480;
     
   $self->{width} = 20;
   $self->{height} = 20;
   my $arr_ref = [  ];
  # used to test delete_line   
  # for my $x (0..18) 
  # {
  #		$arr_ref->[$x][19] = 1;
  #  }
   $self->grid($arr_ref);
  
}

sub store_piece
{
  my $self = shift;
  die 'Expecting 4 parameters'  if ($#_ != 3);
  my ($x, $y, $piece, $rotation) = @_;

  for( my $i1 = $x, my $i2 =0; $i1< $x + 5; $i1++, $i2++)
  {
	  for( my $j1 = $y, my $j2 = 0; $j1 < $y + 5; $j1++, $j2++)
	  {
		  if( !($i1 < 0 || $j1 < 0))
		  {
		  $self->grid->[$i1][$j1] = 1 if( Blocks::get_block_type($piece, $rotation,$j2, $i2) != 0)
		  }
	  }
  }
}

sub is_game_over
{
	my $self = shift;
	for (my $i = 0; $i < $self->{width}; $i++)  
	    {  
			if( defined $self->grid->[$i][0])
			{
		    return 1 if ( $self->grid->[$i][0] == 1);  
			}
        } 
	return 0;
}

#removes a line and moves everything one row down
sub delete_line
{
    my $self = shift;
    my $dline = shift;
    for (my $j = $dline; $j >0; $j--)
    {
	
	 for (my $i = 0; $i < $self->{width}; $i++)  
	         {  
			  $self->grid->[$i][$j] = $self->grid->[$i][$j-1];  
              } 
    }
	return 1;
}

sub delete_possible_lines
{
	
	my $self = shift;
	my $deleted_lines = 0;
	for (my $j=0; $j < $self->{height}; $j++ )
	{
		
		
		my $i =0;
		while ($i < $self->{width} )
		{
		last	if !(defined($self->grid->[$i][$j]));  
		$i++; 
		}
		$deleted_lines += $self->delete_line($j) if $i == $self->{width};
	}
	return $deleted_lines;
}

sub is_free_loc 
{
	my $self = shift;
	die 'Expecting 2 parameters' if $#_ != 1;
	#die 'got '.$_[0].' '.$_[1];
	my $grid = $self->grid();
	#die Dumper $grid;
	return 1 if !defined($grid->[$_[0]][$_[1]]);
	return 0 if ($grid->[$_[0]][$_[1]] == 1);
	
}

sub get_x_pos_in_pixels
{
	my $self = shift;
	die 'Expecting 1 parameter got '.$_[0] if ( !defined ($_[0] ));
	return  (($self->{board_position} - ($self->{block_size} * ($self->{width} /2)) ) +($_[0] * $self->{block_size} ) + 3);
}

sub get_y_pos_in_pixels
{
	my $self = shift;
	die 'Expecting 1 parameter got '.$_[0] if ( !defined ($_[0] ));
	return  (($self->{screen_height} - ($self->{block_size} * $self->{height} ) ) +($_[0] * $self->{block_size} ) );

}

sub is_possible_movement
{
	my $self = shift;
	die 'Expecting 4 parameters' if $#_ !=3;
  	my($x, $y, $piece, $rotation) = @_;

	for(my $i1 = $x, my $i2 =0; $i1 < $x + 5; $i1++, $i2++)
	{
 	   for(my $j1 = $y, my $j2 = 0; $j1 < $y + 5; $j1++, $j2++)
	   {
		#check if block goes outside limits
		if( $i1 < 0 || $i1 > ($self->{width} -1) || $j1 > ($self->{height} -1) )
		{
			return 0 if(Blocks::get_block_type($piece, $rotation, $j2, $i2) != 0 ) 
		}
		#check collision with blocks already on board
		if($j1 >=0 )
		{
			return 0 if( (Blocks::get_block_type($piece, $rotation, $j2, $i2) != 0) && !($self->is_free_loc($i1, $j1)) );
		}
	   }
	}
	#no collision
	return 1;
}

sub notify
{
	    print "Notify in Grid \n" if $EDEBUG;
    my ( $self, $event ) = (@_);

    if ( defined $event && $event->isa('Event::Tick') ) {
			#do checks
        
    }
}




package main;    #On the go testing

my $manager  = Event::Manager->new;
my $keybd    = Controller::Keyboard->new($manager);
my $spinner  = Controller::CPUSpinner->new($manager);
my $gameView = View::Game->new($manager);
my $game     = Controller::Game->new($manager);

$spinner->run;
