package UAV::Pilot::ARDrone::Driver::Mock;
use v5.14;
use Moose;
use namespace::autoclean;
use UAV::Pilot::ARDrone::NavPacket;

extends 'UAV::Pilot::ARDrone::Driver';


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
    $self->_init_nav_data;
    $self->_init_drone;
    return 1;
}


sub _send_multi_cmds
{
    my ($self) = @_;
    my @multi_cmds = @{ $self->_multi_cmds };
    $self->_set_last_cmd( join( '', @multi_cmds ) );
    $self->_add_saved_command( $_ ) for @multi_cmds;
    return 1;
}

sub _send_cmd
{
    my ($self, $cmd) = @_;

    if( $self->_is_multi_cmd_mode ) {
        $self->_add_multi_cmd( $cmd );
    }
    else {
        $self->_set_last_cmd( $cmd );
        $self->_add_saved_command( $cmd );
    }
    return 1;
}

sub read_nav_packet
{
    my ($self, @packet) = @_;
    my $packet = pack( 'H*', join('', @packet) );
    my $nav_packet = UAV::Pilot::ARDrone::NavPacket->new({
        packet => $packet,
    });
    $self->_set_last_nav_packet( $nav_packet );
    return 1;
}

sub _init_nav_data
{
    my ($self) = @_;

    $self->at_config(
        $self->ARDRONE_CONFIG_GENERAL_NAVDATA_DEMO,
        $self->TRUE,
    );

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

