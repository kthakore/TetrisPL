package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

use Class::XSAccessor accessors => {
    name => 'name',
};

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

package SDL::Tutorial::Tetris::Event::Manager;
use Data::Dumper;

use base 'SDL::Tutorial::Tetris';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();

    $self->{listeners} = {};
    $self->{evt_queue} = [];

    return $self;
}

sub listeners : lvalue {
    return shift->{listeners};
}

sub evt_queue : lvalue {
    return shift->{evt_queue};
}

sub reg_listener {
    my ($self, $listener) = (@_);
    $self->listeners->{$listener} = $listener
      if defined $listener;

    return $self->listeners->{$listener};
}

sub un_reg_listener {
    my ($self, $listener) = (@_);

    if (defined $listener) {
        return delete $self->listeners->{\$listener};
    }
    else {
        return;
    }
}

sub post {
    my $self = shift;
    my $event = shift if (@_) or die "Post needs a TickEvent";
    print 'Event' . $event->name . "notified\n" if $self->EDEBUG;
    die "Post needs a Event as parameter"
      unless $event->isa('SDL::Tutorial::Tetris::Event');

#print 'Event' . $event->name ." called \n" if (!$event->isa('SDL::Tutorial::Tetris::Event::Tick') && $self->EFDEBUG);

    foreach my $listener (values %{$self->listeners}) {
        $listener->notify($event);
    }
}


1;
