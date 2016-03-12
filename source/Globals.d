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

//constant
enum SCREEN_WIDTH  = 160;
enum SCREEN_HEIGHT = 228;
enum VSCREEN_X_PAD = 40;
enum VSCREEN_WIDTH = SCREEN_WIDTH+(VSCREEN_X_PAD*2);
enum VSCREEN_HEIGHT = SCREEN_HEIGHT;
enum SCREEN_CENTER   = (SCREEN_WIDTH/2)+VSCREEN_X_PAD;

//global states
SDL_Renderer *g_renderer;
uint[VSCREEN_WIDTH*VSCREEN_HEIGHT] g_screen;

bool ENABLE_COLLISION = true;
bool ENABLE_AUDIO = true;

shared int TEST_STEP = 20;
shared float TEST_STEP2 = 1;

//Increase
pragma( inline, true )
void Increase(T)( ref T value, T amount, T max )
{
	value += amount;
	if( value>max ) value = max;
}

//Decrease
pragma( inline, true )
void Decrease(T)( ref T value, T amount, T min )
{
	value -= amount;
	if( value<min ) value = min;
}

//EOF