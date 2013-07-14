package UAV::Pilot::Video::Mock::RawHandler;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::Video::RawHandler';

has 'cb' => (
    is  => 'ro',
    isa => 'CodeRef',
);


sub process_raw_frame
{
    my ($self, @args) = @_;
    return $self->cb->( $self, @args );
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

