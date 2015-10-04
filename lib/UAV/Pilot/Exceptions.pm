# Copyright (c) 2015  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
package UAV::Pilot::Exception;

use v5.14;
use Moose;
use namespace::autoclean;

with 'Throwable';

has 'error' => (
    is  => 'rw',
    isa => 'Str',
);

sub to_string
{
    my ($self) = @_;
    return $self->error;
}

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


package UAV::Pilot::FileNotFoundException;

use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::IOException';

has 'file' => (
    is  => 'ro',
    isa => 'Str',
);

no Moose;
__PACKAGE__->meta->make_immutable;


package UAV::Pilot::CommandNotFoundException;

use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::IOException';

has 'cmd' => (
    is  => 'ro',
    isa => 'Str',
);

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


package UAV::Pilot::VideoException;

use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::Exception';

no Moose;
__PACKAGE__->meta->make_immutable;


package UAV::Pilot::ArdupilotPacketException::BadHeader;

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


package UAV::Pilot::ArdupilotPacketException::BadChecksum;

use v5.14;
use Moose;
use namespace::autoclean;
extends 'UAV::Pilot::Exception';

has 'got_checksum1' => (
    is  => 'ro',
    isa => 'Int',
);
has 'got_checksum2' => (
    is  => 'ro',
    isa => 'Int',
);
has 'expected_checksum1' => (
    is  => 'ro',
    isa => 'Int',
);
has 'expected_checksum2' => (
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

Exceptions that could be thrown by L<UAV::Pilot> modules.  All inherit from 
L<UAV::Pilot::Exception>, which does the role L<Throwable>.

=head1 EXCEPTIONS

=head2 UAV::Pilot::NumberOutOfRangeException

=head2 UAV::Pilot::IOException

=head2 UAV::Pilot::CommandNotFoundException

=head2 UAV::Pilot::NavPacketException::BadHeader

=head2 UAV::Pilot::VideoException

=head2 UAV::Pilot::ArdupilotPacketException::BadHeader

=head2 UAV::Pilot::ArdupilotPacketException::BadChecksum

=cut
