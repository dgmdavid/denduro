/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module FontBMP;
import derelict.sdl2.sdl;
import Globals;

struct FontBMP
{
	SDL_Texture *texture;
	int horizontal_count;
	int width, height;
	int spacing_x, spacing_y;
}

//RenderText
void RenderText( FontBMP font, int x, int y, const char* text )
{
	SDL_Rect rect1, rect2;
	rect2.x = x;
	rect2.y = y;
	rect2.w = font.width;
	rect2.h = font.height;
	rect1.w = font.width;
	rect1.h = font.height;

	for( int r=0; text[r]!='\0'; ++r )
	{
		char letter = text[r];
		rect1.x = font.width*(letter%font.horizontal_count);
		rect1.y = font.height*(letter/font.horizontal_count);
		if( letter>=33 ) SDL_RenderCopy( g_renderer, font.texture, &rect1, &rect2 );
		rect2.x += font.spacing_x;
		if( letter==10 ) 
		{
			rect2.x = x;
			rect2.y += font.spacing_y;
		}
	}
}

//EOF