/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.

	Some info on Atari's sound for reference:

		2 channels
		AUDVX - Volume - 4 bits
		AUDFX - Frequency divider - 5 bits (31399.5 Hz / X in a NTSC system)
		AUDCX - Noise/2nd divider - 4 bits:
			Noise/Division Control (0-15, see below)
			  0  set to 1                    8  9 bit poly (white noise)
			  1  4 bit poly                  9  5 bit poly
  			  2  div 15 -> 4 bit poly        A  div 31 : pure tone
  			  3  5 bit poly -> 4 bit poly    B  set last 4 bits to 1
  		  	  4  div 2 : pure tone           C  div 6 : pure tone
  			  5  div 2 : pure tone           D  div 6 : pure tone
  			  6  div 31 : pure tone          E  div 93 : pure tone
  			  7  5 bit poly -> div 2         F  5 bit poly div 6
*/
module Audio;
import std.stdio, std.random, core.stdc.stdlib, std.math;
import derelict.sdl2.sdl;
import Globals, Player;

enum SOUND_FREQ =  31440;
enum SOUND_SAMPLES = 1024;
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

//Fillaudio
extern(C) nothrow void FillAudio( void *udata, Uint8 *stream, int len )
{
	byte *ptr = cast(byte*)stream;

	static float i = 0;
	Uint8 volume = 12;

	static int counter = 0, index = 0;
	int divider = (31400/TEST_STEP);

	struct Waveform
	{
		ubyte len;
		ubyte *data;
	}

	Waveform wave = { 10, [4,0,4,1,4,2,4,3,4,4] };
	Waveform wave2 = { 10, [1,1,2,2,3,3,4,4,0,0] };
	Waveform wave3 = { 13, [4,2,4,1,4,4,4,1,4,3,0,0,1] };
	Waveform wave4 = { 8, [0,0,0,0,4,4,4,4] };

	Waveform cur_wave = wave;

	for( int r=0; r<len; ++r )
	{
		ubyte data = cast(ubyte)(cur_wave.data[index]*4);

		*stream = cast(ubyte)(data);
		stream++;

		counter++;
		if( counter>=divider )
		{
			counter = 0;
			index++;
			if( index>=cur_wave.len ) index = 0;
		}
	} 
}

//EOF