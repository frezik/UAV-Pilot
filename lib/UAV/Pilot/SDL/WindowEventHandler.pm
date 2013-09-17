package UAV::Pilot::SDL::WindowEventHandler;
use v5.14;
use Moose::Role;

has 'width' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '_set_width',
);
has 'height' => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '_set_height',
);

requires 'draw';

sub add_to_window
{
    my ($self, $window, $location) = @_;
    $location //= $window->BOTTOM;
    $window->add_child( $self, $location );
    return 1;
}


1;
__END__


=head1 NAME

  UAV::Pilot::SDL::WindowEventHandler

=head1 DESCRIPTION

Role for objects that will be passed into C<UAV::Pilot::SDL::Window> as 
children.

The method C<draw> will be called on the object to draw itself.  It will be 
passed the C<UAV::Pilot::SDL::Window> object.  This is the only method that 
is required for the class doing the role to implement.

The C<add_to_window> method should be called on the object after construction 
and passed an C<UAV::Pilot::SDL::Window> object.  A second optional parameter 
is the float value (default bottom).  The handler will add itself as a child to 
this window.  The default code for the method in the role will do this for you, 
adding the child at the bottom.

Also has C<width> and C<height> attributes.  They are read-only attributes, but 
can be set with the C<_set_width> and C<_set_height> methods.  These methods 
should be considered private to the class.

=cut
