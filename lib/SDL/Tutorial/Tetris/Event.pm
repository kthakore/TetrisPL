package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use Class::XSAccessor accessors => {name => 'name',};

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->name("Generic Event");
    return $self;
}

package SDL::Tutorial::Tetris::Event::Tick;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('CPU Tick Event');
    return $self;
}

package SDL::Tutorial::Tetris::Event::Quit;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Program Close Event');
    return $self;
}

package SDL::Tutorial::Tetris::Event::GridBuilt;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';
use Data::Dumper;
use Class::XSAccessor accessors => {grid => 'grid'};

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->name('Grid Built Event');
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
    $self->name('Game Start Event');
    $self->game($_[0]);
    return $self;
}

package SDL::Tutorial::Tetris::Event::CharactorMove;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Event';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;
    $self->name('Charactor is Moving');
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
    $self->name('Charactor Move Request');
    return $self;
}

1;
