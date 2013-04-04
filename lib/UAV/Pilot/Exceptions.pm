package UAV::Pilot::Exception;
use v5.14;
use Moose;
use namespace::autoclean;

with 'Throwable';

has 'error' => (
    is  => 'rw',
    isa => 'Str',
);

no Moose;
__PACKAGE__->meta->make_immutable;


package UAV::Pilot::NumberOutOfRangeException;
use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::Exception';

no Moose;
__PACKAGE__->meta->make_immutable;


package UAV::Pilot::IOException;
use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::Exception';

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

