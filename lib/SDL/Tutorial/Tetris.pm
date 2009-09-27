package SDL::Tutorial::Tetris;

use SDL::Tutorial::Tetris::EventManager;
use SDL::Tutorial::Tetris::View;
use SDL::Tutorial::Tetris::Controller::Keyboard;
use SDL::Tutorial::Tetris::Controller::CPUSpinner;
use SDL::Tutorial::Tetris::Controller::Game;

sub play {
    my ($class, $EDEBUG, $KEYDEBUG, $GDEBUG, $FPS) = @_;

    my $keybd    = SDL::Tutorial::Tetris::Controller::Keyboard->new();
    my $spinner  = SDL::Tutorial::Tetris::Controller::CPUSpinner->new();
    my $gameView = SDL::Tutorial::Tetris::View::Game->new();

    my $game     = SDL::Tutorial::Tetris::Controller::Game->new(
        EDEBUG      => $EDEBUG,
        GDEBUG      => $GDEBUG,
        KEYDEBUG    => $KEYDEBUG,
        FPS         => $FPS,
    );

    $spinner->run;
}

1;

__END__
