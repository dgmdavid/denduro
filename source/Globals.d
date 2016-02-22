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

immutable int SCREEN_WIDTH = 160;
immutable int SCREEN_HEIGHT = 192;

SDL_Renderer *g_renderer;
uint[SCREEN_WIDTH*SCREEN_HEIGHT] g_screen;

//EOF