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

	bool turn_left = false,
		 turn_right = false, 
		 accelerate = false,
		 deaccelerate = false;
}
Player player;

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

//UpdatePlayer
void UpdatePlayer()
{
	if( player.turn_left )
	{
		player.position--;
		Clamp( player.position, -player_max_position );
	}
	if( player.turn_right )
	{
		player.position++;
		Clamp( player.position, player_max_position );
	}

	if( player.accelerate ) 
	{
		//TODO: adjust at what rate the speed increases and the maximum value
		player.speed += 0.025f;	
		Clamp( player.speed, player_max_speed );
	}
	if( player.deaccelerate )
	{
		player.speed -= 0.05f;
		Clamp( player.speed, -0.0f );
	}
}

//EOF