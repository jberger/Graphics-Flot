package Graphics::Flot;

use strict;
use warnings;

use JSON 'encode_json';
use Scalar::Util 'looks_like_number';
use Carp;

our $Validate = 1;

sub plot {
  my $datasets = @_ == 1 ? shift () : [ @_ ];

  if ($Validate) {
    for my $dataset (@$datasets) {
      my $data = eval { ref $dataset eq 'HASH' } ? $dataset->{data} : $dataset;
      _validate_data($data);
    }
  }

  return encode_json( $datasets );
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

