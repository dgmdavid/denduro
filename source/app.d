/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.

	Some Atari 2600 specs for reference:
		Video:
		Output:      Line-by-line (Registers must be updated each scanline)
		Resolution:  160x192 pixels (NTSC 60Hz), 160x228 pixels (PAL 50Hz)
		Playfield:   40 dots horizontal resolution (rows of 4 pixels per dot)
		Colors:      4 colors at once (one color per object)
		Palette:     128 colors (NTSC), 104 colors (PAL), 8 colors (SECAM)
		Sprites:     2 sprites of 8pix width, 3 sprites of 1pix width

		Additional info: http://problemkaputt.de/2k6specs.htm
*/
import std.stdio;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import Globals, FontBMP;

void main()
{
	DerelictSDL2.load( SharedLibVersion( 2, 0, 0 ) );
	DerelictSDL2Image.load();

	SDL_Init( SDL_INIT_VIDEO );
	IMG_Init( IMG_INIT_PNG );

	SDL_Window *window = SDL_CreateWindow( "Test", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_SHOWN|SDL_WINDOW_RESIZABLE );

	g_renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC );

	SDL_Texture *img = IMG_LoadTexture( g_renderer, "data/maja.png" );
	SDL_Texture *font_tex = IMG_LoadTexture( g_renderer, "data/dgm.png" );

	FontBMP font = { texture:font_tex, spacing_x:8, spacing_y:14, width:16, height:16, horizontal_count:16 };

	SDL_Event event;
	bool running = true;

	while( running ) 
	{
		while( SDL_PollEvent(&event) )
		{
			switch( event.type )
			{
				case SDL_QUIT:
					running = false;
					break;

				case SDL_KEYDOWN:
					if( event.key.keysym.sym==SDLK_ESCAPE ) running = false;				
					break;

				default:
					break;
			}
		}
		
		SDL_RenderClear( g_renderer );
	
		SDL_RenderCopy( g_renderer, img, null, null );

		static int i=0;
		i++; if(i>200) i =0;
		RenderText( font, 50, 50+i, "hello from Linux!" );

		SDL_RenderPresent( g_renderer );
	}
 
	SDL_DestroyWindow( window );
	IMG_Quit();
	SDL_Quit();
}