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
import std.stdio, core.stdc.string, std.random, std.math;
import Globals;

//lines 72 to 175
enum screen_center = (SCREEN_WIDTH/2)+VSCREEN_X_PAD;
int curve = 0;
float disturb = 72;

void RenderRoad()
{
	float dist = 0;

	g_screen[] = 0;

	int center = screen_center-cast(int)(player.position/1.75f);

	disturb+=player.speed;

	if( disturb>190 ) disturb = 72;

	for( int r=72; r<175; ++r )
	{	
		g_screen[VSCREEN_WIDTH*r+VSCREEN_X_PAD..(VSCREEN_WIDTH*r+VSCREEN_X_PAD+SCREEN_WIDTH)] = 255<<24 | 255<<16;
	
		float save_dist = dist;
		float diff = r-disturb;
		if( diff>=-13 && diff<=13 )
		{
			float tmp = ((r-72)/75.0f)*(-13.0f+fabs(diff/1.0f));
			//tmp /=1.3f;
			if( tmp<-4 ) tmp = -4;
			dist += tmp;
		}

		g_screen[cast(int)((VSCREEN_WIDTH*r)+center-dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		g_screen[cast(int)((VSCREEN_WIDTH*r)+center+dist)] = 255<<24 | 255<<16 | 255<<8 | 255;

		if( diff>=-13 && diff<=13 ) dist = save_dist;
		dist+=0.5f;
	}

}

//EOF