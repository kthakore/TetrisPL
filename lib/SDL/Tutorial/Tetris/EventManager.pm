package SDL::Tutorial::Tetris::EventManager;

#use base 'SDL::Tutorial::Tetris';

sub new {
    my ($class, %params) = @_;

    my $self = bless {%params}, $class;

    $self->{listeners} ||= {};
    $self->{evt_queue} ||= [];

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
        return delete $self->listeners->{$listener};
    }
    else {
        return;
    }
}

sub post {
    my $self = shift;
    my $event = shift if (@_) or die "Post needs a TickEvent";

    #print 'Event' . $event->name . "notified\n" if $self->EDEBUG;

    die "Post needs a Event as parameter"
      unless $event->isa('SDL::Tutorial::Tetris::Event');

#print 'Event' . $event->name ." called \n" if (!$event->isa('SDL::Tutorial::Tetris::Event::Tick') && $self->EFDEBUG);

    foreach my $listener (values %{$self->listeners}) {
        $listener->notify($event);
    }
}

1;
