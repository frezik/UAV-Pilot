#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "uav.h"

#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <SDL/SDL.h>


MODULE = UAV::Pilot::SDL::Video    PACKAGE = UAV::Pilot::SDL::Video


void
_draw_last_video_frame( self, overlay, dstrect, frame_sv)
        SV* self
        SDL_Overlay* overlay
        SDL_Rect* dstrect
        SV* frame_sv
    PPCODE:
        AVFrame* frame = (AVFrame*) SvIV( frame_sv );
        AVPicture pict;
        struct SwsContext * sws_context = sws_getContext(
            dstrect->w,
            dstrect->h,
            UAV_PIX_FMT,
            dstrect->w,
            dstrect->h,
            UAV_PIX_FMT,
            SWS_FAST_BILINEAR,
            NULL,
            NULL,
            NULL
        );

        if( sws_context == NULL ) {
            warn( "Could not get SWS context\n" );
            exit( 1 );
        }


        SDL_LockYUVOverlay( overlay );

        // Data comes from YUV420P source; U and V arrays swapped
        pict.data[0] = overlay->pixels[0];
        pict.data[1] = overlay->pixels[2];
        pict.data[2] = overlay->pixels[1];
        pict.linesize[0] = overlay->pitches[0];
        pict.linesize[1] = overlay->pitches[2];
        pict.linesize[2] = overlay->pitches[1];

        sws_scale( sws_context, (const uint8_t * const *) frame->data,
            frame->linesize, 0, dstrect->h, pict.data, pict.linesize );

        SDL_UnlockYUVOverlay( overlay );
        SDL_DisplayYUVOverlay( overlay, dstrect );

        sws_freeContext( sws_context );
