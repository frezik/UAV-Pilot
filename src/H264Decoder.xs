#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <libavcodec/avcodec.h>


MODULE = UAV::Pilot::Video::H264Decoder    PACKAGE = UAV::Pilot::Video::H264Decoder 

int
process_h264_frame( self, frame, width, height, encoded_width, encoded_height )
        SV * self
        SV * frame
        int width
        int height
        int encoded_width
        int encoded_height
    CODE:
        printf("not ok - H264Decoder xs not fully implemented");
        RETVAL = 1;
    OUTPUT:
        RETVAL
