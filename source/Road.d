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

//TODO: should all this be moved to globals?
enum road_start_line = 72;
enum road_end_line   = 175;
enum road_length     = road_end_line-road_start_line;
enum road_width      = 101;
enum road_max_curve  = 176;
enum disturb_size    = 13;
enum screen_center   = (SCREEN_WIDTH/2)+VSCREEN_X_PAD;

struct Road
{
	float center = screen_center;
	float noise = 0.0f;
	float curve = 0.0f;
	float disturb = 0;
}
Road road;

//CalcRoadCurve
///line - from 0 to "road_length"
pragma( inline, true )
float CalcRoadCurve( int line )	
{
	//max curve 176! 176
	return road.center-road.curve+sin(0.8f+cast(float)line/road_length*0.85f)*road.curve;
	//TODO: the road curvature is now _almost_ exactly equal to the original game :) good enough for me
}

//RenderRoad
void RenderRoad()
{
	//TODO: do I really need to clear the screen?
	//g_screen[] = 0;

	road.center = screen_center-cast(int)(player.position/1.75f);

	//"run" the dirturb through the road
	road.disturb += player.speed;
	if( road.disturb>road_end_line+disturb_size ) road.disturb = 0;

	int player_line = cast(int)(road_length-player_sprite[0].height-(player.speed*2.0f));
	int player_center = cast(int)(screen_center+player.position);
	int left_road, right_road;

	//do not apply noise to the road in case the player is not moving
	if( player.speed<=float.epsilon ) road.noise = 0;

	//trace the road
	float dist = 0;
	float step = (road_width/2.0f)/road_length;
	for( int r=0; r<road_length; ++r )
	{	
		//calculate the center of the road considering its curve
		float center = road.noise+CalcRoadCurve(r);

		//fill the road's background
		//TODO: color variation according to "season" and "time of day"
		g_screen[VSCREEN_WIDTH*(r+road_start_line)+VSCREEN_X_PAD..(VSCREEN_WIDTH*(r+road_start_line)+VSCREEN_X_PAD+SCREEN_WIDTH)] = 255<<24 | 255<<16;
	
		//TODO: this needs more work
		float save_dist = dist;
		float diff = r-road.disturb;
		if( diff>=-disturb_size && diff<=disturb_size )
		{
			float tmp = (r/75.0f)*(-disturb_size+fabs(diff/1.0f));
			if( tmp<-3 ) tmp = -3;
			dist += tmp;
		}

		//plot the road's outline
		g_screen[cast(int)((VSCREEN_WIDTH*(r+road_start_line))+center-dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		g_screen[cast(int)((VSCREEN_WIDTH*(r+road_start_line))+center+dist)] = 255<<24 | 255<<16 | 255<<8 | 255;

		//save the road's boundaries at the player's line of collision
		//you could calculate this outside of the loop, too, but let's do this for now
		if( r==player_line )
		{
			left_road = cast(int)(center-dist);
			right_road = cast(int)(center+dist);
		}

		if( diff>=-disturb_size && diff<=disturb_size ) dist = save_dist;

		dist += step;
	}

	//TODO: temporary ugly stuff to "animate" the sprite
	static int spr_count = 0, spr_num = 0;
	if( player.speed>float.epsilon )
	{
		spr_count++;
		if( spr_count>=(player_max_speed/2.0f)-(player.speed/2.0f) )
		{
			spr_count = 0;
			spr_num++;
			if( spr_num==2 ) spr_num = 0;
		}
	}

	BlitSprite( player_sprite[spr_num], player_center-8, player_line+road_start_line, 0xFFFFFFFF );

	//apply "physics" to the player
	//TODO: those values _still_ need adjustment, of course, to match the original game
	float force = road.curve/(road_max_curve*player_max_speed);
	player.position += force*(player.speed/player_max_speed);

	//collide with the road
	//TODO: handle speed loss, and "enemy cars" overtaking the player in case of colision
	if( player.collision==EPCol.NONE )
	{
		if( player_center-7<=left_road )
		{
			//player.position += abs( player_center-8-left_road );
			PlayerCollide( EPCol.LEFT );
		}
		if( player_center+7>=right_road )
		{
			//player.position -= abs( player_center+7-right_road );
			PlayerCollide( EPCol.RIGHT );
		}
	}

	//TODO: obstacle cars
}

//EOF