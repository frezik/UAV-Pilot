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


package UAV::Pilot::NavPacketException::BadHeader;
use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::Exception';

has 'got_header' => (
    is  => 'ro',
    isa => 'Int',
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Exceptions

=head1 DESCRIPTION

Exceptions that could be thrown by C<UAV::Pilot> modules.  All inherit from 
C<UAV::Pilot::Exception>, which does the role C<Throwable>.

=head1 EXCEPTIONS

=head2 UAV::Pilot::NumberOutOfRangeException

=head2 UAV::Pilot::IOException

=head2 UAV::Pilot::NavPacketException::BadHeader

=cut
