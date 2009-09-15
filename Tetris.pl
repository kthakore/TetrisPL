use strict;
use warnings;
use Carp;

sub DIRECTION_UP{ return 0}
sub DIRECTION_DOWN{ return 1}
sub DIRECTION_LEFT{ return 2}
sub DIRECTION_RIGHT{ return 3}

#Event Super Class
package Event;
sub new { my $class = shift; my $self = {}; bless $self, $class; 
	  $self->name("Generic Event"); return $self  }
sub name { my $self = shift; $self->{name} = shift if(@_); return $self->{name}}

package Event::Tick;
sub new { my $class = shift; my $self = {}; bless $self, $class; 
	  $self->name("CPU Tick Event"); return $self  }

package main;

my $event = Event::Tick->new;
print $event->name

