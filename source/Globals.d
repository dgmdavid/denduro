/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Globals;
import derelict.sdl2.sdl;

enum SCREEN_WIDTH  = 160;
enum SCREEN_HEIGHT = 228;
enum VSCREEN_X_PAD = 40;
enum VSCREEN_WIDTH = SCREEN_WIDTH+(VSCREEN_X_PAD*2);
enum VSCREEN_HEIGHT = SCREEN_HEIGHT;

SDL_Renderer *g_renderer;
uint[VSCREEN_WIDTH*VSCREEN_HEIGHT] g_screen;

//Clamp
pragma( inline, true )
void Clamp(T)( ref T value, T max )
{
	if( max>0 )
	{
		if( value>max ) value = max;
	} else {
		if( value<max ) value = max;
	}
}

//EOF