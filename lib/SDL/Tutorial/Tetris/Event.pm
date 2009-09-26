package SDL::Tutorial::Tetris::Event;

use strict;
use warnings;

use base 'SDL::Tutorial::Tetris';

use Class::XSAccessor accessors => {
    name => 'name',
};

1;
