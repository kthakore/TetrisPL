package SDL::Tutorial::Tetris::Model::Pieces;

use strict;
use warnings;

use Carp;

my %pieces  = (
    SQUARE => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    LINE => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 1, 2, 1, 1],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 1, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [1, 1, 2, 1, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 1, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    L_SHAPE => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 0, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 1, 2, 1, 0],
            [0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 1, 1, 0, 0],
            [0, 0, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 1, 0],
            [0, 1, 2, 1, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    L_SHAPE_MIRROR => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 0, 0],
            [0, 1, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0],
            [0, 1, 2, 1, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 1, 2, 1, 0],
            [0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    N_SHAPE => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 1, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 1, 2, 0, 0],
            [0, 0, 1, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 1, 2, 0, 0],
            [0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 1, 1, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    N_SHAPE_MIRROR => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 1, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0],
            [0, 1, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 1, 0],
            [0, 1, 2, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ]
    ],
    T_SHAPE => [
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 2, 1, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 1, 2, 1, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 1, 2, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0]
        ],
        [
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 1, 2, 1, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
        ]
    ]
);

my %pieces_init = (
    SQUARE => [
        [-2, -3],
        [-2, -3],
        [-2, -3],
        [-2, -3]
    ],
    LINE => [
        [-2, -2],
        [-2, -3],
        [-2, -2],
        [-2, -3]
    ],
    L_SHAPE => [
        [-2, -3],
        [-2, -3],
        [-2, -3],
        [-2, -2]
    ],
    L_SHAPE_MIRROR => [
        [-2, -3],
        [-2, -2],
        [-2, -3],
        [-2, -3]
    ],
    N_SHAPE => [
        [-2, -3],
        [-2, -3],
        [-2, -3],
        [-2, -2]
    ],
    N_SHAPE_MIRROR => [
        [-2, -3],
        [-2, -3],
        [-2, -3],
        [-2, -2]
    ],
    T_SHAPE => [
        [-2, -3],
        [-2, -3],
        [-2, -3],
        [-2, -2]
    ]
);

sub piece {
    my ($self, $piece, $rotation) = @_;
    croak "Invalid piece '$piece'"       if !defined $pieces{$piece};
    croak "Invalid rotation '$rotation'" if !defined $pieces{$piece}[$rotation];
    return $pieces{$piece}[$rotation];
}

sub init_xy {
    my ($self, $piece, $rotation) = @_;
    croak "Invalid piece '$piece'"       if !defined $pieces{$piece};
    croak "Invalid rotation '$rotation'" if !defined $pieces{$piece}[$rotation];
    return @{ $pieces_init{$piece}[$rotation] };
}

sub block_color {
    my ($self, $piece, $rotation, $x, $y) = @_;
    croak "Invalid piece '$piece'"       if !defined $pieces{$piece};
    croak "Invalid rotation '$rotation'" if !defined $pieces{$piece}[$rotation];
    croak "Invalid coordinates ($x,$y)"  if !defined $pieces{$piece}[$rotation][$x][$y];
    return $pieces{$piece}[$rotation][$x][$y];
}

sub random {
    my @pieces = keys %pieces;

    my $piece    = $pieces[ rand(@pieces) ];
    my $rotation = int(rand(4));

    return ($piece,$rotation);
}

1;
