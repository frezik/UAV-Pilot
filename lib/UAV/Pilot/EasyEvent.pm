package UAV::Pilot::EasyEvent;
use v5.14;
use Moose;
use namespace::autoclean;

use constant {
    UNITS_MILLISECOND => 0,
};

has 'condvar' => (
    is  => 'ro',
    isa => 'AnyEvent::CondVar',
);


sub after_time
{
    my ($self, $args) = @_;
    return $self;
}

sub run
{
    my ($self) = @_;
    return $self->condvar->recv;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

