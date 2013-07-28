#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <libavcodec/avcodec.h>

#define INBUF_SIZE 4096
#define AV_FRAME_DATA_SIZE 3
#define AV_FRAME_DATA_Y_CHANNEL 0
#define AV_FRAME_DATA_U_CHANNEL 1
#define AV_FRAME_DATA_V_CHANNEL 2
#define CODEC_ID CODEC_ID_H264

#define MY_CXT_KEY "UAV::Pilot::Video::H264Decoder::_guts" XS_VERSION


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

/* Global Data
 * This won't work if we have many decoder objects open, which means this class will be 
 * effectively a singleton.  Need to store these C structures on a per-object basis.
 */
typedef struct {
    AVCodec *codec;
    AVCodecContext *c;
    int frame_count;
    AVFrame *frame;
    uint8_t inbuf[INBUF_SIZE + FF_INPUT_BUFFER_PADDING_SIZE];
    AVPacket avpkt;
} my_cxt_t;

START_MY_CXT


MODULE = UAV::Pilot::Video::H264Decoder    PACKAGE = UAV::Pilot::Video::H264Decoder 

BOOT:
{
    MY_CXT_INIT;
    av_init_packet(&MY_CXT.avpkt);
    /* set end of buffer to 0 (this ensures that no overreading happens for damaged mpeg streams) */
    memset(MY_CXT.inbuf + INBUF_SIZE, 0, FF_INPUT_BUFFER_PADDING_SIZE);

    /* find the h264 video decoder */
    avcodec_register_all();
    MY_CXT.codec = avcodec_find_decoder( CODEC_ID );
    if (!MY_CXT.codec) {
        THROW_XS_ERROR( "Codec H264 not found" );
    }

    MY_CXT.c = avcodec_alloc_context3(MY_CXT.codec);
    if (!MY_CXT.c) {
        THROW_XS_ERROR( "Could not allocate video codec context" );
    }
    if(MY_CXT.codec->capabilities&CODEC_CAP_TRUNCATED) {
        MY_CXT.c->flags|= CODEC_FLAG_TRUNCATED; /* we do not send complete frames */
    }
    MY_CXT.c->pix_fmt = PIX_FMT_YUV420P;
    /* For some codecs, such as msmpeg4 and mpeg4, width and height
    * MUST be initialized there because this information is not
    * available in the bitstream. */
    /* open it */
    if (avcodec_open2(MY_CXT.c, MY_CXT.codec, NULL) < 0) {
        THROW_XS_ERROR( "Could not open codec" );
    }

    MY_CXT.frame = avcodec_alloc_frame();
    if (!MY_CXT.frame) {
        THROW_XS_ERROR( "Could not allocate frame" );
    }
    MY_CXT.frame_count = 0;
}

CLEANUP:
{
    av_free( frame );
    av_free( codec );
    av_free( c );
    av_free( avpkt );
}

AVFrame*
get_last_frame_c_obj( self )
        SV* self
    PREINIT:
        dMY_CXT;
    CODE:
        RETVAL = MY_CXT.frame;
    OUTPUT:
        RETVAL

SV*
get_last_frame_pixels_arrayref( self )
        SV* self
    PREINIT:
        dMY_CXT;
    CODE:
        int i;
        SV* tmp_sv;
        AV* decoded_frame_y_av = newAV();
        AV* decoded_frame_u_av = newAV();
        AV* decoded_frame_v_av = newAV();
        AV* decoded_frame_av = newAV();

        // TODO Sloppy repetition.  How best to fix this?  Macro, maybe?
        for( i = 0; i < MY_CXT.frame->linesize[AV_FRAME_DATA_Y_CHANNEL]; i++ ) {
            tmp_sv = newSViv( (IV) MY_CXT.frame->data[AV_FRAME_DATA_Y_CHANNEL][i] );
            av_push( decoded_frame_y_av, tmp_sv );
        }
        for( i = 0; i < MY_CXT.frame->linesize[AV_FRAME_DATA_U_CHANNEL]; i++ ) {
            tmp_sv = newSViv( (IV) MY_CXT.frame->data[AV_FRAME_DATA_U_CHANNEL][i] );
            av_push( decoded_frame_u_av, tmp_sv );
        }
        for( i = 0; i < MY_CXT.frame->linesize[AV_FRAME_DATA_V_CHANNEL]; i++ ) {
            tmp_sv = newSViv( (IV) MY_CXT.frame->data[AV_FRAME_DATA_V_CHANNEL][i] );
            av_push( decoded_frame_v_av, tmp_sv );
        }

        av_push( decoded_frame_av, newRV_inc((SV *) decoded_frame_y_av) );
        av_push( decoded_frame_av, newRV_inc((SV *) decoded_frame_u_av) );
        av_push( decoded_frame_av, newRV_inc((SV *) decoded_frame_v_av) );
        RETVAL = newRV_inc((SV *) decoded_frame_av);
    OUTPUT:
        RETVAL


int
process_h264_frame( self, incoming_frame, width, height, encoded_width, encoded_height )
        SV * self
        SV * incoming_frame
        int width
        int height
        int encoded_width
        int encoded_height
    PREINIT:
        dMY_CXT;
    CODE:
        int len, got_frame, i;
        SV* display;
        SV** tmp_sv_star;
        AV* incoming_frame_av = (AV*) SvRV(incoming_frame);
        I32 incoming_frame_length = av_len( incoming_frame_av ) + 1;
        AVPacket avpkt = MY_CXT.avpkt;

        uint8_t *pkt_data = malloc( incoming_frame_length * sizeof(uint8_t) );
        if( NULL == pkt_data ) {
            THROW_XS_ERROR( "Could not allocate memory for packet data" );
        }

        for( i = 0; i < incoming_frame_length; i++ ) {
            tmp_sv_star = av_fetch( incoming_frame_av, i, 0 );
            pkt_data[i] = (uint8_t) SvIV( *tmp_sv_star );
        }

        avpkt.data             = pkt_data;
        avpkt.size             = incoming_frame_length;
        MY_CXT.c->width        = width;
        MY_CXT.c->height       = height;
        MY_CXT.c->coded_width  = encoded_width;
        MY_CXT.c->coded_height = encoded_height;

        len = avcodec_decode_video2( MY_CXT.c, MY_CXT.frame, &got_frame, &avpkt );
        free( pkt_data );
        pkt_data = NULL;
        if( len < 0 ) {
            THROW_XS_ERROR( "Error decoding frame" );
        }

        MY_CXT.frame_count++;

        /* Call $self->display() */
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        XPUSHs( self );
        PUTBACK;
        call_method( "display", G_SCALAR );

        SPAGAIN;
        display = POPs;
        //FREETMPS;
        //LEAVE;

        /* Call $display->process_raw_frame() */
        //ENTER;
        //SAVETMPS;

        PUSHMARK(SP);
        XPUSHs( display );
        XPUSHs( sv_2mortal(newSViv(MY_CXT.frame->width)) );
        XPUSHs( sv_2mortal(newSViv(MY_CXT.frame->height)) );
        XPUSHs( self );
        PUTBACK;
        call_method( "process_raw_frame", G_DISCARD );

        FREETMPS;
        LEAVE;

        /* Yay, everything worked! */
        RETVAL = 1;
    OUTPUT:
        RETVAL


