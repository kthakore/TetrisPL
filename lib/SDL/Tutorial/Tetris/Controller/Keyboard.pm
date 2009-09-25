package SDL::Tutorial::Tetris::Controller::Keyboard;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Controller';

use SDL;
use SDL::Event;

sub new {
    my ($class, $event) = (@_);
    my $self  = $class->SUPER::new();

    die 'Expects an SDL::Tutorial::Tetris::EventManager'
      unless defined $event && $event->isa('SDL::Tutorial::Tetris::EventManager');

    $self->evt_manager($event);
    $self->evt_manager->reg_listener($self);
    return $self;
}

sub notify {
    my ($self, $event) = (@_);

    print "Notify in C::KB \n" if $self->EDEBUG;
    if (defined $event and $event->isa('SDL::Tutorial::Tetris::Event::Tick')) {

        #if we got a tick event that means we are starting
        #a new iteration of game loop
        #so we can check input now
        my $event_to_process = undef;
        $self->event(SDL::Event->new);
        $self->event->pump;    #get events from SDL queue
        $self->event->poll;    #get the first one
        my $event_type = $self->event->type;
        $event_to_process = SDL::Tutorial::Tetris::Event::Quit->new if $event_type == SDL_QUIT;
        if ($event_type == SDL_KEYDOWN
            || (defined $self->{key} && $self->{key} =~ 'down'))
        {

            $self->{key} = $self->event->key_name
              if !(defined $self->{key});

            my $key = $self->{key};
            print $key. " pressed \n" if $self->KEYDEBUG;

            #This process the only keys we care about right now
            #later on we will add more stuff
            $event_to_process = SDL::Tutorial::Tetris::Event::Quit->new
              if $key =~ 'escape';
            $event_to_process = SDL::Tutorial::Tetris::Request::CharactorMove->new($self->ROTATE_C)
              if $key =~ 'up';
            $event_to_process = SDL::Tutorial::Tetris::Request::CharactorMove->new($self->ROTATE_CC)
              if $key =~ 'space';
            $event_to_process = SDL::Tutorial::Tetris::Request::CharactorMove->new($self->DIRECTION_DOWN)
              if $key =~ 'down';
            $event_to_process = SDL::Tutorial::Tetris::Request::CharactorMove->new($self->DIRECTION_LEFT)
              if $key =~ 'left';
            $event_to_process = SDL::Tutorial::Tetris::Request::CharactorMove->new($self->DIRECTION_RIGHT)
              if $key =~ 'right';
        }
        if ($event_type == SDL_KEYUP) {
            $self->{key} = undef;
        }

        #lets send the new events to be process back the event manager
        $self->evt_manager->post($event_to_process)
          if defined $event_to_process;

    }

    #if we did not have a tick event then some other controller needs to do
    #something so game state is still beign process we cannot have new input
    #now
}

1;
