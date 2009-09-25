package SDL::Tutorial::Tetris::Controller::CPUSpinner;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Controller';

sub new {
    my ($class, $event) = (@_);
    my $self  = $class->SUPER::new();

    die 'Expects an SDL::Tutorial::Tetris::EventManager'
      unless defined $event and $event->isa('SDL::Tutorial::Tetris::EventManager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    $self->{keep_going} = 1;
    return $self;
}

sub run {
    my $self = shift;
    while ($self->{keep_going} == 1) {
        my $tick = SDL::Tutorial::Tetris::Event::Tick->new;
        $self->evt_manager->post($tick);
    }
}

sub notify {
    my ($self, $event) = (@_);

    print "Notify in CPU Spinner \n" if $self->EDEBUG;

    if (defined $event && $event->isa('SDL::Tutorial::Tetris::Event::Quit')) {
        print "Stopping to pump ticks \n" if $self->EDEBUG;

        #if we got a quit event that means we can stop running the game
        $self->{keep_going} = 0;
    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

1;
