package SDL::Tutorial::Tetris;

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

# ...and those constants:
sub ROTATE_C        { 0 }    # rotates blocks ClockWise
sub ROTATE_CC       { 1 }    # rotates blocks CounterClockWise
sub DIRECTION_DOWN  { 2 }    # Drops the block
sub DIRECTION_LEFT  { 3 }    # move left
sub DIRECTION_RIGHT { 4 }    # move right

# all the classes will also inherit the evt_manager,
# so we won't have to pass it around everywhere

sub new {
    my ($class, %params) = @_;

    my $self = bless ({%params}, ref ($class) || $class);

    return $self;
}

my $evt_manager = SDL::Tutorial::Tetris::EventManager->new();
sub evt_manager { $evt_manager }

1;

__END__

=head1 NAME

SDL::Tutorial::Tetris - Tutorial using SDL and MVC design to make Tetris

=head1 SYNOPSIS

  use SDL::Tutorial::Tetris;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



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
