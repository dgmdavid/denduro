/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Road;
import std.stdio, core.stdc.string, std.random;
import Globals;

//lines 72 to 175

int center = (SCREEN_WIDTH/2)+VSCREEN_X_PAD, curve = 0;

void RenderRoad()
{
	float dist = 0;

	g_screen[] = 0;

	for( int r=72; r<175; ++r )
	{	
		g_screen[VSCREEN_WIDTH*r+VSCREEN_X_PAD..(VSCREEN_WIDTH*r+VSCREEN_X_PAD+SCREEN_WIDTH)] = 255<<24 | 255<<16;
		
		g_screen[cast(int)((VSCREEN_WIDTH*r)+center-dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		g_screen[cast(int)((VSCREEN_WIDTH*r)+center+dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		dist+=0.5f;
	}

	/*
	for( int y=1; y<VSCREEN_HEIGHT-1; y++ )
		for( int x=VSCREEN_X_PAD+1; x<VSCREEN_WIDTH-VSCREEN_X_PAD-1; x++ )
			g_screen[VSCREEN_WIDTH*y+x] = 255<<24 | 255<<16;
	*/
}

//EOF