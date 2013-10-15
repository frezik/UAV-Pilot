package UAV::Pilot::NavCollector::AckEvents;
use v5.14;
use Moose;
use namespace::autoclean;

with 'UAV::Pilot::NavCollector';
with 'UAV::Pilot::Logger';


has 'easy_event' => (
    is  => 'ro',
    isa => 'UAV::Pilot::EasyEvent',
);
has '_last_ack_status' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);


sub got_new_nav_packet
{
    my ($self, $packet) = @_;
    my $new_ack = $packet->state_control_received;
    my $last_ack = $self->_last_ack_status;
    my $event = $self->easy_event;
    my $logger = $self->_logger;

    $logger->info( "Got nav ACK of $new_ack, old ack is $last_ack" );
    my $send_event = $new_ack
        ? 'nav_ack_on'
        : 'nav_ack_off';
    $logger->info( "Sending $send_event event" );
    $event->send_event( $send_event );

    if( $new_ack != $last_ack ) {
        $logger->info( "Sending nav_ack_toggle event" );
        $event->send_event( 'nav_ack_toggle', $new_ack );
        $self->_last_ack_status( $new_ack );
    }

    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::NavCollector::AckEvents

=head1 SYNOPSIS

   my $easy_event = UAV::Pilot::EasyEvent->new;
   my $ack = UAV::Pilot::NavCollector::AckEvents->new({
       easy_event => $easy_event,
   });

   $easy_event->add_event( 'nav_ack_on' => sub {
       say "ACK control bit is on";
   });
   $easy_event->add_event( 'nav_ack_off' => sub {
       say "ACK control bit is off";
   });
   $easy_event->add_event( 'nav_ack_toggle' => sub {
       say "ACK control bit toggled";
   });

=head1 DESCRIPTION

Does the C<UAV::Pilot::NavCollector> role to fire off events into 
C<UAV::Pilot::EasyEvent> based on the ACK control bit.  Each nav packet with 
the bit on will fire a C<nav_ack_on> event, and C<nav_ack_off> when off.  If 
the state toggles, C<nav_ack_toggle> is sent.

=cut
