#ifndef UAV_H
#define UAV_H

#include <libavcodec/avcodec.h>


#define INBUF_SIZE 4096
#define AV_FRAME_DATA_SIZE 3
#define AV_FRAME_DATA_Y_CHANNEL 0
#define AV_FRAME_DATA_U_CHANNEL 1
#define AV_FRAME_DATA_V_CHANNEL 2
#define CODEC_ID CODEC_ID_H264
#define UAV_PIX_FMT PIX_FMT_YUV420P

/*
#define THROW_XS_ERROR(error_str) \
        ENTER;\
        SAVETMPS;\
        PUSHMARK(SP);\
        XPUSHs( sv_2mortal(newSVpv("UAV::Pilot::VideoException", 0)) );\
        XPUSHs( sv_2mortal(newSVpv("error", 0)) );\
        XPUSHs( sv_2mortal(newSVpv(error_str, 0)) );\
        PUTBACK;\
        call_method( "throw", G_DISCARD );\
        FREETMPS;\
        LEAVE;
*/
#define THROW_XS_ERROR(error_str)\
    warn( "Error: %s", error_str );\
    exit(1);


#endif /* ifndef UAV_H */
