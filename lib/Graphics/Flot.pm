package Graphics::Flot;

use strict;
use warnings;

use Scalar::Util 'looks_like_number';
use Carp;

use base 'Exporter';
our @EXPORT = qw/plot/;

sub plot {
  my @datasets = @_;

  my @output_datasets;
  for my $dataset (@datasets) {
    # promote to hashref
    unless (eval { ref $dataset eq 'HASH' }) {
      $dataset = { data => $dataset };
    }

    # 1D piddle
    if (eval { $dataset->{data}->isa('PDL') }) {
      $dataset->{data} = [ $dataset->{data}->sequence, $dataset->{data} ];
    }

    # promote two piddles
    if ( eval { $dataset->{data}->[0]->isa('PDL') } and eval { $dataset->{data}->[1]->isa('PDL') } ) {
      my ($x, $y) = @{ $dataset->{data} };
      my $data = _unroll($x->cat($y)->xchg(0,1));
      $dataset->{data} = $data;
    }

    # promote a 1D list
    if ( not ref $dataset->{data}->[0]) {
      my $x = 0;
      my @pairs;
      for my $y (@{ $dataset->{data} }) {
        if ( ! defined $y ) {
          $x--;
          push @pairs, undef;
          next;
        }

        push @pairs, [$x++, $y];
      }
      $dataset->{data} = \@pairs;
    }

    _validate_data($dataset->{data});

    push @output_datasets, $dataset;
  }

  return +{ plot => \@output_datasets };
}

sub _unroll {
  my $pdl = shift;
  if ($pdl->ndims > 1) {
    return [ map { _unroll($_) } $pdl->dog ];
  } else {
    return [$pdl->list];
  }
}

sub _validate_data {
  my $data = shift;

  croak "Data must be an arrayref" unless eval { ref $data eq 'ARRAY' };
  _validate_point( $_ ) for @$data;

  return $data;
}

sub _validate_point {
  my ($point) = @_;
  return if ! defined $point;
  croak "Points must be pairs" unless @$point == 2;
  for my $num (@$point) {
    croak "Non numeric point ($num)" unless looks_like_number $num;
  }
}

1;

__END__

allow [2,4,6,undef, 10] => [[0,2],[1,4],[3,6], undef, [3,10]]
allow $pdl_y
allow [$pdl_x, $pdl_y]

