use strict;
use warnings;

use Test::More;
END{ done_testing() }

use Graphics::Flot;

ok( Graphics::Flot::_validate_data( [] ), 'Empty arrayref' );
ok( Graphics::Flot::_validate_data( [[0,1],[1,5],[2,7]] ), '2xN array' );
ok( Graphics::Flot::_validate_data( [[0,1],[1,5], undef, [2,7]] ), '2xN array with discontinuity' );

ok( ! eval { Graphics::Flot::_validate_data( [1, [1,2]] ) }, 'Uneven dimensions (bad)' );
ok( ! eval { Graphics::Flot::_validate_data( [[0,1,2],[1,5,5],[2,7,6]] ) } , '3xN array (bad)' );
