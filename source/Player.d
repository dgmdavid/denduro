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
enum player_max_speed = 5.0f;
enum player_max_position = 30;

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

//player sprites
Sprite[2] player_sprite = [ 
	{ 16, 11, [	0,0,1,1,0,0,1,1,1,1,0,0,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
				1,1,0,0,0,0,1,1,1,1,0,0,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,0,0,1,1,1,1,0,0,0,0,1,1	] },

	{ 16, 11, [	0,0,1,1,0,0,1,1,1,1,0,0,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,0,0,1,1,1,1,0,0,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,
				1,1,0,0,0,0,1,1,1,1,0,0,1,1,0,0	] }
	];

//PlayerUpdate
void PlayerUpdate()
{
	if( player.collision==EPCol.NONE )
	{
		if( player.turn_left  ) Decrease( player.position, 1, -player_max_position );
		if( player.turn_right ) Increase( player.position, 1, player_max_position );
		//TODO: adjust at what rate the speed increases and the maximum value
		if( player.accelerate   ) Increase( player.speed, 0.025f, player_max_speed );
		if( player.deaccelerate ) Decrease( player.speed, 0.05f, 0.1f );
	} else

	if( player.collision==EPCol.LEFT || player.collision==EPCol.RIGHT )
	{
		if( player.collision==EPCol.LEFT  ) player.position += 0.3f;
		if( player.collision==EPCol.RIGHT ) player.position -= 0.3f;
		Decrease( player.pos, 0.3f, 0 );
		Decrease( player.speed, 0.04f, 0.5f );
		if( player.pos<=float.epsilon ) player.collision = EPCol.NONE;
	}
}

//PlayerCollide
void PlayerCollide( EPCol type )
{
	final switch( type )
	{
		case EPCol.NONE:
			break;

		case EPCol.LEFT:
		case EPCol.RIGHT:
		{
			player.collision = type;
			player.pos = 10;
		} break;
		
		case EPCol.LEFT_CAR:
		case EPCol.RIGHT_CAR:
		{
		} break;
	}
}

//EOF