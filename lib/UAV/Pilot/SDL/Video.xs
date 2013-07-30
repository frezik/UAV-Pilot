#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <libavcodec/avcodec.h>
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
        warn( "\tUpdating YUV overlay\n" );

        SDL_LockYUVOverlay( overlay );
        overlay->pixels[0] = frame->data[0];
        overlay->pixels[1] = frame->data[2];
        overlay->pixels[2] = frame->data[1];
        overlay->pitches[0] = frame->linesize[0];
        overlay->pitches[1] = frame->linesize[2];
        overlay->pitches[2] = frame->linesize[1];
        SDL_UnlockYUVOverlay( overlay );
        SDL_DisplayYUVOverlay( overlay, dstrect );
