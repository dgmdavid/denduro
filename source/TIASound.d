/*
	Denduro - An Enduro Clone in D

	Written by David G. Maziero

	LICENSE
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to copy,
	distribute, and modify this file as you see fit.
	No warranty is offered or implied; use this code at your own risk.

	This code is adapted from Atari 2600's emulator Stella: http://stella.sourceforge.net/

	I don't want to use this. It's just a way for me to "inspect" the waveform it generates
	so I can try to 'simulate' it in a non-HACKY way :) (nor emulated way, like this).
*/
module TIASound;

__gshared public 
{
	enum AUDCxRegister
	{
	      SET_TO_1    = 0x00,  // 0000
	      POLY4       = 0x01,  // 0001
	      DIV31_POLY4 = 0x02,  // 0010
	      POLY5_POLY4 = 0x03,  // 0011
	      PURE1       = 0x04,  // 0100
	      PURE2       = 0x05,  // 0101
	      DIV31_PURE  = 0x06,  // 0110
	      POLY5_2     = 0x07,  // 0111
	      POLY9       = 0x08,  // 1000
	      POLY5       = 0x09,  // 1001
	      DIV31_POLY5 = 0x0a,  // 1010
	      POLY5_POLY5 = 0x0b,  // 1011
	      DIV3_PURE   = 0x0c,  // 1100
	      DIV3_PURE2  = 0x0d,  // 1101
	      DIV93_PURE  = 0x0e,  // 1110
	      POLY5_DIV3  = 0x0f   // 1111
	}

	enum 
	{
		POLY4_SIZE = 0x000f,
		POLY5_SIZE = 0x001f,
		POLY9_SIZE = 0x01ff,
		DIV3_MASK  = 0x0c,
		AUDV_SHIFT = 10     // shift 2 positions for AUDV, then another 8 for 16-bit sound
	}

	enum TIARegister : ubyte
	{
		AUDC0,  // Write: audio control 0 (D3-0)
		AUDF0,  // Write: audio frequency 0 (D4-0)
		AUDV0,  // Write: audio volume 0 (D3-0)
		AUDC1,  // Write: audio control 1 (D4-0)
		AUDF1,  // Write: audio frequency 1 (D3-0)
		AUDV1,  // Write: audio volume 1 (D3-0)
	}

	ubyte[2] myAUDC;    // AUDCx (15, 16)
	ubyte[2] myAUDF;    // AUDFx (17, 18)
	ushort[2] myAUDV;    // AUDVx (19, 1A)

	short[2] myVolume;  // Last output volume for each channel

	ubyte[2] myP4;      // Position pointer for the 4-bit POLY array
	ubyte[2] myP5;      // Position pointer for the 5-bit POLY array
	ushort[2] myP9;     // Position pointer for the 9-bit POLY array

	ubyte[2] myDivNCnt; // Divide by n counter. one for each channel
	ubyte[2] myDivNMax; // Divide by n maximum, one for each channel
	ubyte[2] myDiv3Cnt; // Div 3 counter, used for POLY5_DIV3 mode

	int myOutputFrequency = 0;
	int myOutputCounter = 0;
	uint myVolumePercentage = 100;
	
	ubyte[POLY4_SIZE] Bit4;
	ubyte[POLY5_SIZE] Bit5;
	ubyte[POLY9_SIZE] Bit9;

	ubyte[POLY5_SIZE] Div31 = [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
}

//TIASound_Reset
void TIASound_Reset( int frequency )
{
	TIASound_PolyInit( Bit4.ptr, 4, 4, 3 );
	TIASound_PolyInit( Bit5.ptr, 5, 5, 3 );
	TIASound_PolyInit( Bit9.ptr, 9, 9, 5 );
	for( int chan=0; chan<=1; ++chan )
	{
		myVolume[chan] = 0;
		myDivNCnt[chan] = 0;
		myDivNMax[chan] = 0;
		myDiv3Cnt[chan] = 3;
		myAUDC[chan] = 0;
		myAUDF[chan] = 0;
		myAUDV[chan] = 0;
		myP4[chan] = 0;
		myP5[chan] = 0;
		myP9[chan] = 0;
	}
	myOutputCounter = 0;
	myOutputFrequency = frequency;	
}

//TIASound_SetRegisters0
void TIASound_SetRegisters0( ubyte f_value, ubyte c_value, ubyte v_value ) nothrow
{
	TIASound_SetRegister( TIARegister.AUDF0, f_value );
	TIASound_SetRegister( TIARegister.AUDC0, c_value );
	TIASound_SetRegister( TIARegister.AUDV0, v_value );
}

//TIASound_SetRegisters1
void TIASound_SetRegisters1( ubyte f_value, ubyte c_value, ubyte v_value ) nothrow
{
	TIASound_SetRegister( TIARegister.AUDF1, f_value );
	TIASound_SetRegister( TIARegister.AUDC1, c_value );
	TIASound_SetRegister( TIARegister.AUDV1, v_value );
}

//TIASound_SetRegister
void TIASound_SetRegister( ushort register, ubyte value ) nothrow
{
	int chan = (register>=TIARegister.AUDC1)?1:0;

	switch( register )
	{
		case TIARegister.AUDC0:
		case TIARegister.AUDC1:
			myAUDC[chan] = value&0x0F;
			break;
			
		case TIARegister.AUDF0:
		case TIARegister.AUDF1:
			myAUDF[chan] = value&0x1F;
			break;
			
		case TIARegister.AUDV0:
		case TIARegister.AUDV1:
			myAUDV[chan] = (value&0x0F)<<AUDV_SHIFT;
			break;
			
		default:
			return;
	}
	
	ushort newVal = 0;
	
	if( myAUDC[chan]==AUDCxRegister.SET_TO_1 || myAUDC[chan]==AUDCxRegister.POLY5_POLY5 )
	{
		newVal = 0;
		myVolume[chan] = cast(short)((myAUDV[chan]*myVolumePercentage)/100);
	}
	else
	{
		newVal = myAUDF[chan]+1;
		if( (myAUDC[chan]&DIV3_MASK)==DIV3_MASK && myAUDC[chan]!=AUDCxRegister.POLY5_DIV3 ) newVal *= 3;
	}
	
	if( newVal!=myDivNMax[chan] )
	{
		myDivNMax[chan] = cast(ubyte)newVal;
		if( (myDivNCnt[chan]==0) || (newVal==0) ) myDivNCnt[chan] = cast(ubyte)newVal;
	}
}

//TIASound_SetVolume
void TIASound_SetVolume( ubyte percent )
{
	if( percent<=100 ) myVolumePercentage = percent;
}

//TIASound_Process
void TIASound_Process( short *buffer, uint samples ) nothrow
{
	ubyte audc0 = myAUDC[0], audc1 = myAUDC[1];
	ubyte p5_0 = myP5[0], p5_1 = myP5[1];
	ubyte div_n_cnt0 = myDivNCnt[0], div_n_cnt1 = myDivNCnt[1];
	short v0 = myVolume[0], v1 = myVolume[1];
	
	short audv0 = cast(short)((myAUDV[0]*myVolumePercentage)/100),
		  audv1 = cast(short)((myAUDV[1]*myVolumePercentage)/100);
	
	while( samples>0 )
	{
		// Process channel 0
		if( div_n_cnt0>1 )
		{
			div_n_cnt0--;
		}
		else if( div_n_cnt0==1 )
		{
			int prev_bit5 = Bit5[p5_0];
			div_n_cnt0 = myDivNMax[0];
			
			p5_0++;
			if( p5_0==POLY5_SIZE ) p5_0 = 0;
			
			if(  (audc0&0x02)==0 ||
				((audc0&0x01)==0 && Div31[p5_0]) ||
				((audc0&0x01)==1 && Bit5[p5_0]) ||
				((audc0&0x0f)==AUDCxRegister.POLY5_DIV3 && Bit5[p5_0]!=prev_bit5) )
			{
				if( audc0&0x04 )
				{
					if( (audc0&0x0f)==AUDCxRegister.POLY5_DIV3 )
					{
						if( Bit5[p5_0]!=prev_bit5 )
						{
							myDiv3Cnt[0]--;
							if( !myDiv3Cnt[0] )
							{
								myDiv3Cnt[0] = 3;
								v0 = v0?0:audv0;
							}
						}
					} else {
						v0 = v0?0:audv0;
					}
				}
				else if( audc0&0x08 )
				{
					if( audc0==AUDCxRegister.POLY9 )
					{
						myP9[0]++;
						if( myP9[0]==POLY9_SIZE ) myP9[0] = 0;
						v0 = Bit9[myP9[0]]?audv0:0;
					}
					else if( audc0&0x02 )
					{
						v0 = (v0||audc0&0x01)?0:audv0;
					} else {
						v0 = Bit5[p5_0]?audv0:0;
					}
				}
				else
				{
					myP4[0]++;
					if( myP4[0]==POLY4_SIZE ) myP4[0] = 0;
					v0 = Bit4[myP4[0]]?audv0:0;
				}
			}
		}
		
		// Process channel 1
		if( div_n_cnt1>1 )
		{
			div_n_cnt1--;
		}
		else if( div_n_cnt1==1 )
		{
			int prev_bit5 = Bit5[p5_1];
			div_n_cnt1 = myDivNMax[1];
			p5_1++;
			if( p5_1==POLY5_SIZE ) p5_1 = 0;
			
			if(  (audc1&0x02)==0 ||
				((audc1&0x01)==0 && Div31[p5_1]) ||
				((audc1&0x01)==1 && Bit5[p5_1]) ||
				((audc1&0x0f)==AUDCxRegister.POLY5_DIV3 && Bit5[p5_1]!=prev_bit5) )
			{
				if( audc1&0x04 )
				{
					if( (audc1&0x0f)==AUDCxRegister.POLY5_DIV3 )
					{
						if( Bit5[p5_1]!=prev_bit5 )
						{
							myDiv3Cnt[1]--;
							if( !myDiv3Cnt[1] )
							{
								myDiv3Cnt[1] = 3;
								v1 = v1?0:audv1;
							}
						}
					} else {
						v1 = v1?0:audv1;
					}
				}
				else if( audc1&0x08 )
				{
					if( audc1==AUDCxRegister.POLY9 ) 
					{
						myP9[1]++;
						if( myP9[1]==POLY9_SIZE ) myP9[1] = 0;
						v1 = Bit9[myP9[1]]?audv1:0;
					}
					else if( audc1&0x02 )
					{
						v1 = (v1||audc1&0x01)?0:audv1;
					} else {
						v1 = Bit5[p5_1]?audv1:0;
					}
				}
				else
				{
					myP4[1]++;
					if( myP4[1]==POLY4_SIZE ) myP4[1] = 0;
					v1 = Bit4[myP4[1]]?audv1:0;
				}
			}
		}

		myOutputCounter += myOutputFrequency;
		while( (samples>0) && (myOutputCounter>=31400) )
        {
			*buffer = cast(short)(v0+v1);
			buffer++;
			myOutputCounter -= 31400;
			samples--;
        }
	}
	
	myP5[0] = p5_0;
	myP5[1] = p5_1;
	myVolume[0] = v0;
	myVolume[1] = v1;
	myDivNCnt[0] = div_n_cnt0;
	myDivNCnt[1] = div_n_cnt1;
}

//TIASound_PolyInit
void TIASound_PolyInit( ubyte *poly, int size, int f0, int f1 )
{
	int mask = (1<<size)-1;
	int x = mask;

	for( int i=0; i<mask; i++ )
	{
		int bit0 = ((size-f0)?(x>>(size-f0)):x)&0x01;
		int bit1 = ((size-f1)?(x>>(size-f1)):x)&0x01;
		poly[i] = cast(ubyte)(x&1);
		x = (x>>1)|((bit0^bit1)<<(size-1));
	}
}

//EOF