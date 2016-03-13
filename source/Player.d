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
import Globals, Sprites, Audio;

//TODO: should this be moved to globals?
enum PLAYER_MAX_SPEED = 5.0f;
enum PLAYER_MIN_SPEED = 1.0f;
enum PLAYER_MAX_POSITION = 30;

struct Player
{
	float kilometers = 0;
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
			float velocity = (player.speed*1.25f)/PLAYER_MAX_SPEED;
			if( player.turn_left  ) Decrease( player.position, velocity, -PLAYER_MAX_POSITION );
			if( player.turn_right ) Increase( player.position, velocity, PLAYER_MAX_POSITION );
		}
		//TODO: adjust at what rate the speed increases and the maximum value
		//TODO: I think the speed must be accelerated at different rates, up until 2 speed up more quickly, up to 4 a slower etc... (it will make the engine sound closer to the original)
		if( player.accelerate ) 
		{
			if( player.speed<PLAYER_MIN_SPEED ) player.speed = PLAYER_MIN_SPEED;
			     if( player.speed<2.4f  ) Increase( player.speed, 0.010f, PLAYER_MAX_SPEED );
			else if( player.speed>=2.4f ) Increase( player.speed, 0.006f, PLAYER_MAX_SPEED );
		}
		if( player.deaccelerate && player.speed>PLAYER_MIN_SPEED ) Decrease( player.speed, 0.04f, PLAYER_MIN_SPEED );
	} else

	//TODO: needless to say those values need to be fine-adjusted
	if( player.collision==EPCol.LEFT || player.collision==EPCol.RIGHT )
	{
		if( player.collision==EPCol.LEFT  ) player.position += 0.3f;
		if( player.collision==EPCol.RIGHT ) player.position -= 0.3f;
		Decrease( player.pos, 0.3f, 0 );
		Decrease( player.speed, 0.04f, PLAYER_MIN_SPEED );
		if( player.pos<=float.epsilon ) player.collision = EPCol.NONE;
	} else
	if( player.collision==EPCol.LEFT_CAR || player.collision==EPCol.RIGHT_CAR )
	{
		if( player.collision==EPCol.LEFT_CAR  ) player.position += 0.4f;
		if( player.collision==EPCol.RIGHT_CAR ) player.position -= 0.4f;
		Decrease( player.pos, 0.3f, 0 );
		Decrease( player.speed, 0.02f, PLAYER_MIN_SPEED );
	}

	if( player.collision==EPCol.NONE )
	{
		if( player.speed<=float.epsilon )
			SOUND_ENGINE = 0;
		else {
			//simulate multiple "gears"
			SOUND_ENGINE = cast(int)(27-((player.speed%2.0f)*6));
		}
		SOUND_ROAD_COLLISION = false;
	} else {
		SOUND_ROAD_COLLISION = true;
	}
}

//PlayerCollide
void PlayerCollide( EPCol type )
{
	player.collision = type;
	if( player.collision==EPCol.LEFT || player.collision==EPCol.RIGHT ) player.pos = 10;
}

//EOF