package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

use Class::XSAccessor accessors => {
    name => 'name',
};

1;

__END__

=head1 NAME

SDL::Tutorial::Tetris::Event - generic event

=head1 DESCRIPTION

This is the generic event class. It has only one mandatory property, 
which is its name; but we can attach more properties to it dinamically.
(For instance, CharactorMoveRequest events can have a "direction").

=head1 SEE ALSO

L<SDL::Tutorial::Tetris::EventManager>
