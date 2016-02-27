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
import Sprites;

struct Player
{
	float position = 0, 
		  speed = 0;

	bool turn_left = false,
		 turn_right = false, 
		 accelerate = false;
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
	if( player.turn_left  ) player.position--;
	if( player.turn_right ) player.position++;
	if( player.accelerate ) player.speed+=0.025f;	//TODO: adjust at what rate the speed increases and the maximum value
}

//EOF