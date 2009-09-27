package SDL::Tutorial::Tetris::Controller::Keyboard;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Controller';

use SDL;
use SDL::Event;

sub notify {
    my ($self, $event) = (@_);

    print "Notify in C::KB \n" if $self->EDEBUG;

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
    return if !defined $event or $event->{name} ne 'Tick';

    #if we got a tick event that means we are starting
    #a new iteration of game loop
    #so we can check input now

    my $event_to_process = undef;

    my $sdl_event = SDL::Event->new();

    $sdl_event->pump;    #get events from SDL queue
    $sdl_event->poll;    #get the first one

    my $event_type = $sdl_event->type;
    my $key        = $self->{last_key} || $sdl_event->key_name;

    if ( $key =~ /(down|left|right)/ ) {
        $self->{last_key} = $key;
    }

    if ( $event_type == SDL_QUIT ) {
        $key = 'escape';
    }
    elsif ($event_type == SDL_KEYUP) {
        delete $self->{last_key};
        $key = '';
    }
   
    my %event_key = (
        'escape' => { name => 'Quit' },
        'up'     => { name => 'CharactorMoveRequest', direction => $self->ROTATE_C },
        'space'  => { name => 'CharactorMoveRequest', direction => $self->ROTATE_CC },
        'down'   => { name => 'CharactorMoveRequest', direction => $self->DIRECTION_DOWN },
        'left'   => { name => 'CharactorMoveRequest', direction => $self->DIRECTION_LEFT },
        'right'  => { name => 'CharactorMoveRequest', direction => $self->DIRECTION_RIGHT },
    );

    $event_to_process = $event_key{$key} if defined $event_key{$key};

    if (defined $event_to_process) {
        #print "SDL event type='$event_type', key='$key'\n";
        $self->evt_manager->post($event_to_process);
    }

    $event_to_process = undef;    #why the hell do I have to do this shouldn't it be destroied now?
}

1;

__END__

=head1 NAME

SDL::Tutorial::Tetris::Controller::Keyboard

=head1 DESCRIPTION

This module takes care of keyboard events.

=head2 notify

C<notify> will generate new events depending on the key pressed:

=over

=item esc

=item direction keys

=item space bar

=back
