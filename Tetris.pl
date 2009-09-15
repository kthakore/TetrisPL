# warning! Untested code :)
use strict;
use warnings;

use Readonly;

# Note to kthatore: if you don't like the $ before the name, 
# since those are simple values you can just as well do:
#
# use constant {
#   DIRECTION_UP => 0,
#   DIRECTION_DOWN => 1,
#   DIRECTION_LEFT => 2,
#   DIRECTION_RIGHT => 3,
# };
#
# instead of the below:

Readonly my $DIRECTION_UP    => 0;  #rotates blocks
Readonly my $DIRECTION_DOWN  => 1;  #rotates blocks other way
Readonly my $DIRECTION_LEFT  => 2;  # move left
Readonly my $DIRECTION_RIGHT => 3;  # move right
                                                                                                    
#Event Super Class
package Event;
use Class::XSAccessor
  constructor => 'new',
  accessors => {
     name => 'name',
  };   
                                                                                                    
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

                                                                                                    
package Event::GridBuiltEvent; #Tetris has a grid
use base 'Event';
use Class::XSAccessor
  accessors => {
    grid => 'grid',
  };
                                                                                                    
package main; #On the go testing
my $event = Event::Tick->new;
print $event->name