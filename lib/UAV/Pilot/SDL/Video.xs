#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <libavcodec/avcodec.h>
#include <SDL/SDL.h>


MODULE = UAV::Pilot::SDL::Video    PACKAGE = UAV::Pilot::SDL::Video


void
_draw_video_frame( self, overlay, dstrect, frame )
        SV* self
        SDL_Overlay* overlay
        SDL_Rect* dstrect
        AVFrame* frame
    CODE:
        SDL_LockYUVOverlay( overlay );
        /* The order of array indexen is correct, according to:
         * http://dranger.com/ffmpeg/tutorial02.html
         */ 
        overlay->pixels[0] = frame->data[0];
        overlay->pixels[2] = frame->data[1];
        overlay->pixels[1] = frame->data[2];
        overlay->pitches[0] = frame->linesize[0];
        overlay->pitches[2] = frame->linesize[1];
        overlay->pitches[1] = frame->linesize[2];
        SDL_UnlockYUVOverlay( overlay );
        SDL_DisplayYUVOverlay( overlay, dstrect );
