use strict;
use warnings;
use Carp;
use Data::Dumper; 
use Readonly;
Readonly my $DIRECTION_UP => 0; #rotates blocks
Readonly my $DIRECTION_DOWN => 1; #rotates blocks other way
Readonly my $DIRECTION_LEFT => 2; # move left
Readonly my $DIRECTION_RIGHT => 3; # move right

our ($EDEBUG, $KEYDEBUG, $GDEBUG) = @ARGV; #Event and key debug

#Event Super Class
package Event;
use Class::XSAccessor accessors => { name => 'name', };
sub new {
 my $class = shift;
 my $self = {};
 bless $self, $class;
 $self->name("Generic Event");
 return $self
}

package Event::Tick;
use base 'Event';
sub new {
  my $class = shift;
  my $self = $class->SUPER::new( );
  $self->name( 'CPU Tick Event' );
  return $self;
}

package Event::Quit;
use base 'Event';
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Program Close Event');
  return $self;
}
 

package Event::GridBuilt; #Tetris has a grid
use base 'Event';
use Class::XSAccessor accessors => { grid => 'grid', };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new( );
  $self->name( 'Grid Built Event' );
  return $self;
}
 
package Event::GameStart;
use base 'Event';
use Class::XSAccessor accessors => { game => 'game', };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Game Start Event' );
  return $self;
}
 
package Request::CharactorMove;
use base 'Event';
use Class::XSAccessor accessors => { direction => 'direction', };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Move Request' );
  return $self;
}
 
package Event::CharactorPlace;
use base 'Event';
use Class::XSAccessor accessors => { charactor => 'charactor', };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Place Event' );
  return $self;
}
 
 
package Event::CharactorMove;
use base 'Event';
use Class::XSAccessor accessors => { charactor => 'charactor', };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Move Event' );
  return $self;
}
 
#---------------------------
package Event::Manager;
use Data::Dumper;
sub new {
  my $class = shift;
  my $self = {
    listeners => {},
    evt_queue => [],
  };
  bless $self, $class;
  return $self
 }
 
sub listeners :lvalue { return shift->{listeners} }
sub evt_queue :lvalue { return shift->{evt_queue} }
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
sub reg_listener{
my ($self) = shift; 
     $self->listeners->{$_[0]} = $_[0]
	          if defined $_[0];

return $self->listeners->{$_[0]};
}
 
sub un_reg_listener{
  my ($self, $listener) = (@_);
        
        if (defined $listener) {
            return delete $self->listeners->{\$listener}
        }
        else {
            return;
        }
}
 
sub post
{
my $self = shift;
my $event = shift if(@_) or die "Post needs a TickEvent";
		print 'Event'.$event->name()."notified\n" if $EDEBUG;
        die "Post needs a TickEvent as parameter"
            unless $event->isa('Event');
		

		foreach my $listener (values %{$self->listeners} )
		{
			  $listener->notify($event);
	    }

 
}
 
package Controller::Keyboard;
use Class::XSAccessor accessors => { event => 'event', evt_manager =>'evt_manager'};
use SDL;
use SDL::Event;
use Scalar::Util qw(weaken);
sub new{
  my $class = shift;
  my $self = {};
  bless $self, $class;

 if ( defined $_[0] && $_[0]->isa('Event::Manager')) { $self->evt_manager( $_[0] ) } else { die 'Expects an Event::Manager' };
 $self->evt_manager->reg_listener($self); 
 my $weak_self = weaken $self;
 #$self->evt_manager->reg_listener($self); 
 #TODO weaken so it works
 return $self;
}

sub notify
{
	print "Notify in C::KB \n" if $EDEBUG;
	my $self = shift;
	
	if( defined $_[0] && $_[0]->isa('Event::Tick') )
	{
		#if we got a tick event that means we are starting 
		#a new iteration of game loop
		#so we can check input now
		my $event_to_process = undef;
		$self->event(SDL::Event->new()); 
		$self->event->pump; #get events from SDL queue
		$self->event->poll; #get the first one
		my $event_type = $self->event->type;
		$event_to_process = Event::Quit->new() if $event_type == SDL_QUIT();
		if ($event_type == SDL_KEYDOWN())
		{   
			
			my $key = $self->event->key_name;
			print $key." pressed \n" if $KEYDEBUG;
			#This process the only keys we care about right now
			#later on we will add more stuff
			$event_to_process = Event::Quit->new() 
					if $key =~ 'escape';			
			$event_to_process = Request::CharactorMove->new($DIRECTION_UP) 
					if $key =~ 'up';
			$event_to_process = Request::CharactorMove->new($DIRECTION_DOWN) 
					if $key =~ 'down';
			$event_to_process = Request::CharactorMove->new($DIRECTION_LEFT) 
					if $key =~ 'left';
			$event_to_process = Request::CharactorMove->new($DIRECTION_RIGHT) 
					if $key =~ 'right';
			}
		#lets send the new events to be process back the event manager
		$self->evt_manager->post($event_to_process) if defined $event_to_process;
		
		
	}
 	#if we did not have a tick event then some other controller needs to do
 	#something so game state is still beign process we cannot have new input 
	#now	
}

package Controller::CPUSpinner;
use Class::XSAccessor accessors => { evt_manager =>'evt_manager'};
use Scalar::Util qw(weaken);
sub new{
  my $class = shift;
  my $self = {};
  bless $self, $class;
if ( defined $_[0] && $_[0]->isa('Event::Manager')) { $self->evt_manager( $_[0] ) } else { die 'Expects an Event::Manager' };
 $self->evt_manager->reg_listener($self); 
 my $weak_self = weaken $self;
 $self->{keep_going} = 1;
 return $self;
}

sub run
{
	my $self = shift;
	while ($self->{keep_going} == 1 )
	{
		my $tick = Event::Tick->new();
		$self->evt_manager->post($tick);
	}
}

sub notify
{
	print "Notify in CPU Spinner \n" if $EDEBUG;
	my $self = shift;
	
	if( defined $_[0] && $_[0]->isa('Event::Quit') )
	{
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
sub new
{
   my $class = shift;
   my $self = {};
   bless $self, $class;
   $self->init();
}

sub init
{
	my $self = shift;
	
}

package View::Game;
use Class::XSAccessor accessors => { evt_manager =>'evt_manager'};
use Scalar::Util qw(weaken);
use SDL;
use SDL::App;

sub new{
  my $class = shift;
  my $self = {};
  bless $self, $class;
if ( defined $_[0] && $_[0]->isa('Event::Manager')) { $self->evt_manager( $_[0] ) } else { die 'Expects an Event::Manager' };
 $self->evt_manager->reg_listener($self); 
 my $weak_self = weaken $self;
 $self->{keep_going} = 1;
 return $self;
}

sub init 
{
	my $self = shift;
	$self->{window} = SDL::App->new(
	-width => 640,
	-height => 480,
	-depth => 16,
	-title => 'SDL Demo',
	);
}

sub notify
{
	print "Notify in View Game \n" if $EDEBUG;
	my $self = shift;
	
	if( defined $_[0] ) 
	{
		if($_[0]->isa('Event::Tick')) 
		{
		print "Update Game View \n" if $GDEBUG;
		#if we got a quit event that means we can stop running the game
		}
		if($_[0]->isa('Event::GridBuilt'))
		{
		print "Showing Grid \n" if $GDEBUG;
		}
		if($_[0]->isa('Event::CharactorPlace'))
		{
		print "Placing charactor sprite \n" if $GDEBUG;
		}
		if($_[0]->isa('Event::CharactorMove'))
		{
		print "Moving chractor sprite \n" if $GDEBUG;
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
use Class::XSAccessor accessors => { evt_manager =>'evt_manager'};
use Scalar::Util qw/weaken/;
use Readonly;
Readonly my $STATE_PREPARING => 0; 
Readonly my $STATE_RUNNING => 1; 
Readonly my $STATE_PAUSED => 2; 
sub new{
  my $class = shift;
  my $self = {};
  bless $self, $class;
if ( defined $_[0] && $_[0]->isa('Event::Manager')) { $self->evt_manager( $_[0] ) } else { die 'Expects an Event::Manager' };
 $self->evt_manager->reg_listener($self); 
 my $weak_self = weaken $self;
 $self->{state} = $STATE_PREPARING;
 print "Game PREPARING ... \n" if $GDEBUG;
 #$self->{player} =;
 #$self->{window} =;
 #$self->{block_queue} =;
 return $self;
}

sub start
{
	my $self = shift;
	#$self->{window}->build();
	$self->{state} = $STATE_RUNNING;
	print "Game RUNNING \n" if $GDEBUG;
	my $event = Event::GameStart->new( $self );
	$self->evt_manager->post($event);
}

sub notify
{
	print "Notify in GAME \n" if $EDEBUG;
	my $self = shift;
	
	if( defined $_[0] && $_[0]->isa('Event') )
	{
		if($self->{state} == $STATE_PREPARING)
		{
		print "Event ".$_[0]->name()."caught to start Game  \n" if $GDEBUG;
		#if we got a quit event that means we can stop running the game
		$self->start();
		}
	}
 	#if we did not have a tick event then some other controller needs to do
 	#something so game state is still beign process we cannot have new input 
	#now	
}


package main; #On the go testing
my $evManager = Event::Manager->new();
my $keybd = Controller::Keyboard->new($evManager);
my $spinner = Controller::CPUSpinner->new($evManager);
my $gameView = View::Game->new( $evManager );
my $game = Controller::Game->new( $evManager);

$spinner->run();
