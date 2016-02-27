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
import std.stdio, std.conv, std.random;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import Globals, Road, Player;
debug import FontBMP;

void main()
{
	DerelictSDL2.load( SharedLibVersion( 2, 0, 0 ) );
	DerelictSDL2Image.load();

	SDL_Init( SDL_INIT_VIDEO );
	IMG_Init( IMG_INIT_PNG );

	SDL_Window *window = SDL_CreateWindow( "Denduro", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, (SCREEN_WIDTH*5), cast(int)(SCREEN_HEIGHT*2.8), SDL_WINDOW_SHOWN|SDL_WINDOW_RESIZABLE );

	g_renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED|SDL_RENDERER_PRESENTVSYNC );

	SDL_Texture *tex_screen = SDL_CreateTexture( g_renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC/*STREAMING*/, SCREEN_WIDTH, SCREEN_HEIGHT );

	//this is just for displaying debug information
	debug 
	{
		SDL_Texture *font_tex = IMG_LoadTexture( g_renderer, "data/dgm_font.png" );
		FontBMP font = { texture:font_tex, spacing_x:8, spacing_y:14, width:16, height:16, horizontal_count:16 };
	}

	SDL_Event event;
	bool running = true;
	uint frame_count, fps, ticks, acc, acc_noise;
	bool player_left=false, player_right=false;
	byte curve = 0; //TODO: temporary -- remove later

	while( running ) 
	{ 
		ticks = SDL_GetTicks();

		//pool events
		while( SDL_PollEvent(&event) )
		{
			switch( event.type )
			{
				case SDL_QUIT:
					running = false;
					break;

				case SDL_KEYDOWN:
					if( event.key.keysym.sym==SDLK_ESCAPE ) running = false;	

					//TODO: temporary
					if( event.key.keysym.scancode==SDL_SCANCODE_1 ) curve = -1;
					if( event.key.keysym.scancode==SDL_SCANCODE_2 ) curve = 1;
					//

					if( event.key.keysym.scancode==SDL_SCANCODE_LEFT ||
						event.key.keysym.scancode==SDL_SCANCODE_A       ) player.turn_left = true;
					if( event.key.keysym.scancode==SDL_SCANCODE_RIGHT ||
						event.key.keysym.scancode==SDL_SCANCODE_D       ) player.turn_right = true;
					if( event.key.keysym.scancode==SDL_SCANCODE_SPACE ||
						event.key.keysym.scancode==SDL_SCANCODE_RCTRL ||
						event.key.keysym.scancode==SDL_SCANCODE_UP    ||
						event.key.keysym.scancode==SDL_SCANCODE_W       ) player.accelerate = true;
					break;

				case SDL_KEYUP:
					if( event.key.keysym.scancode==SDL_SCANCODE_1 ||
						event.key.keysym.scancode==SDL_SCANCODE_2   ) curve = 0;

					if( event.key.keysym.scancode==SDL_SCANCODE_LEFT ||
						event.key.keysym.scancode==SDL_SCANCODE_A       ) player.turn_left = false;
					if( event.key.keysym.scancode==SDL_SCANCODE_RIGHT ||
						event.key.keysym.scancode==SDL_SCANCODE_D       ) player.turn_right = false;
					if( event.key.keysym.scancode==SDL_SCANCODE_SPACE ||
						event.key.keysym.scancode==SDL_SCANCODE_RCTRL ||
						event.key.keysym.scancode==SDL_SCANCODE_UP    ||
						event.key.keysym.scancode==SDL_SCANCODE_W       ) player.accelerate = false;
					break;


				default:
					break;
			}
		}

		//TODO: temporary
		if( curve==-1 ) road.curve += 1;
		if( curve== 1 ) road.curve -= 1;				
		//

		UpdatePlayer();
		RenderRoad();

		//SDL_RenderClear( g_renderer ); //TODO: really needed?
		SDL_UpdateTexture( tex_screen, null, cast(void*)g_screen+VSCREEN_X_PAD*uint.sizeof, VSCREEN_WIDTH*uint.sizeof );
		SDL_RenderCopy( g_renderer, tex_screen, null, null );

		debug
		{
			RenderText( font, 0, 0, "FPS: "~to!string(fps) );
			RenderText( font, 0, 16, "Player: pos:"~to!string(player.position)~" - speed:"~to!string(player.speed) );
			RenderText( font, 0, 32, "Road: curve:"~to!string(road.curve) );
		}

		SDL_RenderPresent( g_renderer );
		
		frame_count++;
		ticks = SDL_GetTicks()-ticks;
		acc += ticks;
		if( acc>1000 ) 
		{
			acc -= 1000;
			fps = frame_count;
			frame_count = 0;
		}
		//TODO: manually limit frame rate to 60 fps?
		acc_noise += ticks;
		if( acc_noise>100 )
		{
			acc_noise -= 100;
			road.noise = uniform( 0, 40 )/100.0f;
		}
	}

	//clean-up 
 	debug SDL_DestroyTexture( font_tex );
 	SDL_DestroyTexture( tex_screen );
 	SDL_DestroyRenderer( g_renderer );
	SDL_DestroyWindow( window );
	IMG_Quit();
	SDL_Quit();
}

//EOF