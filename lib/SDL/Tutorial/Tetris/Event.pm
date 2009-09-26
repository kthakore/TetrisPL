package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

use Class::XSAccessor accessors => {
    name => 'name',
};

package SDL::Tutorial::Tetris::Event::CharactorMoveRequest;

use base 'SDL::Tutorial::Tetris::Event';

use Class::XSAccessor accessors => {
    direction => 'direction',
};

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->direction($_[0]);
    $self->name('CharactorMoveRequest');
    return $self;
}

1;
