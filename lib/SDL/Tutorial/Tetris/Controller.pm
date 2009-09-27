package SDL::Tutorial::Tetris::Controller;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris::Base';

sub new {
    my ($class, %params) = (@_);

    my $self  = $class->SUPER::new(%params);

    # all controllers must register a listener
    $self->evt_manager->reg_listener($self);

    $self->init() if $self->can('init');

    return $self;
}

1;

__END__

=head1 NAME

SDL::Tutorial::Tetris::Controller - base class for controllers

=head1 DESCRIPTION

This is the base class for controllers, so you don't have to
repeat yourself.

=head2 new

It implements a constructor which will 1) register a listener
for your new controller, so it can receive events; and 2) call
the init method.
