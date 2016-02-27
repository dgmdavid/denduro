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
import std.stdio, std.random, std.math;
import Globals, Sprites, Player;

enum road_start_line = 72;
enum road_end_line   = 175;
enum road_length     = road_end_line-road_start_line;
enum road_width      = 101;
enum road_max_curve  = 70;
enum disturb_size    = 13;
enum screen_center   = (SCREEN_WIDTH/2)+VSCREEN_X_PAD;

struct Road
{
	float center = screen_center;
	float noise = 0.0f;
	float curve = 0.0f;
	float disturb = road_start_line;
}
Road road;

//CalcRoadCurve
///line - from 0 to "road_length"
pragma( inline, true ):
float CalcRoadCurve( int line )	
{
	return road.center-road.curve+sin(cast(float)line/road_length*1.475f)*road.curve;
}

//RenderRoad
void RenderRoad()
{
	//TODO: clear the screen?
	g_screen[] = 0;

	road.center = screen_center-cast(int)(player.position/1.75f);

	//"run" the dirturb through the road
	road.disturb+=player.speed;
	if( road.disturb>road_end_line+disturb_size ) road.disturb = road_start_line;

	//trace the road
	float dist = 0;
	float step = (road_width/2.0f)/road_length;
	for( int r=road_start_line; r<road_end_line; ++r )
	{	
		//calculate the center of the road considering it's curve
		float center = road.noise+CalcRoadCurve(r-road_start_line);

		//fill the road's background
		//TODO: color variation according to "season" and "time of day"
		g_screen[VSCREEN_WIDTH*r+VSCREEN_X_PAD..(VSCREEN_WIDTH*r+VSCREEN_X_PAD+SCREEN_WIDTH)] = 255<<24 | 255<<16;
	
		//TODO: this needs more work
		float save_dist = dist;
		float diff = r-road.disturb;
		if( diff>=-disturb_size && diff<=disturb_size )
		{
			float tmp = ((r-road_start_line)/75.0f)*(-disturb_size+fabs(diff/1.0f));
			if( tmp<-3 ) tmp = -3;
			dist += tmp;
		}

		//plot the road's outline
		g_screen[cast(int)((VSCREEN_WIDTH*r)+center-dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		g_screen[cast(int)((VSCREEN_WIDTH*r)+center+dist)] = 255<<24 | 255<<16 | 255<<8 | 255;

		if( diff>=-disturb_size && diff<=disturb_size ) dist = save_dist;

		dist += step;
	}

	//TODO: temporary ugly stuff
	static int spr_count = 0, spr_num = 0;
	spr_count++;
	if( spr_count>=2 )
	{
		spr_count = 0;
		spr_num++;
		if( spr_num==2 ) spr_num = 0;
	}

	BlitSprite( player_sprite[spr_num], cast(int)(screen_center+player.position), cast(int)(road_end_line-player_sprite[0].height-player.speed), 0xFFFFFFFF );

	//apply "physics" to the player
	//TODO: those values need adjustment, of course
	float force = road.curve/(road_max_curve*4.5f); //<-- this must be adjusted depending on "player_max_speed"
	player.position += force*(player.speed/4.0f/*player_max_speed?*/);
}

//EOF