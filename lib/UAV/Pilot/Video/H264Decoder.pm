package UAV::Pilot::Video::H264Decoder;
use v5.14;
use Moose;
use namespace::autoclean;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::Video::H264Decoder;


with 'UAV::Pilot::Video::H264Handler';

has 'display' => (
    is  => 'ro',
    #isa => 'UAV::Pilot::Video::RawHandler',
    isa => 'Item',
);


# Helper sub to simplifiy throwing exceptions in the xs code
sub _throw_error
{
    my ($class, $error_str) = @_;
    UAV::Pilot::VideoException->throw(
        error => $error_str,
    );
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

    UAV::Pilot::Video::H264Decoder

=head1 SYNOPSIS

    # $display is some object that does the role UAV::Pilot::Video::RawHandler, like 
    # UAV::Pilot::SDL::Video
    my $display = ...;

    my $decoder = UAV::Pilot::Video::H264Decoder->new({
        display => $display,
    });

=head1 DESCRIPTION

Decodes a stream of h.264 frames using ffmpeg.  Does the C<UAV::Pilot::Video::H264Handler> 
role.

=head1 LICENSE

Most of UAV::Pilot is under the BSD license, but because C<UAV::Pilot::Video::H264Decoder>
directly includes code from the ffmpeg library, it's licensed under the Lesser GPL:


Copyright (C) 2013  Timm Murray

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

=cut
