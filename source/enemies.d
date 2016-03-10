/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Enemies;
import std.random;
import Globals, Road, Player;

enum MAX_ENEMIES = 12;
enum ENEMY_SPEED = 2.25f;
enum ENEMY_MAX_DISTANCE = ROAD_LENGTH*2;

struct Enemy
{
	float pos;	//translates to line on the road
	byte side;	//0 - left side, 1 - center, 2 - right side
	uint color;
	bool active;
}
Enemy[MAX_ENEMIES] enemies_;

//InitEnemies
void InitEnemies()
{
	foreach( enemy; enemies_ )
	{
		enemy.pos = 0;
		enemy.side = 0;
		enemy.active = false;
	}
}

//UpdatEnemies
void UpdateEnemies()
{
	if( player.speed<=float.epsilon ) return;

	for( int i=0; i<MAX_ENEMIES; ++i )
	{
		if( enemies_[i].active )
		{
			enemies_[i].pos -= ENEMY_SPEED;
			enemies_[i].pos += player.speed;

			if( enemies_[i].pos<-ENEMY_MAX_DISTANCE || enemies_[i].pos>ENEMY_MAX_DISTANCE ) enemies_[i].active = false;

		} else {
			//spawn new enemy 
			//TODO: consider some time of timming
			if( uniform(1,500)<5 )
			{
				enemies_[i].pos = uniform( -80, -10 );
				enemies_[i].side = cast(byte)uniform( 0, 3 );
				enemies_[i].active = true;
				enemies_[i].color = 0xFFFFFF00;
			}
		}
	}
}

//EOF