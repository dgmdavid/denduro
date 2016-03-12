/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.
*/
module Audio;
import std.stdio, std.random, core.stdc.stdlib, std.math;
import derelict.sdl2.sdl;
import Globals, Player;

enum SOUND_FREQ = 8000;
enum SOUND_SAMPLES = 800;
enum PI = 3.14159f;
enum PIH = 1.57079f;
enum PIQ = 0.78539f;
enum PI2 = 6.28318f;

//InitAudio
bool InitAudio()
{
	if( SDL_Init( SDL_INIT_AUDIO )<0 ) return false;

	SDL_AudioSpec spec, obtained;
	spec.freq = SOUND_FREQ;
	spec.format = AUDIO_S8;
   	spec.channels = 0;
   	spec.samples = SOUND_SAMPLES;
   	spec.callback = &FillAudio;
	spec.userdata = null;
	spec.silence = 0;
	spec.size = 0;

	if( SDL_OpenAudio( &spec, null )<0 ) return false;
	SDL_PauseAudio( 0 );

	return true;
}

extern(C) nothrow float TriangleWave( float period, float constant )
{
	return (2.0f/PI)*asin(sin((PI2/constant)*period));
}

extern(C) nothrow float SquareWave( float period, float constant )
{
	return period%constant;
}

//Fillaudio
extern(C) nothrow void FillAudio( void *udata, Uint8 *stream, int len )
{
	byte *ptr = cast(byte*)stream;

	static float i = 0;
	Uint8 volume = 12;

	for( int r=0; r<len; ++r )
	{
		float data = 0;// sin(i*3.1415)*16;
		//data = sin(i%PIQ)*(i%4.0f);

		//data = sin(i%TEST_STEP2)*cos(i%4.0f);
		data = fmod(i,1);

		if( data>1.0f ) data = 1.0f;
		if( data<-1.0f ) data = -1.0f;

		*stream = cast(ubyte)(volume+(data*volume));
		stream++;

		i += cast(float)TEST_STEP/10000.0f;
	} 
}

//EOF