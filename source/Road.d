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
import Globals, Sprites, Player, Enemies, Audio;

//TODO: should all this be moved to globals?
enum ROAD_START_LINE = 73;
enum ROAD_END_LINE   = 176;
enum ROAD_LENGTH     = ROAD_END_LINE-ROAD_START_LINE;
enum ROAD_WIDTH      = 101;
enum ROAD_MAX_CURVE  = 176;
enum DISTURB_SIZE    = 13;

struct Road
{
	float center = SCREEN_CENTER;
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
	//max curve 176!
	return road.center-road.curve+sin(0.8f+cast(float)line/ROAD_LENGTH*0.85f)*road.curve;
	//TODO: the road curvature is now _almost_ exactly equal to the original game :) good enough for me
}

//RenderRoad
void RenderRoad()
{
	//TODO: do I really need to clear the screen?
	//g_screen[] = 0;

	road.center = SCREEN_CENTER-cast(int)(player.position/1.0f);

	//"run" the dirturb through the road
	road.disturb += player.speed;
	if( road.disturb>ROAD_END_LINE+DISTURB_SIZE ) road.disturb = 0;

	int player_line = cast(int)(ROAD_LENGTH-car_sprite[12].height-((player.speed<1)?0:(player.speed-0.75f)*3.0f));
	int player_center = cast(int)(SCREEN_CENTER+player.position);
	int left_road, right_road;

	//do not apply noise to the road in case the player is not moving
	if( player.speed<=float.epsilon ) road.noise = 0;

	//trace the road
	float dist = 0;
	float step = (ROAD_WIDTH/2.0f)/ROAD_LENGTH;
	for( int r=0; r<ROAD_LENGTH; ++r )
	{	
		//calculate the center of the road considering its curve
		float center = /*road.noise+*/CalcRoadCurve(r);

		//fill the road's background
		//TODO: color variation according to "season" and "time of day"
		g_screen[VSCREEN_WIDTH*(r+ROAD_START_LINE)+VSCREEN_X_PAD..(VSCREEN_WIDTH*(r+ROAD_START_LINE)+VSCREEN_X_PAD+SCREEN_WIDTH)] = 255<<24 | 255<<16;
	
		//TODO: this needs more work
		float save_dist = dist;
		float diff = r-road.disturb;
		if( diff>=-DISTURB_SIZE && diff<=DISTURB_SIZE )
		{
			float tmp = (r/75.0f)*(-DISTURB_SIZE+fabs(diff/1.0f));
			if( tmp<-3 ) tmp = -3;
			dist += tmp;
		}

		//plot the road's outline
		g_screen[cast(int)((VSCREEN_WIDTH*(r+ROAD_START_LINE))+center-dist)] = 255<<24 | 255<<16 | 255<<8 | 255;
		g_screen[cast(int)((VSCREEN_WIDTH*(r+ROAD_START_LINE))+center+dist)] = 255<<24 | 255<<16 | 255<<8 | 255;

		//save the road's boundaries at the player's line of collision
		//you could calculate this outside of the loop, too, but let's do this for now (mainly because of the disturbance)
		if( r==player_line )
		{
			left_road = cast(int)(center-dist);
			right_road = cast(int)(center+dist);
		}

		if( diff>=-DISTURB_SIZE && diff<=DISTURB_SIZE ) dist = save_dist;

		dist += step;
	}

	//TODO: temporary ugly stuff to "animate" the sprite
	static int spr_count = 0, spr_num = 0;
	if( player.speed>float.epsilon )
	{
		spr_count++;
		if( spr_count>=(PLAYER_MAX_SPEED/2.0f)-(player.speed/3.0f) )
		{
			spr_count = 0;
			spr_num++;
			if( spr_num==2 ) spr_num = 0;
		}
	}

	BlitSprite( car_sprite[12+spr_num], player_center-8, player_line+ROAD_START_LINE, 0xFFFFFFFF );

	//apply "physics" to the player
	//TODO: those values _still_ need adjustment, of course, to match the original game
	float force = road.curve/(ROAD_MAX_CURVE*PLAYER_MAX_SPEED);
	player.position += force*(player.speed/PLAYER_MAX_SPEED);

	//collide with the road
	//TODO: handle speed loss, and "enemy cars" overtaking the player in case of colision
	if( ENABLE_COLLISION )
	{
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
	
		//stop "car collision status" when player touches one of the sides of the road
		if( (player.collision==EPCol.RIGHT_CAR && player_center-6<=left_road ) ||
	   	    (player.collision==EPCol.LEFT_CAR  && player_center+6>=right_road) ) player.collision = EPCol.NONE;
	}

	//TODO: ANOTHER temporary ugly stuff to "animate" the sprite :P
	static int spr2_count = 0, spr2_num = 0;
	spr2_count++;
	if( spr2_count>=ENEMY_SPEED )
	{
		spr2_count = 0;
		spr2_num++;
		if( spr2_num==2 ) spr2_num = 0;
	}

	int enemy_line_distance = -999;

	//TODO: obstacle cars - render them elsewhere?
	for( int i=0; i<MAX_ENEMIES; ++i )
	{
		if( enemies[i].active==false ) continue;
		if( enemies[i].pos<float.epsilon || enemies[i].pos>ROAD_LENGTH ) continue;
	
		//TODO: do some type of mapping from "screen lines" to "car distance" to make the approaching of cars more "convincing"?
		int enemy_line = cast(int)enemies[i].pos-2;
		float enemy_dist = (enemy_line*step)/1.65f;
		float enemy_center = CalcRoadCurve(enemy_line+5);

		//check if the enemy is near the player for sound effect
		if( enemy_line+8>=player_line && enemy_line<=player_line+8 )
		{
			int eld = enemy_line-player_line;
			if( eld>enemy_line_distance ) enemy_line_distance = eld;
		}

		int enemy_size = 0;
		//TODO: find a way to calculate this?
		//road - from 0 to 103
		//TODO: this is currently wrong because it doesn't consider "where in the sprite the car begins to be drawn"
		if( enemy_line>=10 ) enemy_size = 1; //12
		if( enemy_line>=18 ) enemy_size = 2; //20
		if( enemy_line>=28 ) enemy_size = 3; //30
		if( enemy_line>=40 ) enemy_size = 4; //42
		if( enemy_line>=58 ) enemy_size = 5; //61
		if( enemy_line>=82 ) enemy_size = 6; //85

		if( enemies[i].side==0 ) enemy_center -= enemy_dist;
		else if( enemies[i].side==2 ) enemy_center += enemy_dist;

		BlitSprite( car_sprite[enemy_size*2+spr2_num], (cast(int)enemy_center)-8, enemy_line+ROAD_START_LINE, enemies[i].color );

		//collide with the player
		//TODO: needs some fine-tuning
		if( ENABLE_COLLISION && player.collision==EPCol.NONE )
		{
			if( enemy_line+10>=player_line && enemy_line<=player_line+4 )
			{
				if( enemy_center+13>=player_center && enemy_center<=player_center+13 )
				{
					//immediately matches player's speed with enemy's speed so it seems the car 'bounced'
					player.speed = ENEMY_SPEED;
					if( enemies[i].side==0 ) PlayerCollide( EPCol.LEFT_CAR );
					else if( enemies[i].side==1 )
					{
						if( enemy_center< player_center )
							PlayerCollide( EPCol.LEFT_CAR );
						else
							PlayerCollide( EPCol.RIGHT_CAR );
					} 
					else if( enemies[i].side==2 ) PlayerCollide( EPCol.RIGHT_CAR );
				}
			}
		}
	}

	g_screen[ (ROAD_END_LINE*VSCREEN_WIDTH)..((ROAD_END_LINE+10)*VSCREEN_WIDTH) ] = 0;

	//sound effect of the passing cars
	if( enemy_line_distance!=-999 ) SOUND_PASSING_CAR = 4;

	//TODO: move to another place
	//render the score
	//48x182 - 111x211
	for( int y=182; y<=211; y++ )
		g_screen[ (y*VSCREEN_WIDTH)+VSCREEN_X_PAD+48..(y*VSCREEN_WIDTH)+VSCREEN_X_PAD+112 ] = 0xFF912640;
	//56x185 - 95x193 / 96x185 - 103x193
	for( int y=185; y<=193; y++ )
	{
		g_screen[ (y*VSCREEN_WIDTH)+VSCREEN_X_PAD+56..(y*VSCREEN_WIDTH)+VSCREEN_X_PAD+96 ] = 0xFFB78927;
		g_screen[ (y*VSCREEN_WIDTH)+VSCREEN_X_PAD+96..(y*VSCREEN_WIDTH)+VSCREEN_X_PAD+104 ] = 0;
	}
	//56x200 - 63x208 / 72x200 - 103x208
	for( int y=200; y<=208; y++ )
	{
		g_screen[ (y*VSCREEN_WIDTH)+VSCREEN_X_PAD+56..(y*VSCREEN_WIDTH)+VSCREEN_X_PAD+64 ] = 0xFFB78927;
		g_screen[ (y*VSCREEN_WIDTH)+VSCREEN_X_PAD+72..(y*VSCREEN_WIDTH)+VSCREEN_X_PAD+104 ] = 0xFFB78927;
	}
}

//EOF