package SDL::Tutorial::Tetris;

use strict;
use warnings;

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

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

sub new {
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

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
