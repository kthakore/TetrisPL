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
use Class::XSAccessor accessors => { grid => 'grid', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('Grid Built Event');
    return $self;
}

package Event::GameStart;
use base 'Event';
use Class::XSAccessor accessors => { game => 'game', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Game Start Event');
    return $self;
}

package Request::CharactorMove;
use base 'Event';
use Class::XSAccessor accessors => { direction => 'direction', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Charactor Move Request');
    return $self;
}

package Event::CharactorPlace;
use base 'Event';
use Class::XSAccessor accessors => { charactor => 'charactor', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Charactor Place Event');
    return $self;
}

package Event::CharactorMove;
use base 'Event';
use Class::XSAccessor accessors => { charactor => 'charactor', };

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Charactor Move Event');
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

#
# so now you can access them like:
# $object->listeners->{foo} = 'bar';
# my $listener = $object->listeners->{foo}; # $listener gets 'bar'
#
# $object->evt_queue->[0] = 'baz';
# I think you can even do:
# push @{$object->evt_queue}, 'bla';
# my $event = $objetc->evt_queue->[0]; # $event gets 'baz'
# from the code below I see you don't want the user
# to interact directly with ->listeners, or do you?
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
use Scalar::Util qw(weaken);

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event && $event->isa('Event::Manager');

    $self->evt_manager($event);
    my $weak_self = $self;
    weaken($weak_self);

    $self->evt_manager->reg_listener($weak_self);
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
use Class::XSAccessor accessors => { evt_manager => 'evt_manager' };
use Scalar::Util qw(weaken);

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    my $weak_self = $self;
    weaken $weak_self;
    $self->evt_manager->reg_listener($weak_self);
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

package Sprite::Square;
use base 'SDL::Surface';

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->init;
}

sub init {
    my $self = shift;

}

package View::Game;
use Class::XSAccessor accessors => { evt_manager => 'evt_manager', app => 'app'};
use Scalar::Util qw(weaken);
use SDL;
use SDL::App;
#http://www.colourlovers.com/palette/959495/Toothpaste_Face
our @pallete =
(
	(SDL::Color->new( -r => 0,   -g =>191,  -b =>247)),
	(SDL::Color->new( -r => 0,   -g =>148,  -b =>217)),
	(SDL::Color->new( -r => 247, -g =>202,  -b =>0  )),
	(SDL::Color->new( -r => 0,   -g =>214,  -b =>46)),
	(SDL::Color->new( -r => 237, -g =>0,    -b =>142)),
);

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    my $weak_self = $self;
    weaken $weak_self;
    $self->evt_manager->reg_listener($weak_self);
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
    ));
	
	$self->{background} =  SDL::Rect->new( -x => 0, -y => 0, 
	-w => $self->app->width, -h => $self->app->height);
	my $color = $pallete[0];
	$self->app->fill($self->{background},  $color );
	
	
}

sub show_grid
{
	my $self = shift;
	
	my $w = $self->app->width * (24/32); 
	my $h = $self->app->height * (30/32); 
	my $x = $self->app->width * (1/32);
	my $y = $self->app->height * (1/32);
	
	$self->{grid} = SDL::Rect->new( -x => $x, -y =>$y, -w => $w, -h => $h);
	my $color = $pallete[2];
	$self->app->fill($self->{grid},  $color );
}

#needs the charactor now
sub show_charactor
{
}

sub move_charactor
{
}

sub get_charactor_sprite
{
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

sub test_block
{
	my $self = shift;
	
	my $w = 20; 
	my $h = 20; 
	my $x = ($self->app->width * (1/2))- ($w/2);
	my $y = $self->app->height * (1/32);
#	print "Box is at".$_[0]."\n";
	$y = $_[0] if defined $_[0];
	my $box = SDL::Rect->new( -x => $x, -y =>$y, -w => $w, -h => $h);
	my $color = $pallete[3];
	$self->app->fill($box,  $color );
#	print "Box is at $y \n";
	return $y++;
}
our $y = 15;
sub notify {
    print "Notify in View Game \n" if $EDEBUG;
    my ( $self, $event ) = (@_);
	
    if ( defined $event ) {
        if ( $event->isa('Event::Tick') ) {
            print "Update Game View \n" if $GDEBUG;
			frame_rate(1) if $FPS;
			$y += 20;
			$self->show_grid();
			$self->test_block($y);
			$self->app->sync();
            #if we got a quit event that means we can stop running the game
        }
        if ( $event->isa('Event::GridBuilt') ) {
            print "Showing Grid \n" if $GDEBUG;
			$self->show_grid();
			$self->app->sync();
        }
        if ( $event->isa('Event::CharactorPlace') ) {
            print "Placing charactor sprite \n" if $GDEBUG;
			$self->app->sync();
        }
        if ( $event->isa('Event::CharactorMove') ) {
            print "Moving chractor sprite \n" if $GDEBUG;
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
use Class::XSAccessor accessors => { evt_manager => 'evt_manager' };
use Scalar::Util qw/weaken/;
use Readonly;
Readonly my $STATE_PREPARING => 0;
Readonly my $STATE_RUNNING   => 1;
Readonly my $STATE_PAUSED    => 2;

sub new {
    my ( $class, $event ) = (@_);
    my $self = {};
    bless $self, $class;

    die 'Expects an Event::Manager'
      unless defined $event and $event->isa('Event::Manager');

    $self->evt_manager($event);
    my $weak_self = $self;
    weaken($weak_self);
    $self->evt_manager->reg_listener($weak_self);
    $self->{state} = $STATE_PREPARING;
    print "Game PREPARING ... \n" if $GDEBUG;

    #$self->{player} =;
    #$self->{window} =;
    #$self->{block_queue} =;
    return $self;
}

sub start {
    my $self = shift;

    #$self->{window}->build;
    $self->{state} = $STATE_RUNNING;
    print "Game RUNNING \n" if $GDEBUG;
    my $event = Event::GameStart->new($self);
    $self->evt_manager->post($event);
}

sub show_grid
{
	my $self = shift;
	
}

sub notify {
    print "Notify in GAME \n" if $EDEBUG;
    my ( $self, $event ) = (@_);

    if ( defined $event && $event->isa('Event') ) {
        if ( $self->{state} == $STATE_PREPARING ) {
            print "Event " . $event->name . "caught to start Game  \n"
              if $GDEBUG;

            #if we got a quit event that means we can stop running the game
            $self->start;
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
	die 'Expecting 4 arguments' if ($#_ != 4); 
	my($piece, $rotation, $x, $y) = @_;
	return $Pieces::pieces[$piece][$rotation][$x][$y];
}
sub get_x_init_pos {
	die 'expecting 2 arguments' if ($#_ != 2);
	my($piece, $rotation) = @_;
	return $Pieces::pieces_init[$piece][$rotation][0];
}
sub get_y_init_pos {
	die 'expecting 2 arguments' if ($#_ != 2);
	my($piece, $rotation) = @_;
	return $Pieces::pieces_init[$piece][$rotation][1];
	
}

package Grid;
use Class::XSAccessor accessors => { blocks => 'blocks', grid => 'grid' };
BEGIN
{
	Blocks->import;
}
sub new
{
    my $class = shift;
    my $self = {};
    bless $class, $self;
    $self->init();
    return $self;   
}

sub init
{
  my $self = shift;
  my $x = 10;
  my $y = 20;
  $self->grid( [ [$x x $y] x $y ] );
}

sub store_piece
{

  my $self = shift;
  die'Expecting 4 parameters'  if ($#_ != 4);
  my ($x, $y, $piece, $rotation) = @_;
  for( my $i1 = $x, my $i2 =0; $i1< $x + 5; $i1++, $i2++)
  {
	  for( my $j1 = $y, my $j2 = 0; $j1 < $y + 5; $j1++, $j2++)
	  {
		  $self->grid->[$i1][$j1] = 1 if( get_block_type($piece, $rotation,$j2, $i2) != 0)

	  }
  }
}
package main;    #On the go testing

my $manager  = Event::Manager->new;
my $keybd    = Controller::Keyboard->new($manager);
my $spinner  = Controller::CPUSpinner->new($manager);
my $gameView = View::Game->new($manager);
my $game     = Controller::Game->new($manager);

$spinner->run;
