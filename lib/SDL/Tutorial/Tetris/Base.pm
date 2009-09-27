package SDL::Tutorial::Tetris::Base;

use strict;
use warnings;

use SDL::Tutorial::Tetris::EventManager;

# all the classes inherit these basic accessors:
use Class::XSAccessor accessors => {
    EDEBUG   => 'EDEBUG',
    GDEBUG   => 'GDEBUG',
    KEYDEBUG => 'KEYDEBUG',
    FPS      => 'FPS',
};

our $VERSION = '0.01';

# ...and those constants:
sub ROTATE_C        { 0 }    # rotates blocks ClockWise
sub ROTATE_CC       { 1 }    # rotates blocks CounterClockWise
sub DIRECTION_DOWN  { 2 }    # Drops the block
sub DIRECTION_LEFT  { 3 }    # move left
sub DIRECTION_RIGHT { 4 }    # move right

# all the classes will also inherit the evt_manager,
# so we won't have to pass it around everywhere
my $evt_manager = SDL::Tutorial::Tetris::EventManager->new();
sub evt_manager { $evt_manager }

sub new {
    my ($class, %params) = @_;

    my $self = bless ({%params}, ref ($class) || $class);

    return $self;
}

1;

__END__

=head1 NAME

SDL::Tutorial::Tetris::Base - base class

=head1 DESCRIPTION

This is the base class for most of the game objects. We put in this class
all the information that we want to be visible across the game:

=head2 Constants

=head2 Debug properties

=head2 Event Manager

=head1 SEE ALSO

L<SDL::Tutorial::Tetris::EventManager>

=head1 AUTHOR

    Kartik Thakore
    CPAN ID: KTHAKORE
    kthakore@CPAN.org
    http://yapgh.blogspot.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).
