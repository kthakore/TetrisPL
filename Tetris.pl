use strict;
use warnings;
use Carp;
use Data::Dumper; 
use Readonly;
Readonly my $DIRECTION_UP => 0; #rotates blocks
Readonly my $DIRECTION_DOWN => 1; #rotates blocks other way
Readonly my $DIRECTION_LEFT => 2; # move left
Readonly my $DIRECTION_RIGHT => 3; # move right
                                                                                                    
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
 
        die "Post needs a TickEvent as parameter"
            unless $event->isa('Event::Tick');
		while( my($key, $listener) = %{$self->listeners} ){
			  $listener->notify($event);
	    }

 
}
 
package Controller::Keyboard;
use Class::XSAccessor accessors => { event => 'event', evt_manager =>'evt_manager'};
use SDL;
use SDL::Event;
use Scalar::Util qw(weaken);
use Data::Dumper;
sub new{
  my $class = shift;
  my $self = {};
  bless $self, $class;
 if ( defined $_[0] && $_[0]->isa('Event::Manager')) { $self->evt_manager( $_[0] ) } else { die 'Expects an Event::Manager' };
 print Dumper $self;
 my $weak_self = weaken $self;
 print Dumper $weak_self;
 die;
 $self->evt_manager->reg_listener($weak_self); 
 #$self->evt_manager->reg_listener($self); 
 #TODO weaken so it works
 return $self;

}

sub notify
{
#	print "This Should Print";
	my $self = shift;
	if( defined $_[0] && $_[0]->isa('Event::Tick') )
	{
		my $tick_event = $_[0]
	}
	else
	{
		die 'expecting Event::Tick';
	}
	
	$self->event(SDL::Event->new()); 
	$self->event->pump;
	$self->event->poll;
	exit if $self->event->type == SDL_QUIT();
	exit if $self->event->type == SDL_KEYDOWN() && $self->event->key_name =~ 'escape';

}

package main; #On the go testing
 

use SDL;
use SDL::App;
# after launching this script press the keyboard and whach the console

# this script is using the internal event loop of SDL but as far as I can understand
# this is not a recommended practice.

my $window = SDL::App->new(
	-width => 640,
	-height => 480,
	-depth => 16,
	-title => 'SDL Demo',
);



my $evManager = Event::Manager->new();
my $keybd = Controller::Keyboard->new($evManager);
my $tick = Event::Tick->new();
$evManager->post($tick);



#my $spiner = Controller::CPUSpinnerController($evManager);
#my $gameView = View::Game->new( $evManager );
#my $game = Game( $evManager);

#$spinner->Run();
