/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Player;
import Globals, Sprites;

//TODO: should this be moved to globals?
enum PLAYER_MAX_SPEED = 5.0f;
enum PLAYER_MAX_POSITION = 30;

struct Player
{
	float position = 0, 
		  speed = 0;

	EPCol collision;
	float pos;

	bool turn_left = false,
		 turn_right = false, 
		 accelerate = false,
		 deaccelerate = false;
}
Player player;

enum EPCol
{
	NONE, LEFT, RIGHT, LEFT_CAR, RIGHT_CAR
}

//UpdatePlayer
void UpdatePlayer()
{
	if( player.collision==EPCol.NONE )
	{
		if( player.speed>float.epsilon )
		{
			if( player.turn_left  ) Decrease( player.position, 1, -PLAYER_MAX_POSITION );
			if( player.turn_right ) Increase( player.position, 1, PLAYER_MAX_POSITION );
		}
		//TODO: adjust at what rate the speed increases and the maximum value
		if( player.accelerate   ) Increase( player.speed, 0.015f, PLAYER_MAX_SPEED );
		if( player.deaccelerate ) Decrease( player.speed, 0.04f, 0.1f );
	} else

	//TODO: needless to say those values need to be fine-adjusted
	if( player.collision==EPCol.LEFT || player.collision==EPCol.RIGHT )
	{
		if( player.collision==EPCol.LEFT  ) player.position += 0.3f;
		if( player.collision==EPCol.RIGHT ) player.position -= 0.3f;
		Decrease( player.pos, 0.3f, 0 );
		Decrease( player.speed, 0.04f, 0.5f );
		if( player.pos<=float.epsilon ) player.collision = EPCol.NONE;
	} else
	if( player.collision==EPCol.LEFT_CAR || player.collision==EPCol.RIGHT_CAR )
	{
		if( player.collision==EPCol.LEFT_CAR  ) player.position += 0.4f;
		if( player.collision==EPCol.RIGHT_CAR ) player.position -= 0.4f;
		Decrease( player.pos, 0.3f, 0 );
		Decrease( player.speed, 0.02f, 0.85f );
	}
}

//PlayerCollide
void PlayerCollide( EPCol type )
{
	player.collision = type;
	if( player.collision==EPCol.LEFT || player.collision==EPCol.RIGHT ) player.pos = 10;
}

//EOF