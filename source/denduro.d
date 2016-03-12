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

		Additional info on Atari's sound: http://www.randomterrain.com/atari-2600-memories-music-and-sound.html
*/
import std.stdio, std.random, std.math;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import Globals, Audio, Road, Player, Enemies, Sprites;
debug import FontBMP;

void main()
{
	DerelictSDL2.load( SharedLibVersion( 2, 0, 0 ) );
	DerelictSDL2Image.load();

	SDL_Init( SDL_INIT_VIDEO );
	IMG_Init( IMG_INIT_PNG );

	if( !InitAudio() ) 
	{
		ENABLE_AUDIO = false;
		writeln("NO AUDIO!");
	}

	SDL_Window *window = SDL_CreateWindow( "Denduro", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, (SCREEN_WIDTH*4), (SCREEN_HEIGHT*2)+SCREEN_HEIGHT/32, SDL_WINDOW_SHOWN|SDL_WINDOW_RESIZABLE );

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
	uint frame_count, fps, ticks, last_frame_time, acc, acc_noise;
	bool player_left=false, player_right=false;
	byte curve = 0; //TODO: temporary -- remove later

	InitEnemies();

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
				{
					auto k = event.key.keysym.scancode;
					if( k==SDL_SCANCODE_ESCAPE ) running = false;	
					if( k==SDL_SCANCODE_1 ) curve = -1;	//TODO: remove later
					if( k==SDL_SCANCODE_2 ) curve = 1;
					if( k==SDL_SCANCODE_LEFT  || k==SDL_SCANCODE_A ) player.turn_left = true;
					if( k==SDL_SCANCODE_RIGHT || k==SDL_SCANCODE_D ) player.turn_right = true;
					if( k==SDL_SCANCODE_DOWN  || k==SDL_SCANCODE_S ) player.deaccelerate = true;
					if( k==SDL_SCANCODE_SPACE || k==SDL_SCANCODE_RCTRL || k==SDL_SCANCODE_UP || k==SDL_SCANCODE_W ) player.accelerate = true;

					//TODO: test stuff, remove later
					if( k==SDL_SCANCODE_Q ) TEST_STEP++;
					if( k==SDL_SCANCODE_W ) TEST_STEP--;
					if( k==SDL_SCANCODE_A ) TEST_STEP2+=0.025f;
					if( k==SDL_SCANCODE_S ) TEST_STEP2-=0.025f;
				} break;

				case SDL_KEYUP:
				{
					auto k = event.key.keysym.scancode;
					if( k==SDL_SCANCODE_1 || k==SDL_SCANCODE_2   ) curve = 0; //TODO: remove later
					if( k==SDL_SCANCODE_LEFT  || k==SDL_SCANCODE_A ) player.turn_left = false;
					if( k==SDL_SCANCODE_RIGHT || k==SDL_SCANCODE_D ) player.turn_right = false;
					if( k==SDL_SCANCODE_DOWN  || k==SDL_SCANCODE_S ) player.deaccelerate = false;
					if( k==SDL_SCANCODE_SPACE || k==SDL_SCANCODE_RCTRL || k==SDL_SCANCODE_UP || k==SDL_SCANCODE_W ) player.accelerate = false;
					debug if( k==SDL_SCANCODE_C ) ENABLE_COLLISION = !ENABLE_COLLISION;
				} break;

				default:
					break;
			}
		}

		//TODO: temporary ugly stuff, remove later
		if( curve==-1 )	Increase( road.curve, cast(int)ceil(player.speed), ROAD_MAX_CURVE );
		if( curve== 1 ) Decrease( road.curve, cast(int)ceil(player.speed), -ROAD_MAX_CURVE );
		if( curve== 0 ) 
		{
			if( road.curve>0 )  
				Decrease( road.curve, cast(int)ceil(player.speed), 0 );
			else
				Increase( road.curve, cast(int)ceil(player.speed), 0 );
		}

		static float road_timer = 0.0f;
		road_timer += last_frame_time;
		if( road_timer>2000 )
		{
			road_timer -= 2000;
			if( curve==0 || (curve!=0 && ( (road.curve<=-ROAD_MAX_CURVE+2) || (road.curve>=ROAD_MAX_CURVE-2) ) ) )
			{
				int decision = uniform( 0, 100 );
				if( curve==0 )
				{
					if( decision<=15 ) curve = -1;
					if( decision>=85 ) curve =  1;
				} 
				else if( curve==-1 )
				{
					if( decision<=20 ) curve = 0;
				}
				else if( curve==1 )
				{
					if( decision<=20 ) curve = 0;
				}
			}
		}
		//

		UpdateEnemies();
		UpdatePlayer();
		RenderRoad();

		//TODO: player's kilometers -- move to another place -- finish it first :)
		player.kilometers += player.speed/(PLAYER_MAX_SPEED*4);
		int trunc = cast(int)player.kilometers;
		float dec = player.kilometers-trunc;
		int divisor = 10000;
		uint color = 0;
		for( int i=0; i<5; ++i )
		{
			int tmp = trunc/divisor;
			tmp %= 10;
			if( i==4 ) color = 0xFFB78927; 
			BlitSpriteNumbersScroll( 64+i*8, 185, color, 0, cast(byte)tmp );
			divisor /= 10;
		}

		BlitSprite( mini_car, 72+VSCREEN_X_PAD, 200, 0 );
		BlitSpriteNumbersScroll( 56, 200, 0, 0, 1 );
		BlitSpriteNumbersScroll( 80, 200, 0, 0, 2 );
		BlitSpriteNumbersScroll( 88, 200, 0, 0, 0 );
		BlitSpriteNumbersScroll( 96, 200, 0, 0, 0 );

		//48x215
		static float line=0;
		static int logo=0;
		logo+=last_frame_time;
		if( logo>6000 )
		{
			line+=0.1f;
			if( line>=9 )
			{
				line=0;
				logo=0;
			}
		}
		BlitFullColorSpriteScroll( dgm_soft_logo, 54, 215, cast(byte)line );

		//SDL_RenderClear( g_renderer ); //TODO: really needed?
		SDL_UpdateTexture( tex_screen, null, cast(void*)g_screen+VSCREEN_X_PAD*uint.sizeof, VSCREEN_WIDTH*uint.sizeof );
		SDL_RenderCopy( g_renderer, tex_screen, null, null );

		debug
		{
			RenderText( font, 0, 0, "FPS: %d", fps );
			RenderText( font, 0, 16, "Player: pos:%.3f - speed:%.3f", player.position, player.speed );
			RenderText( font, 0, 32, "Road: curve:%.3f", road.curve );
			RenderText( font, 0, 48, "Collisions: %s - %d - %f", ENABLE_COLLISION?"enabled".ptr:"disabled".ptr, TEST_STEP, TEST_STEP2 );
		}

		SDL_RenderPresent( g_renderer );
		
		frame_count++;
		last_frame_time = SDL_GetTicks()-ticks;
		acc += last_frame_time;
		if( acc>1000 ) 
		{
			acc -= 1000;
			fps = frame_count;
			frame_count = 0;
		}
		//TODO: manually limit frame rate to 60 fps?
		acc_noise += last_frame_time;
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
	SDL_CloseAudio();
	IMG_Quit();
	SDL_Quit();
}

//EOF