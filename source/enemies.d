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
import std.random, std.math;
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

//NearCar
bool NearCar( byte side, float pos )
{
	for( int i=0; i<MAX_ENEMIES; ++i )
	{
		if( enemies_[i].active==false ) continue;
		if( abs( pos-enemies_[i].pos )<35 ) return true;
	}
	return false;
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

			//if the enemy is able to overtake the player, avoid crashing into the player
			//TODO: it's not quite working yet -- should I consider if the player is in "collision mode" and going to one side or another? probably
			if( player.speed<ENEMY_SPEED )
			{
				if( enemies_[i].pos>=ROAD_LENGTH && enemies_[i].pos<=ROAD_LENGTH+20 )	
				{
					//TODO: see if there isn't already another car near the new position
					//enemy is in the left side
					if( enemies_[i].side==0 )
					{
						if( player.position<=-8 ) enemies_[i].side = 2;
					}
					//enemy is in the center
					else if( enemies_[i].side==1 )
					{
						if( player.position>=-15 && player.position<=15 ) 
						{
							if( uniform(0,2)==0 )
								enemies_[i].side = 0;
							else
								enemies_[i].side = 2;
						}
					}
					//enemy is in the right side
					else if( enemies_[i].side==2 )
					{
						if( player.position>=8 ) enemies_[i].side = 0;
					}

				}
			}

			//if the enemy is too distant, "despawn" it
			if( enemies_[i].pos<-ENEMY_MAX_DISTANCE || enemies_[i].pos>ENEMY_MAX_DISTANCE ) enemies_[i].active = false;

		} else {
			//spawn new enemy 
			//TODO: consider some tipe of timming?
			if( player.speed>float.epsilon && uniform(1,50)<5 )
			{
				if( player.speed>=ENEMY_SPEED )
				{
					float position = uniform( -50, -10 );
					byte side = cast(byte)uniform( 0, 3 );
					if( !NearCar( side, position ) )
					{
						enemies_[i].pos = position;
						enemies_[i].side = side;
						enemies_[i].active = true;
						enemies_[i].color = 0xFFFFFF00;
					}
				} else {
					float position = uniform( ROAD_LENGTH+5, ROAD_LENGTH+50 );
					byte side = cast(byte)uniform( 0, 3 );
					if( !NearCar( side, position ) )
					{
						enemies_[i].pos = position;
						enemies_[i].side = side;
						enemies_[i].active = true;
						enemies_[i].color = 0xFF00FF00;
					}
				}
			}
		}
	}
}

//EOF