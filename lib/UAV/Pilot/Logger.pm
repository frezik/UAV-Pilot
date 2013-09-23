package UAV::Pilot::Logger;
use v5.14;
use Moose::Role;
use UAV::Pilot;
use Log::Log4perl;

has '_logger' => (
    is      => 'ro',
    isa     => 'Log::Log4perl::Logger',
    default => sub {
        my ($self) = @_;
        UAV::Pilot->init_log;
        return Log::Log4perl->get_logger( $self->_logger_name );
    },
);


sub _logger_name
{
    my ($self) = @_;
    return ref $self;
}


1;
__END__


=head1 NAME

  UAV::Pilot::Logger

=head1 DESCRIPTION

A Moose role for C<UAV::Pilot> classes that want to log things.

Provides the attribute C<_logger>, which returns a C<Log::Log4perl> logger for 
your object.

Also provides a method C<_logger_name> for fetching the logger name.  This will 
be your class's name by default.  Override as you see fit.

=cut
