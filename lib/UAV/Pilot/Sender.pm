package UAV::Pilot::Sender;
use v5.14;
use Moose;
use namespace::autoclean;


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

  UAV::Pilot::Sender

=head1 DESCRIPTION

This is an abstract class for a low-level interface to a given UAV.  These are primarily for 
those developing the C<UAV::Pilot> API against a new UAV.  Programmers seeking to use an 
existing UAV should look at L<UAV::Pilot::Sender>.
