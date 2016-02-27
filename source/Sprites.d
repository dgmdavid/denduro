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

//BlitSprite
void BlitSprite( ref Sprite sprite, int x, int y, uint color )
{
	for( int ey=0; ey<sprite.height; ey++ )
	{
		for( int ex=0; ex<sprite.width; ex++ )
		{
			if( sprite.data[ey*sprite.width+ex]==1 ) g_screen[((ey+y)*VSCREEN_WIDTH)+(ex+x)] = color;
		}
	}
}

//EOF