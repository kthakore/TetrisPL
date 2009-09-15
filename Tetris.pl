use strict;
use warnings;

use Readonly;
Readonly my $DIRECTION_UP    => 0;  #rotates blocks
Readonly my $DIRECTION_DOWN  => 1;  #rotates blocks other way
Readonly my $DIRECTION_LEFT  => 2;  # move left
Readonly my $DIRECTION_RIGHT => 3;  # move right
                                                                                                    
#Event Super Class
package Event;
use Class::XSAccessor  accessors => { name => 'name', };   
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
  my $self = $class->SUPER::new( name => 'CPU Tick Event' );
  return $self;
}
                                                                                                    
package Event::Quit;
use base 'Event';
sub new { 
  my $class = shift;
  my $self = $class->SUPER::new( name => 'Program Quit Event' );
  return $self;
}

                                                                                                    
package Event::GridBuilt; #Tetris has a grid
use base 'Event';
use Class::XSAccessor   accessors => {  grid => 'grid',  };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new( );
  $self->name( 'Grid Built Event' );
  return $self;
}

package Event::GameStart; 
use base 'Event';
use Class::XSAccessor  accessors => {  game => 'game',  };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Game Start Event' );
  return $self;
}

package Request::CharactorMove; 
use base 'Event';
use Class::XSAccessor  accessors => {  direction => 'direction',  };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Move Request' );
  return $self;
}

package Event::CharactorPlace; 
use base 'Event';
use Class::XSAccessor  accessors => {  charactor => 'charactor',  };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Place Event' );
  return $self;
}


package Event::CharactorMove; 
use base 'Event';
use Class::XSAccessor  accessors => {  charactor => 'charactor',  };
sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  $self->name( 'Charactor Move Event' );
  return $self;
}

#---------------------------
package Event::Manager;
#Coordinates MVC
sub new {
  my $class = shift;
  my $self = {};
  return $self
 }


package main; #On the go testing

my $event = Event::GridBuilt->new();
print $event->name
