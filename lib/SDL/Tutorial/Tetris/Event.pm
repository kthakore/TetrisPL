package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

use Class::XSAccessor accessors => {
    name => 'name',
};

package SDL::Tutorial::Tetris::Event::GridBuilt;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';
use Data::Dumper;
use Class::XSAccessor accessors => {grid => 'grid'};

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('GridBuilt');
    $self->grid($_[0]);
    return $self;
}

package SDL::Tutorial::Tetris::Event::GameStart;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';
use Class::XSAccessor accessors => {game => 'game',};

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('GameStart');
    $self->game($_[0]);
    return $self;
}

package SDL::Tutorial::Tetris::Request::CharactorMove;

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
