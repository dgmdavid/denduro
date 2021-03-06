﻿/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Sprites;
import Globals;

struct Sprite
{
	ubyte width, height;
	ubyte *data;
}

struct FullColorSprite
{
	ubyte width, height;
	uint *data;
}

//BlitSprite
void BlitSprite( ref Sprite sprite, int x, int y, uint color )
{
	//TODO: correct with PAD, verify player/enemies blitting
	//x += VSCREEN_X_PAD;

	if( x>VSCREEN_X_PAD+SCREEN_WIDTH ||
		x<VSCREEN_X_PAD-sprite.width ) return;

	for( int ey=0; ey<sprite.height; ey++ )
	{
		for( int ex=0; ex<sprite.width; ex++ )
		{
			if( sprite.data[ey*sprite.width+ex]==1 ) g_screen[((ey+y)*VSCREEN_WIDTH)+(ex+x)] = color;
		}
	}
}

//BlitSpriteScroll
void BlitSpriteScroll( ref Sprite sprite, int x, int y, uint color, byte scroll )
{
	x += VSCREEN_X_PAD;
	int s_line = scroll;
	for( int ey=0; ey<sprite.height; ey++ )
	{
		for( int ex=0; ex<sprite.width; ex++ )
		{
			if( sprite.data[s_line*sprite.width+ex]==1 ) g_screen[((ey+y)*VSCREEN_WIDTH)+(ex+x)] = color;
		}
		s_line++;
		if( s_line>=sprite.height ) s_line = 0;
	}
}

//BlitSpriteNumbersScroll
void BlitSpriteNumbersScroll( int x, int y, uint color, byte scroll, byte number )
{
	import std.math;
	x += VSCREEN_X_PAD;
	int s_line = abs( scroll );
	if( scroll>=0 )
	{
		Sprite sprite = numbers[number];
		for( int ey=0; ey<sprite.height; ey++ )
		{
			for( int ex=0; ex<sprite.width; ex++ )
			{
				if( sprite.data[s_line*sprite.width+ex]==1 ) g_screen[((ey+y)*VSCREEN_WIDTH)+(ex+x)] = color;
			}
			s_line++;
			if( s_line>=sprite.height ) 
			{
				s_line = 0;
				number++;
				if( number>9 ) number = 0;
				sprite = numbers[number];
			}
		}
	} else {
		Sprite sprite = numbers[number];
		for( int ey=0; ey<sprite.height-s_line; ey++ )
			for( int ex=0; ex<sprite.width; ex++ )
				if( sprite.data[(ey*sprite.width)+ex]==1 ) g_screen[((ey+y+s_line)*VSCREEN_WIDTH)+(ex+x)] = color;
		number++;
		if( number>9 ) number = 0;
		sprite = numbers[number];
		for( int ey=sprite.height-s_line; ey<sprite.height; ey++ )
			for( int ex=0; ex<sprite.width; ex++ )
				if( sprite.data[(ey*sprite.width)+ex]==1 ) g_screen[((ey+y-sprite.height+s_line)*VSCREEN_WIDTH)+(ex+x)] = color;
	}

}

//BlitFullColorSpriteScroll
void BlitFullColorSpriteScroll( ref FullColorSprite sprite, int x, int y, byte scroll )
{
	x += VSCREEN_X_PAD;
	int s_line = scroll;
	for( int ey=0; ey<sprite.height; ey++ )
	{
		for( int ex=0; ex<sprite.width; ex++ )
			g_screen[((ey+y)*VSCREEN_WIDTH)+(ex+x)] = sprite.data[s_line*sprite.width+ex];
		s_line++;
		if( s_line>=sprite.height ) s_line = 0;
	}
}

static enum X = 1;

//mini-car
Sprite mini_car =
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,X,0,0,0,0,X,0,
			 0,X,X,X,X,X,X,0,
			 0,X,0,X,X,0,X,0,
			 0,0,0,X,X,0,0,0,
			 0,X,0,X,X,0,X,0,
			 0,X,X,X,X,X,X,0,
			 0,X,0,X,X,0,X,0,
	 		 0,0,0,0,0,0,0,0 ] };

//numbers
Sprite[10] numbers = [
	//0
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//1
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,X,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//2
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,0,0,0,X,X,0,
			 0,0,0,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,0,0,0,
			 0,X,X,0,0,0,0,0,
			 0,X,X,X,X,X,X,0,
			 0,0,0,0,0,0,0,0 ] },
	//3
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,0,0,0,X,X,0,
			 0,0,0,X,X,X,0,0,
			 0,0,0,X,X,X,0,0,
			 0,0,0,0,0,X,X,0,
			 0,X,0,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//4
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,0,0,X,X,0,0,
			 0,0,0,X,X,X,0,0,
			 0,0,X,0,X,X,0,0,
			 0,X,0,0,X,X,0,0,
			 0,X,X,X,X,X,X,0,
			 0,0,0,0,X,X,0,0,
			 0,0,0,0,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//5
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,X,X,X,X,X,X,0,
			 0,X,X,0,0,0,0,0,
			 0,X,X,0,0,0,0,0,
			 0,X,X,X,X,X,0,0,
			 0,0,0,0,0,X,X,0,
			 0,X,0,0,0,X,X,0,
			 0,X,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//6
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,0,X,0,
			 0,X,X,0,0,0,0,0,
			 0,X,X,X,X,X,0,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//7
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,X,X,X,X,X,X,0,
			 0,X,0,0,0,0,X,0,
			 0,0,0,0,0,X,X,0,
			 0,0,0,0,X,X,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,X,X,0,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//8
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] },
	//9
	{ 8, 9, [0,0,0,0,0,0,0,0,
			 0,0,X,X,X,X,0,0,
			 0,X,X,0,0,X,X,0,
			 0,X,X,0,0,X,X,0,
			 0,0,X,X,X,X,X,0,
			 0,0,0,0,0,X,X,0,
			 0,X,0,0,0,X,X,0,
			 0,0,X,X,X,X,0,0,
			 0,0,0,0,0,0,0,0 ] }

];

//car sprites
Sprite[14] car_sprite = [ 
	//7 zoom levels - from the smallest to the biggest car
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,					
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,					
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,					
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },					

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },

	//one more
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	//one more
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,X,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,X,X,X,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },		

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,X,0,0,0,0,0,0,		
				0,0,0,0,0,0,X,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	//one more
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,			
				0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },		

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,		
				0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	//one more
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,			
				0,0,0,0,0,X,X,X,X,X,X,0,0,0,0,0,			
				0,0,0,0,0,X,X,X,X,X,0,X,0,0,0,0,			
				0,0,0,0,X,0,X,X,X,X,X,0,0,0,0,0,			
				0,0,0,0,0,X,X,X,X,X,0,X,0,0,0,0,			
				0,0,0,0,X,0,X,X,X,X,X,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },		

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,X,X,0,0,0,0,0,0,0,		
				0,0,0,0,0,X,X,X,X,X,X,0,0,0,0,0,		
				0,0,0,0,X,0,X,X,X,X,X,0,0,0,0,0,		
				0,0,0,0,0,X,X,X,X,X,0,X,0,0,0,0,		
				0,0,0,0,X,0,X,X,X,X,X,0,0,0,0,0,		
				0,0,0,0,0,X,X,X,X,X,0,X,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	//one more
	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,			
				0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,			
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,			
				0,0,0,0,0,0,X,X,X,X,0,0,X,X,0,0,			
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,0,0,			
				0,0,0,0,X,X,X,X,X,X,X,X,X,X,0,0,			
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,0,0,			
				0,0,0,0,X,X,X,X,X,X,X,X,X,X,0,0,			
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,0,0,			
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },		

	{ 16, 11, [	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		
				0,0,0,0,0,0,X,X,X,X,0,0,0,0,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,0,0,X,X,X,X,0,0,0,0,0,0,		
				0,0,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,0,0,		
				0,0,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,0,0,		
				0,0,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	] },	

	//player's car (also closest enemy)
	{ 16, 11, [	0,0,X,X,0,0,X,X,X,X,0,0,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,		
				1,X,0,0,0,0,X,X,X,X,0,0,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,		
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,		
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,		
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,		
				0,0,X,X,0,0,X,X,X,X,0,0,0,0,X,X	] },	

	{ 16, 11, [	0,0,X,X,0,0,X,X,X,X,0,0,X,X,0,0,
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,
				0,0,X,X,X,X,X,X,X,X,X,X,X,X,0,0,
				0,0,X,X,0,0,X,X,X,X,0,0,0,0,X,X,
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,
				1,X,0,0,X,X,X,X,X,X,X,X,X,X,0,0,
				0,0,X,X,X,X,X,X,X,X,X,X,0,0,X,X,
				1,X,0,0,0,0,X,X,X,X,0,0,X,X,0,0	] }

];

//mountains
Sprite[2] mountain_sprites = [ 
	{ 32, 6, [  0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,							
				0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
				0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,
				0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ] },					

	{ 29, 5, [	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,	
				0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,	
				0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,	
				0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,	
				0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ] },
];

//dgm soft logo
static enum W = 0xFFFFFFFF;
static enum R = 0xFFFF0000;//0xFF912640;
static enum O = 0xFFFF8000;//0xFFA37513;
static enum Y = 0xFFFFFF00;//0xFFA8B828;
static enum G = 0xFF00FF00;//0xFF5B8D2D;
static enum B = 0xFF0000FF;//0xFF4D4DBB;

FullColorSprite dgm_soft_logo =
	{ 52, 9, [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 		  0,R,R,R,R,R,R,R,R,R,R,R,R,R,R,R,R,R,R,W,W,W,W,0,0,0,W,W,0,0,W,0,0,0,W,0,W,W,W,0,W,W,W,0,W,W,W,W,W,W,W,0,
	 		  0,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,0,0,W,0,W,0,0,W,0,W,W,0,W,W,0,W,0,0,0,W,0,W,0,W,0,0,0,0,W,0,0,
	 		  0,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,0,0,W,0,W,0,0,0,0,W,W,W,W,W,0,W,W,W,0,W,0,W,0,W,W,0,0,0,W,0,0,
	 		  0,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,W,0,0,W,0,W,0,W,W,0,W,0,W,0,W,0,0,0,W,0,W,0,W,0,W,0,0,0,0,W,0,0,
	 		  0,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,W,0,0,W,0,W,0,0,W,0,W,0,0,0,W,0,W,W,W,0,W,W,W,0,W,0,0,0,0,W,0,0,
	 		  0,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,W,0,0,W,0,W,0,0,W,0,W,0,0,0,W,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 		  0,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,W,W,W,W,0,0,0,W,W,W,0,W,0,0,0,0,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,0,
			  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ] };

//EOF