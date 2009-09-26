package SDL::Tutorial::Tetris::Controller;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

# all controllers inherit these accessors:
use Class::XSAccessor accessors => {
    event => 'event', 
};

sub new {
    my ($class, %params) = (@_);

    my $self  = $class->SUPER::new(%params);

    # all controllers must register a listener
    $self->evt_manager->reg_listener($self);

    $self->init() if $self->can('init');

    return $self;
}

1;
