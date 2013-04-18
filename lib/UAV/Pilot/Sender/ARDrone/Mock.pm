package UAV::Pilot::Sender::ARDrone::Mock;
use v5.14;
use Moose;
use namespace::autoclean;

extends 'UAV::Pilot::Sender::ARDrone';


has 'last_cmd' => (
    is     => 'ro',
    isa    => 'Str',
    writer => '_set_last_cmd',
);
has '_saved_commands' => (
    traits  => ['Array'],
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        '_add_saved_command' => 'push',
    },
);


sub connect
{
    my ($self) = @_;
    return 1;
}


sub _send_cmd
{
    my ($self, $cmd) = @_;
    $self->_set_last_cmd( $cmd );
    $self->_add_saved_command( $cmd );
    return 1;
}

sub saved_commands
{
    my ($self) = @_;
    my @cmds = @{ $self->_saved_commands };
    $self->_saved_commands( [] );
    return @cmds;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

