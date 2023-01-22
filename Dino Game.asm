; Copyright 2021 DADi590
;
; Licensed to the Apache Software Foundation (ASF) under one
; or more contributor license agreements.  See the NOTICE file
; distributed with this work for additional information
; regarding copyright ownership.  The ASF licenses this file
; to you under the Apache License, Version 2.0 (the
; "License"); you may not use this file except in compliance
; with the License.  You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing,
; software distributed under the License is distributed on an
; "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
; KIND, either express or implied.  See the License for the
; specific language governing permissions and limitations
; under the License.


; Main note: this was tested with MASM 9.00.21022.08 and passed from OBJ to EXE with LINK 5.60.339 Dec  5 1994, so it
; can be compiled with it.
; Also works on a 32 bit Windows - except INT 86h doesn't seem to be emulated on Windows 7 Ultimate x86, at least (the
; program won't slow down, it's at maximum speed).
; Note: should also be compatible with MAS 6.15 (freely available from Microsoft's website - which comes with the LINK
; that was used here), since we didn't use directives newer than those used with MASM 6.

name "ProjF_AC" ; Deprecated as of MASM something, but EMU8086 is outdated (old version of FASM), so this is still used
; there.

; Small note: not much attention was paied to the stack, so probably there are bugs on that. Sooner or later the stack
; may get full because we're not clearing it in all places we should. A bit more time would be needed to transform the
; function calls into jumps or put more "mov sp, bp / push bp".

; Another small note: already happened twice a bush coming out of nowhere in the beginning of the screen --> that's not
; supposed to happen, because the vector of random has values from 80 to 255, not from 0 to 255...
; No idea hot to fix that. Should even be happening hahaha.

; And another small note: the music works only outside the emulator. It doesn't recognize a call to a custom segment or
; something like that. So with sound, the program must be assembled with MASM.

.8086
.model small
.stack 100h

.data
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Drawing arrays

	;DRAW_DATA_TEMP db 0, 0, 0, 0, 0, 0

	; Dinossaur (head)
	DRAW_DATA_DINO_ORIGINAL db 12, 0, 21, 02, 00001100b, "#", 07
	DRAW_DATA_DINOSSAUR db 12, 0, 21, 02, 00001100b, "#", 07
	X_DRAW_DINOSSAUR db                 00,  01,  02,02,  03,  04,04,  05,05,  06,06,  07
	Y_BEGIN_DRAW_DINOSSAUR db         00,  -1,  -01,1,  -1,  -1,03,  -1,03,  -1,03,  00
	TIMES_WRITE_Y_DRAW_DINOSSAUR db  04,  05,  01,03,  05,  03,01,  03,01,  03,01,  02
	; Dinossaur (head)

	; Big bush
	DRAW_DATA_BUSH1_ORIGINAL db 03, 0, 16, 200, 00001010b, "#", 03
	DRAW_DATA_BUSH1 db 03, 0, 16, 200, 00001010b, "#", 03
	X_DRAW_BUSH1 db                 00,  01,  02
	Y_BEGIN_DRAW_BUSH1 db         00,  00,  00
	TIMES_WRITE_Y_DRAW_BUSH1 db  09,  09,  09
	; Bug bush

	; Small bush
	DRAW_DATA_BUSH2_ORIGINAL db 03, 0, 19, 140, 00001010b, "#", 03
	DRAW_DATA_BUSH2 db 03, 0, 19, 140, 00001010b, "#", 03
	X_DRAW_BUSH2 db                 00,  01,  02
	Y_BEGIN_DRAW_BUSH2 db         00,  00,  00
	TIMES_WRITE_Y_DRAW_BUSH2 db  06,  06,  06
	; Small bush

	; Bird
	DRAW_DATA_BIRD_ORIGINAL db 14, 0, 8, 80, 00001110b, "#", 14
	DRAW_DATA_BIRD db 14, 0, 8, 80, 00001110b, "#", 14
	X_DRAW_BIRD db                 00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13
	Y_BEGIN_DRAW_BIRD db         00,  00,  -1,  -2,  01,  -5,  -4,  -2,  -2,  -1,  00,  00,  00,  00
	TIMES_WRITE_Y_DRAW_BIRD db  01,  01,  02,  04,  01,  07,  07,  05,  05,  04,  02,  01,  01,  01
	; Bird

	; GAME OVER
	DRAW_DATA_GAMEOVER db 105, 0, 9, 05, 11001010b, " ", 0

	X_DRAW_GAMEOVER db                 00,  01,  02,02,  03,03,  04,04,  05,05,05,  06,06,  07,07,  08,  09,  10,  11,  12,12,  13,13,  14,14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27
							 db                  28,28,28,  29,29,29,  30,30,30,  31,31,  32,32,  33,  34,  35,  36,  37,  38,  39,  40,40,  41,41,  42,42,  43,43,  44,  45,  46, 47,  48,  49,  50,  51,  52,  53
							   db                      54,  55,  56,  57,57,57,  58,58,58,  59,59,59,  60,60,  61,61,  62,  63,  64,  65,65,  66,66,  67,67,  68,68,  69,69

	Y_BEGIN_DRAW_GAMEOVER db         02,  01,  00,05,  00,06,  00,06,  00,03,06,  00,03,  00,03,  01,  00,  02,  01,  00,04,  00,04,  00,04,  01,  02,  00,  00,  00,  01,  02,  01,  00,  00,  00,  00,  00
									 db          00,03,06,  00,03,06,  00,03,06,  00,06,  00,06,  00,  00,  00,  00,  00,  01,  00,  00,06,  00,06,  00,06,  00,06,  00,  01,  00,  00,  00,  03,  04,  03,  00,  00
									   db              00,  00,  00,  00,03,06,  00,03,06,  00,03,06,  00,06,  00,06,  00,  00,  00,  00,04,  00,04,  00,03,  00,05,  01,06

	TIMES_WRITE_Y_DRAW_GAMEOVER db  03,  05,  02,02,  01,01,  01,01,  01,01,01,  01,04,  01,04,  01,  00,  05,  06,  03,01,  02,01,  03,01,  06,  05,  00,  07,  07,  02,  02,  02,  07,  07,  00,  07,  07
										    db   01,01,01,  01,01,01,  01,01,01,  01,01,  01,01,  00,  00,  00,  00,  00,  05,  07,  01,01,  01,01,  01,01,  01,01,  07,  05,  00,  04,  05,  03,  03,  03,  05,  04
											  db       00,  07,  07,  01,01,01,  01,01,01,  01,01,01,  01,01,  01,01,  00,  07,  07,  01,01,  01,02,  01,04,  04,02,  03,01
	; GAME OVER

	; START
	DRAW_DATA_START db 55, 0, 08, 20, 10101100b, " ", 0

	X_DRAW_START db                 00,00,  01,01,  02,02,02,  03,03,03, 04,04,04,  05,05,  06,06,  07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17,17, 18,18, 19,19, 20, 21, 22, 23, 24
						   db                   25,25, 26,26, 27,27, 28,28, 29,29, 30, 31, 32, 33, 34, 35, 36

	Y_BEGIN_DRAW_START db         01,05,  00,05,  00,03,06,  00,03,06, 00,03,06,  00,03,  01,04,  00, 00, 00, 00, 00, 00, 00, 00, 02, 01, 00,04, 00,04, 00,04, 01, 02, 00, 00, 00
								  db           00,04, 00,04, 00,03, 00,05, 01,06, 00, 00, 00, 00, 00, 00, 00

	TIMES_WRITE_Y_DRAW_START db  02,01,  04,02,  01,01,01,  01,01,01, 01,01,01,  02,04,  01,02,  00, 02, 02, 07, 07, 02, 02, 00, 05, 06, 03,01, 02,01, 03,01, 06, 05, 00, 07, 07
										 db    01,01, 01,02, 01,04, 04,02, 03,01, 00, 02, 02, 07, 07, 02, 02
	; START

	; DINO GAME - unused
	DRAW_DATA_DINO_GAME db 91, 0, 15, 01

	X_DRAW_DINO_GAME db                 00,  01,  02,02,  03,03,  04,04,  05,05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,22,  23,23,  24,24,  25,25,  26,  27,  28,  29
							  db                    30,  31,  32,  33,  34,34,  35,35,  36,36,  37,37,37,  38,38,  39,39,  40,  41,  42,  43,  44,44,  45,45,  46,46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57
							    db                     58,  59,  60,60,60,  61,61,61,  62,62,62,  63,63,  64,64

	Y_BEGIN_DRAW_DINO_GAME db         00,   00,  00,06,  00,06,  00,06,  01,05,  02,  00,  00,  00,  00,  00,  00,  01,  02,  03,  04,  00,  00,  00,  01,  00,  00,06,  00,06,  00,06,  00,06,  00,  01,  00,  00
									  db            00,  00,  02,  01,  00,05,  00,06,  00,06,  00,03,06,  00,03,  00,03,  01,  00,  02,  01,  00,04,  00,04,  00,04,  01,  02,  00,  00,  00,  01,  02,  01,  00,  00,  00
									    db             00,  00,  00,03,06,  00,03,06,  00,03,06,  00,06,  00,06

	TIMES_WRITE_Y_DRAW_DINO_GAME db  07,  07,  01,01,  01,01,  01,01,  01,01,  03,  00,  07,  07,  00,  07,  07,  01,  01,  01,  01,  07,  07,  00,  05,  07,  01,01,  01,01,  01,01,  01,01,  07,  05,  00,  00
											 db     00,  00,  03,  05,  02,02,  01,01,  01,01,  01,01,01,  01,04,  01,04,  01,  00,  05,  06,  03,01,  02,01,  03,01,  06,  05,  00,  07,  07,  02,  02,  02,  07,  07,  00
											   db      07,  07,  01,01,01,  01,01,01,  01,01,01,  01,01,  01,01
	; DINO GAME - unused

	; Dinossaur (head) - but on the main menu
	DRAW_DATA_DINOSSAUR_MAIN_MENU db 36, 0, 16, 05, 10011111b, " ", 0
	X_DRAW_DINOSSAUR_MAIN_MENU db                 00,   01,  02,02,  03,03,  04,04,  05,05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,22,  23,23,  24,24,  25,25,  26,  27
	Y_BEGIN_DRAW_DINOSSAUR_MAIN_MENU db         00,   00,  00,06,  00,06,  00,06,  01,05,  02,  00,  00,  00,  00,  00,  00,  01,  02,  03,  04,  00,  00,  00,  01,  00,  00,06,  00,06,  00,06,  00,06,  00,  01
	TIMES_WRITE_Y_DRAW_DINOSSAUR_MAIN_MENU db  07,   07,  01,01,  01,01,  01,01,  01,01,  03,  00,  07,  07,  00,  07,  07,  01,  01,  01,  01,  07,  07,  00,  05,  07,  01,01,  01,01,  01,01,  01,01,  07,  05
	; Dinossaur (head) - but on the main menu

	; GAME
	DRAW_DATA_GAME db 51, 0, 10, 42, 10011111b, " ", 0

	X_DRAW_GAME db                 00,  01,  02,02,  03,03,  04,04,  05,05,05,  06,06,  07,07,  08,  09,  10,  11,  12,12,  13,13,  14,14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,28,28
						 db                    29,29,29,  30,30,30,  31,31,  32,32

	Y_BEGIN_DRAW_GAME db         02,  01,  00,05,  00,06,  00,06,  00,03,06,  00,03,  00,03,  01,  00,  02,  01,  00,04,  00,04,  00,04,  01,  02,  00,  00,  00,  01,  02,  01,  00,  00,  00,  00,  00,  00,03,06
								 db            00,03,06,  00,03,06,  00,06,  00,06

	TIMES_WRITE_Y_DRAW_GAME db  03,  05,  02,02,  01,01,  01,01,  01,01,01,  01,04,  01,04,  01,  00,  05,  06,  03,01,  02,01,  03,01,  06,  05,  00,  07,  07,  02,  02,  02,  07,  07,  00,  07,  07,  01,01,01
										db     01,01,01,  01,01,01,  01,01,  01,01
	; GAME


	; Drawing arrays
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; PROCEDURES

	JUMP_DATA_DINOSSAUR_ORIGINAL db 0, 0, 0, 0
	JUMP_DATA_DINOSSAUR db 0, 0, 0, 0

	DRAW_ERASE_FIGURE_data dw 0000h, 0000h, 0000h, 0000h, 0;, "#", 00001111b

	ADVANCE_SCENERARIO_data_vector_positions_x_random dw 1055, 0
	ADVANCE_SCENERARIO_positions_x_random db 172, 104,  95, 182, 126,  97,  96, 203, 152, 149,  80, 139, 122, 157, 209, 158, 249, 163, 237, 109, 194, 181,  98, 125, 153, 193, 120, 251, 189, 255, 226, 222, 179, 202, 112, 252, 228, 148, 200, 254, 239, 178,  85, 135, 171
										  db 210, 121, 211, 205,  92, 102, 188, 216, 165, 246,  89, 204,  88, 197, 115, 142, 111, 234, 105, 133, 207, 177, 156, 150, 187, 151, 247, 123, 119,  86, 108, 170, 143,  81, 128, 176, 236, 218, 232, 175, 103, 227, 223, 248, 230, 214
										  db 199, 124, 106, 217, 131, 241, 213, 174, 117, 107, 186, 136, 183, 225, 167, 191, 140,  90, 215, 113, 118, 184, 116, 220,  84,  82, 137, 160, 253,  91, 180, 212, 147, 130,  93, 155, 196, 192, 233,  94,  83, 243, 166, 132, 161, 129
										  db 221, 159, 145, 154, 185, 162, 146, 195, 250, 127, 169, 168, 110, 231, 198, 134,  99, 238, 206, 245, 240, 219, 138, 208, 100, 190, 144, 224, 244, 201, 173, 235, 141, 229,  87, 164, 114, 101, 242, 172, 160, 181, 191, 244, 115, 234
										  db 206,  90,  95, 130, 123, 143, 246, 103, 229, 194, 254, 161, 134, 214, 138, 226, 222, 245, 117, 135, 232, 133, 165, 184,  88, 240, 235, 162, 182, 231, 127, 237, 210, 152, 220, 252, 171, 215, 144, 241, 247, 251, 175, 196,  96, 159
										  db 86,  208, 190, 198, 225, 174, 238, 255, 148, 120, 118, 216, 147, 239, 164, 186, 122, 156,  99, 155, 178, 207, 157, 223, 145, 150, 183, 132, 221, 106,  94, 200, 129, 109, 121, 179, 248, 195, 108,  83, 211, 253, 219,  91, 205,  89
										  db 202, 158,  80, 199, 169,  81, 151, 153, 176, 110, 224,  92, 213, 188, 124, 173,  97, 189, 209, 243, 185, 204, 116, 249, 154, 227, 107, 168, 140, 136, 228, 131, 166,  87, 218, 236, 142, 217, 170,  93, 119, 163, 114, 187, 146, 201
										  db 212, 100, 192, 177, 137, 233, 126, 180, 105, 112, 128, 104, 193, 167, 102, 125,  84, 111, 139, 203, 250,  85, 230,  82, 113,  98, 141, 197, 101, 149, 177, 205, 160, 179, 248, 255, 209,  87, 118, 236, 194, 207, 201, 170, 138, 123
										  db 133, 221, 152, 119, 182, 229, 115, 157, 159, 245, 185, 193, 144, 217, 214, 134, 204, 113, 234, 156, 249, 117, 188, 184,  84, 222, 235, 112, 104, 243, 158,  89, 246, 150, 226, 242, 253, 165, 190, 108, 146, 186, 101, 254, 141, 191
										  db 147, 228, 181, 213, 251, 163, 128, 225, 239, 208, 211, 137, 145, 110, 187, 241, 206, 130, 196, 216, 240, 126, 149, 197, 143, 106, 161,  90, 199,  96, 135,  97, 148, 231, 136,  86, 250, 127, 154, 167, 153, 233, 218,  98, 223, 219
										  db 238, 155, 100, 227,  94,  82, 173,  83, 200,  93, 120, 131, 107, 198,  85, 224,  88, 116, 168, 109, 210, 175, 237, 124, 111, 169, 139, 232, 171, 166, 176, 183, 230, 162,  95, 129, 140, 164, 189,  80, 247, 195, 121, 172, 151, 174
										  db 180, 192, 103, 125, 132,  92, 203,  99, 202, 105, 122,  81, 244, 178, 252, 142, 102, 215, 220, 212, 114,  91,  97, 206, 252, 141, 177, 179, 205, 248, 154, 229, 183, 225, 186, 112,  81, 171, 219, 153, 201, 166, 122, 223, 181, 106
										  db 129, 218, 109, 176, 189, 208, 145, 149, 168, 134, 237, 182, 167, 231, 175, 151,  84, 180, 142, 190,  82, 212, 158, 140, 105, 191, 195,  86, 118, 104, 246, 245, 157, 188, 100, 170, 102, 146,  98, 222,  91, 120, 136, 244, 164, 243
										  db 148,  87,  95, 240, 119, 194, 235, 228, 200, 117, 174, 202,  96, 253, 165, 234,  85, 172, 178, 161,  83, 111, 185,  94, 192, 230, 220, 135, 204, 247, 159,  80, 249,  88, 187, 196, 143, 251, 131, 101,  93, 173, 236, 147, 139, 241
										  db 90,  116, 113, 193, 215, 216, 125, 239, 133, 108, 217, 184, 127, 138, 110, 211, 160, 103, 238, 114, 107,  92, 121, 221, 132, 156,  99, 162, 232, 214, 169, 203, 255, 163, 155, 198, 199,  89, 137, 123, 209, 233, 130, 213, 254, 152
										  db 227, 150, 224, 250, 128, 207, 124, 144, 126, 242, 115, 226, 210, 197, 222, 102, 221, 200, 198, 224, 121, 244, 181, 133, 164, 241, 252, 243, 255, 127, 151, 140,  81, 191, 118,  98, 138,  82, 215, 225, 150, 188, 249, 220, 120, 174
										  db 160, 167, 245, 185, 149, 106, 227, 111,  84, 187, 210, 155, 240, 178, 157, 152, 144, 122, 168,  93, 248, 199, 175, 238, 107, 226, 192, 203, 163,  96, 208, 137, 179, 139, 236, 216, 124,  86, 158,  89, 104,  91, 205, 197, 156, 129
										  db 126,  88, 100, 108, 228, 172,  99, 143, 195, 109, 113,  92, 209, 234, 239, 206, 134, 162, 154, 207, 161, 183, 146, 201, 153, 141, 119, 204, 233, 148, 186, 223, 214,  85,  90, 232, 235,  95, 132,  97, 182, 242, 230, 114, 131, 237
										  db 101, 211, 105, 184, 128, 253, 247, 171, 250, 219, 246, 136, 218, 194, 116, 212, 229, 173, 103, 112, 254,  87, 176, 110, 142, 169, 177, 159, 147, 130,  83, 231, 117, 193,  94, 202, 251, 123, 213, 135,  80, 115, 125, 180, 145, 217
										  db 170, 166, 189, 165, 190, 196, 249, 142, 141, 214, 220, 106, 189,  97, 116, 105, 158, 204, 111, 229,  88, 170,  83, 153,  89,  81, 155, 184,  95, 195, 212, 104,  80, 165, 183, 231, 129, 143, 242, 245, 110, 117, 182, 166, 145, 124
										  db 235, 251, 177, 186, 178, 223, 132,  85, 221,  86, 199, 248, 252,  82, 238, 222,  98, 224, 208, 176, 144, 205, 255, 109, 226, 171, 190, 202, 188, 239,  84,  93, 115, 228,  92, 173, 151, 118, 254, 128, 119, 157, 137, 227, 139, 101
										  db 253, 172, 219, 156, 209, 232, 185, 121, 194, 206, 169, 187, 179,  96, 135, 152, 180, 244, 241, 103, 149, 233, 213,  90, 225, 198, 247, 114, 211, 136, 250,  87, 150, 127, 203, 174, 207, 191, 146, 216, 100,  91, 167, 246, 162, 201
										  db 161, 125, 130, 147, 107, 120, 134, 196, 236, 138, 113, 181, 234, 131, 164, 218, 133, 175, 243, 192, 168, 154, 112, 126,  99, 200, 163, 197, 122, 123, 160, 102, 217, 140, 215, 210, 237, 230, 148, 108,  94, 159, 240, 193

	;ADVANCE_SCENERARIO_positions_x_random db 80, 80, 80, 140, 240, 80, 240, 140, 140, 140, 80, 80, 240, 80, 140, 140, 250, 140, 250, 80, 80, 80, 250, 140, 240, 140, 80, 140, 240, 140, 140, 140, 240, 80, 250, 80, 250, 140, 140, 250, 250, 80, 80, 140, 80, 80, 80, 140
	;ADVANCE_SCENERARIO_positions_x_random_cont db 250, 250, 80, 80, 250, 140, 80, 250, 80, 240, 240, 240, 240, 80, 240, 80, 140, 250, 240, 140, 250, 250, 140, 250, 250, 250, 140, 240, 240, 250, 240, 80, 140, 240, 240, 80, 80, 240, 250, 140, 80, 250, 240, 250, 240, 80, 240, 80
	;ADVANCE_SCENERARIO_positions_x_random_cont_2 db 250, 140, 80, 250

	MAIN_MENU_begin_game db "1 - Being game", "$"
	MAIN_MENU_instructions db "$";"2 - Instructions", "$"
	MAIN_MENU_exit db "3 - Exit", "$"

	; PROCEDURES
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	SCORE_STR db "Score: ", "$"
	SCORE dw 0, 0, 0

	sb16_environment db "A220 I7 D1 H5 T6", 0

.code
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; MACROS

	LOAD_FIGURE_FUNCTION macro vector1, vector2, vector3, vector4

		push bp
		mov bp, sp

		;push ax
		push bx
		;push cx
		;push dx
		;push si
		;push di

		lea bx, vector1
		mov DRAW_ERASE_FIGURE_data[2*0], bx
		lea bx, vector2
		mov DRAW_ERASE_FIGURE_data[2*1], bx
		lea bx, vector3
		mov DRAW_ERASE_FIGURE_data[2*2], bx
		lea bx, vector4
		mov DRAW_ERASE_FIGURE_data[2*3], bx

		;pop di
		;pop si
		;pop dx
		;pop cx
		pop bx
		;pop ax

		mov sp, bp
		pop bp

	endm

	CLEAR_SCREAN macro

		push bp
		mov bp, sp

		push ax
		;push bx
		;push cx
		;push dx
		;push si
		;push di

		; To clear the screen, all there is to do is reset the video mode.

		; set video mode
		mov ah, 0     ; ou mov ah, 0 (para por tudo a zeros e depois change a parte inferior)
		mov al, 03h   ; text mode 80x25, 16 colors, 8 pages (ah=0, al=3)
		int 10h       ; do it!

		;pop di
		;pop si
		;pop dx
		;pop cx
		;pop bx
		pop ax

		mov sp, bp
		pop bp

	endm

	COPY_ARRAY macro source, destination, length

		LOCAL COPY_ARRAY_loop1

		push bp
		mov bp, sp

		push ax
		push bx
		;push cx
		push dx
		push si
		;push di

		mov si, 1
		COPY_ARRAY_loop1:
			lea bx, source
			mov dl, byte ptr [bx+si-1]
			lea bx, destination
			mov byte ptr [bx+si-1], dl

			inc si

			cmp si, length
			jne COPY_ARRAY_loop1

		;pop di
		pop si
		pop dx
		;pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

	endm

	SUM_32BIT macro
		; To sum a number in DX:AX and another one in CX:BX.

		; The add instruction adds the two values and sets the C (carry) bit to 1 or 0 depending on whether there was a carry or not.
		; The adc instruction adds the two values plus the value of the carry bit (and then sets the carry bit again).
		; In this way, you can add values of any size by continuing with more adc instructions.

		; Add the least significant bytes first, keep the carry. Add the most significant bytes considering the carry from LSBs.

		add ax, bx
		adc dx, cx

	endm

	; MACROS
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	START:

	mov ax, @data
	mov ds, ax

	; We used direct writing to the memory because it's faster than asking BIOS to write on the screen
	;mov ax, 0A000h ; Endereço da placa VGA no modo gráfico
	mov ax, 0B800h ; Endereço da placa VGA no modo de texto
	mov es, ax

	; set video mode
	mov ah, 0     ; or mov ah, 0 (to put all to zeroes and then change the inferior part)
	mov al, 03h   ; text mode 80x25, 16 colors, 8 pages (ah=0, al=3)
	int 10h       ; do it!

	; cancel blinking and enable all 16 colors:
	mov ah, 10h
	mov al, 03h
	mov bx, 0
	int 10h

	; Prepare the speakers
	mov ax, 10110110b
	out 43h, ax

	; Prepare Sound Blaster 16
	; Note: the string came from executing the command "set blaster" on DOSBox
	mov bx, 2
	mov dx, ds
	lea ax, sb16_environment
	call driver:ctmidi_drv

	; Initialize Sound Blaster 16
	mov bx, 3
	call driver:ctmidi_drv

	jmp MAIN_MENU

	;jmp end

	begin_game:

	CLEAR_SCREAN

	LOAD_FIGURE_FUNCTION DRAW_DATA_START X_DRAW_START Y_BEGIN_DRAW_START TIMES_WRITE_Y_DRAW_START
	mov ax, 0
	mov dl, 0
	call DRAW_ERASE_FIGURE_MAIN

	mov cx, 0020h
	mov dx, 0000h
	mov ah, 86h
	int 15h

	LOAD_FIGURE_FUNCTION DRAW_DATA_START X_DRAW_START Y_BEGIN_DRAW_START TIMES_WRITE_Y_DRAW_START
	mov ax, 0
	mov dl, 1
	call DRAW_ERASE_FIGURE_MAIN

	mov ah, 02h
	mov dh, 1
	mov dl, 60
	mov bh, 0
	int 10h

	mov ah, 09h
	lea dx, SCORE_STR
	int 21h

	; Activate the columns
	;in ax, 61h
	;or ax, 00000011b
	;out 61h, ax

	; Give the song to Sound Blaster 16 for it to be pre-processes (for some reason, it has to be pre-processed again
	; after the stop, even though we haven't seen that in the documentation, but ok).
	; Note: both the string and the driver were included through a program called bin2db, version 3.
	; This is EXACTLY equivalent to opening the file (either the MID or the DRV) with HxD (or any other hexadecimal
	; editor) and copy/paste everything to byte declarations. Just the program does that automatically, which is
	; infinitely easier and faster. NASM seems to have incbine, but MASM doesn't, and this is a solution.
	; Another solution is to use MASM to generate an OBJ file and then link it to the final program, but we don't know
	; how to do that (we think MASM will throw an error when it doesn't know where the labels come from, so there's some
	; way to that which we don't know about).
	mov bx, 8
	mov dx, songs_midi
	lea ax, queen_i_want_to_break_free
	call driver:ctmidi_drv

	; Play the song
	mov bx, 9
	call driver:ctmidi_drv

	loop_principal_novo:

		call DETECT_KEY

		loop_principal_novo_continue:

		; This is to put the BIOS stopping the program during the microseconds on CX:DX (32 bit number).
		mov cx, 0000h
		mov dx, 20E8h
		;mov dx, 80E8h ; --> 30 FPS
		;mov dx, 411Ah ; --> 60 FPS
		mov ah, 86h
		int 15h

		LOAD_FIGURE_FUNCTION DRAW_DATA_DINOSSAUR X_DRAW_DINOSSAUR Y_BEGIN_DRAW_DINOSSAUR TIMES_WRITE_Y_DRAW_DINOSSAUR
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN

		call ADVANCE_SCENARIO

		call JUMP

		call PRINT_SCORE

		jmp loop_principal_novo



	mov ah, 07h
	int 21h


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Return to the operating system - end of the program
	FIM:

	; Disable Sound Blaster 16
	mov bx, 4
	call driver:ctmidi_drv

	CLEAR_SCREAN

	mov al, 0   ; Return code of 0
	mov ah, 4Ch ; Exit back to MS/PCDOS
	int 21h

	; Return to the operating system - end of the program
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; PROCEDURES

	MAIN_MENU:

		CLEAR_SCREAN

		; Load the figure's drawing vectors to the vector of drawing data of the DRAW_ERASE_FIGURE function.
		LOAD_FIGURE_FUNCTION DRAW_DATA_DINOSSAUR X_DRAW_DINOSSAUR Y_BEGIN_DRAW_DINOSSAUR TIMES_WRITE_Y_DRAW_DINOSSAUR
		; Copy the data from the original vetor back to the vector in use. Which means, reset the positions to the
		; original ones of game. It's useful this is here too, because after a game, the values must be all reset.
		COPY_ARRAY DRAW_DATA_DINO_ORIGINAL DRAW_DATA_DINOSSAUR 6
		; Change the position of the figure
		lea bx, DRAW_DATA_DINOSSAUR
		mov byte ptr [bx+2], 5
		mov byte ptr [bx+3], 20
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN
		COPY_ARRAY DRAW_DATA_DINO_ORIGINAL DRAW_DATA_DINOSSAUR 6
		COPY_ARRAY JUMP_DATA_DINOSSAUR_ORIGINAL JUMP_DATA_DINOSSAUR 4

		LOAD_FIGURE_FUNCTION DRAW_DATA_BUSH1 X_DRAW_BUSH1 Y_BEGIN_DRAW_BUSH1 TIMES_WRITE_Y_DRAW_BUSH1
		COPY_ARRAY DRAW_DATA_BUSH1_ORIGINAL DRAW_DATA_BUSH1 6
		lea bx, DRAW_DATA_BUSH1
		mov byte ptr [bx+2], 5
		mov byte ptr [bx+3], 5
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN
		COPY_ARRAY DRAW_DATA_BUSH1_ORIGINAL DRAW_DATA_BUSH1 6

		LOAD_FIGURE_FUNCTION DRAW_DATA_BUSH2 X_DRAW_BUSH2 Y_BEGIN_DRAW_BUSH2 TIMES_WRITE_Y_DRAW_BUSH2
		COPY_ARRAY DRAW_DATA_BUSH2_ORIGINAL DRAW_DATA_BUSH2 6
		lea bx, DRAW_DATA_BUSH2
		mov byte ptr [bx+2], 8
		mov byte ptr [bx+3], 35
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN
		COPY_ARRAY DRAW_DATA_BUSH2_ORIGINAL DRAW_DATA_BUSH2 6

		LOAD_FIGURE_FUNCTION DRAW_DATA_BIRD X_DRAW_BIRD Y_BEGIN_DRAW_BIRD TIMES_WRITE_Y_DRAW_BIRD
		COPY_ARRAY DRAW_DATA_BIRD_ORIGINAL DRAW_DATA_BIRD 6
		lea bx, DRAW_DATA_BIRD
		mov byte ptr [bx+2], 6
		mov byte ptr [bx+3], 60
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN
		COPY_ARRAY DRAW_DATA_BIRD_ORIGINAL DRAW_DATA_BIRD 6

		LOAD_FIGURE_FUNCTION DRAW_DATA_DINOSSAUR_MAIN_MENU X_DRAW_DINOSSAUR_MAIN_MENU Y_BEGIN_DRAW_DINOSSAUR_MAIN_MENU TIMES_WRITE_Y_DRAW_DINOSSAUR_MAIN_MENU
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN

		LOAD_FIGURE_FUNCTION DRAW_DATA_GAME X_DRAW_GAME Y_BEGIN_DRAW_GAME TIMES_WRITE_Y_DRAW_GAME
		mov ax, 0
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN


		mov ah, 02h
		mov dh, 19
		mov dl, 45
		mov bh, 0
		int 10h

		mov ah, 09h
		lea dx, MAIN_MENU_begin_game
		int 21h


		mov ah, 02h
		mov dh, 21
		mov dl, 45
		mov bh, 0
		int 10h

		mov ah, 09h
		lea dx, MAIN_MENU_instructions
		int 21h


		mov ah, 02h
		mov dh, 23
		mov dl, 45
		mov bh, 0
		int 10h

		mov ah, 09h
		lea dx, MAIN_MENU_exit
		int 21h

		call DETECT_KEY

		mov ah, 07h
		int 21h

		cmp al, "1"
		je begin_game
		cmp al, "3"
		je FIM

		jmp MAIN_MENU

	GAME_OVER:
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This "function" ends the game, printing GAME OVER in the center of the screen. Before getting back to the main
		; menu, it waits for the user to press any key.

		; NOTE: this "function" must not be called. It must be jumped to. The reason of this is written on the collision
		; detection, and because of that, this "function" doesn't return. It jumps directly to another place (main menu).

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		; Disable the speakers
		;in ax, 61h
		;and ax, 11111100b
		;out 61h, ax

		LOAD_FIGURE_FUNCTION DRAW_DATA_GAMEOVER X_DRAW_GAMEOVER Y_BEGIN_DRAW_GAMEOVER TIMES_WRITE_Y_DRAW_GAMEOVER
		call DRAW_ERASE_FIGURE

		; Stop the song
		mov bx, 10
		call driver:ctmidi_drv

		mov ah, 07h
		int 21h

		jmp MAIN_MENU

	PRINT_SCORE proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function prints the current user score.

		;;;;;;;;;;;;;;;;;;;;
		; Needed arrays
		;SCORE dw 0, 0, 0
		; Format:
		;	- Upper score 16 bits (leave on 0 - the function will take care of increasing it);
		;	- Lower score 16 bits (leave on 0 - the function will take care of increasing it);
		;	- Number to slow down the score count (leave on 0 - the function changes the number on its own).
		; Needed arrays
		;;;;;;;;;;;;;;;;;;;;

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		push ax
		push bx
		push cx
		push dx
		;push si
		;push di

		; This is just to not count so fast. This way, it was decreased to half the speed
		lea bx, SCORE
		cmp word ptr [bx+2*2], 0
		jne PRINT_SCORE_end

		; Put the cursor always in the same position before beginning writting the number
		mov ah, 02h
		mov dh, 1
		mov dl, 68
		mov bh, 0
		int 10h

		; Get the number from the SCORE vector, sum 1 and keep the result in the vector
		lea bx, SCORE
		mov dx, word ptr [bx+2*0]
		mov ax, word ptr [bx+2*1]
		mov cx, 0
		mov bx, 1
		SUM_32BIT
		lea bx, SCORE
		mov word ptr [bx+2*0], dx
		mov word ptr [bx+2*1], ax

		; Display the current score
		call PRINT_NUM_UNSIGNED

		PRINT_SCORE_end:

		; This instruction is part of the slow down of the score count
		NOT word ptr [bx+2*2]

		;pop di
		;pop si
		pop dx
		pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

		ret

	PRINT_SCORE endp

	PRINT_NUM_UNSIGNED proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; Main note: This function was copied from somewhere and wasn't completely understood. Though, it was enough to
		; to be changed and improved to not throw error of overflow.

		; The unsigned number to print must be in DX:AX.
		; NOTE: the highest number DX:AX is 9FFFFh, which means 65359 in decimal. As of that number, the function will
		; keep printing 65359 until the registers have a value below that maximum.

		; Explanation of the above: the division divides the number in DX:AX by the number in BX and keeps the result
		; of the division in AX, and the rest of the devision in DX. So, the number resulting from the division must
		; be inside 16 bits. If it does not, an overflow error will be thrown ("Divide overflow").
		; 9FFFFh / 10 = 0FFFFh, which is the maximum in 16 bit. Which means, this is dependent of the number we are
		; dividing.

		; This divides the number in 10 and prints each digit that resulted from the division (for example, 1234 / 10,
		; prints 4; 123 / 10 and prints 3...).

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		push ax
		push bx
		push cx
		push dx
		;push si
		;push di

		; This is the improvement to not throw overflow on the program. If DX has 10 or above there, no matter the
		; contents of AX, the division will result in a 9 bits number --> overflow error.
		cmp dx, 10
		jl PRINT_NUM_UNSIGNED_continue
		; So when that happens, it stays on the same number. At least until it's given to the function a number with
		; DX below 10.
		mov ax, 0FFFFh
		mov dx, 09h

		PRINT_NUM_UNSIGNED_continue:

		mov cx, 0
		;mov dx, 0 --> We think this is here because it's not normal to print 32 bits numbers? So now it's commented out.
		; Read the updated description of the function.
		PRINT_NUM_UNSIGNED_label1:
			cmp ax, 0
			je PRINT_NUM_UNSIGNED_print1

			; Base on which print the number (in this case it's base 10 - decimal -, so it's 10, but we wanted in
			; hexadecimal, it would be 16 here, which would work too).
			mov bx, 10

			div bx

			push dx

			inc cx

			xor dx, dx
			jmp PRINT_NUM_UNSIGNED_label1

		PRINT_NUM_UNSIGNED_print1:
			cmp cx, 0
			je PRINT_NUM_UNSIGNED_exit

			pop dx

			add dx, 48 ; Add the number of characters to pass from real number to string number (equivalent to add dx, "0").

			; Print the string number
			mov ah, 02h
			int 21h

			dec cx
			jmp PRINT_NUM_UNSIGNED_print1

		PRINT_NUM_UNSIGNED_exit:

		;pop di
		;pop si
		pop dx
		pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

		ret

	PRINT_NUM_UNSIGNED endp

	ADVANCE_SCENARIO proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function advanced the scenario a character at a time, at each function call. When one of the objects
		; disappears completely from the screen, the function puts the object back in a position much ahead, defined
		; through an array of positions automatically generated externally by a website.
		; We tried putting the game generating random numbers, but as the function was always called in the same period
		; of time (the game doesn't request to insert anything coming from human control), nothing would stay random.
		; So we generated random numbers on the Internet and put them in vectors.
		; The vector has 1055 positions (separated in various because MASM doesn't allow too big instructions - "too
		; complex instruction"), and with numbers actually random between 80 (minimum of the window) and 255 (8 bit
		; maximum to interruption 10h, at least in case it's to be used again).

		;;;;;;;;;;;;;;;;;;;;
		; Needed arrays
		;ADVANCE_SCENERARIO_data_vector_positions_x_random dw 1055, 0
		; Format: length of the random x positions vector; current index of iterating the vector (always leave on 0 -
		; this value is changed by the function).
		;ADVANCE_SCENERARIO_positions_x_random db 172, 104,  95, 182, 126,  97,  96, 203, 152, 149,  80, 139, 122, 157, 209, 158, 249, 163, 237, 109, 194, 181,  98, 125, 153, 193, 120, 251, 189, 255, 226, 222, 179, 202, 112, 252, 228, 148, 200, 254, 239, 178,  85, 135, 171
		; Format: in each index of the array, put a random position generated between 80 and 255. Separate in various
		; arrays if necessary, and leave the declarations one after another.
		;DRAW_DATA_BUSH1 db [ignorado], [ignorado], [ignorado], 200, [ignorado], 03
		; Format:
		;	- [See on the function DRAW_ERASE_FIGURE];
		;	- [See on the function DRAW_ERASE_FIGURE];
		;	- [See on the function DRAW_ERASE_FIGURE];
		;	- [See on the function DRAW_ERASE_FIGURE];
		;	- [See on the function DRAW_ERASE_FIGURE];
		;	- Maximum width of the object (look for the biggest line of the object and count the number of characters on
		;     that line);
		; Needed arrays
		;;;;;;;;;;;;;;;;;;;;

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		push ax
		push bx
		push cx
		push dx
		push si
		push di

		; Here the x position is summed with the maximum object width. If it results in 0, then it just disappeard
		; completely from the screen.
		; In that case, call the part of the function that changes the x position of the object. Otherwise, keep
		; advancing the scenario normally.

		mov al, byte ptr DRAW_DATA_BIRD[3]
		add al, byte ptr DRAW_DATA_BIRD[6]
		cmp al, 0
		jne ADVANCE_SCENARIO_continue1
		lea di, DRAW_DATA_BIRD
		call ADVANCE_SCENARIO_change_x
		ADVANCE_SCENARIO_continue1:

		mov al, byte ptr DRAW_DATA_BUSH1[3]
		add al, byte ptr DRAW_DATA_BUSH1[6]
		cmp al, 0
		jne ADVANCE_SCENARIO_continue2
		lea di, DRAW_DATA_BUSH1
		call ADVANCE_SCENARIO_change_x
		ADVANCE_SCENARIO_continue2:

		mov al, byte ptr DRAW_DATA_BUSH2[3]
		add al, byte ptr DRAW_DATA_BUSH2[6]
		cmp al, 0
		jne ADVANCE_SCENARIO_continue3
		lea di, DRAW_DATA_BUSH2
		call ADVANCE_SCENARIO_change_x
		ADVANCE_SCENARIO_continue3:

		; Here is the part of the function where the scenario is advanced a character to the right.

		LOAD_FIGURE_FUNCTION DRAW_DATA_BUSH1 X_DRAW_BUSH1 Y_BEGIN_DRAW_BUSH1 TIMES_WRITE_Y_DRAW_BUSH1
		mov ax, 0
		mov al, -1
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN

		LOAD_FIGURE_FUNCTION DRAW_DATA_BUSH2 X_DRAW_BUSH2 Y_BEGIN_DRAW_BUSH2 TIMES_WRITE_Y_DRAW_BUSH2
		mov ax, 0
		mov al, -1
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN

		LOAD_FIGURE_FUNCTION DRAW_DATA_BIRD X_DRAW_BIRD Y_BEGIN_DRAW_BIRD TIMES_WRITE_Y_DRAW_BIRD
		mov ax, 0
		mov al, -1
		mov dl, 0
		call DRAW_ERASE_FIGURE_MAIN

		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

		ret

		ADVANCE_SCENARIO_change_x:
			; This is to be used not with a jump but with a call. A call can be used with any label.
			; That stores the IP on stack, makes a jump, and the Return removes the IP from the stack and jumps there.
			; So it's not exclusive to procedures.

			; This part of the function changes the x position of each object in the following way:
			; - Gets the index of random positions vector iteration;
			; - Uses that index to go get the position to put on the object;
			; - Before it's set, checks if other objects are in an internal defined between its position and the position
			;   gotten from the random positions vetor;
			; - In case any object is inside that interval, goes to the next position on the vector;
			; - In case no object is inside that interval, that position is picked, the index of the vetor iteration is
			;   incremented, and the label returns to where it was called.

			lea bx, ADVANCE_SCENERARIO_data_vector_positions_x_random
			mov cx, word ptr [bx+2*0]
			ADVANCE_SCENARIO_loop1:
				;lea bx, ADVANCE_SCENERARIO_data_vector_positions_x_random --> This is in the end, so it's not needed
				; This checks if it's gotten already to the end of the vector. If that's true, reset the counter to 0.
				mov ax, word ptr [bx+2*1]
				cmp ax, word ptr [bx+2*0]
				je ADVANCE_SCENARIO_repor_contagem_pos_aleat
				ADVANCE_SCENARIO_loop1_continue:
				mov si, ax
				lea bx, ADVANCE_SCENERARIO_positions_x_random
				xor ah, ah
				mov al, byte ptr [bx+si]
				mov si, ax ; The gotten position remains permanently on AX register, whilst SI is used to calculate if
				           ; the object is in the interval or not.
						   ; Got like that because below we need an 8 bit register.

				lea bx, DRAW_DATA_BIRD
				mov si, ax ; Put AX back in SI
				xor dh, dh ; Equivalent to mov dh, 0
				mov dl, byte ptr [bx+3] ; Put in DL, the position x of the bird
				sub si, dx ; Subtracts DX to SI - this checks if the object is in an interval of, in this case, 25
				           ; characters until the position gotten from the random positions vector.
				call ADVANCE_SCENARIO_abs ; If the value is negative (depends where the objects are), call the absolute
				                          ; value of the fuction
				cmp si, 25 ; Here is the number of characters interval
				jle ADVANCE_SCENARIO_loop1_end ; If it's up to 25 characters at most, go to the next value of the vector

				lea bx, DRAW_DATA_BUSH1
				mov si, ax
				xor dh, dh
				mov dl, byte ptr [bx+3]
				sub si, dx
				call ADVANCE_SCENARIO_abs
				cmp si, 55
				jle ADVANCE_SCENARIO_loop1_end

				lea bx, DRAW_DATA_BUSH2
				mov si, ax
				xor dh, dh
				mov dl, byte ptr [bx+3]
				sub si, dx
				call ADVANCE_SCENARIO_abs
				cmp si, 45
				jle ADVANCE_SCENARIO_loop1_end

				mov bx, di ; Here the address stored on the main part of the function is reset (the address of the
				           ; object currently being analysed).
				mov byte ptr [bx+3], al ; The chosen position of the vector is put on the vector of figure data in the
				                        ; index of position x.

				; Here the current iteration index of the random positions vector is incremented.
				lea bx, ADVANCE_SCENERARIO_data_vector_positions_x_random
				inc word ptr [bx+2*1]
				ret ; And returnes to where this part of the function was called.

				ADVANCE_SCENARIO_loop1_end:

				lea bx, ADVANCE_SCENERARIO_data_vector_positions_x_random
				inc word ptr [bx+2*1]

				;loop ADVANCE_SCENARIO_loop1 --> disabled by the same reason that on the function DRAW_ERASE_FIGURE.
				dec cx
				jnz ADVANCE_SCENARIO_loop1

			; It won't get here, supposedly, but it's just in case it does, to get back
			ret

			ADVANCE_SCENARIO_repor_contagem_pos_aleat:
				mov word ptr [bx+2*1], 0
				jmp ADVANCE_SCENARIO_loop1_continue

			ADVANCE_SCENARIO_abs:
				; This is to be used not as a jump but as a call.

				; This part of the function calculates the absolute value of a number. First it stores it in another
				; register, and then applies of the Complement of Two.
				; If after that, the number is negative, return the stored value in the other register. If it's positive,
				; return the new value instead.
				; Note: the Complement of Two is the Complement of One adding 1 (which means negate all bits and add 1
				; to the result).
				mov dx, si ;store eax in ebx
				neg si
				jge ADVANCE_SCENARIO_abs_end
				mov si, dx ;if eax is now negative, restore its saved value

				ADVANCE_SCENARIO_abs_end:
				ret


	ADVANCE_SCENARIO endp

	JUMP proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function puts the dinossaur jumping a square each time it's called. Aside from that, it tries to simulate
		; the gravity, which means, when the dinossaur is finishing the climb, it starts slowing down, and when it
		; starts falling, it starts accelerating.

		;;;;;;;;;;;;;;;;;;;;
		; Needed arrays
		;JUMP_DATA_DINOSSAUR db 0, 0, 0, 0
		; Format:
		;	- Is the dinossaur jumping? 1 if yet, 0 if not;
		;	- If yet, is it going up (0) or down (1)?;
		;	- Number of coordinates already added to jump;
		;	- Number of function calls ignored because of the gravity.
		; Leave all on 0. The function changes the values automatically, except the first one which must be put to 1
		; before calling the function to start the jump.
		; Needed arrays
		;;;;;;;;;;;;;;;;;;;;

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		push ax
		push bx
		;push cx
		;push dx
		;push si
		;push di

		lea bx, JUMP_DATA_DINOSSAUR

		; Check if it's to put the dinossaur jumping or not
		cmp byte ptr [bx+0], 1
		jne JUMP_end

		; Call the gravity simulator and, if a 1 comes on AX, ignore the function call and jump directly to the end. Ou
		; carry on, in case AX is 0.
		call GRAVITY_SIMULATION_JUMP
		cmp ax, 1
		je JUMP_end

		LOAD_FIGURE_FUNCTION DRAW_DATA_DINOSSAUR X_DRAW_DINOSSAUR Y_BEGIN_DRAW_DINOSSAUR TIMES_WRITE_Y_DRAW_DINOSSAUR

		; Check if the dinossaur is rising or falling.
		mov al, byte ptr [bx+1]
		cmp byte ptr [bx+1], 0
		je JUMP_subida
		jne JUMP_descida

		JUMP_subida:
			; Check if it's already in the maximum height defined below
			cmp byte ptr [bx+2], 16
			jl JUMP_subida_cont1
			; If it is, put int the array information of being to initiate the fall in the next function call
			mov byte ptr [bx+1], 1
			jmp JUMP_descida
			JUMP_subida_cont1:
			; Put AL to 0 and AH to -1 to decrement 1 to the current y coordinate of the dinossaur
			xor al, al
			mov ah, -1
			mov dl, 0
			call DRAW_ERASE_FIGURE_MAIN

			; Increment the number of coordinates already added
			inc byte ptr [bx+2]

			jmp JUMP_end

		JUMP_descida:
			; Check if it's gotten to the height it starts
			cmp byte ptr [bx+2], 0
			jg JUMP_descida_cont1
			; If it has, put information in the array that is to start the rise in the next function call and also
			; information to stop the jump.
			mov byte ptr [bx+1], 0
			mov byte ptr [bx+0], 0
			jmp JUMP_end
			JUMP_descida_cont1:
			; Put AL to 0 and AH to -1 to increment 1 to the current y coordinate of the dinossaur
			xor al, al
			mov ah, 1
			mov dl, 0
			call DRAW_ERASE_FIGURE_MAIN

			; Decrement the number of coordinates already added
			dec byte ptr [bx+2]

			jmp JUMP_end

		JUMP_end:

		;pop di
		;pop si
		;pop dx
		;pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

		ret

	JUMP endp

	GRAVITY_SIMULATION_JUMP proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function is supposed to be used only by the JUMP function.
		; It simulates the gravity and tells the JUMP function to ignore the drawing of the dinossaur in various function
		; calls, depending of how high the dinossaur is.

		; The function needs to have in the BX register, the address of the vector of the dinossaur's jump data, and
		; returns on the AX register if the function JUMP should be ignored or not.

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		;push ax
		;push bx
		;push cx
		;push dx
		;push si
		;push di

		; Com y = 14 ou mais, ignora 2 chamadas da função
		cmp byte ptr [bx+2], 14
		jge GRAVITY_SIMULATION_JUMP_ignore_2
		; With y = 10 or more (except 14 and above), ignores 1 function call
		cmp byte ptr [bx+2], 12
		jge GRAVITY_SIMULATION_JUMP_ignore_1

		; In case the 2 cases above are not verified, the function call is not ignored
		mov ax, 0

		jmp GRAVITY_SIMULATION_JUMP_end

		GRAVITY_SIMULATION_JUMP_end:

		;pop di
		;pop si
		;pop dx
		;pop cx
		;pop bx
		;pop ax

		mov sp, bp
		pop bp

		ret

		GRAVITY_SIMULATION_JUMP_ignore_1:
			; The comparision is the number of function calls to ignore (the bigger, the more time it stays in the air)
			cmp byte ptr [bx+3], 1
			je GRAVITY_SIMULATION_JUMP_ignore_end
			; Increase the count of how many times the function was ignored if it hasn't got to the limit
			inc byte ptr [bx+3]
			; Here it says to ignore the function call by putting 1 in AX
			mov ax, 1
			jmp GRAVITY_SIMULATION_JUMP_end

		GRAVITY_SIMULATION_JUMP_ignore_2:
			cmp byte ptr [bx+3], 2
			je GRAVITY_SIMULATION_JUMP_ignore_end
			inc byte ptr [bx+3]
			mov ax, 1
			jmp GRAVITY_SIMULATION_JUMP_end

		GRAVITY_SIMULATION_JUMP_ignore_end:
			mov byte ptr [bx+3], 0
			mov ax, 0
			jmp GRAVITY_SIMULATION_JUMP_end

	GRAVITY_SIMULATION_JUMP endp

	DETECT_KEY proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function detects any pressed key without stopping the program, and processes it.

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		push ax
		push bx
		;push cx
		;push dx
		;push si
		;push di

		mov ah, 01h ; This checks if there's any key in processing list (doesn't get any out of the list)
		int 16h
		jz DETECT_KEY_end ; This deletes the key from the buffer and goes back to the beginning of the loop, instead
		                     ; of comparing everything
		mov ah, 00h ; This gets the last key on the list to the AX register and deletes it from the list
		int 16h
		; Key comparision
		cmp ax, 3920h ; Space?
		je DETECT_KEY_continue_space
		cmp ax, 0231h ; 1?
		je DETECT_KEY_continue_1
		cmp ax, 0332h ; 2?
		je DETECT_KEY_continue_2
		cmp ax, 0433h ; 3?
		je DETECT_KEY_continue_3

		; None of the said ones? Then back to the beginning
		jmp DETECT_KEY_end ; jmp loop1

		DETECT_KEY_continue_space:

			; Check if it's already jumping, so it's not possible to make infinite sound (which would also slow the game
			; down because this has to wait a bit while playing the sound, or it would be instantaneos and it wouldn't
			; be heard).
			lea bx, JUMP_DATA_DINOSSAUR
			cmp byte ptr [bx+0], 1
			je DETECT_KEY_end

			; If it's not jumping, active the jump
			mov byte ptr [bx+0], 1

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::
			; Play beep when jumping

			; Could have been with the beep character, but DOSBox doesn't support that (said by one of the authors), so
			; we used the PC Speaker. We also thought in keeping the speakers always On, but for some reason, this has
			; interference even while not playing anything, so we put the note, activate, wait, and disable the speakers.

			; In an attempt of improvement by what was told to us of starting and going instantly to the maximum and
			; not being that good idea, we put this going to the maximum before activating the speakers.
			; Update: we put a loop going to the wanted frequency after enabling the speakers. So it goes from 0 to the
			; correct note one by one to go slower, like a sin function (but much faster on the rise).
			; Update 2: we think it's the with the loop and the old way, so we left it like this becuase it doesn't need
			; to be in a loop and slow then the game more than the BIOS wait time will.

			; Give the PIT a frequency to put on the square waves of the speakers
			mov ax, 4560 ; Central C Major's frequency --> 1,193,180 / 261.63 = 4560 (rounded down as a PC does)
			out 42h, al
			mov al, ah
			out 42h, al

			; Active the speakers
			in ax, 61h
			or ax, 00000011b
			out 61h, ax

			; Increase the frequency one by one until it gets to the wanted frequency
			;mov cx, 0
			;DETECT_KEY_loop1:
			;	; Give the PIT a frequency to put on the square waves of the speakers
			;	mov ax, cx ; Central C Major's frequency --> 1,193,180 / 261.63 = 4560 (rounded down as a PC does)
			;	out 42h, al
			;	mov al, ah
			;	out 42h, al
;
			;	inc cx
			;	cmp cx, 4561 ; +1 than the wanted frequency to stop on the wanted one
			;	jne DETECT_KEY_loop1


			; Wait a bit to have time to play the sound. 0000h:5000h was the time that was thought to be the best to not
			; delay too much but to still be possible to hear the sound decently.
			mov cx, 0000h
			mov dx, 5000h
			mov ah, 86h
			int 15h

			;mov cx, 4560
			;DETECT_KEY_loop2:
			;	; Give the PIT a frequency to put on the square waves of the speakers
			;	mov ax, cx ; Central C Major's frequency --> 1,193,180 / 261.63 = 4560 (rounded down as a PC does)
			;	out 42h, al
			;	mov al, ah
			;	out 42h, al
;
			;	loop DETECT_KEY_loop2 ; This makes it so that AX doesn't get to 0, because when CX is 0, it doesn't go
			                          ; up again

			; Give a frequency to the PIT again to put on the speakers, but this time 0. This is to try to minimize the
			; noise that happens.
			;mov ax, 1 ; NOTE: this has to be in more than 0 or it won't work and the speakers will make VERY weird
			           ; sounds. Must not like like 0, of being stopped haha.
			;out 42h, al
			;mov al, ah
			;out 42h, al

			; Deactive the speakers
			in ax, 61h
			and ax, 11111100b
			out 61h, ax

			; Play beep when jumping
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::

			jmp DETECT_KEY_end

		DETECT_KEY_continue_1:

			jmp begin_game

		DETECT_KEY_continue_2:

			; SEM USO AINDA

			jmp DETECT_KEY_end

		DETECT_KEY_continue_3:

			jmp FIM

		DETECT_KEY_end:

		;pop di
		;pop si
		;pop dx
		;pop cx
		pop bx
		pop ax

		mov sp, bp
		pop bp

		ret

	DETECT_KEY endp

	DRAW_ERASE_FIGURE_MAIN proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function should be called instead of DRAW_ERASE_FIGURE. It adds to the coordinates x and y the given
		; number before calling DRAW_ERASE_FIGURE. If at least one of the numbers to add is different than 0, the function
		; erases the figure in the current position, changes its coordinates and draws it again in the new place.
		; In case both numbers to add are 0, the function just redraws the figure in the same place without changing
		; its coordinates and without deleting it before redrawing.

		; It must have on the AH register the number to add to the y coordinate and on the AL register, the number to
		; add to the x coordinate, both initial coordinates of the figure (can be positive or negative - or zero).
		; NOTE: this will change the initial coordinates stored on the original vectors!
		; In the BL register there must be a 1 in case it's to only delete the figure in the current position, or a 0 in
		; case it's to act as described above.

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		;push ax
		push bx
		;push cx
		push dx
		;push si
		;push di

		; Check if it's to just delete
		cmp dl, 1
		jne DRAW_ERASE_FIGURE_MAIN_continue2

		; Put on the vector of drawing data of the figure of the DATA_ERASE_FIGURE function that is to delete and not to
		; write.
		mov word ptr DRAW_ERASE_FIGURE_data[2*4], 1
		call DRAW_ERASE_FIGURE

		jmp DRAW_ERASE_FIGURE_MAIN_end

		DRAW_ERASE_FIGURE_MAIN_continue2:

		; Check if AX is 0. If it is, jump to the immediate drawing of the figure. Otherwise, erase it first and then
		; draw it in the new position.
		cmp ah, 0
		jne DRAW_ERASE_FIGURE_MAIN_continue
		cmp al, 0
		jne DRAW_ERASE_FIGURE_MAIN_continue
		jmp DRAW_ERASE_FIGURE_MAIN_continue1

		DRAW_ERASE_FIGURE_MAIN_continue:

		; Put on the vector of drawing data of the figure of the DATA_ERASE_FIGURE function that is to delete and not to
        ; write.
		mov word ptr DRAW_ERASE_FIGURE_data[2*4], 1
		call DRAW_ERASE_FIGURE

		; Part in which the function changes the initial coordinates in the figure's vecotr of drawing data
		mov bx, word ptr DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
		add byte ptr [bx+2], ah ; --> DRAW_DATA_DINOSSAUR[2]
		add byte ptr [bx+3], al ; --> DRAW_DATA_DINOSSAUR[3]

		DRAW_ERASE_FIGURE_MAIN_continue1:

		; Put on the vector of drawing data of the figure of the DATA_ERASE_FIGURE function that is to delete and not to
        ; write.
		mov word ptr DRAW_ERASE_FIGURE_data[2*4], 0
		call DRAW_ERASE_FIGURE

		DRAW_ERASE_FIGURE_MAIN_end:

		;pop di
		;pop si
		pop dx
		;pop cx
		pop bx
		;pop ax

		mov sp, bp
		pop bp

		ret

	DRAW_ERASE_FIGURE_MAIN endp

	DRAW_ERASE_FIGURE proc near
		;;;;;;;;;;;;;;;;;;;;;;;;
		; Documentation of the function

		; This function draws any figure from an initial coordinate (all defined in the follwing arrays is relative to
		; the first coordinate to be easier to change the place of drawing of the figure).
		; Weak points:
		; - it draws only in a default color on the function --> it does now;
		; - doesn't erase in case it's needed --> it does now;
		; - doesn't store the used pixels by the picture in an array, so must calculate everything every time.

		; Linked to this procedure is:
		; 	- The array "DRAW_ERASE_FIGURE_data".

		; Format:
		;	- Address of DRAW_DATA_DINOSSAUR;
		;	- Address of X_DRAW_DINOSSAUR;
		;	- Address of Y_BEGIN_DRAW_DINOSSAUR;
		;	- Address of TIMES_WRITE_Y_DRAW_DINOSSAUR;
		;	- Write (0) or erase (1);
		;	- [X] character to use to write (default: # - number sign); --> deprecated
		;	- [X] color in binary (text mode: 1st 4 bits to background color, 2nd 4 bits to the character cpde / graphics
		;     mode: 8 bits to all colors (8 bit colors)). --> deprecated (it's now on the figure data array)

		;;;;;;;;;;;;;;;;;;;;
		; Needed arrays
		; It's here an example that draws the head of the dinossaur which has 4 irregularities, caused by empty places
		; in the image (the eye, which is 1 character, and the mouth art, which are 3 characters).
		; Format:
		;	- Size of the coordinate arrays;
		;	- Last processed index of the arrays, to keep being increased (always leave on 0 - the function takes care of it);
		;	- Initial y;
		;	- Initial x;
		;	- Color in binary (text mode: 1st 4 bits to background, 2nd 4 bits to character / graphics mode: 8 bits to all colors).
		;	- [See on the function ADVANCE_SCENARIO];
		;DRAW_DATA_DINOSSAUR db 12, 0, 21, 02, 00001100b, 07
		; Format: number to ---sum--- to the initial x coordinate to indicate where to draw vertically (in this case,
		;         the numbers that are closer together [no idea what this means XD] are drawn on the same column -
		;         they're drawing irregularities, like empty places)
		;X_DRAW_DINOSSAUR db                 00,  01,  02,02,  03,  04,04,  05,05,  06,06,  07
		; Format: number to ---sum--- to the initial y coordinate to indicate where to draw vertically (in this case,
        ;         the numbers that are closer together [no idea what this means XD] are drawn on the same column -
        ;         they're drawing irregularities, like empty places)
		; Note: the function draws from above to bottom (in each column, starts by the highest coordinate and draws down)
		;Y_BEGIN_DRAW_DINOSSAUR db         00,  -1,  -01,1,  -1,  -1,03,  -1,03,  -1,03,  00
		; Format: number of characters to draw minus 1 (n-1), as of the initial coordinate defined on the array above
		;TIMES_WRITE_Y_DRAW_DINOSSAUR db  03,  04,  00,02,  04,  02,00,  02,00,  02,00,  01
		; Needed arrays
		;;;;;;;;;;;;;;;;;;;;

		; Documentation of the function
		;;;;;;;;;;;;;;;;;;;;;;;;

		push bp
		mov bp, sp

		; Store the value of all registers on the stack (even of those not used - so can't forget of anything)
		push ax
		push bx
		push cx
		push dx
		push si
		push di

		DRAW_ERASE_FIGURE_inicio:

		; Compare the last processed index of the arrays with the size of the drawing arrays
		mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
		mov ah, [bx+0] ; --> DRAW_DATA_DINOSSAUR[0] // Size of the arrays
		mov al, [bx+1] ; --> DRAW_DATA_DINOSSAUR[1] // Last processed index of the arrays
		cmp al, ah
		je DRAW_ERASE_FIGURE_end

		xor ah, ah ; Equivalent to mov ah, 0 (aside from being faster and also takes less memory (opcode of 1 byte) -
		; Stackoverflow with confirmation of the reference optimization manual of the architectures 64 IA-32 of Intel -->
		; it's said on it that it's only on Intel Core that is preferable, but why not use anyways)
		mov si, ax ; Index to use to know the number of characters to write. In this case, the first one (AL didn't change)
		xor ch, ch
		mov bx, DRAW_ERASE_FIGURE_data[2*3] ; --> TIMES_WRITE_Y_DRAW_DINOSSAUR // Address
		mov cl, [bx+si] ; --> TIMES_WRITE_Y_DRAW_DINOSSAUR[bx] // Number of characters to draw is in the last drawing array (address gotten above)
		cmp cx, 0
		je DRAW_ERASE_FIGURE_depois_do_loop1
		DRAW_ERASE_FIGURE_loop1:
			mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
			xor ah, ah
			mov al, [bx+1] ; --> DRAW_DATA_DINOSSAUR[1] // Current column in index
			mov si, ax ; This is just to use the correct register to better understanding of the program (SI - Source INDEX / BX - Base ADDRESS)
			mov dh, [bx+2] ; --> DRAW_DATA_DINOSSAUR[2] // Initial y coordinate
			mov bx, DRAW_ERASE_FIGURE_data[2*2] ; --> Y_BEGIN_DRAW_DINOSSAUR
			add dh, [bx+si] ; --> Y_BEGIN_DRAW_DINOSSAUR[bx] // Sum the initial coordinate with a number to know the coordinate where to start drawing the column
			mov bx, DRAW_ERASE_FIGURE_data[2*3] ; --> TIMES_WRITE_Y_DRAW_DINOSSAUR // Address
			add dh, [bx+si] ; --> TIMES_WRITE_Y_DRAW_DINOSSAUR[bx]
			sub dh, cl ; Sum the coordinate where to start drawing the column with CL, to know in which current column position it's in
			mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
			mov dl, [bx+3] ; --> DRAW_DATA_DINOSSAUR[3] // Initial x coordinate
			mov bx, DRAW_ERASE_FIGURE_data[2*1] ; --> X_DRAW_DINOSSAUR // Address
			add dl, [bx+si] ; --> X_DRAW_DINOSSAUR[bx] // Current x coordinate

			; In case it's going to draw outside the screen limits, doesn't continue and go to the next character
			cmp dh, 25
			jge DRAW_ERASE_FIGURE_direto_ao_loop1
			cmp dh, 0
			jl DRAW_ERASE_FIGURE_direto_ao_loop1

			cmp dl, 80
			jge DRAW_ERASE_FIGURE_direto_ao_loop1
			cmp dl, 0
			jl DRAW_ERASE_FIGURE_direto_ao_loop1
			; In case it's going to draw outside the screen limits, doesn't continue and go to the next character

			mov si, cx ; Store of the CX value in a non-used register

			mov cx, dx
			xor ax, ax
			mov al, ch
			mov bx, 80
			mul bx
			xor ch, ch
			add ax, cx
			mov bx, 2
			mul bx
			mov di, ax
			;offset = (80*y + x) * 2

			mov cx, si ; Put the CX value back in a non-used register

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; Collision detector

			; Checks if the figure is being written or erased. This can only check if if there's anything already written
			; in the new dinossaur position after it's erased, or it would see itself written there (not very helpful haha).
			; In case it's being erased, continue the program
			cmp DRAW_ERASE_FIGURE_data[2*4], 0
			jne DRAW_ERASE_FIGURE_continue1

			; Check if it's the dinossaur that's being written, comparing the address of the dinossaur data vector
			; (for example that one) with the first index of the functions's vector of drawing data
			; If it's not the dinossaur, continue the program
			lea bx, DRAW_DATA_DINOSSAUR
			mov dx, DRAW_ERASE_FIGURE_data[2*0]
			cmp bx, dx
			jne DRAW_ERASE_FIGURE_continue1

			; Checks if there's any character written on the position on which the current character of the figure
			; In case there's not an hashtag already there, continue the program
			cmp byte ptr es:[di], "#"
			jne DRAW_ERASE_FIGURE_continue1

			cmp byte ptr es:[di+1], 00001100b
			je DRAW_ERASE_FIGURE_continue1

			; In case all the described above happens, simulates a normal exit of the function removing everything that
			; was on the stack, including the IP value previous to this function's call, and then calls the GAME_OVER function.
			; This so there are no stack memory failures, since this would keep storing infinitely until the memory limit
			; (in this case, it's defined as 100h in the beginning of the code).
			mov sp, bp
			pop bp
			add sp, 2 ; This is to remove the IP stored on the stack

			; A jump to not store the current IP on the stack for anything, because the game will restart
			jmp GAME_OVER

			DRAW_ERASE_FIGURE_continue1:

			; Collision detector
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			; Compares if it's to erase or write
			cmp DRAW_ERASE_FIGURE_data[2*4], 0
			jne DRAW_ERASE_FIGURE_apagar

			mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
			mov al, byte ptr [bx+4]
			mov ah, [bx+5] ; Character to use to write
			mov byte ptr es:[di], ah
			mov byte ptr es:[di+1], al
			jmp DRAW_ERASE_FIGURE_continue
			DRAW_ERASE_FIGURE_apagar:
			mov byte ptr es:[di], " "
			mov byte ptr es:[di+1], 00000000b

			DRAW_ERASE_FIGURE_continue:

			DRAW_ERASE_FIGURE_direto_ao_loop1:

			;loop DRAW_ERASE_FIGURE_loop1 ; loop can only jump between -128 and +127 bytes (StackOverflow) - this was
			; exceeded on the DRAW_ERASE_FIGURE function. So goes a normal jump:
			dec cx
			jnz DRAW_ERASE_FIGURE_loop1

		DRAW_ERASE_FIGURE_depois_do_loop1:

		mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
		inc byte ptr [bx+1] ; --> DRAW_DATA_DINOSSAUR[1] // Increment the last processed index of the arrays
		; byte ptr we think it's because if it was a word, without this statement, it would increase the next 8 bits (it
		; would change a total of 16 bits), and that's an array of numbers of 8 bits, so it would change the number next,
		; therefore it has to know that it's 8 bits to change the correct number and not the next one too.
		; Yep, that's it. Confirmed below with move byte ptr after half an hour without knowing the problem...
		; Put ALWAYS ALWAYS ALWYAS byte/word/... prt before an address with an index if the other operand doesn't say
		; the type (AL/AX say byte/word by themselves, respectively; 0 doesn't say anything --> YEAH).
		; In this case, MASM assumed as  being a word and it wasn't working, while on EMU8086 it was assumed to be a byte
		; and was working. To don't exist any confusion, DON'T FORGET OF DOING THIS!!!!!
		; On MASM/TASM it's byte ptr; on NASM/YASM it's just byte. byte, word, or quad, whatever.
		jmp DRAW_ERASE_FIGURE_inicio

		DRAW_ERASE_FIGURE_end:

		mov bx, DRAW_ERASE_FIGURE_data[2*0] ; --> DRAW_DATA_DINOSSAUR // Address
		mov byte ptr [bx+1], 0 ; --> DRAW_DATA_DINOSSAUR[1]

		; Reset the value of all registers stored on the stack in the opposite order
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax

		mov sp, bp ; Won't do anything because we didn't use function paramters, but why not leave it here (can't forget
		           ; if it's already here).
		pop bp

		; Return to the next instruction next to that in which the function was called
		ret

	DRAW_ERASE_FIGURE endp

	; PROCEDURES
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

driver segment READONLY para ; The para isn't needed because it's the default, but why not keep it.
; PS: it's mandatory to leave the driver with offset 0 for some reason we didn't understand. So that's why it's being
; put in a separate segment.
; Note: the driver seems to be activated right after it's called, so it's to put the right parameters and call it, and it
; will start automatically - it's not needed to call some sub-function or something.
; Note 2: this works because, as it was told to us, the processor will just read what's here since we jumped here -
; it's like trying to read what's in the segment data as code (which will not go very well, because they're not supposed
; to be instructions, even though the processor can't distinguish).
; Note 3: this doesn't work on Windows 7. Must not have support to Sound Blaster 16 (or any other old sound card? - no
; idea if it works with PC Speaker, but we think maybe it should, since is it not supposed for PCs to still have that?
; Even though we haven't tested).

	ctmidi_drv:
    db 233,173,0,67,84,77,73,68,73,0,67,114,101,97,116,105
    db 118,101,32,83,111,117,110,100,32,66,108,97,115,116,101,114
    db 32,49,54,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,13,10,22,1,8,8,67,114,101,97,116,105,118,101,32
    db 76,111,97,100,97,98,108,101,32,77,73,68,73,32,68,114
    db 105,118,101,114,44,32,32,86,101,114,115,105,111,110,32,49
    db 46,50,50,13,10,67,111,112,121,114,105,103,104,116,32,40
    db 99,41,32,67,114,101,97,116,105,118,101,32,84,101,99,104
    db 110,111,108,111,103,121,32,76,116,100,46,44,32,49,57,57
    db 48,45,49,57,57,51,46,32,32,65,108,108,32,114,105,103
    db 104,116,115,32,114,101,115,101,114,118,101,100,46,13,10,26
    db 156,250,30,6,80,83,81,82,87,86,85,139,236,80,140,200
    db 142,216,142,192,88,131,78,18,1,199,70,12,255,255,128,62
    db 111,32,0,117,36,198,6,111,32,1,251,252,129,251,40,0
    db 114,5,184,0,128,235,13,131,102,18,254,209,227,255,151,140
    db 32,137,70,12,198,6,111,32,0,93,94,95,90,89,91,88
    db 7,31,157,203,30,6,80,83,81,82,87,86,85,140,200,142
    db 216,142,192,198,6,112,32,1,128,62,110,32,1,116,108,198
    db 6,110,32,1,250,140,22,138,32,137,38,136,32,140,216,142
    db 208,188,220,34,251,252,131,62,151,35,1,117,3,232,198,8
    db 128,62,43,35,0,116,4,255,6,117,32,161,121,32,139,22
    db 123,32,3,6,115,32,131,210,0,59,6,113,32,115,5,131
    db 250,1,114,17,156,255,30,132,32,198,6,112,32,0,43,6
    db 113,32,131,218,0,163,121,32,137,22,123,32,250,142,22,138
    db 32,139,38,136,32,198,6,110,32,0,251,128,62,112,32,0
    db 116,4,176,32,230,32,93,94,95,90,89,91,88,7,31,207
    db 156,30,209,227,209,227,250,80,43,192,142,216,88,137,7,137
    db 87,2,31,157,195,156,30,209,227,209,227,250,43,192,142,216
    db 139,7,139,87,2,31,157,195,187,8,0,232,231,255,140,203
    db 59,211,117,8,61,4,1,117,3,248,235,1,249,195,161,51
    db 0,195,30,6,86,87,83,82,38,129,14,220,31,3,128,128
    db 62,109,32,0,116,3,233,130,0,38,129,38,220,31,255,127
    db 142,218,139,240,191,236,31,232,243,1,139,215,139,247,6,31
    db 232,250,1,191,224,31,232,109,0,115,28,139,216,128,63,49
    db 114,21,128,63,50,119,16,138,7,180,0,44,49,38,163,62
    db 35,38,131,38,220,31,254,191,231,31,232,73,0,115,60,139
    db 216,128,63,71,116,12,128,63,69,116,16,128,63,66,116,20
    db 235,41,38,199,6,56,35,0,0,235,16,38,199,6,56,35
    db 1,0,235,7,38,199,6,56,35,2,0,38,255,54,56,35
    db 38,143,6,58,35,38,131,38,220,31,253,38,161,220,31,90
    db 91,95,94,7,31,195,86,87,83,81,82,185,0,0,139,215
    db 38,138,5,10,192,116,32,138,28,10,219,116,26,56,216,116
    db 15,11,201,116,8,185,0,0,139,250,70,235,227,70,235,231
    db 185,1,0,70,71,235,217,11,201,117,3,248,235,3,139,198
    db 249,90,89,91,95,94,195,6,30,232,153,0,11,192,117,0
    db 31,7,195,128,62,109,32,0,116,5,184,1,0,235,59,232
    db 6,17,11,192,116,3,64,235,49,232,234,1,232,5,2,11
    db 192,116,5,131,192,7,235,34,232,147,1,187,8,0,232,180
    db 254,163,132,32,137,22,134,32,187,8,0,140,202,184,4,1
    db 232,141,254,198,6,109,32,1,43,192,195,128,62,109,32,0
    db 116,44,131,78,18,1,232,159,254,114,26,187,8,0,161,132
    db 32,139,22,134,32,232,104,254,131,62,62,35,0,116,3,232
    db 15,19,232,169,14,198,6,109,32,0,51,192,235,3,184,1
    db 0,195,156,250,232,205,1,232,124,1,232,151,1,51,192,157
    db 195,184,0,128,195,129,14,222,31,7,128,128,62,109,32,0
    db 116,3,233,132,0,129,38,222,31,255,127,142,218,139,240,191
    db 236,31,232,120,0,139,215,139,247,6,31,232,127,0,6,86
    db 176,65,232,152,0,114,34,139,216,232,170,0,114,27,128,252
    db 2,117,22,36,240,60,128,119,16,60,16,114,12,168,16,117
    db 8,163,125,32,131,38,222,31,254,176,80,232,111,0,114,19
    db 139,216,232,129,0,114,12,163,127,32,64,163,129,32,131,38
    db 222,31,251,176,73,232,85,0,114,24,139,216,232,103,0,114
    db 17,37,255,0,60,9,118,2,44,6,162,131,32,131,38,222
    db 31,253,161,222,31,94,7,235,3,184,255,255,195,86,87,80
    db 172,10,192,116,3,170,235,248,170,88,95,94,195,86,80,139
    db 242,252,172,60,96,114,5,44,32,136,68,255,10,192,117,242
    db 88,94,195,252,172,174,117,4,10,192,117,248,195,30,86,6
    db 31,138,224,252,172,10,192,116,9,56,224,117,247,139,198,248
    db 235,1,249,94,31,195,43,210,38,138,7,67,60,32,116,60
    db 60,0,116,56,177,4,211,226,60,48,114,10,60,57,119,6
    db 44,48,10,208,235,22,60,97,114,6,60,122,119,2,44,97
    db 60,65,114,24,60,70,119,20,44,55,10,208,38,138,7,67
    db 60,32,116,4,10,192,117,204,139,194,235,1,249,195,80,83
    db 81,82,187,0,0,185,0,128,176,194,186,67,0,238,186,64
    db 0,236,236,138,224,236,134,224,59,195,114,2,139,216,226,232
    db 131,251,240,114,3,187,255,255,137,30,113,32,137,30,115,32
    db 90,89,91,88,195,80,228,97,168,16,117,250,228,97,168,16
    db 116,250,226,242,88,195,199,6,170,35,0,0,199,6,161,35
    db 0,0,199,6,176,35,0,1,255,54,58,35,143,6,56,35
    db 232,19,0,195,232,76,15,11,192,117,10,232,37,15,198,6
    db 246,34,1,51,192,195,87,86,185,8,0,139,54,56,35,209
    db 230,209,230,209,230,209,230,129,198,82,35,191,66,35,252,243
    db 165,94,95,195,80,232,11,15,232,55,15,184,0,0,232,202
    db 2,161,113,32,232,102,4,88,195,135,22,226,34,135,6,224
    db 34,51,192,195,156,250,6,87,128,62,222,34,1,116,10,131
    db 62,151,35,0,116,3,232,203,255,199,6,146,35,0,0,137
    db 22,53,35,163,51,35,142,194,139,248,232,191,2,129,250,84
    db 77,116,3,233,191,0,61,100,104,116,3,233,183,0,232,171
    db 2,232,178,2,131,248,2,114,3,233,169,0,232,167,2,163
    db 159,35,232,161,2,10,228,120,42,163,155,35,198,6,237,35
    db 0,199,6,178,35,0,0,235,35,52,18,134,228,202,194,232
    db 210,236,202,64,168,202,198,208,220,222,216,222,206,242,64,152
    db 232,200,92,246,220,246,228,43,210,232,10,3,139,14,159,35
    db 131,249,65,114,3,185,65,0,139,54,8,42,73,227,10,198
    db 68,9,1,3,54,6,42,226,246,198,68,9,129,139,54,8
    db 42,232,56,2,61,107,114,117,60,129,250,84,77,117,54,232
    db 42,2,87,6,80,82,232,54,2,137,60,140,68,2,137,68
    db 4,137,84,6,90,88,7,95,246,68,9,128,117,13,232,128
    db 2,198,68,9,1,3,54,6,42,235,198,199,6,146,35,1
    db 0,43,192,235,3,184,1,0,95,7,157,195,184,255,255,131
    db 62,146,35,0,116,17,232,250,13,232,215,13,232,183,3,184
    db 1,0,232,166,1,43,192,195,128,62,150,35,1,116,249,156
    db 250,232,192,254,199,6,146,35,0,0,157,195,131,62,151,35
    db 1,117,13,232,189,13,184,2,0,232,127,1,51,192,235,3
    db 184,1,0,195,131,62,151,35,2,117,16,232,149,13,232,61
    db 0,184,1,0,232,100,1,51,192,235,3,184,1,0,195,87
    db 86,6,30,139,240,142,218,185,8,0,191,3,0,209,231,209
    db 231,209,231,209,231,129,199,82,35,252,243,165,31,198,6,55
    db 35,1,184,3,0,232,167,0,51,192,7,94,95,195,81,83
    db 86,87,156,250,131,62,146,35,0,117,3,233,135,0,161,151
    db 35,163,153,35,184,2,0,232,17,1,198,6,222,34,1,255
    db 54,8,42,199,6,8,42,120,38,255,54,6,42,199,6,6
    db 42,14,0,139,22,53,35,161,51,35,251,232,54,254,190,238
    db 35,187,120,38,139,4,137,71,10,139,68,2,137,71,12,246
    db 68,9,128,117,8,131,198,10,131,195,14,235,231,198,6,223
    db 34,0,199,6,182,35,255,255,255,54,180,35,199,6,180,35
    db 1,0,232,193,2,128,62,223,34,1,116,2,235,244,143,6
    db 180,35,143,6,6,42,143,6,8,42,198,6,222,34,0,161
    db 153,35,232,150,0,157,95,94,91,89,195,161,56,35,195,156
    db 250,128,62,246,34,0,116,41,131,248,3,114,12,131,248,3
    db 117,26,128,62,55,35,0,116,19,232,167,12,163,56,35,232
    db 116,253,232,142,12,232,54,255,51,192,235,8,184,2,0,235
    db 3,184,1,0,157,195,161,62,35,195,83,156,250,128,62,246
    db 34,0,116,65,11,192,116,5,131,248,1,117,51,232,115,12
    db 139,30,62,35,137,30,60,35,163,62,35,232,26,12,11,192
    db 116,3,64,235,7,232,28,253,11,192,116,13,80,139,30,60
    db 35,137,30,62,35,232,12,253,88,80,232,225,254,88,235,8
    db 184,1,0,235,3,184,1,0,157,91,195,6,87,131,62,226
    db 34,0,117,9,131,62,224,34,0,117,2,235,7,196,62,224
    db 34,38,137,5,163,151,35,95,7,195,38,138,5,71,11,255
    db 117,9,80,140,192,5,0,16,142,192,88,195,232,235,255,138
    db 240,232,230,255,138,208,232,225,255,138,224,232,220,255,195,43
    db 210,42,228,232,212,255,10,192,121,86,138,224,128,228,127,232
    db 200,255,10,192,120,6,208,224,209,232,235,68,138,212,138,224
    db 128,228,127,232,180,255,10,192,120,21,208,224,209,232,208,202
    db 208,202,138,242,128,230,192,10,230,50,214,42,246,235,33,138
    db 242,138,212,138,224,128,228,127,232,143,255,208,226,208,224,209
    db 232,209,202,209,202,209,202,138,238,128,229,63,10,229,51,209
    db 195,3,248,131,210,0,116,10,140,192,5,0,16,74,117,250
    db 142,192,195,80,86,87,6,30,60,240,117,3,232,105,12,81
    db 232,87,255,139,200,50,237,232,80,255,232,91,12,226,248,89
    db 31,7,95,94,88,195,83,43,201,137,14,174,35,11,210,116
    db 7,209,234,209,216,65,235,245,187,128,1,131,248,19,115,3
    db 184,19,0,59,195,118,28,87,139,248,65,209,232,59,195,119
    db 249,43,210,151,247,247,139,194,139,215,232,40,0,163,174,35
    db 139,199,95,163,157,35,184,1,0,211,224,163,172,35,186,18
    db 0,184,220,52,247,54,157,35,3,210,131,208,0,232,43,0
    db 232,106,0,91,195,83,81,82,43,219,11,192,116,23,11,210
    db 116,19,185,0,128,209,224,114,4,59,194,114,4,11,217,43
    db 194,209,233,117,240,139,195,90,89,91,195,247,38,176,35,2
    db 192,128,212,0,131,210,0,10,246,116,6,184,255,255,249,235
    db 13,138,194,134,224,59,6,236,34,115,3,161,236,34,195,80
    db 83,81,82,86,139,216,161,117,32,139,14,115,32,247,225,247
    db 243,163,119,32,163,117,32,94,90,89,91,88,195,80,83,82
    db 156,250,131,62,148,35,0,116,3,232,211,255,163,115,32,199
    db 6,121,32,0,0,199,6,123,32,0,0,139,30,234,34,186
    db 0,0,247,243,161,113,32,139,30,115,32,137,30,232,34,80
    db 186,0,0,247,243,163,228,34,137,22,230,34,88,147,163,115
    db 32,176,54,186,67,0,238,235,0,235,0,160,115,32,230,64
    db 235,0,235,0,138,196,230,64,235,0,235,0,198,6,247,34
    db 1,157,90,91,88,195,128,62,150,35,1,117,3,233,76,1
    db 198,6,150,35,1,6,139,54,8,42,198,6,236,35,0,128
    db 62,222,34,1,116,19,139,14,174,35,1,14,178,35,161,172
    db 35,131,208,0,163,180,35,235,6,199,6,182,35,255,255,196
    db 60,246,68,9,1,117,3,233,180,0,198,6,236,35,1,131
    db 124,4,0,117,6,131,124,6,0,116,26,161,180,35,41,68
    db 4,131,92,6,0,120,14,116,3,233,146,0,131,124,4,0
    db 116,3,233,137,0,138,68,8,162,12,42,38,246,5,128,116
    db 9,232,150,253,136,68,8,162,12,42,138,92,8,138,203,128
    db 251,240,115,30,42,255,128,227,15,138,135,66,35,152,163,64
    db 35,81,138,14,12,42,128,225,240,36,15,10,200,136,14,12
    db 42,89,138,217,131,227,112,209,235,209,235,209,235,255,151,184
    db 35,246,68,9,1,116,55,128,62,222,34,1,117,18,59,124
    db 10,114,13,140,193,59,76,12,114,6,128,100,9,254,235,30
    db 232,92,253,11,192,117,4,11,210,116,138,1,68,4,17,84
    db 6,120,130,117,9,131,124,4,0,117,3,233,119,255,128,62
    db 222,34,1,117,23,139,68,4,139,84,6,11,210,117,13,11
    db 192,116,9,59,6,182,35,115,3,163,182,35,246,68,9,128
    db 117,12,137,60,140,68,2,3,54,6,42,233,17,255,128,62
    db 222,34,1,117,6,161,182,35,163,180,35,137,60,140,68,2
    db 128,62,236,35,0,117,15,198,6,223,34,1,128,62,222,34
    db 1,116,3,232,206,249,7,198,6,150,35,0,195,82,232,185
    db 252,138,224,232,180,252,128,62,222,34,1,116,40,131,62,64
    db 35,255,116,33,131,62,170,35,0,116,23,131,62,64,35,9
    db 116,16,127,10,139,22,170,35,247,218,42,226,235,4,2,38
    db 170,35,232,243,8,90,195,82,232,127,252,138,224,232,122,252
    db 128,62,222,34,1,116,45,131,62,64,35,255,116,38,131,62
    db 170,35,0,116,23,131,62,64,35,9,116,16,127,10,139,22
    db 170,35,247,218,42,226,235,4,2,38,170,35,128,252,127,119
    db 3,232,204,8,90,195,232,65,252,138,224,232,60,252,131,62
    db 64,35,255,116,3,232,204,8,195,232,46,252,138,224,232,41
    db 252,131,62,64,35,255,116,3,232,200,8,195,232,27,252,138
    db 224,131,62,64,35,255,116,3,232,212,8,195,138,224,232,9
    db 252,131,62,64,35,255,116,3,232,224,8,195,232,251,251,138
    db 224,232,246,251,131,62,64,35,255,116,3,232,220,8,195,138
    db 217,128,227,15,208,227,42,255,255,151,200,35,195,232,218,8
    db 232,252,251,232,91,252,195,232,208,251,232,205,251,195,232,201
    db 251,195,195,195,195,195,195,195,195,232,190,251,6,87,140,217
    db 142,193,191,10,42,185,2,0,242,174,117,19,139,223,95,7
    db 6,87,232,202,251,129,235,11,42,209,227,255,151,232,35,95
    db 7,232,187,251,232,26,252,195,83,81,82,199,6,164,35,1
    db 0,128,62,237,35,0,116,3,233,204,0,185,4,0,209,234
    db 209,216,226,250,131,208,0,131,210,0,185,36,244,11,210,117
    db 25,61,36,244,119,20,61,9,61,115,3,184,9,61,145,247
    db 241,145,146,232,111,252,139,209,235,39,11,210,116,26,131,250
    db 1,119,5,61,54,110,118,6,186,1,0,184,230,99,209,234
    db 209,216,209,233,11,210,117,246,139,208,139,194,232,70,252,43
    db 210,139,202,247,38,155,35,3,192,131,210,0,139,218,139,193
    db 247,38,155,35,3,195,131,210,0,86,83,82,80,139,240,139
    db 194,153,185,20,0,247,241,139,216,139,198,247,241,139,211,91
    db 94,147,135,214,139,14,161,35,198,6,163,35,1,11,201,116
    db 36,121,7,247,217,198,6,163,35,0,129,249,128,0,115,27
    db 128,62,163,35,0,116,8,3,195,19,214,226,250,235,6,43
    db 195,27,214,226,250,199,6,164,35,0,0,91,94,131,62,164
    db 35,0,117,3,232,111,251,161,164,35,90,89,91,195,82,232
    db 168,250,138,208,232,163,250,138,224,232,158,250,163,166,35,137
    db 22,168,35,232,2,255,90,195,82,57,6,161,35,116,31,139
    db 208,11,210,121,2,247,218,131,250,20,118,5,184,1,0,235
    db 15,163,161,35,161,166,35,139,22,168,35,232,218,254,51,192
    db 90,195,82,156,250,57,6,170,35,116,30,139,208,11,210,121
    db 2,247,218,131,250,12,118,5,184,1,0,235,14,163,170,35
    db 232,96,6,232,77,6,232,245,248,51,192,157,90,195,83,6
    db 87,187,1,0,128,62,109,32,0,116,69,156,250,252,80,139
    db 216,42,255,128,227,15,138,135,66,35,152,163,64,35,191,250
    db 34,138,194,170,138,193,170,88,128,62,150,35,1,116,249,138
    db 14,12,42,162,12,42,138,216,131,227,112,209,235,209,235,209
    db 235,191,250,34,255,151,184,35,136,14,12,42,157,187,0,0
    db 139,195,95,7,91,195,51,219,232,1,0,195,83,6,87,86
    db 199,6,220,34,1,0,128,62,109,32,0,116,119,139,248,139
    db 194,142,192,87,190,120,38,198,68,9,1,3,249,19,195,137
    db 60,137,68,2,95,38,138,5,71,235,16,38,138,5,71,168
    db 128,117,248,38,138,5,71,168,128,116,73,80,139,216,42,255
    db 128,227,15,138,135,66,35,152,163,64,35,88,128,62,150,35
    db 1,116,249,81,138,14,12,42,162,12,42,138,200,138,216,131
    db 227,112,209,235,209,235,209,235,255,151,184,35,136,14,12,42
    db 89,59,60,114,182,140,192,59,68,2,115,2,226,173,199,6
    db 220,34,0,0,161,220,34,94,95,7,91,195,128,100,9,254
    db 195,6,87,131,62,20,35,0,117,9,131,62,18,35,0,117
    db 2,235,7,196,62,18,35,38,137,5,163,148,35,95,7,195
    db 80,209,232,209,232,209,232,209,232,3,208,88,131,224,15,195
    db 86,87,83,81,156,250,176,0,186,67,0,238,235,0,235,0
    db 228,64,134,224,228,64,134,224,251,139,62,117,32,59,62,119
    db 32,116,17,119,7,51,192,186,0,0,235,94,163,232,34,186
    db 0,0,235,9,59,6,232,34,118,3,71,235,239,139,14,115
    db 32,43,200,163,232,34,139,193,186,0,0,137,62,119,32,139
    db 216,139,199,247,38,115,32,3,195,131,210,0,139,240,139,194
    db 153,139,14,234,34,247,241,139,248,139,198,247,241,139,215,163
    db 238,34,137,22,240,34,139,216,139,242,43,6,242,34,27,22
    db 244,34,137,30,242,34,137,54,244,34,157,89,91,95,94,195
    db 30,6,80,83,81,82,87,86,85,140,200,142,216,142,192,139
    db 22,125,32,131,194,4,176,130,238,235,0,235,0,235,0,235
    db 0,66,236,168,4,117,3,233,48,1,198,6,49,35,1,138
    db 14,131,32,232,129,1,250,140,22,16,35,137,38,14,35,140
    db 216,142,208,188,14,43,251,232,50,1,252,191,64,0,232,232
    db 6,114,3,233,209,0,232,200,6,128,62,43,35,0,117,11
    db 198,6,43,35,1,199,6,117,32,0,0,6,87,128,62,44
    db 35,0,116,47,196,62,26,35,80,161,8,35,139,22,10,35
    db 64,131,210,0,59,22,6,35,114,15,59,6,4,35,118,9
    db 88,199,6,12,35,1,0,235,108,163,8,35,137,22,10,35
    db 88,235,5,14,7,191,0,35,137,62,38,35,140,195,137,30
    db 40,35,170,232,186,254,128,62,47,35,1,117,7,161,238,34
    db 139,22,240,34,171,139,194,170,131,62,30,35,0,117,9,131
    db 62,32,35,0,117,2,235,22,80,255,54,40,35,255,54,38
    db 35,255,54,36,35,255,54,34,35,255,30,30,35,88,128,62
    db 44,35,0,116,16,139,30,38,35,131,195,4,131,22,28,35
    db 0,137,30,26,35,95,7,128,62,44,35,0,116,17,131,62
    db 12,35,0,116,10,198,6,50,35,1,232,243,2,235,36,79
    db 11,255,116,3,233,39,255,128,62,44,35,0,116,21,80,82
    db 161,26,35,139,22,28,35,232,38,254,163,26,35,137,22,28
    db 35,90,88,250,139,38,14,35,142,22,16,35,198,6,49,35
    db 0,138,14,131,32,232,52,0,235,24,131,62,252,34,0,117
    db 12,131,62,254,34,0,117,5,232,17,0,235,5,156,255,30
    db 252,34,93,94,95,90,89,91,88,7,31,207,80,176,32,128
    db 62,131,32,7,118,2,230,160,230,32,88,195,80,82,156,250
    db 128,249,8,115,5,186,33,0,235,6,186,161,0,128,233,8
    db 184,0,1,210,228,246,212,236,235,0,235,0,34,196,238,235
    db 0,235,0,157,90,88,195,80,82,156,250,128,249,8,115,5
    db 186,33,0,235,6,186,161,0,128,233,8,184,0,1,210,228
    db 236,235,0,235,0,10,196,238,235,0,235,0,157,90,88,195
    db 83,139,30,45,35,232,61,240,140,203,59,211,117,8,61,144
    db 15,117,3,248,235,1,249,91,195,80,83,81,82,156,250,160
    db 131,32,60,8,115,4,4,8,235,4,44,8,4,112,42,228
    db 163,45,35,139,30,45,35,232,11,240,137,22,254,34,163,252
    db 34,139,30,45,35,140,202,184,144,15,232,227,239,138,14,131
    db 32,128,249,8,115,5,186,33,0,235,6,186,161,0,128,233
    db 8,184,0,1,210,228,236,34,196,162,42,35,138,14,131,32
    db 232,57,255,198,6,48,35,1,157,90,89,91,88,195,82,156
    db 250,128,62,48,35,0,116,45,232,117,255,114,40,128,62,131
    db 32,8,115,5,186,33,0,235,3,186,161,0,236,10,6,42
    db 35,238,139,30,45,35,139,22,254,34,161,252,34,232,128,239
    db 198,6,48,35,0,157,90,195,80,156,250,199,6,121,32,0
    db 0,199,6,123,32,0,0,128,62,247,34,0,117,17,161,248
    db 34,57,6,113,32,115,6,161,113,32,163,248,34,235,3,161
    db 115,32,232,72,247,157,88,195,128,62,109,32,0,116,31,128
    db 62,131,32,255,117,5,184,1,0,235,17,135,22,20,35,135
    db 6,18,35,80,43,192,232,88,252,88,51,192,235,3,184,1
    db 0,195,128,62,131,32,255,117,5,184,1,0,235,5,162,47
    db 35,51,192,195,81,128,62,109,32,0,116,58,128,62,131,32
    db 255,117,5,184,1,0,235,44,73,137,14,4,35,137,62,6
    db 35,232,60,252,163,22,35,131,192,4,163,26,35,137,22,24
    db 35,131,210,0,137,22,28,35,198,6,44,35,1,198,6,43
    db 35,0,51,192,235,3,184,1,0,89,195,128,62,109,32,0
    db 116,32,128,62,131,32,255,117,5,184,1,0,235,18,135,22
    db 32,35,135,6,30,35,135,62,36,35,135,14,34,35,51,192
    db 235,3,184,1,0,195,156,250,128,62,109,32,0,116,124,131
    db 62,148,35,0,117,112,131,62,125,32,255,116,14,128,62,131
    db 32,255,116,7,232,229,3,114,2,235,5,184,1,0,235,84
    db 161,248,34,59,6,234,34,115,5,184,1,0,235,70,6,87
    db 80,196,62,22,35,161,8,35,171,161,10,35,171,88,95,7
    db 248,131,62,151,35,0,117,5,232,132,2,235,10,131,62,62
    db 35,0,117,3,232,120,2,115,5,184,1,0,235,22,232,90
    db 2,232,180,254,184,255,255,232,87,251,232,12,254,198,6,50
    db 35,0,51,192,235,8,184,1,0,235,3,184,1,0,157,195
    db 131,62,148,35,0,116,8,156,250,232,4,0,51,192,157,195
    db 156,250,82,131,62,151,35,0,117,9,161,113,32,232,237,245
    db 232,158,2,232,1,2,43,192,232,22,251,232,48,254,6,87
    db 80,128,62,50,35,1,116,7,128,62,49,35,1,116,249,198
    db 6,50,35,0,250,196,62,22,35,161,8,35,171,161,10,35
    db 171,88,95,7,90,157,195,0,131,62,62,35,1,116,25,161
    db 125,32,131,248,255,117,5,184,1,0,235,38,232,107,3,11
    db 192,116,31,184,2,0,235,26,131,62,127,32,255,117,5,184
    db 3,0,235,14,232,245,2,115,5,184,4,0,235,4,51,192
    db 43,192,195,131,62,62,35,0,116,5,232,109,1,235,3,232
    db 73,4,195,131,62,62,35,0,116,5,232,248,0,235,3,232
    db 66,6,195,131,62,62,35,0,116,18,131,62,148,35,0,117
    db 7,232,139,1,51,192,235,2,51,192,235,5,232,78,3,51
    db 192,195,131,62,62,35,0,116,2,235,3,232,164,3,195,80
    db 160,12,42,232,178,0,88,134,224,232,172,0,134,224,232,167
    db 0,195,232,234,255,195,235,250,131,62,62,35,0,116,5,232
    db 240,255,235,3,232,136,9,195,10,192,116,234,232,208,255,195
    db 131,62,62,35,0,116,5,232,238,255,235,3,232,228,9,195
    db 232,188,255,195,131,62,62,35,0,116,3,232,242,255,195,232
    db 173,255,195,131,62,62,35,0,116,5,232,242,255,235,3,232
    db 62,10,195,80,160,12,42,232,78,0,88,232,74,0,195,131
    db 62,62,35,0,116,5,232,234,255,235,3,232,80,10,195,80
    db 160,12,42,232,50,0,88,232,46,0,195,131,62,62,35,0
    db 116,3,232,234,255,195,232,102,255,195,131,62,62,35,0,116
    db 5,232,242,255,235,3,232,113,10,195,131,62,62,35,0,116
    db 5,232,143,243,235,0,195,0,80,82,81,156,250,232,98,1
    db 157,89,90,88,195,80,83,81,82,128,62,150,35,0,116,2
    db 226,247,156,250,131,62,62,35,1,117,17,131,62,151,35,0
    db 117,10,128,62,15,43,1,116,3,232,131,0,184,176,0,232
    db 198,255,80,176,120,232,192,255,176,0,232,187,255,88,232,183
    db 255,80,176,121,232,177,255,176,0,232,172,255,88,232,168,255
    db 80,176,123,232,162,255,176,0,232,157,255,88,254,192,168,15
    db 116,2,235,203,157,90,89,91,88,195,80,184,176,0,232,135
    db 255,80,176,7,232,129,255,176,100,232,124,255,88,254,192,168
    db 15,116,2,235,233,88,195,80,82,139,22,125,32,131,194,4
    db 176,131,238,66,236,36,251,238,90,88,195,80,82,139,22,125
    db 32,131,194,4,176,131,238,66,236,12,4,238,90,88,195,80
    db 81,82,156,250,248,128,62,15,43,1,116,91,131,62,148,35
    db 1,116,84,185,2,0,81,176,255,139,22,129,32,238,185,0
    db 16,236,10,192,121,5,226,249,249,235,1,248,89,115,4,226
    db 229,235,42,139,22,127,32,236,52,254,117,33,176,63,139,22
    db 129,32,238,185,0,16,236,10,192,121,5,226,249,249,235,13
    db 139,22,127,32,236,52,254,116,3,249,235,1,248,139,22,127
    db 32,236,198,6,15,43,1,139,22,127,32,236,157,90,89,88
    db 195,80,81,82,156,250,248,128,62,15,43,0,116,47,131,62
    db 148,35,1,116,40,185,2,0,81,176,255,139,22,129,32,238
    db 185,0,16,236,10,192,121,5,226,249,249,235,1,248,89,115
    db 2,226,229,139,22,127,32,236,198,6,15,43,0,157,90,89
    db 88,195,81,82,80,185,0,16,139,22,129,32,236,168,64,116
    db 6,226,249,249,88,235,7,88,139,22,127,32,238,248,90,89
    db 195,81,82,185,0,16,139,22,129,32,236,10,192,121,2,226
    db 249,139,22,127,32,236,90,89,195,80,82,139,22,129,32,236
    db 10,192,121,3,248,235,1,249,90,88,195,81,82,156,250,248
    db 187,0,0,80,139,208,66,176,255,238,185,0,16,226,254,236
    db 176,255,238,185,0,16,236,10,192,121,3,226,249,249,74,236
    db 88,114,2,235,3,187,1,0,157,90,89,195,83,161,127,32
    db 128,62,14,43,1,117,2,235,18,232,191,255,11,219,116,3
    db 249,235,9,198,6,14,43,1,163,127,32,248,91,195,80,81
    db 82,3,22,125,32,134,224,238,185,1,0,232,135,237,66,138
    db 196,238,185,3,0,232,125,237,90,89,88,195,81,82,185,0
    db 1,138,224,128,228,224,139,22,125,32,236,36,224,56,196,116
    db 5,226,247,249,235,1,248,90,89,195,186,0,0,184,0,1
    db 232,187,255,184,96,4,232,181,255,184,128,4,232,175,255,176
    db 0,232,200,255,114,35,184,255,2,232,162,255,184,33,4,232
    db 156,255,176,192,232,181,255,114,16,184,96,4,232,143,255,184
    db 128,4,232,137,255,43,192,235,3,184,1,0,195,186,0,0
    db 184,96,4,232,120,255,184,128,4,232,114,255,186,2,0,184
    db 1,5,232,105,255,184,63,4,232,99,255,199,6,16,43,6
    db 0,186,0,0,184,32,1,232,84,255,184,0,8,232,78,255
    db 184,32,189,232,72,255,232,1,0,195,186,0,0,184,0,166
    db 232,59,255,184,10,182,232,53,255,184,11,167,232,47,255,184
    db 10,183,232,41,255,184,87,168,232,35,255,184,9,184,232,29
    db 255,195,186,2,0,184,48,192,232,19,255,254,196,128,252,200
    db 118,246,176,0,43,219,180,192,2,167,70,70,232,255,254,67
    db 131,251,18,114,241,186,0,0,184,48,192,232,240,254,254,196
    db 128,252,200,118,246,176,0,43,219,180,192,2,167,70,70,232
    db 220,254,67,131,251,18,114,241,186,2,0,184,0,4,232,205
    db 254,184,0,5,232,199,254,6,87,140,216,142,192,252,176,255
    db 185,11,0,191,66,69,243,170,95,7,195,6,87,140,223,142
    db 199,252,43,192,163,18,43,198,6,3,70,32,184,48,48,185
    db 8,0,191,100,68,243,171,43,192,185,8,0,191,116,68,243
    db 171,43,192,185,8,0,191,132,68,243,171,43,192,185,16,0
    db 191,148,68,243,171,184,0,1,185,16,0,191,180,68,243,171
    db 176,255,185,11,0,191,110,69,243,170,186,0,0,184,32,189
    db 232,91,254,232,20,255,95,7,195,80,81,86,138,225,172,232
    db 76,254,172,138,200,128,225,192,136,141,127,69,138,200,128,225
    db 63,128,233,63,246,217,136,141,171,69,128,196,32,232,46,254
    db 172,128,196,32,232,39,254,172,128,196,32,232,32,254,70,172
    db 128,196,96,232,24,254,94,89,88,195,81,87,86,139,62,64
    db 35,138,141,100,68,136,143,44,69,177,5,42,228,211,224,139
    db 240,129,198,20,49,138,68,31,152,177,4,211,224,209,227,137
    db 135,22,69,209,235,138,68,4,138,100,16,37,1,1,208,224
    db 10,196,136,135,99,69,42,246,138,151,212,68,138,143,223,68
    db 139,251,232,116,255,138,167,121,69,138,68,4,36,15,136,133
    db 215,69,10,135,44,69,232,181,253,128,193,3,131,198,6,131
    db 199,11,232,84,255,131,198,6,128,193,5,131,199,11,232,72
    db 255,138,167,121,69,128,196,3,138,68,4,36,15,136,133,215
    db 69,10,135,44,69,232,134,253,128,193,3,131,198,6,131,199
    db 11,232,37,255,94,95,89,195,81,86,198,135,44,69,48,42
    db 228,45,128,0,209,224,209,224,209,224,209,224,190,20,65,3
    db 240,138,68,3,128,251,7,114,3,138,68,2,138,224,37,63
    db 192,136,167,127,69,44,63,246,216,136,135,171,69,128,251,6
    db 117,85,138,167,223,68,186,0,0,172,232,49,253,128,196,3
    db 172,232,42,253,128,236,3,128,196,32,172,232,32,253,70,185
    db 2,0,128,196,32,172,232,21,253,128,196,3,172,232,14,253
    db 128,236,3,226,237,128,196,96,172,232,2,253,128,196,3,172
    db 232,251,252,128,236,3,138,227,128,196,192,172,36,63,10,135
    db 44,69,232,233,252,235,58,138,167,223,68,186,0,0,172,70
    db 232,219,252,128,196,32,172,70,232,211,252,185,2,0,128,196
    db 32,172,70,232,200,252,226,246,128,196,96,172,70,232,190,252
    db 138,167,3,70,128,196,192,172,10,135,44,69,36,63,232,173
    db 252,94,89,195,80,83,82,186,0,0,128,38,3,70,32,160
    db 3,70,180,189,232,151,252,139,30,16,43,75,128,191,66,69
    db 127,119,3,232,63,0,254,203,121,242,90,91,88,195,87,43
    db 219,160,23,70,60,35,114,39,60,75,119,35,42,228,44,35
    db 162,23,70,139,248,138,157,4,68,10,219,116,18,129,235,128
    db 0,209,227,209,227,209,227,209,227,138,159,31,65,42,255,139
    db 195,11,192,95,195,81,82,128,143,66,69,128,198,135,110,69
    db 255,209,227,139,135,234,68,209,235,138,204,42,246,138,151,212
    db 68,138,167,223,68,128,196,128,232,35,252,138,193,128,196,16
    db 232,27,252,90,89,195,87,232,148,255,117,3,233,132,0,160
    db 23,70,42,228,139,248,138,133,4,68,232,139,254,138,135,254
    db 69,8,6,3,70,160,24,70,232,106,0,232,63,1,128,251
    db 6,116,5,128,251,8,117,80,160,23,70,42,228,139,248,138
    db 133,52,68,232,80,1,114,75,138,204,42,246,138,151,212,68
    db 138,167,12,70,232,199,251,138,193,128,196,16,232,191,251,128
    db 251,8,117,36,160,23,70,42,228,139,248,138,133,52,68,4
    db 7,232,34,1,114,29,138,204,180,167,186,0,0,232,158,251
    db 138,193,128,196,16,232,150,251,160,3,70,180,189,186,0,0
    db 232,139,251,95,195,87,42,228,249,209,208,139,62,64,35,209
    db 231,247,165,180,68,138,196,208,232,208,232,208,232,208,232,20
    db 0,42,228,139,248,209,231,139,133,25,70,95,195,42,228,3
    db 193,131,248,63,118,11,11,192,120,5,184,63,0,235,2,43
    db 192,131,232,63,247,216,195,81,87,86,42,246,138,151,212,68
    db 81,138,143,99,69,42,237,139,249,138,141,14,70,42,237,139
    db 241,89,139,251,247,198,1,0,116,21,138,133,171,69,232,188
    db 255,10,133,127,69,138,167,223,68,128,196,32,232,15,251,131
    db 199,11,247,198,2,0,116,21,138,133,171,69,232,158,255,10
    db 133,127,69,138,167,223,68,128,196,35,232,241,250,131,199,11
    db 247,198,4,0,116,21,138,133,171,69,232,128,255,10,133,127
    db 69,138,167,223,68,128,196,40,232,211,250,131,199,11,247,198
    db 8,0,116,21,138,133,171,69,232,98,255,10,133,127,69,138
    db 167,223,68,128,196,43,232,181,250,94,95,89,195,87,139,251
    db 42,228,2,133,171,69,43,201,232,66,255,10,135,127,69,138
    db 167,223,68,128,251,6,117,3,128,196,3,128,196,32,186,0
    db 0,232,138,250,95,195,87,138,224,42,192,209,232,209,232,209
    db 227,3,135,22,69,209,235,139,62,64,35,209,231,3,133,148
    db 68,191,0,3,43,199,114,42,61,0,24,245,114,36,43,210
    db 247,247,208,224,208,224,138,224,42,192,139,250,209,231,11,133
    db 20,43,209,227,137,135,234,68,139,14,18,43,137,143,0,69
    db 209,235,95,195,6,87,140,217,142,193,139,14,16,43,138,224
    db 12,128,191,66,69,242,174,116,32,139,14,16,43,176,255,191
    db 66,69,242,174,116,19,139,14,16,43,176,128,191,66,69,132
    db 5,117,5,71,226,249,235,3,71,235,65,86,43,246,139,14
    db 16,43,191,0,69,187,66,69,139,195,80,139,5,43,6,18
    db 43,153,51,194,43,194,139,208,88,59,214,118,4,139,242,139
    db 195,71,71,67,73,117,227,11,246,117,3,249,235,11,45,66
    db 69,139,216,232,127,253,139,195,248,94,235,7,129,239,67,69
    db 139,199,248,95,7,195,42,228,249,208,224,139,30,64,35,209
    db 227,137,135,180,68,209,235,195,131,62,64,35,9,116,89,180
    db 16,60,42,118,8,180,48,60,84,118,2,180,32,139,30,64
    db 35,136,167,100,68,86,190,66,69,139,14,16,43,42,246,172
    db 36,127,58,6,64,35,117,44,139,222,129,235,67,69,136,167
    db 44,69,80,138,196,138,151,212,68,138,167,223,68,128,196,160
    db 10,135,215,69,232,87,249,36,48,128,196,3,10,135,237,69
    db 232,75,249,88,73,117,200,94,195,6,87,131,62,64,35,9
    db 116,42,139,30,64,35,136,135,132,68,10,192,117,30,140,217
    db 142,193,185,11,0,191,110,69,160,64,35,242,174,117,13,139
    db 223,129,235,111,69,232,205,252,11,201,117,239,95,7,195,252
    db 136,38,23,70,162,24,70,139,14,16,43,128,62,64,35,9
    db 117,30,232,121,252,116,89,139,216,138,135,254,69,246,208,34
    db 6,3,70,162,3,70,180,189,186,0,0,232,224,248,235,64
    db 6,87,140,216,142,192,160,23,70,138,38,64,35,191,55,69
    db 139,14,16,43,242,174,117,38,139,223,129,235,56,69,58,167
    db 66,69,116,4,227,24,235,236,139,62,64,35,128,189,132,68
    db 0,116,8,139,199,136,135,110,69,235,3,232,87,252,95,7
    db 195,235,148,252,136,38,23,70,10,192,116,245,162,24,70,139
    db 30,64,35,138,195,60,9,117,5,232,106,252,235,97,255,6
    db 18,43,232,63,254,114,88,139,216,160,64,35,134,135,66,69
    db 36,127,58,6,64,35,116,13,87,139,62,64,35,138,133,116
    db 68,232,70,250,95,160,24,70,232,202,252,139,200,232,7,253
    db 160,23,70,136,135,55,69,232,188,253,115,7,128,143,66,69
    db 128,235,28,42,246,138,151,212,68,138,204,138,167,223,68,128
    db 196,128,232,41,248,138,193,12,32,128,196,16,232,31,248,195
    db 252,128,252,123,114,5,232,107,251,235,34,6,87,134,196,140
    db 223,142,199,191,61,70,185,3,0,242,174,139,223,95,7,117
    db 12,134,196,129,235,62,70,209,227,255,151,64,70,195,252,139
    db 30,64,35,136,167,116,68,6,87,140,216,142,192,128,62,64
    db 35,9,116,51,139,14,16,43,160,64,35,12,128,191,66,69
    db 242,174,117,8,198,69,255,255,11,201,117,244,139,14,16,43
    db 191,66,69,160,64,35,242,174,117,13,139,223,129,235,67,69
    db 232,98,251,11,201,117,236,95,7,195,252,87,139,62,64,35
    db 131,255,9,116,68,208,228,209,192,44,128,152,209,231,137,133
    db 148,68,43,219,160,64,35,58,135,66,69,117,37,138,135,55
    db 69,232,242,252,114,28,138,204,138,167,223,68,128,196,128,42
    db 246,138,151,212,68,232,102,247,138,193,12,32,128,196,16,232
    db 92,247,67,59,30,16,43,114,203,95,195,0,3,128,7,128
    db 83,89,78,84,72,58,0,77,65,80,58,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255
    db 255,0,0,255,0,0,0,0,0,0,0,0,222,1,226,1
    db 199,2,211,2,27,3,82,3,159,6,57,5,68,5,60,6
    db 88,6,108,6,132,6,107,7,111,7,136,13,178,13,222,13
    db 54,14,97,3,97,3,97,3,97,3,97,3,97,3,97,3
    db 97,3,97,3,166,7,170,7,88,18,130,18,148,18,219,18
    db 6,19,144,19,97,3,97,3,97,3,97,3,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,169,4,169,4,0,0
    db 0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0
    db 0,0,0,1,2,3,4,5,6,7,8,9,255,255,255,255
    db 255,255,0,1,2,3,4,5,6,7,8,9,10,11,12,13
    db 14,15,0,1,2,3,4,5,6,7,8,9,255,255,255,255
    db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,12,13
    db 14,9,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    db 255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,1,0,0,0,0,0,0,93,11,151,11,214,11,233,11
    db 252,11,12,12,28,12,47,12,61,12,60,12,71,12,78,12
    db 60,12,60,12,82,12,61,12,84,12,60,12,85,12,86,12
    db 87,12,60,12,88,12,89,12,110,13,204,14,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,10,0,238,35,81,47,0,0,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,195,195
    db 195,195,195,195,195,195,195,195,195,195,195,195,195,195,0,0
    db 6,0,0,0,87,1,87,1,88,1,88,1,88,1,88,1
    db 89,1,89,1,89,1,90,1,90,1,90,1,91,1,91,1
    db 91,1,92,1,92,1,92,1,93,1,93,1,93,1,93,1
    db 94,1,94,1,94,1,95,1,95,1,95,1,96,1,96,1
    db 96,1,97,1,97,1,97,1,98,1,98,1,98,1,99,1
    db 99,1,99,1,100,1,100,1,100,1,100,1,101,1,101,1
    db 101,1,102,1,102,1,102,1,103,1,103,1,103,1,104,1
    db 104,1,104,1,105,1,105,1,105,1,106,1,106,1,106,1
    db 107,1,107,1,107,1,108,1,108,1,108,1,109,1,109,1
    db 109,1,110,1,110,1,110,1,111,1,111,1,111,1,112,1
    db 112,1,112,1,113,1,113,1,113,1,114,1,114,1,114,1
    db 115,1,115,1,115,1,116,1,116,1,116,1,117,1,117,1
    db 117,1,118,1,118,1,118,1,119,1,119,1,119,1,120,1
    db 120,1,120,1,121,1,121,1,121,1,122,1,122,1,122,1
    db 123,1,123,1,123,1,124,1,124,1,124,1,125,1,125,1
    db 125,1,126,1,126,1,126,1,127,1,127,1,128,1,128,1
    db 128,1,129,1,129,1,129,1,130,1,130,1,130,1,131,1
    db 131,1,131,1,132,1,132,1,132,1,133,1,133,1,133,1
    db 134,1,134,1,135,1,135,1,135,1,136,1,136,1,136,1
    db 137,1,137,1,137,1,138,1,138,1,138,1,139,1,139,1
    db 139,1,140,1,140,1,141,1,141,1,141,1,142,1,142,1
    db 142,1,143,1,143,1,143,1,144,1,144,1,145,1,145,1
    db 145,1,146,1,146,1,146,1,147,1,147,1,147,1,148,1
    db 148,1,149,1,149,1,149,1,150,1,150,1,150,1,151,1
    db 151,1,151,1,152,1,152,1,153,1,153,1,153,1,154,1
    db 154,1,154,1,155,1,155,1,156,1,156,1,156,1,157,1
    db 157,1,157,1,158,1,158,1,158,1,159,1,159,1,160,1
    db 160,1,160,1,161,1,161,1,161,1,162,1,162,1,163,1
    db 163,1,163,1,164,1,164,1,165,1,165,1,165,1,166,1
    db 166,1,166,1,167,1,167,1,168,1,168,1,168,1,169,1
    db 169,1,169,1,170,1,170,1,171,1,171,1,171,1,172,1
    db 172,1,173,1,173,1,173,1,174,1,174,1,174,1,175,1
    db 175,1,176,1,176,1,176,1,177,1,177,1,178,1,178,1
    db 178,1,179,1,179,1,180,1,180,1,180,1,181,1,181,1
    db 182,1,182,1,182,1,183,1,183,1,184,1,184,1,184,1
    db 185,1,185,1,186,1,186,1,186,1,187,1,187,1,188,1
    db 188,1,188,1,189,1,189,1,190,1,190,1,190,1,191,1
    db 191,1,192,1,192,1,192,1,193,1,193,1,194,1,194,1
    db 194,1,195,1,195,1,196,1,196,1,196,1,197,1,197,1
    db 198,1,198,1,198,1,199,1,199,1,200,1,200,1,201,1
    db 201,1,201,1,202,1,202,1,203,1,203,1,203,1,204,1
    db 204,1,205,1,205,1,205,1,206,1,206,1,207,1,207,1
    db 208,1,208,1,208,1,209,1,209,1,210,1,210,1,211,1
    db 211,1,211,1,212,1,212,1,213,1,213,1,213,1,214,1
    db 214,1,215,1,215,1,216,1,216,1,216,1,217,1,217,1
    db 218,1,218,1,219,1,219,1,219,1,220,1,220,1,221,1
    db 221,1,222,1,222,1,222,1,223,1,223,1,224,1,224,1
    db 225,1,225,1,225,1,226,1,226,1,227,1,227,1,228,1
    db 228,1,229,1,229,1,229,1,230,1,230,1,231,1,231,1
    db 232,1,232,1,232,1,233,1,233,1,234,1,234,1,235,1
    db 235,1,236,1,236,1,236,1,237,1,237,1,238,1,238,1
    db 239,1,239,1,240,1,240,1,240,1,241,1,241,1,242,1
    db 242,1,243,1,243,1,244,1,244,1,245,1,245,1,245,1
    db 246,1,246,1,247,1,247,1,248,1,248,1,249,1,249,1
    db 250,1,250,1,250,1,251,1,251,1,252,1,252,1,253,1
    db 253,1,254,1,254,1,255,1,255,1,255,1,0,2,0,2
    db 1,2,1,2,2,2,2,2,3,2,3,2,4,2,4,2
    db 5,2,5,2,6,2,6,2,6,2,7,2,7,2,8,2
    db 8,2,9,2,9,2,10,2,10,2,11,2,11,2,12,2
    db 12,2,13,2,13,2,14,2,14,2,14,2,15,2,15,2
    db 16,2,16,2,17,2,17,2,18,2,18,2,19,2,19,2
    db 20,2,20,2,21,2,21,2,22,2,22,2,23,2,23,2
    db 24,2,24,2,25,2,25,2,26,2,26,2,26,2,27,2
    db 27,2,28,2,28,2,29,2,29,2,30,2,30,2,31,2
    db 31,2,32,2,32,2,33,2,33,2,34,2,34,2,35,2
    db 35,2,36,2,36,2,37,2,37,2,38,2,38,2,39,2
    db 39,2,40,2,40,2,41,2,41,2,42,2,42,2,43,2
    db 43,2,44,2,44,2,45,2,45,2,46,2,46,2,47,2
    db 47,2,48,2,48,2,49,2,49,2,50,2,50,2,51,2
    db 51,2,52,2,52,2,53,2,53,2,54,2,54,2,55,2
    db 55,2,56,2,56,2,57,2,57,2,58,2,59,2,59,2
    db 60,2,60,2,61,2,61,2,62,2,62,2,63,2,63,2
    db 64,2,64,2,65,2,65,2,66,2,66,2,67,2,67,2
    db 68,2,68,2,69,2,69,2,70,2,70,2,71,2,72,2
    db 72,2,73,2,73,2,74,2,74,2,75,2,75,2,76,2
    db 76,2,77,2,77,2,78,2,78,2,79,2,79,2,80,2
    db 81,2,81,2,82,2,82,2,83,2,83,2,84,2,84,2
    db 85,2,85,2,86,2,86,2,87,2,88,2,88,2,89,2
    db 89,2,90,2,90,2,91,2,91,2,92,2,92,2,93,2
    db 94,2,94,2,95,2,95,2,96,2,96,2,97,2,97,2
    db 98,2,98,2,99,2,100,2,100,2,101,2,101,2,102,2
    db 102,2,103,2,103,2,104,2,105,2,105,2,106,2,106,2
    db 107,2,107,2,108,2,108,2,109,2,110,2,110,2,111,2
    db 111,2,112,2,112,2,113,2,114,2,114,2,115,2,115,2
    db 116,2,116,2,117,2,117,2,118,2,119,2,119,2,120,2
    db 120,2,121,2,121,2,122,2,123,2,123,2,124,2,124,2
    db 125,2,125,2,126,2,127,2,127,2,128,2,128,2,129,2
    db 130,2,130,2,131,2,131,2,132,2,132,2,133,2,134,2
    db 134,2,135,2,135,2,136,2,137,2,137,2,138,2,138,2
    db 139,2,139,2,140,2,141,2,141,2,142,2,142,2,143,2
    db 144,2,144,2,145,2,145,2,146,2,147,2,147,2,148,2
    db 148,2,149,2,150,2,150,2,151,2,151,2,152,2,153,2
    db 153,2,154,2,154,2,155,2,156,2,156,2,157,2,157,2
    db 158,2,159,2,159,2,160,2,160,2,161,2,162,2,162,2
    db 163,2,163,2,164,2,165,2,165,2,166,2,166,2,167,2
    db 168,2,168,2,169,2,170,2,170,2,171,2,171,2,172,2
    db 173,2,173,2,20,171,255,255,15,0,20,158,255,255,0,1
    db 18,25,240,240,14,1,17,0,243,244,0,0,0,0,0,0
    db 0,0,0,0,18,0,255,255,0,0,18,26,255,255,0,5
    db 19,27,243,245,0,1,1,0,244,245,0,0,0,0,0,0
    db 0,0,0,0,49,147,253,205,1,2,114,147,253,221,0,3
    db 50,21,255,36,0,1,241,2,211,243,0,0,0,0,0,0
    db 0,0,0,0,49,148,223,255,1,0,114,148,223,255,0,4
    db 50,18,217,41,0,2,241,2,211,185,0,0,0,0,0,0
    db 0,0,0,0,16,0,255,249,14,0,16,9,255,175,0,2
    db 1,16,244,233,15,1,17,1,243,201,0,0,0,0,0,0
    db 0,0,0,0,179,193,223,223,0,0,243,215,220,255,0,7
    db 178,23,211,211,1,2,241,128,210,243,0,0,0,0,0,0
    db 0,0,0,0,0,28,239,175,1,0,2,18,255,160,0,1
    db 1,1,223,34,0,0,1,4,245,213,0,0,0,0,0,0
    db 0,0,0,0,0,0,255,255,15,0,2,30,255,6,0,4
    db 2,37,243,245,14,0,0,3,179,245,0,0,0,0,0,0
    db 0,0,0,48,0,8,255,255,0,0,0,30,156,255,0,0
    db 2,28,212,247,1,0,1,0,212,247,0,0,0,0,0,0
    db 0,0,0,0,48,225,251,224,14,3,50,220,244,230,0,3
    db 53,148,240,243,15,2,1,1,244,245,0,0,0,0,0,0
    db 0,0,0,0,18,18,223,255,1,0,23,20,223,253,0,6
    db 28,11,246,252,1,6,1,0,212,245,0,0,0,0,0,0
    db 0,0,0,0,128,0,255,255,14,0,128,54,255,255,0,1
    db 140,92,243,245,14,1,194,0,243,245,0,0,0,0,0,0
    db 0,0,0,0,0,0,255,255,0,0,0,14,159,255,0,0
    db 2,24,245,245,1,0,1,0,245,245,0,0,0,0,0,0
    db 0,0,0,0,3,18,255,255,14,1,3,210,255,254,0,1
    db 5,207,248,88,15,6,1,0,243,246,0,0,0,0,0,0
    db 0,0,0,0,33,28,207,239,0,0,33,18,245,230,0,1
    db 36,23,245,229,1,0,1,6,196,228,0,0,0,0,0,0
    db 0,0,0,0,1,158,255,239,14,0,2,158,243,239,0,2
    db 1,30,247,67,14,3,17,0,243,212,0,0,0,0,0,0
    db 0,0,0,0,34,82,127,191,4,7,34,82,127,159,0,6
    db 34,78,115,255,5,5,225,3,115,255,0,0,0,0,0,0
    db 0,0,0,0,34,82,127,191,4,7,34,82,127,159,0,6
    db 33,142,115,255,5,5,226,3,115,255,0,0,0,0,0,0
    db 0,0,0,0,2,72,255,191,4,0,2,72,255,158,0,2
    db 2,78,243,255,5,2,1,0,244,255,0,0,0,0,0,0
    db 0,0,0,0,34,91,127,191,4,0,34,92,127,159,0,0
    db 33,24,115,252,5,5,225,0,116,255,0,0,0,0,0,0
    db 0,0,0,0,32,67,127,191,4,0,32,18,127,159,0,0
    db 33,20,115,252,5,4,225,0,116,255,0,0,0,0,0,0
    db 0,0,0,0,49,37,80,255,14,4,49,0,80,255,0,5
    db 50,45,255,255,15,2,177,0,85,255,0,0,0,0,0,0
    db 0,0,0,0,193,69,127,255,0,0,193,104,125,255,0,2
    db 193,30,116,255,1,3,193,0,116,255,0,0,0,0,0,0
    db 0,0,0,0,17,33,80,255,14,4,17,0,64,255,0,4
    db 19,0,255,255,15,2,209,0,85,255,0,0,0,0,0,0
    db 0,0,0,0,17,0,242,255,14,0,16,28,252,255,0,5
    db 18,27,241,242,14,1,1,0,212,255,0,0,0,0,0,0
    db 0,0,0,0,17,8,255,255,8,0,16,40,255,255,0,3
    db 1,8,244,243,8,1,2,1,244,255,0,0,0,0,0,0
    db 0,0,0,0,17,18,255,255,14,0,18,30,255,255,0,5
    db 19,30,243,255,14,1,1,0,211,255,0,0,0,0,0,0
    db 0,0,0,0,0,37,255,255,0,0,0,33,255,255,0,5
    db 1,5,240,240,1,0,1,0,244,246,0,0,0,0,0,0
    db 0,0,0,0,0,8,255,255,0,0,0,5,255,255,0,2
    db 1,8,240,255,1,1,2,1,244,255,0,0,0,0,0,0
    db 0,0,0,0,32,8,255,255,1,0,32,8,255,255,0,0
    db 33,8,240,255,0,1,34,0,243,255,0,0,0,0,0,0
    db 0,0,0,0,32,8,255,255,1,0,32,8,255,255,0,0
    db 33,8,240,255,0,1,34,1,243,255,0,0,0,0,0,0
    db 0,0,0,0,16,28,255,255,1,0,16,8,255,255,0,0
    db 20,76,240,241,0,1,24,11,240,244,0,0,0,0,0,0
    db 0,0,0,0,17,0,196,239,9,0,16,143,223,239,0,7
    db 16,23,239,240,9,7,209,0,227,246,0,4,0,0,0,0
    db 0,0,0,0,17,2,243,239,7,5,16,161,215,239,0,3
    db 16,30,229,255,6,2,209,0,227,255,0,0,0,0,0,0
    db 0,0,0,0,1,30,255,239,6,0,2,0,255,239,0,0
    db 1,18,240,246,7,2,2,0,244,245,0,0,0,0,0,0
    db 0,0,0,0,32,28,255,255,1,0,32,23,243,255,0,2
    db 35,0,243,255,1,0,34,3,255,255,0,0,0,0,0,0
    db 0,0,0,0,1,28,255,247,1,0,1,30,244,247,0,2
    db 1,14,242,255,0,0,2,1,245,255,0,0,0,0,0,0
    db 0,0,0,0,1,28,255,247,1,0,1,30,244,247,0,2
    db 1,78,242,255,0,0,2,0,245,255,0,0,0,0,0,0
    db 0,0,0,0,0,33,245,239,14,2,0,29,245,239,0,2
    db 0,144,243,239,14,0,0,0,245,249,0,0,0,0,0,0
    db 0,0,0,0,1,25,255,247,1,0,1,19,244,247,0,2
    db 1,83,242,255,0,0,2,1,245,255,0,0,0,0,0,0
    db 0,0,0,0,18,31,81,242,14,0,17,0,80,246,0,1
    db 18,64,79,255,15,0,18,28,95,255,0,0,0,0,0,0
    db 0,0,0,0,17,31,81,210,14,0,17,0,80,211,0,1
    db 19,64,79,255,15,0,19,28,95,255,0,0,0,0,0,0
    db 0,0,0,0,17,30,81,242,14,0,17,0,80,249,0,1
    db 17,0,79,255,15,0,17,28,95,255,0,0,0,0,0,0
    db 0,0,0,0,17,31,80,210,14,0,17,0,81,211,0,1
    db 16,147,79,255,15,3,18,23,95,255,0,2,0,0,0,0
    db 0,0,0,0,209,30,66,243,14,4,209,0,64,244,0,1
    db 210,7,79,255,15,3,209,28,79,255,0,2,0,0,0,0
    db 0,0,0,0,0,0,255,255,0,0,0,38,223,255,0,1
    db 1,28,246,255,0,1,1,0,181,245,0,0,0,0,0,0
    db 0,0,0,0,16,41,143,223,0,1,16,41,161,210,0,0
    db 18,41,209,210,0,0,16,6,146,210,0,0,0,0,0,0
    db 0,0,0,48,17,0,244,246,7,0,18,0,252,253,0,0
    db 18,30,254,255,7,0,17,0,252,255,0,0,0,0,0,0
    db 0,0,0,0,49,30,79,255,14,0,49,30,79,255,0,0
    db 49,19,64,243,15,1,241,3,64,243,0,0,0,0,0,0
    db 0,0,0,0,49,30,47,255,14,0,49,30,47,255,0,0
    db 49,19,32,240,15,1,241,3,32,244,0,0,0,0,0,0
    db 0,0,0,0,49,30,79,255,14,0,49,30,79,255,0,0
    db 49,19,64,243,15,1,240,1,64,243,0,0,0,0,0,0
    db 0,0,0,0,0,7,79,255,6,0,0,33,79,255,0,1
    db 2,19,68,198,7,2,1,8,68,198,0,0,0,0,0,0
    db 0,0,0,0,80,23,127,255,0,1,80,69,127,255,0,4
    db 80,82,128,255,1,4,209,1,113,255,0,0,0,0,0,0
    db 0,0,0,0,17,18,79,255,0,4,17,87,79,255,0,4
    db 17,75,66,242,1,2,17,3,65,243,0,0,0,0,0,0
    db 0,0,0,0,192,0,95,255,0,0,192,38,79,255,0,5
    db 192,19,64,240,1,2,49,0,81,244,0,0,0,0,0,0
    db 0,0,0,0,18,192,255,251,1,0,18,192,255,253,0,2
    db 18,192,252,253,1,3,17,0,196,105,0,4,0,0,0,0
    db 0,0,0,0,1,29,127,255,14,2,1,28,85,249,0,1
    db 1,16,114,239,14,1,1,4,130,252,0,0,0,0,0,0
    db 0,0,0,0,1,26,241,255,14,0,2,1,115,255,0,0
    db 0,0,255,255,15,1,128,0,127,255,0,2,0,0,0,0
    db 0,0,0,0,1,33,241,255,14,0,2,0,116,255,0,0
    db 1,158,255,255,15,1,128,0,87,247,0,2,0,0,0,0
    db 0,0,0,0,208,25,255,255,6,2,16,28,78,253,0,2
    db 18,20,64,215,7,1,81,3,64,216,0,0,0,0,0,0
    db 0,0,0,0,1,29,241,255,14,0,2,0,116,255,0,0
    db 0,94,255,255,15,1,128,0,87,247,0,2,0,0,0,0
    db 0,0,0,0,1,38,127,255,14,2,1,30,116,255,0,1
    db 1,20,114,255,14,1,1,0,114,255,0,0,0,0,0,0
    db 0,0,0,0,1,29,127,223,14,2,1,92,116,249,0,1
    db 1,18,112,239,14,1,2,3,114,252,0,0,0,0,0,0
    db 0,0,0,0,1,40,127,255,14,2,1,40,85,255,0,1
    db 3,83,114,231,14,1,1,1,129,248,0,0,0,0,0,0
    db 0,0,0,0,209,58,83,135,7,3,17,31,64,135,0,2
    db 17,23,64,167,6,1,81,2,64,168,0,0,0,0,0,0
    db 0,0,0,0,209,58,83,135,7,3,17,31,64,135,0,2
    db 17,23,64,167,6,1,82,2,64,168,0,0,0,0,0,0
    db 0,0,0,0,128,40,255,255,15,0,128,51,255,255,0,0
    db 65,72,242,249,14,0,146,0,82,249,0,0,0,0,0,0
    db 0,0,0,0,128,40,255,255,15,0,128,51,255,255,0,0
    db 65,8,242,249,14,0,146,0,82,249,0,0,0,0,0,0
    db 0,0,0,0,16,33,95,255,14,0,16,33,95,255,0,1
    db 17,15,80,240,15,0,17,0,80,255,0,0,0,0,0,0
    db 0,0,0,0,1,28,241,255,14,0,2,5,115,255,0,0
    db 0,64,255,255,15,1,128,0,127,255,0,2,0,0,0,0
    db 0,0,0,0,16,33,95,255,14,0,16,33,95,255,0,1
    db 17,15,80,240,15,0,17,0,80,255,0,0,0,0,0,0
    db 0,0,0,0,17,82,95,253,14,0,17,97,95,253,0,0
    db 18,151,80,235,15,1,16,2,80,248,0,0,0,0,0,0
    db 0,0,0,0,2,94,159,255,1,0,2,83,114,253,0,0
    db 1,87,115,204,0,0,2,2,114,188,0,0,0,0,0,0
    db 0,0,0,0,1,64,95,191,4,3,1,97,95,255,0,2
    db 1,77,82,240,5,2,17,0,80,255,0,0,0,0,0,0
    db 0,0,0,0,1,82,111,205,0,2,1,102,111,205,0,1
    db 1,72,98,207,1,2,1,2,98,207,0,0,0,0,0,0
    db 0,0,0,0,1,83,111,254,0,0,1,72,109,254,0,0
    db 1,83,97,252,1,1,65,0,97,252,0,0,0,0,0,0
    db 0,0,0,0,2,105,95,191,4,0,1,155,95,255,0,2
    db 1,79,97,255,5,1,17,0,65,255,0,0,0,0,0,0
    db 0,0,0,0,129,64,255,255,0,0,129,75,255,255,0,1
    db 193,91,146,246,1,3,193,0,146,247,0,0,0,0,0,0
    db 0,0,0,0,0,158,60,255,6,2,2,158,60,254,0,1
    db 1,158,2,255,7,4,2,0,98,255,0,0,0,0,0,0
    db 0,0,0,0,145,78,95,253,14,2,145,83,95,253,0,0
    db 146,85,80,235,15,1,145,0,80,248,0,0,0,0,0,0
    db 0,0,0,0,16,8,95,255,14,6,0,41,95,255,0,6
    db 6,192,255,255,15,6,1,5,242,246,0,6,0,0,0,0
    db 0,0,0,0,16,1,255,255,14,0,16,0,255,255,0,3
    db 18,0,255,226,14,0,16,0,144,249,0,3,0,0,0,0
    db 0,0,0,0,32,33,127,191,4,7,32,33,127,191,0,6
    db 33,19,115,249,5,5,226,1,115,249,0,0,0,0,0,0
    db 0,0,0,0,32,30,159,191,14,7,32,30,159,191,0,6
    db 33,19,147,249,15,5,226,1,147,249,0,0,0,0,0,0
    db 0,0,0,0,16,30,79,255,14,0,16,5,79,255,0,7
    db 1,94,64,247,15,7,17,0,65,247,0,0,0,0,0,0
    db 0,0,0,0,2,98,108,191,4,3,2,91,108,255,0,2
    db 2,84,99,250,5,2,17,64,96,250,0,0,0,0,0,0
    db 0,0,0,0,16,30,255,255,14,0,16,30,255,255,0,7
    db 1,94,240,247,15,7,17,0,65,247,0,0,0,0,0,0
    db 0,0,0,0,16,18,255,255,14,2,16,17,255,169,0,2
    db 1,68,243,231,15,1,17,0,240,198,0,0,0,0,0,0
    db 0,0,0,0,32,8,255,255,4,2,32,28,255,255,0,2
    db 33,24,242,245,5,2,225,0,242,245,0,0,0,0,0,0
    db 0,0,0,0,32,30,95,255,4,2,32,30,95,255,0,2
    db 34,94,82,245,5,2,225,0,82,245,0,0,0,0,0,0
    db 0,0,0,0,1,25,83,245,10,1,3,18,83,229,0,0
    db 1,8,83,229,11,1,129,0,83,245,0,0,0,0,0,0
    db 0,0,0,0,17,28,63,255,0,0,17,28,255,255,0,3
    db 18,28,50,245,0,2,145,0,49,229,0,0,0,0,0,0
    db 0,0,0,0,18,107,255,251,0,2,18,171,255,251,0,3
    db 18,146,66,245,0,2,145,0,65,245,0,0,0,0,0,0
    db 0,0,0,0,49,30,79,255,14,0,49,30,79,255,0,0
    db 49,19,64,243,15,1,241,3,64,243,0,0,0,0,0,0
    db 0,0,0,0,2,40,95,239,14,0,1,28,95,239,0,0
    db 1,22,81,233,15,2,1,0,81,233,0,0,0,0,0,0
    db 0,0,0,0,17,33,49,241,14,0,210,0,50,241,0,1
    db 81,37,63,255,15,0,209,0,20,255,0,0,0,0,0,0
    db 0,0,0,0,0,33,207,237,14,1,1,33,252,237,0,0
    db 6,33,245,229,15,2,2,3,196,228,0,0,0,0,0,0
    db 0,0,0,0,0,0,111,239,14,1,0,41,111,239,0,0
    db 2,30,99,226,15,2,1,1,96,229,0,0,0,0,0,0
    db 0,0,0,0,5,33,207,239,14,0,1,33,255,239,0,0
    db 1,72,244,231,15,1,1,0,195,229,0,0,0,0,0,0
    db 0,0,0,0,0,28,207,238,14,0,0,28,255,238,0,2
    db 1,18,244,228,15,2,1,0,244,244,0,0,0,0,0,0
    db 0,0,0,0,16,1,255,255,10,0,16,1,255,255,0,0
    db 17,94,241,242,10,3,209,0,242,244,0,0,0,0,0,0
    db 0,0,0,0,18,31,33,245,14,4,209,3,34,245,0,1
    db 82,0,3,245,15,7,209,0,34,245,0,4,0,0,0,0
    db 0,0,0,0,20,0,255,255,14,2,210,8,255,253,0,1
    db 80,192,244,245,15,2,209,0,243,245,0,0,0,0,0,0
    db 0,0,0,0,209,29,66,243,14,4,209,0,64,244,0,1
    db 210,3,79,255,15,3,209,29,79,255,0,2,0,0,0,0
    db 0,0,0,0,129,72,253,254,14,4,129,94,254,254,0,3
    db 130,13,244,244,15,1,193,5,180,246,0,0,0,0,0,0
    db 0,0,0,0,131,102,159,255,14,2,195,83,159,255,0,0
    db 131,81,149,245,15,0,193,0,148,245,0,0,0,0,0,0
    db 0,0,0,0,0,50,244,148,1,0,3,22,244,7,0,4
    db 2,37,243,6,0,0,192,0,243,5,0,3,0,0,0,0
    db 0,0,0,0,128,128,255,255,15,2,131,24,255,255,0,3
    db 130,146,243,244,14,1,129,0,244,245,0,0,0,0,0,0
    db 0,0,0,0,128,0,255,255,1,0,131,82,255,38,0,2
    db 129,28,245,246,0,0,129,0,244,245,0,0,0,0,0,0
    db 0,0,0,0,49,38,80,255,14,4,49,0,64,255,0,5
    db 48,25,255,255,15,2,177,0,85,255,0,5,0,0,0,0
    db 0,0,0,0,49,28,242,255,14,4,49,3,66,255,0,5
    db 48,28,242,255,15,2,178,0,82,255,0,0,0,0,0,0
    db 0,0,0,0,17,97,95,255,14,0,17,97,95,255,0,1
    db 17,11,80,240,15,0,17,0,80,255,0,0,0,0,0,0
    db 0,0,0,0,0,0,15,255,0,0,0,0,15,255,0,0
    db 2,0,5,245,1,0,2,0,245,245,0,0,0,0,0,0
    db 0,0,0,0,13,116,242,243,0,0,12,94,242,245,0,1
    db 6,200,242,245,0,1,2,0,244,214,0,0,0,0,0,0
    db 0,0,0,0,0,0,255,239,0,0,0,192,255,239,0,0
    db 5,20,244,230,1,2,130,0,246,229,0,0,0,0,0,0
    db 0,0,0,0,1,3,255,255,1,0,2,19,246,255,0,0
    db 1,3,248,245,1,0,129,0,213,245,0,0,0,0,0,0
    db 0,0,0,0,0,64,255,255,0,0,0,192,252,255,0,7
    db 0,0,252,83,1,5,0,0,196,38,0,0,0,0,0,0
    db 0,0,0,0,0,0,255,255,0,0,0,0,252,255,0,2
    db 0,0,252,83,1,2,3,0,196,38,0,0,0,0,0,0
    db 0,0,0,0,16,64,255,255,1,3,16,64,255,255,0,1
    db 16,64,249,249,1,1,17,0,148,245,0,6,0,0,0,0
    db 0,0,0,0,0,20,240,255,14,0,0,2,240,255,0,0
    db 0,2,240,255,14,0,0,5,63,255,0,0,0,0,0,0
    db 0,0,0,0,49,30,66,255,15,0,49,211,66,255,0,2
    db 48,19,50,255,15,2,40,8,77,255,0,0,0,0,0,0
    db 0,0,0,0,4,5,73,255,14,0,2,69,153,255,0,0
    db 2,5,150,255,14,1,1,5,66,159,0,0,0,0,0,0
    db 0,0,0,0,0,0,240,241,14,0,0,2,240,241,0,0
    db 0,2,240,241,14,0,0,8,34,242,0,0,0,0,0,0
    db 0,0,0,0,192,0,13,255,15,0,192,0,14,207,0,1
    db 195,0,13,255,15,1,195,0,66,251,0,0,0,0,0,0
    db 0,0,0,0,15,18,204,255,1,5,15,236,252,255,0,5
    db 7,151,252,17,0,5,6,0,252,5,0,0,0,0,0,0
    db 0,0,0,0,2,28,159,255,14,0,2,33,31,255,0,0
    db 0,0,145,241,14,0,1,0,50,50,0,0,0,0,0,0
    db 0,0,0,208,0,0,240,241,14,0,0,8,242,241,0,0
    db 0,8,112,241,14,0,0,13,114,242,0,0,0,0,0,0
    db 0,0,0,0,0,64,255,255,0,0,0,192,252,255,0,6
    db 0,0,252,83,1,4,0,0,196,38,0,0,0,0,0,0
    db 0,0,0,0,0,0,11,0,168,214,76,69,0,0,0,6
    db 0,0,0,0,0,0,11,0,170,210,200,183,0,0,0,6
    db 0,0,0,0,38,0,0,0,240,250,240,183,3,3,14,6
    db 0,0,0,0,16,194,7,35,247,224,245,65,2,2,130,7
    db 0,0,0,0,242,241,10,56,136,173,244,136,2,2,2,7
    db 0,0,0,0,208,194,129,35,166,224,246,65,2,2,129,7
    db 0,0,0,0,64,194,0,35,245,224,56,65,0,2,5,8
    db 0,0,0,0,1,194,3,35,184,224,181,65,1,2,125,10
    db 0,0,0,0,64,194,0,35,245,224,56,65,0,2,241,8
    db 0,0,0,0,1,179,8,193,136,24,165,80,1,0,163,10
    db 0,0,0,0,0,194,0,35,198,224,152,65,0,2,131,8
    db 0,0,0,0,1,179,9,193,134,24,165,80,1,0,163,10
    db 0,0,0,0,0,194,0,35,198,224,152,65,0,2,3,8
    db 0,0,0,0,0,194,0,35,198,224,152,65,0,2,5,8
    db 0,0,0,0,4,194,12,35,197,224,246,65,0,2,5,9
    db 0,0,0,0,1,194,0,35,198,224,152,65,0,2,5,8
    db 0,0,0,0,1,194,130,35,246,224,213,65,1,2,131,10
    db 0,0,0,0,3,191,9,255,227,208,151,80,0,0,187,10
    db 0,0,0,0,14,191,7,255,181,209,21,80,1,0,187,10
    db 0,0,0,0,1,191,7,193,119,209,115,80,1,0,187,10
    db 0,0,0,0,14,241,199,56,149,173,120,142,0,2,2,9
    db 0,0,0,0,1,191,0,255,248,210,182,80,1,0,186,10
    db 0,0,0,0,10,194,199,35,149,224,120,65,0,2,124,9
    db 0,0,0,0,1,191,7,193,249,212,181,80,0,0,187,9
    db 0,0,0,0,209,194,5,35,231,224,101,65,1,2,157,9
    db 0,0,0,0,1,254,0,56,231,169,148,130,0,2,3,8
    db 0,0,0,0,1,191,0,255,231,216,148,80,0,0,187,8
    db 0,0,0,0,1,191,0,255,150,216,103,80,0,0,186,8
    db 0,0,0,0,1,191,0,255,180,218,38,80,0,0,186,8
    db 0,0,0,0,1,191,0,193,180,219,38,80,0,0,186,8
    db 0,0,0,0,149,19,129,0,231,149,1,101,0,0,14,6
    db 0,0,0,0,149,19,129,0,231,149,1,101,0,0,14,6
    db 0,0,0,0,16,191,0,193,150,222,103,80,0,0,186,9
    db 0,0,0,0,17,191,0,255,150,223,103,80,0,0,186,9
    db 0,0,0,0,0,191,14,193,88,208,220,80,2,0,186,7
    db 0,0,0,0,0,191,14,255,90,210,214,80,2,0,186,7
    db 0,0,0,0,82,191,7,193,73,211,4,80,3,0,187,8
    db 0,0,0,0,82,191,7,193,65,212,2,80,3,0,187,8
    db 0,0,0,0,0,191,14,255,90,213,214,80,1,0,186,7
    db 0,0,0,0,16,191,14,193,83,214,159,80,1,0,186,7
    db 0,0,0,0,17,254,0,56,245,169,117,128,0,2,2,8
    db 0,0,0,0,4,194,0,35,248,224,182,65,1,2,3,8
    db 0,0,0,0,4,194,0,35,248,224,183,65,1,2,3,8
    db 0,0,0,0,1,191,11,193,94,216,220,80,1,0,186,7
    db 0,0,0,0,0,191,7,193,92,218,220,80,1,0,186,7
    db 0,0,0,0,197,213,79,0,242,244,96,122,0,0,8,6
    db 0,0,0,0,197,213,79,0,242,242,96,114,0,0,8,6
    db 0,0,0,0,128,129,130,131,132,0,143,135,143,137,143,139
    db 143,143,142,143,144,0,0,147,0,160,0,0,0,153,154,155
    db 156,157,143,143,160,161,162,163,164,165,166,0,168,0,0,0
    db 0,0,0,0,47,36,67,60,60,60,48,60,52,60,55,60
    db 60,64,60,67,60,60,60,60,60,48,60,60,60,67,62,67
    db 67,60,60,55,53,48,60,60,79,79,60,60,91,60,53,60
    db 60,79,79,0,48,48,48,48,48,48,48,48,48,48,48,48
    db 48,48,48,48,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,32
    db 33,34,32,33,34,48,52,50,53,49,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,255,255,255,255,255,255,255,255,255,255,255,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255
    db 255,255,255,255,255,255,255,255,255,192,193,194,192,193,194,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,16,8,4,2,1,6,7,8,8,7,8,10
    db 9,13,166,167,168,168,167,0,0,193,255,240,255,248,255,250
    db 255,252,255,253,255,254,255,255,255,0,0,2,0,4,0,5
    db 0,6,0,7,0,8,0,9,0,10,0,12,0,10,7,64
    db 136,29,118,29,233,29,32,33,34,35,36,37,40,41,42,43
    db 44,45,48,49,50,51,52,53

driver ends

songs_midi segment READONLY para ; The para isn't needed because it's the default, but why not keep it.
; On the other hand, the song file doesn't need to have offest 0, but was put on another segment in case more songs
; want to be used, to exist space for them - since every segment can only have 64 kB of data.
; IT would be possible to put more sons, it would be just open the files, read and put in an array, and send to the Sound
; Blaster for it to read that, but more time would be needed.

	queen_i_want_to_break_free:
    db 77,84,104,100,0,0,0,6,0,1,0,15,0,240,77,84
    db 114,107,0,0,0,19,0,255,88,4,4,2,24,8,0,255
    db 81,3,8,122,35,0,255,47,0,77,84,114,107,0,0,0
    db 138,0,255,3,12,83,111,102,116,32,75,97,114,97,111,107
    db 101,0,255,1,19,64,75,77,73,68,73,32,75,65,82,65
    db 79,75,69,32,70,73,76,69,0,255,1,6,64,86,48,49
    db 48,48,0,255,1,24,64,73,87,114,105,116,116,101,110,32
    db 98,121,32,74,111,104,110,32,68,101,97,99,111,110,0,255
    db 1,29,64,73,77,73,68,73,32,102,105,108,101,32,98,121
    db 32,84,114,105,115,116,97,32,76,121,99,111,115,107,121,0
    db 255,1,20,64,73,75,65,82,32,102,105,108,101,32,98,121
    db 32,77,97,114,107,32,66,0,255,47,0,77,84,114,107,0
    db 0,8,161,0,255,3,5,87,111,114,100,115,0,255,1,6
    db 64,76,69,78,71,76,0,255,1,22,64,84,73,32,87,97
    db 110,116,32,116,111,32,66,114,101,97,107,32,70,114,101,101
    db 0,255,1,7,64,84,81,85,69,69,78,153,40,255,1,3
    db 92,73,32,120,255,1,5,119,97,110,116,32,129,36,255,1
    db 3,116,111,32,129,38,255,1,6,98,114,101,97,107,32,129
    db 22,255,1,5,102,114,101,101,32,120,255,1,0,137,48,255
    db 1,3,47,73,32,120,255,1,5,119,97,110,116,32,129,36
    db 255,1,3,116,111,32,129,38,255,1,6,98,114,101,97,107
    db 32,129,82,255,1,4,102,114,101,101,137,108,255,1,3,47
    db 73,32,120,255,1,5,119,97,110,116,32,129,36,255,1,3
    db 116,111,32,129,38,255,1,6,98,114,101,97,107,32,129,22
    db 255,1,5,102,114,101,101,32,129,36,255,1,5,102,114,111
    db 109,32,129,38,255,1,5,121,111,117,114,32,129,22,255,1
    db 4,108,105,101,115,129,36,255,1,8,47,89,111,117,39,114
    db 101,32,129,38,255,1,3,115,111,32,130,58,255,1,5,115
    db 101,108,102,32,129,38,255,1,10,115,97,116,105,115,102,105
    db 101,100,32,74,255,1,0,129,68,255,1,0,120,255,1,3
    db 47,73,32,120,255,1,6,100,111,110,39,116,32,120,255,1
    db 5,110,101,101,100,32,130,104,255,1,0,60,255,1,0,60
    db 255,1,4,121,111,117,32,120,255,1,0,133,80,255,1,6
    db 47,73,39,118,101,32,120,255,1,4,103,111,116,32,129,36
    db 255,1,3,116,111,32,129,38,255,1,6,98,114,101,97,107
    db 32,129,22,255,1,5,102,114,101,101,32,120,255,1,0,60
    db 255,1,0,139,92,255,1,5,47,71,111,100,32,129,112,255
    db 1,6,107,110,111,119,115,32,129,52,255,1,0,60,255,1
    db 0,133,80,255,1,5,47,71,111,100,32,129,36,255,1,6
    db 107,110,111,119,115,32,129,38,255,1,2,73,32,129,22,255
    db 1,5,119,97,110,116,32,129,36,255,1,3,116,111,32,129
    db 38,255,1,6,98,114,101,97,107,32,129,22,255,1,5,102
    db 114,101,101,32,129,52,255,1,0,136,116,255,1,6,92,73
    db 39,118,101,32,120,255,1,7,102,97,108,108,101,110,32,129
    db 52,255,1,0,129,52,255,1,3,105,110,32,120,255,1,5
    db 108,111,118,101,32,120,255,1,0,137,48,255,1,6,47,73
    db 39,118,101,32,120,255,1,7,102,97,108,108,101,110,32,129
    db 52,255,1,0,129,52,255,1,3,105,110,32,120,255,1,5
    db 108,111,118,101,32,129,36,255,1,4,102,111,114,32,129,38
    db 255,1,4,116,104,101,32,129,22,255,1,6,102,105,114,115
    db 116,32,129,36,255,1,4,116,105,109,101,129,38,255,1,5
    db 47,65,110,100,32,129,22,255,1,5,116,104,105,115,32,129
    db 36,255,1,5,116,105,109,101,32,129,38,255,1,2,73,32
    db 129,22,255,1,5,107,110,111,119,32,129,36,255,1,5,105
    db 116,39,115,32,129,38,255,1,4,102,111,114,32,129,22,255
    db 1,5,114,101,97,108,32,130,104,255,1,0,60,255,1,0
    db 60,255,1,0,120,255,1,0,120,255,1,0,132,88,255,1
    db 6,47,73,39,118,101,32,120,255,1,7,102,97,108,108,101
    db 110,32,120,255,1,0,60,255,1,3,105,110,32,129,52,255
    db 1,6,108,111,118,101,44,32,129,112,255,1,0,60,255,1
    db 0,132,28,255,1,4,121,101,97,104,135,64,255,1,5,47
    db 71,111,100,32,129,112,255,1,6,107,110,111,119,115,32,129
    db 52,255,1,0,60,255,1,0,133,80,255,1,5,47,71,111
    db 100,32,129,36,255,1,6,107,110,111,119,115,32,129,38,255
    db 1,5,73,39,118,101,32,129,22,255,1,7,102,97,108,108
    db 101,110,32,129,36,255,1,0,129,38,255,1,3,105,110,32
    db 74,255,1,5,108,111,118,101,32,129,68,255,1,0,60,255
    db 1,0,60,255,1,0,140,24,255,1,6,92,73,116,39,115
    db 32,120,255,1,8,115,116,114,97,110,103,101,32,131,96,255
    db 1,4,98,117,116,32,120,255,1,5,105,116,39,115,32,129
    db 112,255,1,5,116,114,117,101,32,129,112,255,1,0,60,255
    db 1,0,131,36,255,1,3,47,73,32,131,96,255,1,6,99
    db 97,110,39,116,32,120,255,1,4,103,101,116,32,120,255,1
    db 5,111,118,101,114,32,120,255,1,0,120,255,1,0,60,255
    db 1,4,116,104,101,32,60,255,1,4,119,97,121,32,120,255
    db 1,4,121,111,117,32,120,255,1,5,108,111,118,101,32,120
    db 255,1,3,109,101,32,120,255,1,5,108,105,107,101,32,120
    db 255,1,4,121,111,117,32,60,255,1,3,100,111,32,60,255
    db 1,0,129,112,255,1,5,47,66,117,116,32,120,255,1,2
    db 73,32,120,255,1,5,104,97,118,101,32,129,36,255,1,3
    db 116,111,32,129,38,255,1,3,98,101,32,129,22,255,1,4
    db 115,117,114,101,129,112,255,1,6,47,87,104,101,110,32,120
    db 255,1,2,73,32,120,255,1,5,119,97,108,107,32,129,36
    db 255,1,4,111,117,116,32,129,38,255,1,5,116,104,97,116
    db 32,129,22,255,1,5,100,111,111,114,32,60,255,1,0,60
    db 255,1,0,60,255,1,0,131,36,255,1,4,47,79,104,32
    db 120,255,1,4,104,111,119,32,120,255,1,2,73,32,120,255
    db 1,5,119,97,110,116,32,129,36,255,1,3,116,111,32,129
    db 38,255,1,3,98,101,32,129,22,255,1,6,102,114,101,101
    db 44,32,130,104,255,1,5,98,97,98,121,32,120,255,1,0
    db 132,88,255,1,4,47,79,104,32,120,255,1,4,104,111,119
    db 32,120,255,1,2,73,32,120,255,1,5,119,97,110,116,32
    db 129,112,255,1,3,116,111,32,120,255,1,3,98,101,32,120
    db 255,1,5,102,114,101,101,32,120,255,1,0,60,255,1,0
    db 133,20,255,1,4,47,79,104,32,130,104,255,1,4,104,111
    db 119,32,120,255,1,2,73,32,120,255,1,5,119,97,110,116
    db 32,129,112,255,1,3,116,111,32,120,255,1,6,98,114,101
    db 97,107,32,60,255,1,0,129,52,255,1,4,102,114,101,101
    db 227,48,255,1,5,92,66,117,116,32,120,255,1,5,108,105
    db 102,101,32,129,36,255,1,6,115,116,105,108,108,32,129,38
    db 255,1,5,103,111,101,115,32,129,22,255,1,3,111,110,32
    db 120,255,1,0,137,48,255,1,3,47,73,32,120,255,1,6
    db 99,97,110,39,116,32,120,255,1,4,103,101,116,32,120,255
    db 1,5,117,115,101,100,32,120,255,1,3,116,111,32,120,255
    db 1,7,108,105,118,105,110,103,32,60,255,1,0,60,255,1
    db 8,119,105,116,104,111,117,116,32,60,255,1,0,129,52,255
    db 1,8,47,76,105,118,105,110,103,32,60,255,1,0,60,255
    db 1,8,119,105,116,104,111,117,116,32,60,255,1,0,129,52
    db 255,1,8,47,76,105,118,105,110,103,32,60,255,1,0,60
    db 255,1,8,119,105,116,104,111,117,116,32,60,255,1,0,120
    db 255,1,4,121,111,117,32,120,255,1,3,98,121,32,131,36
    db 255,1,3,109,121,32,120,255,1,5,115,105,100,101,32,120
    db 255,1,0,120,255,1,0,137,48,255,1,3,47,73,32,120
    db 255,1,6,100,111,110,39,116,32,120,255,1,5,119,97,110
    db 116,32,120,255,1,3,116,111,32,120,255,1,5,108,105,118
    db 101,32,120,255,1,6,97,108,111,110,101,32,120,255,1,0
    db 120,255,1,0,120,255,1,0,120,255,1,0,133,80,255,1
    db 6,47,72,101,121,44,32,132,88,255,1,4,71,111,100,32
    db 129,112,255,1,5,107,110,111,119,115,137,48,255,1,5,47
    db 71,111,116,32,120,255,1,3,116,111,32,120,255,1,5,109
    db 97,107,101,32,120,255,1,3,105,116,32,120,255,1,3,111
    db 110,32,120,255,1,3,109,121,32,129,112,255,1,3,111,119
    db 110,137,48,255,1,4,47,83,111,32,120,255,1,5,98,97
    db 98,121,32,120,255,1,0,120,255,1,6,99,97,110,39,116
    db 32,120,255,1,4,121,111,117,32,120,255,1,4,115,101,101
    db 32,120,255,1,0,129,112,255,1,0,135,64,255,1,6,47
    db 73,39,118,101,32,120,255,1,4,103,111,116,32,129,36,255
    db 1,3,116,111,32,129,38,255,1,6,98,114,101,97,107,32
    db 129,22,255,1,5,102,114,101,101,32,129,52,255,1,0,135
    db 124,255,1,6,92,73,39,118,101,32,129,112,255,1,4,103
    db 111,116,32,129,36,255,1,3,116,111,32,129,38,255,1,6
    db 98,114,101,97,107,32,129,82,255,1,5,102,114,101,101,32
    db 60,255,1,0,60,255,1,0,136,116,255,1,3,47,73,32
    db 120,255,1,5,119,97,110,116,32,129,36,255,1,3,116,111
    db 32,129,38,255,1,6,98,114,101,97,107,32,131,6,255,1
    db 4,102,114,101,101,134,72,255,1,6,47,89,101,97,104,32
    db 60,255,1,0,149,12,255,1,3,92,73,32,120,255,1,6
    db 119,97,110,116,44,32,129,112,255,1,2,73,32,120,255,1
    db 6,119,97,110,116,44,32,129,112,255,1,2,73,32,120,255
    db 1,6,119,97,110,116,44,32,129,112,255,1,2,73,32,120
    db 255,1,5,119,97,110,116,32,129,112,255,1,3,116,111,32
    db 120,255,1,6,98,114,101,97,107,32,138,40,255,1,4,102
    db 114,101,101,157,8,255,1,5,47,89,101,97,104,144,112,255
    db 1,3,47,73,32,132,12,255,1,5,119,97,110,116,32,129
    db 38,255,1,3,116,111,32,74,255,1,6,98,114,101,97,107
    db 32,76,255,1,5,102,114,101,101,32,129,112,255,1,0,131
    db 20,255,1,4,47,84,111,32,129,38,255,1,6,98,114,101
    db 97,107,32,129,22,255,1,4,102,114,101,101,136,116,255,1
    db 6,47,87,97,110,116,32,60,255,1,3,116,111,32,60,255
    db 1,6,98,114,101,97,107,32,60,255,1,4,102,114,101,101
    db 0,255,47,0,77,84,114,107,0,0,7,180,0,255,3,5
    db 86,111,99,97,108,0,196,82,153,40,148,71,64,90,71,0
    db 30,76,64,129,6,76,0,30,78,64,129,6,78,0,32,78
    db 64,129,6,78,0,16,78,64,120,80,64,30,78,0,60,80
    db 0,136,86,71,64,90,71,0,30,76,64,129,6,76,0,30
    db 78,64,129,6,78,0,32,81,64,129,52,81,0,30,80,64
    db 131,6,80,0,134,102,71,64,90,71,0,30,76,64,129,6
    db 76,0,30,78,64,129,6,78,0,32,78,64,129,6,78,0
    db 16,81,64,129,6,81,0,30,80,64,129,6,80,0,32,78
    db 64,129,6,78,0,16,81,64,129,6,81,0,30,80,64,129
    db 6,80,0,32,78,64,129,6,78,0,129,52,81,64,129,6
    db 81,0,32,80,64,44,80,0,30,78,64,44,78,0,129,24
    db 81,64,90,81,0,30,80,64,90,80,0,30,78,64,90,78
    db 0,30,78,64,130,104,80,64,14,78,0,46,80,0,0,78
    db 64,30,78,0,30,76,64,120,73,64,44,76,0,130,30,73
    db 0,131,6,78,64,90,78,0,30,78,64,129,6,78,0,30
    db 76,64,129,6,76,0,32,73,64,129,6,73,0,16,71,64
    db 120,69,64,14,71,0,46,68,64,14,69,0,130,0,68,0
    db 137,78,80,64,0,76,64,129,82,76,0,0,80,0,30,75
    db 64,0,78,64,129,52,73,64,0,76,64,14,78,0,0,75
    db 0,46,71,64,0,75,64,14,73,0,0,76,0,76,71,0
    db 0,75,0,132,118,81,64,129,6,81,0,30,80,64,129,6
    db 80,0,32,81,64,129,6,81,0,16,80,64,129,6,80,0
    db 30,76,64,129,6,76,0,32,78,64,129,22,76,64,30,78
    db 0,120,76,0,30,76,64,130,14,76,0,134,102,71,64,90
    db 71,0,30,76,64,129,22,76,0,30,78,64,90,78,0,90
    db 78,64,0,81,64,90,81,0,0,78,0,30,78,64,0,81
    db 64,120,80,64,0,83,64,14,81,0,0,78,0,76,80,0
    db 0,83,0,136,86,71,64,90,71,0,30,76,64,129,22,76
    db 0,30,78,64,90,78,0,90,78,64,90,78,0,30,81,64
    db 129,6,81,0,30,80,64,129,6,80,0,32,81,64,129,6
    db 81,0,16,80,64,129,6,80,0,30,76,64,129,6,76,0
    db 32,71,64,129,6,71,0,16,81,64,129,6,81,0,30,80
    db 64,129,6,80,0,32,81,64,129,6,81,0,16,80,64,129
    db 6,80,0,30,78,64,129,6,78,0,32,78,64,129,6,78
    db 0,16,78,64,0,74,64,130,104,80,64,0,76,64,14,74
    db 0,0,78,0,46,78,64,0,73,64,14,80,0,0,76,0
    db 46,76,64,0,69,64,14,78,0,0,73,0,106,73,64,14
    db 76,0,106,64,64,30,69,0,129,52,64,0,0,73,0,131
    db 6,78,64,90,78,0,30,78,64,90,78,0,30,76,64,30
    db 76,0,30,73,64,129,22,73,0,30,71,64,129,112,69,64
    db 14,71,0,46,69,0,0,68,64,30,68,0,131,126,68,64
    db 90,68,0,134,102,80,64,0,76,64,129,82,76,0,0,80
    db 0,30,78,64,0,75,64,129,22,75,0,0,78,0,30,76
    db 64,0,73,64,60,75,64,0,71,64,14,73,0,0,76,0
    db 76,75,0,0,71,0,132,118,81,64,129,6,81,0,30,80
    db 64,129,6,80,0,32,81,64,129,6,81,0,16,80,64,129
    db 6,80,0,30,76,64,129,6,76,0,32,76,64,44,76,0
    db 30,76,64,129,68,71,64,14,76,0,46,73,64,14,71,0
    db 46,76,64,14,73,0,76,76,0,139,62,76,64,90,76,0
    db 30,75,64,131,66,75,0,30,75,64,90,75,0,30,75,64
    db 129,82,75,0,30,76,64,129,112,75,64,14,76,0,46,75
    db 0,0,73,64,30,73,0,131,6,78,64,129,82,78,0,130
    db 14,78,64,90,78,0,30,78,64,90,78,0,30,78,64,90
    db 78,0,30,78,64,90,78,0,30,78,64,30,78,0,30,78
    db 64,30,78,0,30,78,64,90,78,0,30,80,64,90,80,0
    db 30,78,64,90,78,0,30,76,64,90,76,0,30,76,64,90
    db 76,0,30,73,64,30,73,0,30,76,64,60,73,64,30,76
    db 0,60,73,0,129,22,76,64,90,76,0,30,78,64,90,78
    db 0,30,80,64,129,6,80,0,30,78,64,129,6,78,0,32
    db 76,64,129,6,76,0,16,73,64,129,82,73,0,30,76,64
    db 90,76,0,30,78,64,90,78,0,30,80,64,129,6,80,0
    db 30,85,64,129,6,85,0,32,80,64,129,6,80,0,16,78
    db 64,60,80,64,14,78,0,46,78,64,14,80,0,46,78,0
    db 0,76,64,30,76,0,131,6,81,64,90,81,0,30,81,64
    db 90,81,0,30,81,64,90,81,0,30,80,64,129,6,80,0
    db 30,78,64,129,6,78,0,32,76,64,129,6,76,0,16,76
    db 64,130,74,76,0,30,73,64,90,73,0,30,76,64,129,82
    db 76,0,131,6,76,64,90,76,0,30,76,64,90,76,0,30
    db 76,64,90,76,0,30,75,64,129,82,75,0,30,73,64,90
    db 73,0,30,71,64,90,71,0,30,73,64,120,71,64,14,73
    db 0,46,68,64,14,71,0,130,0,68,0,131,6,81,64,130
    db 74,81,0,30,81,64,90,81,0,30,83,64,90,83,0,30
    db 80,64,129,82,80,0,30,78,64,90,78,0,30,80,64,60
    db 78,64,14,80,0,129,8,78,0,30,78,64,132,58,78,0
    db 222,118,71,64,90,71,0,30,76,64,129,6,76,0,30,78
    db 64,129,6,78,0,32,78,64,129,6,78,0,16,78,64,120
    db 80,64,30,78,0,60,80,0,136,86,71,64,90,71,0,30
    db 71,64,90,71,0,30,71,64,90,71,0,30,73,64,90,73
    db 0,30,75,64,90,75,0,30,76,64,30,76,0,30,76,64
    db 30,76,0,30,76,64,30,76,0,30,75,64,129,22,75,0
    db 30,75,64,30,75,0,30,75,64,30,75,0,30,75,64,30
    db 75,0,30,73,64,129,22,73,0,30,73,64,30,73,0,30
    db 73,64,30,73,0,30,73,64,30,73,0,30,71,64,90,71
    db 0,30,73,64,120,68,64,30,73,0,129,112,68,0,129,22
    db 69,64,90,69,0,30,71,64,90,71,0,30,73,64,120,76
    db 64,30,73,0,133,20,76,0,131,126,81,64,0,76,64,90
    db 76,0,0,81,0,30,81,64,0,76,64,90,76,0,0,81
    db 0,30,81,64,0,76,64,90,76,0,0,81,0,30,81,64
    db 0,76,64,90,76,0,0,81,0,30,81,64,0,78,64,90
    db 78,0,0,81,0,30,81,64,0,78,64,90,78,0,0,81
    db 0,30,80,64,0,71,64,104,71,0,16,71,64,0,68,64
    db 30,80,0,90,73,64,0,69,64,30,68,0,0,71,0,90
    db 71,64,0,68,64,30,73,0,0,69,0,130,44,71,0,0
    db 68,0,131,6,80,64,129,82,80,0,131,6,80,64,0,76
    db 64,129,82,76,0,0,80,0,30,75,64,0,78,64,129,82
    db 78,0,0,75,0,135,94,81,64,90,81,0,30,81,64,90
    db 81,0,30,80,64,90,80,0,30,76,64,90,76,0,30,76
    db 64,90,76,0,30,78,64,129,82,78,0,30,76,64,130,74
    db 76,0,134,102,80,64,90,80,0,30,80,64,90,80,0,30
    db 80,64,90,80,0,30,80,64,90,80,0,30,80,64,90,80
    db 0,30,80,64,120,78,64,30,80,0,129,82,80,64,30,78
    db 0,130,44,80,0,132,118,81,64,90,81,0,30,80,64,129
    db 6,80,0,30,76,64,129,6,76,0,32,78,64,129,22,76
    db 64,30,78,0,120,76,0,30,76,64,131,126,76,0,131,126
    db 80,64,129,82,80,0,30,83,64,129,6,83,0,30,80,64
    db 129,6,80,0,32,78,64,129,6,78,0,76,76,64,60,78
    db 64,14,76,0,46,76,64,30,78,0,129,112,76,0,134,102
    db 80,64,90,80,0,30,83,64,129,6,83,0,30,80,64,129
    db 6,80,0,32,85,64,130,104,85,0,30,80,64,134,42,80
    db 0,30,78,64,60,76,64,30,78,0,129,112,76,0,146,126
    db 71,64,90,71,0,30,73,64,129,82,73,0,30,71,64,90
    db 71,0,30,73,64,129,82,73,0,30,71,64,90,71,0,30
    db 76,64,129,82,76,0,30,71,64,90,71,0,30,80,64,129
    db 82,80,0,30,76,64,90,76,0,30,78,64,138,10,78,0
    db 30,76,64,137,18,76,0,141,46,180,7,110,134,72,148,83
    db 64,120,180,7,90,129,82,148,83,0,133,110,180,7,70,135
    db 64,7,50,120,148,80,64,131,110,80,0,30,80,64,129,6
    db 80,0,32,78,64,74,76,64,16,78,0,28,76,0,32,76
    db 64,0,180,7,30,129,82,148,76,0,30,76,64,129,82,76
    db 0,129,66,75,64,129,6,75,0,32,73,64,129,6,73,0
    db 16,71,64,0,180,7,20,129,82,148,71,0,133,110,180,7
    db 10,129,52,148,71,64,30,71,0,30,73,64,30,73,0,30
    db 76,64,30,76,0,30,78,64,132,72,78,0,0,255,47,0
    db 77,84,114,107,0,0,16,50,0,255,3,4,66,97,115,115
    db 0,194,33,0,146,52,64,90,52,0,30,52,64,30,52,0
    db 30,52,64,30,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,129,22,52,64,90,52,0,30,52,64,129,82,52,0
    db 30,52,64,90,52,0,30,52,64,30,52,0,30,52,64,30
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,129,22
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,30,52,0,30,52,64
    db 30,52,0,30,52,64,90,52,0,30,52,64,90,52,0,129
    db 22,52,64,90,52,0,30,47,64,90,47,0,30,44,64,90
    db 44,0,30,40,64,90,40,0,134,102,52,64,90,52,0,30
    db 52,64,30,52,0,30,52,64,30,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,129,22,52,64,90,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,30,52,0,30,52,64,30,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,129,22,52,64,90,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,30,52,0,30,52,64,30,52,0,30,52,64
    db 90,52,0,30,52,64,90,52,0,129,22,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,30,52,0,30,52,64,30,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,129,22,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,30,52,0,30,52,64,30,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,129,22,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,30,52,64,30,52,0,30,52,64,30,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,129,22,52,64
    db 90,52,0,30,52,64,90,52,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,45,64,30,45,0,30,45,64,30,45
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,129,22,45
    db 64,90,45,0,30,45,64,90,45,0,30,45,64,90,45,0
    db 30,45,64,90,45,0,30,45,64,30,45,0,30,45,64,30
    db 45,0,30,45,64,90,45,0,30,45,64,90,45,0,129,22
    db 45,64,90,45,0,30,45,64,90,45,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,30,52,0,30,52,64
    db 30,52,0,30,52,64,90,52,0,30,52,64,90,52,0,129
    db 22,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,30,52,0,30,52
    db 64,30,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 129,22,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,47,64,90,47,0,30,47,64,90,47,0,30
    db 47,64,90,47,0,30,47,64,90,47,0,30,47,64,90,47
    db 0,30,47,64,90,47,0,30,47,64,90,47,0,30,45,64
    db 90,45,0,30,45,64,90,45,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,30,45,64
    db 90,45,0,30,52,64,90,52,0,30,52,64,30,52,0,30
    db 52,64,30,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,129,22,52,64,90,52,0,30,47,64,90,47,0,30,44
    db 64,90,44,0,30,40,64,90,40,0,134,102,52,64,90,52
    db 0,30,52,64,30,52,0,30,52,64,30,52,0,30,52,64
    db 90,52,0,30,52,64,90,52,0,129,22,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,30,52,0,30,52,64,30,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,129,22,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,30,52,0,30,52,64,30,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,129,22,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,30,52,64,30,52,0,30,52,64,30,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,129,22,52,64
    db 90,52,0,30,52,64,90,52,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,45,64,30,45,0,30,45,64,30,45
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,129,22,45
    db 64,90,45,0,30,45,64,90,45,0,30,45,64,90,45,0
    db 30,45,64,90,45,0,30,45,64,30,45,0,30,45,64,30
    db 45,0,30,45,64,90,45,0,30,45,64,90,45,0,129,22
    db 45,64,90,45,0,30,45,64,90,45,0,129,22,52,64,90
    db 52,0,30,52,64,30,52,0,30,52,64,30,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,129,22,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,30,52,0,30,52,64,30,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,129,22,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,30,47
    db 64,90,47,0,30,47,64,90,47,0,30,47,64,90,47,0
    db 30,47,64,90,47,0,30,47,64,90,47,0,30,47,64,90
    db 47,0,30,47,64,90,47,0,30,45,64,90,45,0,30,45
    db 64,90,45,0,30,45,64,90,45,0,30,45,64,90,45,0
    db 30,45,64,90,45,0,30,45,64,90,45,0,30,45,64,90
    db 45,0,30,45,64,90,45,0,30,45,64,90,45,0,30,52
    db 64,90,52,0,30,52,64,30,52,0,30,52,64,30,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,129,22,52,64
    db 90,52,0,30,47,64,90,47,0,30,44,64,90,44,0,30
    db 40,64,90,40,0,30,40,64,90,40,0,30,44,64,90,44
    db 0,30,44,64,90,44,0,30,50,64,90,50,0,30,50,64
    db 90,50,0,30,44,64,30,44,0,30,45,64,90,45,0,30
    db 45,64,30,45,0,30,47,64,90,47,0,30,47,64,90,47
    db 0,30,47,64,90,47,0,30,47,64,90,47,0,30,47,64
    db 90,47,0,30,47,64,90,47,0,30,47,64,90,47,0,30
    db 47,64,90,47,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,30,45,64
    db 90,45,0,30,45,64,90,45,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,47,64,90,47,0,30,47,64,90,47
    db 0,30,47,64,90,47,0,30,47,64,90,47,0,30,47,64
    db 90,47,0,30,47,64,90,47,0,30,47,64,90,47,0,30
    db 47,64,90,47,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,30,45,64
    db 90,45,0,30,45,64,90,45,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,49,64,90,49,0,30,49,64,90,49
    db 0,30,49,64,90,49,0,30,49,64,90,49,0,30,49,64
    db 90,49,0,30,49,64,90,49,0,30,49,64,90,49,0,30
    db 49,64,90,49,0,30,42,64,90,42,0,30,42,64,90,42
    db 0,30,42,64,90,42,0,30,42,64,90,42,0,30,42,64
    db 90,42,0,30,42,64,90,42,0,30,42,64,90,42,0,30
    db 42,64,90,42,0,30,45,64,129,82,45,0,30,45,64,129
    db 82,45,0,30,47,64,129,82,47,0,30,47,64,129,82,47
    db 0,30,49,64,90,49,0,30,49,64,90,49,0,30,49,64
    db 90,49,0,30,49,64,90,49,0,30,49,64,90,49,0,129
    db 22,47,64,90,47,0,129,22,45,64,130,74,45,0,30,45
    db 64,90,45,0,30,47,64,129,82,47,0,30,47,64,129,82
    db 47,0,30,49,64,90,49,0,30,49,64,90,49,0,30,49
    db 64,90,49,0,30,49,64,90,49,0,30,49,64,90,49,0
    db 129,22,47,64,90,47,0,129,22,45,64,129,82,45,0,30
    db 45,64,90,45,0,30,45,64,90,45,0,30,47,64,129,82
    db 47,0,30,47,64,129,82,47,0,30,52,64,0,40,64,90
    db 40,0,0,52,0,30,52,64,0,40,64,30,40,0,0,52
    db 0,30,52,64,0,40,64,30,40,0,0,52,0,30,52,64
    db 0,40,64,90,40,0,0,52,0,30,52,64,0,40,64,90
    db 40,0,0,52,0,129,22,52,64,90,52,0,30,47,64,90
    db 47,0,30,44,64,90,44,0,30,40,64,90,40,0,134,102
    db 52,64,90,52,0,30,52,64,30,52,0,30,52,64,30,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,129,22,52
    db 64,90,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,30,52,0,30,52,64,30
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,129,22
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,30,52,0,30,52,64
    db 30,52,0,30,52,64,90,52,0,30,52,64,90,52,0,129
    db 22,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,30,52,0,30,52
    db 64,30,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 129,22,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,45,64,90,45,0,30,45,64,30,45,0,30
    db 45,64,30,45,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,129,22,45,64,90,45,0,30,45,64,90,45,0,30,45
    db 64,90,45,0,30,45,64,90,45,0,30,45,64,30,45,0
    db 30,45,64,30,45,0,30,45,64,90,45,0,30,45,64,90
    db 45,0,129,22,45,64,90,45,0,30,45,64,90,45,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,30,52
    db 0,30,52,64,30,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,129,22,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,30,52,64,30
    db 52,0,30,52,64,30,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,129,22,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,47,64,90,47,0,30,47,64
    db 90,47,0,30,47,64,90,47,0,30,47,64,90,47,0,30
    db 47,64,90,47,0,30,47,64,90,47,0,30,47,64,90,47
    db 0,30,45,64,90,45,0,30,45,64,90,45,0,30,45,64
    db 90,45,0,30,45,64,90,45,0,30,45,64,90,45,0,30
    db 45,64,90,45,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,30,45,64,90,45,0,30,52,64,90,52,0,30,52,64
    db 30,52,0,30,52,64,30,52,0,30,52,64,90,52,0,30
    db 52,64,90,52,0,129,22,52,64,90,52,0,30,47,64,90
    db 47,0,30,44,64,90,44,0,30,40,64,90,40,0,134,102
    db 52,64,90,52,0,30,52,64,30,52,0,30,52,64,30,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,129,22,52
    db 64,90,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,30,52,0,30,52,64,30
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,129,22
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,30,52,0,30,52,64
    db 30,52,0,30,52,64,90,52,0,30,52,64,90,52,0,129
    db 22,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,30,52,0,30,52
    db 64,30,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 129,22,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,45,64,90,45,0,30,45,64,30,45,0,30
    db 45,64,30,45,0,30,45,64,90,45,0,30,45,64,90,45
    db 0,129,22,45,64,90,45,0,30,45,64,90,45,0,30,45
    db 64,90,45,0,30,45,64,90,45,0,30,45,64,30,45,0
    db 30,45,64,30,45,0,30,45,64,90,45,0,30,45,64,90
    db 45,0,129,22,45,64,90,45,0,30,45,64,90,45,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,30,52
    db 0,30,52,64,30,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,129,22,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,30,52,64,30
    db 52,0,30,52,64,30,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,129,22,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,47,64,129,82,47,0,30,47
    db 64,90,47,0,30,47,64,90,47,0,30,47,64,129,82,47
    db 0,30,47,64,90,47,0,30,47,64,90,47,0,30,45,64
    db 129,82,45,0,30,45,64,90,45,0,30,45,64,90,45,0
    db 30,45,64,129,82,45,0,30,45,64,90,45,0,30,45,64
    db 90,45,0,30,52,64,90,52,0,30,52,64,30,52,0,30
    db 52,64,30,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,129,22,52,64,90,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,30,40,64,90,40,0,30,40,64,90,40,0
    db 30,44,64,90,44,0,30,44,64,90,44,0,30,50,64,90
    db 50,0,30,50,64,90,50,0,30,44,64,90,44,0,30,45
    db 64,90,45,0,30,47,64,129,82,47,0,30,47,64,90,47
    db 0,30,47,64,90,47,0,30,47,64,90,47,0,30,47,64
    db 90,47,0,30,47,64,90,47,0,30,45,64,90,45,0,30
    db 45,64,130,74,45,0,30,45,64,90,45,0,30,45,64,129
    db 82,45,0,30,45,64,90,45,0,30,45,64,90,45,0,30
    db 52,64,90,52,0,30,52,64,30,52,0,30,52,64,30,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,129,22,52
    db 64,90,52,0,30,47,64,90,47,0,30,44,64,90,44,0
    db 30,40,64,90,40,0,134,102,52,64,90,52,0,30,52,64
    db 30,52,0,30,52,64,30,52,0,30,52,64,90,52,0,30
    db 52,64,90,52,0,129,22,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,30,52
    db 64,30,52,0,30,52,64,30,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,129,22,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,90,52,0,30,52,64,90,52,0,30
    db 52,64,30,52,0,30,52,64,30,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,129,22,52,64,90,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,30,52,0,30,52,64,30,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,129,22,52,64,90,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,30,52,0,30,52,64,30,52,0,30,52,64
    db 90,52,0,30,52,64,90,52,0,129,22,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,30,52,0,30,52,64,30,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,129,22,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,30,52,0,30,52,64,30,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,129,22,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,30,52,64,30,52,0,30,52,64,30,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,129,22,52,64
    db 90,52,0,30,52,64,90,52,0,30,52,64,90,52,0,30
    db 52,64,90,52,0,30,52,64,30,52,0,30,52,64,30,52
    db 0,30,52,64,90,52,0,30,52,64,90,52,0,129,22,52
    db 64,90,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,30,52,64,30,52,0,30,52,64,30
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,129,22
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,30,52,0,30,52,64
    db 30,52,0,30,52,64,90,52,0,30,52,64,90,52,0,129
    db 22,52,64,90,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,30,52,64,30,52,0,30,52
    db 64,30,52,0,30,52,64,90,52,0,30,52,64,90,52,0
    db 129,22,52,64,90,52,0,30,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,0,178,7,110,90,146,52,0,30,52
    db 64,30,52,0,30,52,64,30,52,0,30,52,64,90,52,0
    db 30,52,64,90,52,0,129,22,52,64,90,52,0,30,52,64
    db 90,52,0,30,52,64,90,52,0,30,52,64,0,178,7,90
    db 90,146,52,0,30,52,64,30,52,0,30,52,64,30,52,0
    db 30,52,64,90,52,0,30,52,64,90,52,0,129,22,52,64
    db 90,52,0,30,52,64,90,52,0,30,52,64,90,52,0,30
    db 52,64,0,178,7,70,90,146,52,0,30,52,64,30,52,0
    db 30,52,64,30,52,0,30,52,64,90,52,0,30,52,64,90
    db 52,0,129,22,52,64,90,52,0,30,52,64,90,52,0,30
    db 52,64,90,52,0,30,52,64,0,178,7,50,90,146,52,0
    db 30,52,64,30,52,0,30,52,64,30,52,0,30,52,64,90
    db 52,0,30,52,64,90,52,0,129,22,52,64,90,52,0,30
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,0,178
    db 7,30,90,146,52,0,30,52,64,30,52,0,30,52,64,30
    db 52,0,30,52,64,90,52,0,30,52,64,90,52,0,129,22
    db 52,64,90,52,0,30,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,0,178,7,20,90,146,52,0,30,52,64,30
    db 52,0,30,52,64,30,52,0,30,52,64,90,52,0,30,52
    db 64,90,52,0,129,22,52,64,90,52,0,30,52,64,90,52
    db 0,30,52,64,90,52,0,30,52,64,0,178,7,10,90,146
    db 52,0,30,52,64,30,52,0,30,52,64,30,52,0,30,52
    db 64,90,52,0,30,52,64,90,52,0,30,178,7,0,120,146
    db 52,64,90,52,0,14,178,7,2,16,146,52,64,90,52,0
    db 30,52,64,90,52,0,0,255,47,0,77,84,114,107,0,0
    db 41,136,0,255,3,5,68,114,117,109,115,0,201,16,0,153
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,30,42,0,30,42,64
    db 30,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,36,64,0,42,64,0,69,64
    db 0,56,64,90,56,0,0,36,0,0,42,0,0,69,0,30
    db 42,64,90,42,0,30,38,64,0,42,64,90,42,0,0,38
    db 0,30,42,64,90,42,0,30,36,64,0,42,64,0,69,64
    db 0,56,64,90,56,0,0,36,0,0,42,0,0,69,0,30
    db 42,64,30,42,0,30,42,64,30,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,36,64,0,42,64,0,69,64
    db 0,56,64,90,56,0,0,36,0,0,42,0,0,69,0,30
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,90,42,0,30,38,64
    db 0,42,64,90,42,0,0,38,0,30,42,64,90,42,0,30
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,30,42,0,30,42,64
    db 30,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,36,64,0,42,64,0,69,64
    db 0,56,64,90,56,0,0,36,0,0,42,0,0,69,0,30
    db 42,64,90,42,0,30,38,64,0,42,64,90,42,0,0,38
    db 0,30,42,64,90,42,0,30,36,64,0,42,64,0,56,64
    db 0,69,64,90,69,0,0,36,0,0,42,0,0,56,0,133
    db 110,42,64,90,42,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,30,42,0,30,42,64,30,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,30,42,0,30,42,64,30,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,30,42,0,30,42,64,30,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,30,42,0,30,42,64,30,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,30,42,0,30,42,64,30,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,42,64,0,36,64,0,69,64,90
    db 69,0,0,36,0,0,42,0,30,42,64,90,42,0,30,42
    db 64,0,38,64,0,45,64,90,45,0,0,38,0,0,42,0
    db 30,42,64,0,36,64,0,69,64,90,69,0,0,36,0,0
    db 42,0,30,42,64,0,36,64,0,69,64,90,69,0,0,36
    db 0,0,42,0,30,42,64,90,42,0,30,42,64,0,38,64
    db 0,45,64,90,45,0,0,38,0,0,42,0,30,42,64,90
    db 42,0,30,42,64,0,36,64,0,69,64,90,69,0,0,36
    db 0,0,42,0,30,42,64,90,42,0,30,42,64,0,38,64
    db 0,45,64,90,45,0,0,38,0,0,42,0,30,42,64,0
    db 36,64,0,69,64,90,69,0,0,36,0,0,42,0,30,42
    db 64,0,36,64,0,69,64,90,69,0,0,36,0,0,42,0
    db 30,42,64,90,42,0,30,42,64,0,38,64,0,45,64,90
    db 45,0,0,38,0,0,42,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,42,64,30,42,0,30,42,64,30
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,0,56,64,90,56,0,0,36,0
    db 0,42,0,0,69,0,30,36,64,0,42,64,0,69,64,0
    db 56,64,90,56,0,0,36,0,0,42,0,0,69,0,30,42
    db 64,90,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,30,36,64,0,42,64,90,42,0,0
    db 36,0,134,102,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,30,42
    db 0,30,42,64,30,42,0,30,38,64,0,42,64,90,42,0
    db 0,38,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,90,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,30,42,0,30,42,64,30,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,90,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,42,64
    db 90,42,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,30,42
    db 0,30,42,64,30,42,0,30,38,64,0,42,64,90,42,0
    db 0,38,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,90,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,30,42,0,30,42,64,30,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,90,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,42,64
    db 90,42,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,30,42
    db 0,30,42,64,30,42,0,30,38,64,0,42,64,90,42,0
    db 0,38,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,90,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,30,42,0,30,42,64,30,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,90,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,42,64
    db 90,42,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,30,42
    db 0,30,42,64,30,42,0,30,38,64,0,42,64,90,42,0
    db 0,38,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,90,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,30,42,0,30,42,64,30,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,90,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,42,64
    db 90,42,0,30,42,64,0,36,64,0,69,64,90,69,0,0
    db 36,0,0,42,0,30,42,64,90,42,0,30,42,64,0,38
    db 64,0,45,64,90,45,0,0,38,0,0,42,0,30,42,64
    db 0,36,64,0,69,64,90,69,0,0,36,0,0,42,0,30
    db 42,64,0,36,64,0,69,64,90,69,0,0,36,0,0,42
    db 0,30,42,64,90,42,0,30,42,64,0,38,64,0,45,64
    db 90,45,0,0,38,0,0,42,0,30,42,64,90,42,0,30
    db 42,64,0,36,64,0,69,64,90,69,0,0,36,0,0,42
    db 0,30,42,64,90,42,0,30,42,64,0,38,64,0,45,64
    db 90,45,0,0,38,0,0,42,0,30,42,64,0,36,64,0
    db 69,64,90,69,0,0,36,0,0,42,0,30,42,64,0,36
    db 64,0,69,64,90,69,0,0,36,0,0,42,0,30,42,64
    db 90,42,0,30,42,64,0,38,64,0,45,64,90,45,0,0
    db 38,0,0,42,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,30,42,0,30,42,64,30,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,42,64,90,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,42,64
    db 90,42,0,30,36,64,0,42,64,0,56,64,0,69,64,90
    db 69,0,0,36,0,0,42,0,0,56,0,30,42,64,30,42
    db 0,30,42,64,30,42,0,30,42,64,0,38,64,90,38,0
    db 0,42,0,30,42,64,0,36,64,0,56,64,0,69,64,90
    db 69,0,0,42,0,0,36,0,0,56,0,30,42,64,0,36
    db 64,0,56,64,0,69,64,90,69,0,0,42,0,0,36,0
    db 0,56,0,30,42,64,0,38,64,90,38,0,0,42,0,30
    db 42,64,0,38,64,30,38,0,30,38,64,30,42,0,30,42
    db 64,30,38,0,30,38,64,30,38,0,0,42,0,30,59,64
    db 0,36,64,0,54,64,0,69,64,90,69,0,0,59,0,0
    db 36,0,0,54,0,129,22,59,64,0,38,64,0,54,64,90
    db 54,0,0,38,0,0,59,0,30,36,64,0,69,64,90,69
    db 0,0,36,0,30,59,64,0,36,64,0,54,64,0,69,64
    db 90,69,0,0,59,0,0,36,0,0,54,0,129,22,59,64
    db 0,38,64,0,54,64,90,54,0,0,38,0,0,59,0,129
    db 22,59,64,0,36,64,0,54,64,0,69,64,90,69,0,0
    db 59,0,0,36,0,0,54,0,129,22,59,64,0,38,64,0
    db 54,64,90,54,0,0,38,0,0,59,0,30,36,64,0,69
    db 64,90,69,0,0,36,0,30,59,64,0,36,64,0,54,64
    db 0,69,64,90,69,0,0,59,0,0,36,0,0,54,0,129
    db 22,59,64,0,38,64,0,54,64,90,54,0,0,38,0,0
    db 59,0,30,36,64,90,36,0,30,59,64,0,36,64,0,54
    db 64,0,69,64,90,69,0,0,59,0,0,36,0,0,54,0
    db 129,22,59,64,0,38,64,0,54,64,90,54,0,0,38,0
    db 0,59,0,30,36,64,90,36,0,30,59,64,0,36,64,0
    db 54,64,0,69,64,90,69,0,0,59,0,0,36,0,0,54
    db 0,129,22,59,64,0,38,64,0,54,64,90,54,0,0,38
    db 0,0,59,0,129,22,59,64,0,36,64,0,54,64,0,69
    db 64,90,69,0,0,59,0,0,36,0,0,54,0,129,22,59
    db 64,0,38,64,0,54,64,90,54,0,0,38,0,0,59,0
    db 30,36,64,0,69,64,90,69,0,0,36,0,30,59,64,0
    db 36,64,0,54,64,0,69,64,90,69,0,0,59,0,0,36
    db 0,0,54,0,129,22,59,64,0,38,64,0,54,64,90,54
    db 0,0,38,0,0,59,0,30,69,64,0,36,64,90,36,0
    db 0,69,0,30,59,64,0,36,64,0,54,64,0,69,64,90
    db 69,0,0,59,0,0,36,0,0,54,0,129,22,59,64,0
    db 38,64,0,54,64,90,54,0,0,38,0,0,59,0,30,36
    db 64,90,36,0,30,59,64,0,36,64,0,54,64,0,69,64
    db 90,69,0,0,59,0,0,36,0,0,54,0,129,22,59,64
    db 0,38,64,0,54,64,90,54,0,0,38,0,0,59,0,129
    db 22,59,64,0,36,64,0,54,64,0,69,64,90,69,0,0
    db 59,0,0,36,0,0,54,0,129,22,59,64,0,38,64,0
    db 54,64,90,54,0,0,38,0,0,59,0,30,36,64,90,36
    db 0,30,59,64,0,36,64,0,54,64,0,69,64,90,69,0
    db 0,59,0,0,36,0,0,54,0,129,22,59,64,0,38,64
    db 0,54,64,90,54,0,0,38,0,0,59,0,30,69,64,0
    db 36,64,90,36,0,0,69,0,30,59,64,0,36,64,0,54
    db 64,0,69,64,90,69,0,0,59,0,0,36,0,0,54,0
    db 129,22,59,64,0,38,64,0,54,64,90,54,0,0,38,0
    db 0,59,0,30,36,64,90,36,0,30,59,64,0,36,64,0
    db 54,64,0,69,64,90,69,0,0,59,0,0,36,0,0,54
    db 0,129,22,59,64,0,38,64,0,54,64,90,54,0,0,38
    db 0,0,59,0,129,22,59,64,0,36,64,0,54,64,0,69
    db 64,90,69,0,0,59,0,0,36,0,0,54,0,129,22,59
    db 64,0,38,64,0,54,64,90,54,0,0,38,0,0,59,0
    db 30,36,64,0,69,64,90,69,0,0,36,0,30,59,64,0
    db 36,64,0,54,64,0,69,64,90,69,0,0,59,0,0,36
    db 0,0,54,0,129,22,59,64,0,38,64,0,54,64,90,54
    db 0,0,38,0,0,59,0,30,69,64,0,36,64,90,36,0
    db 0,69,0,30,59,64,0,36,64,0,54,64,0,69,64,90
    db 69,0,0,59,0,0,36,0,0,54,0,129,22,59,64,0
    db 38,64,0,54,64,90,54,0,0,38,0,0,59,0,30,36
    db 64,90,36,0,30,59,64,0,36,64,0,54,64,0,69,64
    db 90,69,0,0,59,0,0,36,0,0,54,0,129,22,59,64
    db 0,38,64,0,54,64,90,54,0,0,38,0,0,59,0,129
    db 22,59,64,0,36,64,0,54,64,0,69,64,90,69,0,0
    db 59,0,0,36,0,0,54,0,129,22,59,64,0,38,64,0
    db 54,64,90,54,0,0,38,0,0,59,0,30,36,64,0,69
    db 64,90,69,0,0,36,0,30,36,64,0,54,64,0,69,64
    db 0,57,64,90,57,0,0,36,0,0,54,0,0,69,0,129
    db 22,38,64,0,36,64,0,54,64,0,57,64,90,57,0,0
    db 38,0,0,36,0,0,54,0,30,69,64,0,36,64,90,36
    db 0,0,69,0,30,59,64,0,36,64,0,54,64,0,69,64
    db 90,69,0,0,59,0,0,36,0,0,54,0,129,22,59,64
    db 0,38,64,0,54,64,90,54,0,0,38,0,0,59,0,30
    db 36,64,90,36,0,30,36,64,0,54,64,0,69,64,0,59
    db 64,90,59,0,0,36,0,0,54,0,0,69,0,129,22,38
    db 64,0,54,64,0,59,64,90,59,0,0,54,0,0,38,0
    db 129,22,59,64,0,36,64,0,54,64,0,69,64,90,69,0
    db 0,59,0,0,36,0,0,54,0,129,22,59,64,0,38,64
    db 0,54,64,90,54,0,0,38,0,0,59,0,30,36,64,90
    db 36,0,30,36,64,0,59,64,0,57,64,14,57,0,0,57
    db 64,14,57,0,2,57,64,14,57,0,0,57,64,14,57,0
    db 2,57,64,14,57,0,0,57,64,14,57,0,2,59,0,0
    db 36,0,0,57,64,14,57,0,0,57,64,14,57,0,2,57
    db 64,14,57,0,0,57,64,14,57,0,2,57,64,14,57,0
    db 0,57,64,14,57,0,2,57,64,14,57,0,0,57,64,14
    db 57,0,2,57,64,14,57,0,0,57,64,14,57,0,2,59
    db 64,0,38,64,0,57,64,14,57,0,0,57,64,14,57,0
    db 2,57,64,14,57,0,0,57,64,14,57,0,2,57,64,14
    db 57,0,0,57,64,14,57,0,2,38,0,0,59,0,0,57
    db 64,14,57,0,0,57,64,14,57,0,2,36,64,0,57,64
    db 14,57,0,0,57,64,14,57,0,2,57,64,14,57,0,0
    db 57,64,14,57,0,2,57,64,14,57,0,0,57,64,14,57
    db 0,2,36,0,0,57,64,14,57,0,0,57,64,16,36,64
    db 90,36,0,14,57,0,133,96,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,0,57,64,14,57,0
    db 0,57,64,14,57,0,2,57,64,14,57,0,0,57,64,14
    db 57,0,2,57,64,14,57,0,0,57,64,14,57,0,2,42
    db 0,0,57,64,14,57,0,0,57,64,16,36,64,0,42,64
    db 0,69,64,0,54,64,90,54,0,0,42,0,0,69,0,0
    db 36,0,30,42,64,30,42,0,30,42,64,28,57,0,2,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,90,69,0,0,42,0,0,36,0,30
    db 36,64,0,42,64,0,69,64,0,54,64,90,54,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,90,42,0,30,38,64
    db 0,42,64,90,42,0,0,38,0,30,42,64,90,42,0,30
    db 36,64,0,42,64,0,69,64,0,54,64,90,54,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,30,42,0,30,42,64
    db 30,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 36,64,0,42,64,0,69,64,90,69,0,0,42,0,0,36
    db 0,30,36,64,0,42,64,0,69,64,0,54,64,90,54,0
    db 0,36,0,0,42,0,0,69,0,30,42,64,90,42,0,30
    db 38,64,0,42,64,90,42,0,0,38,0,30,42,64,90,42
    db 0,30,36,64,0,42,64,0,69,64,0,56,64,90,56,0
    db 0,36,0,0,42,0,0,69,0,30,42,64,30,42,0,30
    db 42,64,30,42,0,30,38,64,0,42,64,90,42,0,0,38
    db 0,30,36,64,0,42,64,0,69,64,0,56,64,90,56,0
    db 0,36,0,0,42,0,0,69,0,30,36,64,0,42,64,0
    db 69,64,0,56,64,0,57,64,14,57,0,0,57,64,14,57
    db 0,2,57,64,14,57,0,0,57,64,14,57,0,2,57,64
    db 14,57,0,0,57,64,14,57,0,2,56,0,0,36,0,0
    db 42,0,0,69,0,0,57,64,14,57,0,0,57,64,14,57
    db 0,2,42,64,0,57,64,14,57,0,0,57,64,14,57,0
    db 2,57,64,14,57,0,0,57,64,14,57,0,2,57,64,14
    db 57,0,0,57,64,14,57,0,2,42,0,0,57,64,14,57
    db 0,0,57,64,14,57,0,2,38,64,0,42,64,0,57,64
    db 14,57,0,0,57,64,14,57,0,2,57,64,14,57,0,0
    db 57,64,14,57,0,2,57,64,14,57,0,0,57,64,14,57
    db 0,2,42,0,0,38,0,0,57,64,14,57,0,0,57,64
    db 14,57,0,2,42,64,0,57,64,14,57,0,0,57,64,14
    db 57,0,2,57,64,14,57,0,0,57,64,14,57,0,2,57
    db 64,14,57,0,0,57,64,14,57,0,2,42,0,0,57,64
    db 14,57,0,0,57,64,16,57,0,0,69,64,0,42,64,0
    db 36,64,90,36,0,0,42,0,0,69,0,134,102,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,30,42,0,30,42,64,30,42,0
    db 30,38,64,0,42,64,90,42,0,0,38,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,90
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,42
    db 64,90,42,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,42,64,90,42,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,30,42,0,30,42,64,30,42,0
    db 30,38,64,0,42,64,90,42,0,0,38,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,90
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,42
    db 64,90,42,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,42,64,90,42,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,30,42,0,30,42,64,30,42,0
    db 30,38,64,0,42,64,90,42,0,0,38,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,90
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,42
    db 64,90,42,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,42,64,90,42,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,30,42,0,30,42,64,30,42,0
    db 30,38,64,0,42,64,90,42,0,0,38,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,90
    db 42,0,30,38,64,0,42,64,90,42,0,0,38,0,30,42
    db 64,90,42,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,42,64,0,57,64,14,57,0,0
    db 57,64,14,57,0,2,57,64,14,57,0,0,57,64,14,57
    db 0,2,57,64,14,57,0,0,57,64,14,57,0,2,42,0
    db 0,57,64,14,57,0,0,57,64,16,36,64,0,42,64,0
    db 69,64,90,69,0,0,42,0,0,36,0,30,42,64,30,42
    db 0,30,42,64,28,57,0,2,42,0,30,38,64,0,42,64
    db 0,45,64,90,45,0,0,42,0,0,38,0,30,36,64,0
    db 42,64,0,69,64,90,69,0,0,42,0,0,36,0,30,36
    db 64,0,42,64,0,69,64,90,69,0,0,42,0,0,36,0
    db 30,42,64,90,42,0,30,38,64,0,42,64,0,45,64,90
    db 45,0,0,42,0,0,38,0,30,42,64,90,42,0,30,36
    db 64,0,42,64,0,69,64,90,69,0,0,42,0,0,36,0
    db 30,42,64,30,42,0,30,42,64,30,42,0,30,38,64,0
    db 42,64,0,45,64,90,45,0,0,42,0,0,38,0,30,36
    db 64,0,42,64,0,69,64,90,69,0,0,42,0,0,36,0
    db 30,36,64,0,42,64,0,69,64,90,69,0,0,42,0,0
    db 36,0,30,42,64,90,42,0,30,38,64,0,42,64,0,45
    db 64,90,45,0,0,42,0,0,38,0,30,42,64,90,42,0
    db 30,36,64,0,42,64,0,69,64,0,56,64,90,56,0,0
    db 36,0,0,42,0,0,69,0,30,42,64,30,42,0,30,42
    db 64,30,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,36,64,0,42,64,0,69,64,0,56,64,90,56,0,0
    db 36,0,0,42,0,0,69,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,90,56,0,0,36,0,0,42,0,0,69,0
    db 30,42,64,90,42,0,30,38,64,0,42,64,90,42,0,0
    db 38,0,30,42,64,90,42,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,90,56,0,0,36,0,0,42,0,0,69,0
    db 30,42,64,30,42,0,30,42,64,30,42,0,30,38,64,0
    db 42,64,90,42,0,0,38,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,90,56,0,0,36,0,0,42,0,0,69,0
    db 30,36,64,0,42,64,0,69,64,0,56,64,90,56,0,0
    db 36,0,0,42,0,0,69,0,30,42,64,90,42,0,30,38
    db 64,0,42,64,90,42,0,0,38,0,30,42,64,90,42,0
    db 30,36,64,0,42,64,0,69,64,90,69,0,0,42,0,0
    db 36,0,30,42,64,30,42,0,30,42,64,30,42,0,30,38
    db 64,0,42,64,0,45,64,90,45,0,0,42,0,0,38,0
    db 30,36,64,0,42,64,0,69,64,90,69,0,0,42,0,0
    db 36,0,30,36,64,0,42,64,0,69,64,90,69,0,0,42
    db 0,0,36,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 0,45,64,90,45,0,0,42,0,0,38,0,30,42,64,90
    db 42,0,30,36,64,0,42,64,0,69,64,90,69,0,0,42
    db 0,0,36,0,30,42,64,30,42,0,30,42,64,30,42,0
    db 30,38,64,0,42,64,0,45,64,90,45,0,0,42,0,0
    db 38,0,30,36,64,0,42,64,0,69,64,90,69,0,0,42
    db 0,0,36,0,30,36,64,0,42,64,0,69,64,90,69,0
    db 0,42,0,0,36,0,30,42,64,90,42,0,30,38,64,0
    db 42,64,0,45,64,90,45,0,0,42,0,0,38,0,30,42
    db 64,90,42,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,30,36,64,0
    db 42,64,0,69,64,0,56,64,90,56,0,0,36,0,0,42
    db 0,0,69,0,30,42,64,90,42,0,30,38,64,0,42,64
    db 90,42,0,0,38,0,30,42,64,90,42,0,30,36,64,0
    db 42,64,0,56,64,0,69,64,90,69,0,0,36,0,0,42
    db 0,0,56,0,134,102,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,0,57,64,14,57,0
    db 0,57,64,14,57,0,2,57,64,14,57,0,0,57,64,14
    db 57,0,2,57,64,14,57,0,0,57,64,14,57,0,2,42
    db 0,0,57,64,14,57,0,0,57,64,16,36,64,0,42,64
    db 0,69,64,0,56,64,90,56,0,0,42,0,0,69,0,0
    db 36,0,30,42,64,30,42,0,30,42,64,28,57,0,2,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 30,42,0,30,42,64,30,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,90,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,42,64,90,42,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,0,57,64,90,56,0,0
    db 69,0,0,36,0,0,42,0,30,42,64,30,42,0,30,42
    db 64,30,42,0,0,57,0,30,38,64,0,42,64,90,42,0
    db 0,38,0,30,36,64,0,42,64,0,69,64,0,56,64,90
    db 56,0,0,36,0,0,42,0,0,69,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,90,56,0,0,36,0,0,42,0
    db 0,69,0,30,42,64,90,42,0,30,38,64,0,42,64,90
    db 42,0,0,38,0,30,42,64,90,42,0,30,36,64,0,42
    db 64,0,69,64,0,56,64,0,185,7,110,90,153,56,0,0
    db 36,0,0,42,0,0,69,0,30,42,64,30,42,0,30,42
    db 64,30,42,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,36,64,0,42,64,0,69,64,0,56,64,90,56,0,0
    db 36,0,0,42,0,0,69,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,90,56,0,0,36,0,0,42,0,0,69,0
    db 30,42,64,90,42,0,30,38,64,0,42,64,90,42,0,0
    db 38,0,30,42,64,90,42,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,0,185,7,90,90,153,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,28,42,0,32,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,0,57,64,0,185,7,70,90,153,56,0,0,69,0,0
    db 36,0,0,42,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,0,57,0,30,38,64,0,42,64,90,42,0,0,38,0
    db 30,36,64,0,42,64,0,69,64,0,56,64,90,56,0,0
    db 36,0,0,42,0,0,69,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,90,56,0,0,36,0,0,42,0,0,69,0
    db 30,42,64,90,42,0,30,38,64,0,42,64,90,42,0,0
    db 38,0,30,42,64,90,42,0,30,36,64,0,42,64,0,69
    db 64,0,56,64,0,185,7,50,90,153,56,0,0,36,0,0
    db 42,0,0,69,0,30,42,64,30,42,0,30,42,64,30,42
    db 0,30,38,64,0,42,64,90,42,0,0,38,0,30,36,64
    db 0,42,64,0,69,64,0,56,64,90,56,0,0,36,0,0
    db 42,0,0,69,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,90,56,0,0,36,0,0,42,0,0,69,0,30,42,64
    db 90,42,0,30,38,64,0,42,64,90,42,0,0,38,0,30
    db 42,64,90,42,0,30,36,64,0,42,64,0,69,64,0,56
    db 64,0,185,7,30,90,153,56,0,0,36,0,0,42,0,0
    db 69,0,30,42,64,30,42,0,30,42,64,30,42,0,30,38
    db 64,0,42,64,90,42,0,0,38,0,30,36,64,0,42,64
    db 0,69,64,0,56,64,90,56,0,0,36,0,0,42,0,0
    db 69,0,30,36,64,0,42,64,0,69,64,0,56,64,90,56
    db 0,0,36,0,0,42,0,0,69,0,30,42,64,90,42,0
    db 30,38,64,0,42,64,90,42,0,0,38,0,30,42,64,90
    db 42,0,30,36,64,0,42,64,0,69,64,0,56,64,0,185
    db 7,20,90,153,56,0,0,36,0,0,42,0,0,69,0,30
    db 42,64,30,42,0,30,42,64,30,42,0,30,38,64,0,42
    db 64,90,42,0,0,38,0,30,36,64,0,42,64,0,69,64
    db 0,56,64,90,56,0,0,36,0,0,42,0,0,69,0,30
    db 36,64,0,42,64,0,69,64,0,56,64,90,56,0,0,36
    db 0,0,42,0,0,69,0,30,42,64,90,42,0,30,38,64
    db 0,42,64,90,42,0,0,38,0,30,42,64,0,57,64,14
    db 57,0,0,57,64,14,57,0,2,57,64,14,57,0,0,57
    db 64,14,57,0,2,57,64,14,57,0,0,57,64,14,57,0
    db 2,42,0,0,57,64,14,57,0,0,57,64,16,36,64,0
    db 42,64,0,69,64,0,56,64,0,185,7,10,74,153,57,0
    db 16,69,0,0,36,0,0,42,0,0,56,0,30,42,64,30
    db 42,0,30,42,64,30,42,0,30,38,64,0,42,64,90,42
    db 0,0,38,0,30,36,64,0,42,64,0,69,64,0,56,64
    db 90,56,0,0,36,0,0,42,0,0,69,0,14,185,7,5
    db 16,153,36,64,0,42,64,0,69,64,0,56,64,90,56,0
    db 0,36,0,0,42,0,0,69,0,30,42,64,90,42,0,14
    db 185,7,2,16,153,38,64,0,42,64,90,42,0,0,38,0
    db 30,42,64,90,42,0,0,255,47,0,77,84,114,107,0,0
    db 61,190,0,255,3,6,71,117,105,116,97,114,0,195,29,0
    db 147,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,30,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,30,52,0,0
    db 64,0,0,71,0,0,76,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,90,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,76,64,0,71,64,0,52,64,90,52,0,0
    db 64,0,0,76,0,0,71,0,129,22,76,64,0,68,64,0
    db 64,64,0,52,64,90,52,0,0,76,0,0,68,0,0,64
    db 0,30,64,64,0,71,64,0,76,64,0,52,64,90,52,0
    db 0,64,0,0,71,0,0,76,0,30,52,64,90,52,0,30
    db 64,64,0,71,64,0,76,64,0,52,64,90,52,0,0,64
    db 0,0,71,0,0,76,0,30,64,64,0,76,64,0,71,64
    db 0,52,64,30,52,0,0,64,0,0,76,0,0,71,0,30
    db 64,64,0,71,64,0,76,64,0,52,64,30,52,0,0,64
    db 0,0,71,0,0,76,0,30,64,64,0,76,64,0,71,64
    db 0,52,64,90,52,0,0,64,0,0,76,0,0,71,0,30
    db 64,64,0,76,64,0,71,64,0,52,64,90,52,0,0,64
    db 0,0,76,0,0,71,0,129,22,68,64,0,64,64,0,52
    db 64,0,71,64,90,71,0,0,68,0,0,64,0,0,52,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,52,64,0,64,64,0,71
    db 64,0,76,64,90,76,0,0,52,0,0,64,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,30,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,30,52,0,0
    db 64,0,0,71,0,0,76,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,90,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,76,64,0,71,64,0,52,64,90,52,0,0
    db 64,0,0,76,0,0,71,0,129,22,68,64,0,64,64,0
    db 52,64,0,71,64,0,76,64,90,76,0,0,52,0,0,68
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,30
    db 52,64,0,64,64,0,71,64,0,76,64,90,76,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,134
    db 102,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,76,64,0,71,64,0,64
    db 64,0,52,64,30,52,0,0,76,0,0,71,0,0,64,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,30,52,0,0
    db 76,0,0,71,0,0,64,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,90,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,129,22,64,64,0,68,64,0
    db 52,64,0,71,64,90,71,0,0,64,0,0,68,0,0,52
    db 0,30,64,64,0,52,64,0,71,64,90,71,0,0,52,0
    db 0,64,0,30,64,64,0,52,64,0,71,64,90,71,0,0
    db 52,0,0,64,0,30,64,64,0,71,64,0,76,64,0,52
    db 64,90,52,0,0,64,0,0,71,0,0,76,0,30,76,64
    db 0,71,64,0,64,64,0,52,64,30,52,0,0,76,0,0
    db 71,0,0,64,0,30,76,64,0,71,64,0,64,64,0,52
    db 64,30,52,0,0,76,0,0,71,0,0,64,0,30,64,64
    db 0,76,64,0,71,64,0,52,64,90,52,0,0,64,0,0
    db 76,0,0,71,0,30,64,64,0,71,64,0,76,64,0,52
    db 64,90,52,0,0,64,0,0,71,0,0,76,0,129,22,64
    db 64,0,68,64,0,52,64,0,71,64,90,71,0,0,64,0
    db 0,68,0,0,52,0,30,64,64,0,52,64,0,71,64,90
    db 71,0,0,52,0,0,64,0,30,64,64,0,52,64,0,71
    db 64,90,71,0,0,52,0,0,64,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,64,64,0,76,64,0,71,64,0,52,64,90,52
    db 0,0,64,0,0,76,0,0,71,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,129,22,64,64,0,68,64,0,52,64,0,71,64,90
    db 71,0,0,64,0,0,68,0,0,52,0,30,64,64,0,52
    db 64,0,71,64,90,71,0,0,52,0,0,64,0,30,64,64
    db 0,52,64,0,71,64,90,71,0,0,52,0,0,64,0,30
    db 64,64,0,71,64,0,76,64,0,52,64,90,52,0,0,64
    db 0,0,71,0,0,76,0,30,76,64,0,71,64,0,64,64
    db 0,52,64,30,52,0,0,76,0,0,71,0,0,64,0,30
    db 76,64,0,71,64,0,64,64,0,52,64,30,52,0,0,76
    db 0,0,71,0,0,64,0,30,64,64,0,76,64,0,71,64
    db 0,52,64,90,52,0,0,64,0,0,76,0,0,71,0,30
    db 64,64,0,71,64,0,76,64,0,52,64,90,52,0,0,64
    db 0,0,71,0,0,76,0,129,22,64,64,0,68,64,0,52
    db 64,0,71,64,90,71,0,0,64,0,0,68,0,0,52,0
    db 30,64,64,0,52,64,0,71,64,90,71,0,0,52,0,0
    db 64,0,30,64,64,0,52,64,0,71,64,90,71,0,0,52
    db 0,0,64,0,30,64,64,0,71,64,0,76,64,0,52,64
    db 90,52,0,0,64,0,0,71,0,0,76,0,30,76,64,0
    db 71,64,0,64,64,0,52,64,30,52,0,0,76,0,0,71
    db 0,0,64,0,30,76,64,0,71,64,0,64,64,0,52,64
    db 30,52,0,0,76,0,0,71,0,0,64,0,30,64,64,0
    db 76,64,0,71,64,0,52,64,90,52,0,0,64,0,0,76
    db 0,0,71,0,30,64,64,0,71,64,0,76,64,0,52,64
    db 90,52,0,0,64,0,0,71,0,0,76,0,129,22,64,64
    db 0,68,64,0,52,64,0,71,64,90,71,0,0,64,0,0
    db 68,0,0,52,0,30,64,64,0,52,64,0,71,64,90,71
    db 0,0,52,0,0,64,0,30,64,64,0,52,64,0,71,64
    db 90,71,0,0,52,0,0,64,0,30,64,64,0,71,64,0
    db 76,64,0,52,64,90,52,0,0,64,0,0,71,0,0,76
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,30,52,0
    db 0,76,0,0,71,0,0,64,0,30,76,64,0,71,64,0
    db 64,64,0,52,64,30,52,0,0,76,0,0,71,0,0,64
    db 0,30,64,64,0,76,64,0,71,64,0,52,64,90,52,0
    db 0,64,0,0,76,0,0,71,0,30,64,64,0,71,64,0
    db 76,64,0,52,64,90,52,0,0,64,0,0,71,0,0,76
    db 0,129,22,64,64,0,52,64,0,71,64,0,76,64,90,76
    db 0,0,64,0,0,52,0,0,71,0,30,64,64,0,52,64
    db 0,71,64,0,76,64,90,76,0,0,64,0,0,52,0,0
    db 71,0,30,64,64,0,52,64,0,71,64,0,76,64,0,57
    db 64,90,57,0,0,71,0,0,64,0,0,52,0,0,76,0
    db 30,69,64,0,64,64,0,57,64,0,52,64,90,52,0,0
    db 69,0,0,64,0,0,57,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,30,52,0,0,69,0,0,64,0,0,57,0
    db 30,69,64,0,64,64,0,57,64,0,52,64,30,52,0,0
    db 69,0,0,64,0,0,57,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,90,52,0,0,69,0,0,64,0,0,57,0
    db 30,69,64,0,64,64,0,57,64,0,52,64,90,52,0,0
    db 69,0,0,64,0,0,57,0,129,22,69,64,0,64,64,0
    db 57,64,0,52,64,90,52,0,0,69,0,0,64,0,0,57
    db 0,30,69,64,0,64,64,0,57,64,90,57,0,0,64,0
    db 0,69,0,30,69,64,0,64,64,0,57,64,0,52,64,90
    db 52,0,0,69,0,0,64,0,0,57,0,30,69,64,0,64
    db 64,0,57,64,0,52,64,90,52,0,0,69,0,0,64,0
    db 0,57,0,30,69,64,0,64,64,0,57,64,0,52,64,30
    db 52,0,0,69,0,0,64,0,0,57,0,30,69,64,0,64
    db 64,0,57,64,0,52,64,30,52,0,0,69,0,0,64,0
    db 0,57,0,30,69,64,0,64,64,0,57,64,0,52,64,90
    db 52,0,0,69,0,0,64,0,0,57,0,30,69,64,0,64
    db 64,0,57,64,0,52,64,90,52,0,0,69,0,0,64,0
    db 0,57,0,129,22,69,64,0,64,64,0,57,64,0,52,64
    db 90,52,0,0,69,0,0,64,0,0,57,0,30,69,64,0
    db 64,64,0,57,64,90,57,0,0,64,0,0,69,0,30,69
    db 64,0,64,64,0,57,64,0,52,64,90,52,0,0,69,0
    db 0,64,0,0,57,0,30,64,64,0,71,64,0,76,64,0
    db 52,64,90,52,0,0,64,0,0,71,0,0,76,0,30,76
    db 64,0,71,64,0,64,64,0,52,64,30,52,0,0,76,0
    db 0,71,0,0,64,0,30,76,64,0,71,64,0,64,64,0
    db 52,64,30,52,0,0,76,0,0,71,0,0,64,0,30,64
    db 64,0,76,64,0,71,64,0,52,64,90,52,0,0,64,0
    db 0,76,0,0,71,0,30,64,64,0,71,64,0,76,64,0
    db 52,64,90,52,0,0,64,0,0,71,0,0,76,0,129,22
    db 64,64,0,68,64,0,52,64,0,71,64,90,71,0,0,64
    db 0,0,68,0,0,52,0,30,64,64,0,52,64,0,71,64
    db 90,71,0,0,52,0,0,64,0,30,64,64,0,52,64,0
    db 71,64,90,71,0,0,52,0,0,64,0,30,64,64,0,71
    db 64,0,76,64,0,52,64,90,52,0,0,64,0,0,71,0
    db 0,76,0,30,76,64,0,71,64,0,64,64,0,52,64,30
    db 52,0,0,76,0,0,71,0,0,64,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,30,52,0,0,76,0,0,71,0
    db 0,64,0,30,64,64,0,76,64,0,71,64,0,52,64,90
    db 52,0,0,64,0,0,76,0,0,71,0,30,64,64,0,71
    db 64,0,76,64,0,52,64,90,52,0,0,64,0,0,71,0
    db 0,76,0,129,22,64,64,0,68,64,0,52,64,0,71,64
    db 90,71,0,0,64,0,0,68,0,0,52,0,30,64,64,0
    db 52,64,0,71,64,90,71,0,0,52,0,0,64,0,30,64
    db 64,0,52,64,0,71,64,90,71,0,0,52,0,0,64,0
    db 30,66,64,0,59,64,0,54,64,90,54,0,0,59,0,0
    db 66,0,30,66,64,0,59,64,0,54,64,90,54,0,0,59
    db 0,0,66,0,30,54,64,0,59,64,0,66,64,90,66,0
    db 0,59,0,0,54,0,30,54,64,0,59,64,0,66,64,90
    db 66,0,0,59,0,0,54,0,30,54,64,0,59,64,0,66
    db 64,90,66,0,0,59,0,0,54,0,30,54,64,0,59,64
    db 0,66,64,90,66,0,0,59,0,0,54,0,30,54,64,0
    db 59,64,0,66,64,90,66,0,0,59,0,0,54,0,30,54
    db 64,0,59,64,0,66,64,90,66,0,0,59,0,0,54,0
    db 30,64,64,0,57,64,0,52,64,90,52,0,0,57,0,0
    db 64,0,30,64,64,0,57,64,0,52,64,90,52,0,0,57
    db 0,0,64,0,30,64,64,0,57,64,0,52,64,90,52,0
    db 0,57,0,0,64,0,30,64,64,0,57,64,0,52,64,90
    db 52,0,0,57,0,0,64,0,30,64,64,0,57,64,0,52
    db 64,90,52,0,0,57,0,0,64,0,30,64,64,0,57,64
    db 0,52,64,90,52,0,0,57,0,0,64,0,30,64,64,0
    db 57,64,0,52,64,90,52,0,0,57,0,0,64,0,30,64
    db 64,0,57,64,0,52,64,90,52,0,0,57,0,0,64,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,76,64,0,71,64,0,64
    db 64,0,52,64,30,52,0,0,76,0,0,71,0,0,64,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,30,52,0,0
    db 76,0,0,71,0,0,64,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,90,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,129,22,64,64,0,52,64,0
    db 71,64,0,76,64,90,76,0,0,64,0,0,52,0,0,71
    db 0,30,64,64,0,52,64,0,71,64,0,76,64,90,76,0
    db 0,64,0,0,52,0,0,71,0,30,64,64,0,52,64,0
    db 71,64,0,76,64,90,76,0,0,64,0,0,52,0,0,71
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,90,52,0
    db 0,76,0,0,71,0,0,64,0,134,102,76,64,0,71,64
    db 0,64,64,0,52,64,90,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,90,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,90,52,0,0,76,0,0,71,0,0
    db 64,0,129,22,76,64,0,71,64,0,64,64,0,52,64,90
    db 52,0,0,76,0,0,71,0,0,64,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,90,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,69,64,0
    db 52,64,90,52,0,0,64,0,0,76,0,0,71,0,0,69
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,90,52,0
    db 0,76,0,0,71,0,0,64,0,30,76,64,0,71,64,0
    db 64,64,0,52,64,30,52,0,0,76,0,0,71,0,0,64
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,30,52,0
    db 0,76,0,0,71,0,0,64,0,30,76,64,0,71,64,0
    db 64,64,0,52,64,90,52,0,0,76,0,0,71,0,0,64
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,90,52,0
    db 0,76,0,0,71,0,0,64,0,129,22,76,64,0,71,64
    db 0,64,64,0,52,64,90,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,90,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,90,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,90,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,90,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,90,52
    db 0,0,76,0,0,71,0,0,64,0,129,22,76,64,0,71
    db 64,0,64,64,0,52,64,90,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,52,64,90
    db 52,0,0,76,0,0,71,0,0,64,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,90,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,52,64,90
    db 52,0,0,76,0,0,71,0,0,64,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,30,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,52,64,30
    db 52,0,0,76,0,0,71,0,0,64,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,90,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,52,64,90
    db 52,0,0,76,0,0,71,0,0,64,0,129,22,76,64,0
    db 71,64,0,64,64,0,52,64,90,52,0,0,76,0,0,71
    db 0,0,64,0,30,76,64,0,71,64,0,64,64,0,52,64
    db 90,52,0,0,76,0,0,71,0,0,64,0,30,76,64,0
    db 71,64,0,64,64,0,52,64,0,57,64,90,57,0,0,64
    db 0,0,76,0,0,71,0,0,52,0,30,69,64,0,64,64
    db 0,57,64,0,52,64,0,74,64,90,74,0,0,57,0,0
    db 69,0,0,64,0,0,52,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,0,74,64,30,74,0,0,57,0,0,69,0
    db 0,64,0,0,52,0,30,69,64,0,64,64,0,57,64,0
    db 52,64,0,74,64,30,74,0,0,57,0,0,69,0,0,64
    db 0,0,52,0,30,69,64,0,64,64,0,57,64,0,52,64
    db 0,74,64,90,74,0,0,57,0,0,69,0,0,64,0,0
    db 52,0,30,69,64,0,64,64,0,57,64,0,52,64,0,74
    db 64,90,74,0,0,57,0,0,69,0,0,64,0,0,52,0
    db 129,22,69,64,0,64,64,0,57,64,0,52,64,0,74,64
    db 90,74,0,0,57,0,0,69,0,0,64,0,0,52,0,30
    db 69,64,0,64,64,0,57,64,0,74,64,90,74,0,0,69
    db 0,0,64,0,0,57,0,30,69,64,0,64,64,0,57,64
    db 0,52,64,0,74,64,90,74,0,0,57,0,0,69,0,0
    db 64,0,0,52,0,30,69,64,0,64,64,0,57,64,0,52
    db 64,90,52,0,0,69,0,0,64,0,0,57,0,30,69,64
    db 0,64,64,0,57,64,0,52,64,30,52,0,0,69,0,0
    db 64,0,0,57,0,30,69,64,0,64,64,0,57,64,0,52
    db 64,30,52,0,0,69,0,0,64,0,0,57,0,30,69,64
    db 0,64,64,0,57,64,0,52,64,90,52,0,0,69,0,0
    db 64,0,0,57,0,30,69,64,0,64,64,0,57,64,0,52
    db 64,90,52,0,0,69,0,0,64,0,0,57,0,129,22,69
    db 64,0,64,64,0,57,64,0,52,64,90,52,0,0,69,0
    db 0,64,0,0,57,0,30,69,64,0,64,64,0,57,64,90
    db 57,0,0,64,0,0,69,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,90,52,0,0,69,0,0,64,0,0,57,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,90,52,0,0
    db 76,0,0,71,0,0,64,0,30,76,64,0,71,64,0,64
    db 64,0,52,64,30,52,0,0,76,0,0,71,0,0,64,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,30,52,0,0
    db 76,0,0,71,0,0,64,0,30,76,64,0,71,64,0,64
    db 64,0,52,64,90,52,0,0,76,0,0,71,0,0,64,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,90,52,0,0
    db 76,0,0,71,0,0,64,0,129,22,71,64,0,64,64,0
    db 52,64,0,68,64,90,68,0,0,71,0,0,64,0,0,52
    db 0,30,71,64,0,64,64,0,52,64,90,52,0,0,64,0
    db 0,71,0,30,71,64,0,64,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,30,76,64,0,71,64,0,64,64,0,52
    db 64,90,52,0,0,76,0,0,71,0,0,64,0,30,76,64
    db 0,71,64,0,64,64,0,52,64,30,52,0,0,76,0,0
    db 71,0,0,64,0,30,76,64,0,71,64,0,64,64,0,52
    db 64,30,52,0,0,76,0,0,71,0,0,64,0,30,76,64
    db 0,71,64,0,64,64,0,52,64,90,52,0,0,76,0,0
    db 71,0,0,64,0,30,76,64,0,71,64,0,64,64,0,52
    db 64,90,52,0,0,76,0,0,71,0,0,64,0,129,22,71
    db 64,0,64,64,0,52,64,0,68,64,90,68,0,0,71,0
    db 0,64,0,0,52,0,30,71,64,0,64,64,0,52,64,90
    db 52,0,0,64,0,0,71,0,30,71,64,0,64,64,0,52
    db 64,90,52,0,0,64,0,0,71,0,30,66,64,0,59,64
    db 0,54,64,90,54,0,0,59,0,0,66,0,30,66,64,0
    db 59,64,0,54,64,90,54,0,0,59,0,0,66,0,30,54
    db 64,0,59,64,0,66,64,90,66,0,0,59,0,0,54,0
    db 30,54,64,0,59,64,0,66,64,90,66,0,0,59,0,0
    db 54,0,30,54,64,0,59,64,0,66,64,90,66,0,0,59
    db 0,0,54,0,30,54,64,0,59,64,0,66,64,90,66,0
    db 0,59,0,0,54,0,30,54,64,0,59,64,0,66,64,90
    db 66,0,0,59,0,0,54,0,30,54,64,0,59,64,0,66
    db 64,90,66,0,0,59,0,0,54,0,30,64,64,0,57,64
    db 0,52,64,90,52,0,0,57,0,0,64,0,30,64,64,0
    db 57,64,0,52,64,90,52,0,0,57,0,0,64,0,30,64
    db 64,0,57,64,0,52,64,90,52,0,0,57,0,0,64,0
    db 30,64,64,0,57,64,0,52,64,90,52,0,0,57,0,0
    db 64,0,30,64,64,0,57,64,0,52,64,90,52,0,0,57
    db 0,0,64,0,30,64,64,0,57,64,0,52,64,90,52,0
    db 0,57,0,0,64,0,30,64,64,0,57,64,0,52,64,90
    db 52,0,0,57,0,0,64,0,30,64,64,0,57,64,0,52
    db 64,90,52,0,0,57,0,0,64,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,64,64,0,76,64,0,71,64,0,52,64,90,52
    db 0,0,64,0,0,76,0,0,71,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,129,22,64,64,0,52,64,0,71,64,0,76,64,90
    db 76,0,0,64,0,0,52,0,0,71,0,30,64,64,0,52
    db 64,0,71,64,0,76,64,90,76,0,0,64,0,0,52,0
    db 0,71,0,30,64,64,0,52,64,0,71,64,0,76,64,90
    db 76,0,0,64,0,0,52,0,0,71,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,90,52,0,0,76,0,0,71,0
    db 0,64,0,30,52,64,0,64,64,0,71,64,0,76,64,90
    db 76,0,0,52,0,0,64,0,0,71,0,30,52,64,0,76
    db 64,0,71,64,0,64,64,0,56,64,90,56,0,0,71,0
    db 0,52,0,0,76,0,0,64,0,30,52,64,0,64,64,0
    db 71,64,0,76,64,0,56,64,90,56,0,0,71,0,0,52
    db 0,0,64,0,0,76,0,30,52,64,0,64,64,0,76,64
    db 0,71,64,0,62,64,90,62,0,0,76,0,0,52,0,0
    db 64,0,0,71,0,30,52,64,0,64,64,0,76,64,0,71
    db 64,0,62,64,90,62,0,0,76,0,0,52,0,0,64,0
    db 0,71,0,30,52,64,0,64,64,0,71,64,0,76,64,0
    db 56,64,30,56,0,30,57,64,30,71,0,0,76,0,0,52
    db 0,0,64,0,30,52,64,0,64,64,0,71,64,0,76,64
    db 30,57,0,30,57,64,30,57,0,0,76,0,0,52,0,0
    db 64,0,0,71,0,30,71,64,0,66,64,0,59,64,90,59
    db 0,0,66,0,0,71,0,30,71,64,0,66,64,0,59,64
    db 90,59,0,0,66,0,0,71,0,30,71,64,0,66,64,0
    db 59,64,90,59,0,0,66,0,0,71,0,30,71,64,0,66
    db 64,0,59,64,90,59,0,0,66,0,0,71,0,30,71,64
    db 0,66,64,0,59,64,90,59,0,0,66,0,0,71,0,30
    db 71,64,0,66,64,0,59,64,90,59,0,0,66,0,0,71
    db 0,30,71,64,0,66,64,0,59,64,90,59,0,0,66,0
    db 0,71,0,30,57,64,90,57,0,30,57,64,0,64,64,0
    db 71,64,90,71,0,0,64,0,0,57,0,30,57,64,0,64
    db 64,0,71,64,90,71,0,0,64,0,0,57,0,30,57,64
    db 0,64,64,0,71,64,90,71,0,0,64,0,0,57,0,30
    db 57,64,0,64,64,0,71,64,90,71,0,0,64,0,0,57
    db 0,30,57,64,0,64,64,0,71,64,90,71,0,0,64,0
    db 0,57,0,30,57,64,0,64,64,0,71,64,90,71,0,0
    db 64,0,0,57,0,30,57,64,0,64,64,0,71,64,90,71
    db 0,0,64,0,0,57,0,30,57,64,0,64,64,0,71,64
    db 90,71,0,0,64,0,0,57,0,30,71,64,0,66,64,0
    db 59,64,90,59,0,0,66,0,0,71,0,30,71,64,0,66
    db 64,0,59,64,90,59,0,0,66,0,0,71,0,30,71,64
    db 0,66,64,0,59,64,90,59,0,0,66,0,0,71,0,30
    db 71,64,0,66,64,0,59,64,90,59,0,0,66,0,0,71
    db 0,30,71,64,0,66,64,0,59,64,90,59,0,0,66,0
    db 0,71,0,30,71,64,0,66,64,0,59,64,90,59,0,0
    db 66,0,0,71,0,30,71,64,0,66,64,0,59,64,90,59
    db 0,0,66,0,0,71,0,30,57,64,90,57,0,30,57,64
    db 0,64,64,0,71,64,90,71,0,0,64,0,0,57,0,30
    db 57,64,0,64,64,0,71,64,90,71,0,0,64,0,0,57
    db 0,30,57,64,0,64,64,0,71,64,90,71,0,0,64,0
    db 0,57,0,30,57,64,0,64,64,0,71,64,90,71,0,0
    db 64,0,0,57,0,30,57,64,0,64,64,0,71,64,90,71
    db 0,0,64,0,0,57,0,30,57,64,0,64,64,0,71,64
    db 90,71,0,0,64,0,0,57,0,30,57,64,0,64,64,0
    db 71,64,90,71,0,0,64,0,0,57,0,30,57,64,0,64
    db 64,0,71,64,90,71,0,0,64,0,0,57,0,30,61,64
    db 0,68,64,0,73,64,90,73,0,0,68,0,0,61,0,30
    db 73,64,0,68,64,0,61,64,90,61,0,0,68,0,0,73
    db 0,30,61,64,0,68,64,0,73,64,90,73,0,0,68,0
    db 0,61,0,30,61,64,0,68,64,0,73,64,90,73,0,0
    db 68,0,0,61,0,30,61,64,0,68,64,0,73,64,90,73
    db 0,0,68,0,0,61,0,30,61,64,0,68,64,0,73,64
    db 90,73,0,0,68,0,0,61,0,30,61,64,0,68,64,0
    db 73,64,90,73,0,0,68,0,0,61,0,30,61,64,0,68
    db 64,0,73,64,90,73,0,0,68,0,0,61,0,30,66,64
    db 0,61,64,0,57,64,90,57,0,0,61,0,0,66,0,30
    db 57,64,0,61,64,0,66,64,90,66,0,0,61,0,0,57
    db 0,30,57,64,0,61,64,0,66,64,90,66,0,0,61,0
    db 0,57,0,30,57,64,0,61,64,0,66,64,90,66,0,0
    db 61,0,0,57,0,30,57,64,0,61,64,0,66,64,90,66
    db 0,0,61,0,0,57,0,30,57,64,0,61,64,0,66,64
    db 90,66,0,0,61,0,0,57,0,30,57,64,0,61,64,0
    db 66,64,90,66,0,0,61,0,0,57,0,30,57,64,0,61
    db 64,0,66,64,90,66,0,0,61,0,0,57,0,30,69,64
    db 0,64,64,0,57,64,90,57,0,0,64,0,0,69,0,30
    db 57,64,0,64,64,0,69,64,90,69,0,0,64,0,0,57
    db 0,30,57,64,0,69,64,0,64,64,90,64,0,0,69,0
    db 0,57,0,30,57,64,0,64,64,0,69,64,90,69,0,0
    db 64,0,0,57,0,30,71,64,0,66,64,0,59,64,90,59
    db 0,0,66,0,0,71,0,129,22,59,64,0,66,64,0,71
    db 64,90,71,0,0,66,0,0,59,0,129,22,61,64,0,68
    db 64,0,73,64,90,73,0,0,68,0,0,61,0,30,61,64
    db 0,68,64,0,73,64,30,68,0,30,68,64,30,68,0,0
    db 73,0,0,61,0,30,61,64,0,68,64,0,73,64,90,73
    db 0,0,68,0,0,61,0,30,61,64,0,68,64,0,73,64
    db 0,76,64,90,76,0,0,61,0,0,68,0,0,73,0,30
    db 73,64,0,68,64,0,61,64,90,61,0,0,68,0,0,73
    db 0,129,22,59,64,0,66,64,0,71,64,90,71,0,0,66
    db 0,0,59,0,129,22,69,64,0,64,64,0,57,64,90,57
    db 0,0,64,0,0,69,0,30,57,64,0,64,64,0,69,64
    db 90,69,0,0,64,0,0,57,0,30,57,64,0,69,64,0
    db 64,64,90,64,0,0,69,0,0,57,0,30,57,64,0,64
    db 64,0,69,64,90,69,0,0,64,0,0,57,0,30,71,64
    db 0,66,64,0,59,64,90,59,0,0,66,0,0,71,0,30
    db 71,64,90,71,0,30,59,64,0,66,64,0,71,64,90,71
    db 0,0,66,0,0,59,0,30,71,64,90,71,0,30,61,64
    db 0,68,64,0,73,64,90,73,0,0,68,0,0,61,0,30
    db 61,64,0,68,64,0,73,64,30,68,0,30,68,64,30,68
    db 0,0,73,0,0,61,0,30,61,64,0,68,64,0,73,64
    db 90,73,0,0,68,0,0,61,0,30,61,64,0,68,64,0
    db 73,64,0,76,64,90,76,0,0,61,0,0,68,0,0,73
    db 0,30,73,64,0,68,64,0,61,64,90,61,0,0,68,0
    db 0,73,0,129,22,59,64,0,66,64,0,71,64,90,71,0
    db 0,66,0,0,59,0,129,22,69,64,0,64,64,0,57,64
    db 90,57,0,0,64,0,0,69,0,30,57,64,0,64,64,0
    db 69,64,90,69,0,0,64,0,0,57,0,30,57,64,0,69
    db 64,0,64,64,90,64,0,0,69,0,0,57,0,30,57,64
    db 0,64,64,0,69,64,90,69,0,0,64,0,0,57,0,30
    db 71,64,0,66,64,0,59,64,90,59,0,0,66,0,0,71
    db 0,30,71,64,90,71,0,30,59,64,0,66,64,0,71,64
    db 90,71,0,0,66,0,0,59,0,30,71,64,90,71,0,30
    db 71,64,0,76,64,0,52,64,0,64,64,90,64,0,0,71
    db 0,0,76,0,0,52,0,30,71,64,0,76,64,0,52,64
    db 0,64,64,0,59,64,30,59,0,0,52,0,0,71,0,0
    db 76,0,0,64,0,30,71,64,0,76,64,0,52,64,0,64
    db 64,30,64,0,0,71,0,0,76,0,0,52,0,30,71,64
    db 0,76,64,0,52,64,0,64,64,0,68,64,90,68,0,0
    db 52,0,0,71,0,0,76,0,0,64,0,30,71,64,0,76
    db 64,0,52,64,0,64,64,90,64,0,0,71,0,0,76,0
    db 0,52,0,30,76,64,90,76,0,30,71,64,0,76,64,0
    db 64,64,0,52,64,90,52,0,0,71,0,0,76,0,0,64
    db 0,30,71,64,0,76,64,0,64,64,0,52,64,0,69,64
    db 90,69,0,0,64,0,0,71,0,0,76,0,0,52,0,30
    db 71,64,0,76,64,0,64,64,0,52,64,0,69,64,90,69
    db 0,0,64,0,0,71,0,0,76,0,0,52,0,30,64,64
    db 0,71,64,0,76,64,0,52,64,0,68,64,0,59,64,90
    db 59,0,0,71,0,0,76,0,0,64,0,0,68,0,0,52
    db 0,134,102,64,64,0,71,64,0,76,64,0,52,64,90,52
    db 0,0,64,0,0,71,0,0,76,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,64,64,0,76,64
    db 0,71,64,0,52,64,90,52,0,0,64,0,0,76,0,0
    db 71,0,30,64,64,0,71,64,0,76,64,0,52,64,90,52
    db 0,0,64,0,0,71,0,0,76,0,129,22,64,64,0,68
    db 64,0,52,64,0,71,64,90,71,0,0,64,0,0,68,0
    db 0,52,0,30,64,64,0,52,64,0,71,64,90,71,0,0
    db 52,0,0,64,0,30,64,64,0,52,64,0,71,64,90,71
    db 0,0,52,0,0,64,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,30
    db 76,64,0,71,64,0,64,64,0,52,64,30,52,0,0,76
    db 0,0,71,0,0,64,0,30,76,64,0,71,64,0,64,64
    db 0,52,64,30,52,0,0,76,0,0,71,0,0,64,0,30
    db 64,64,0,76,64,0,71,64,0,52,64,90,52,0,0,64
    db 0,0,76,0,0,71,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,129
    db 22,64,64,0,68,64,0,52,64,0,71,64,90,71,0,0
    db 64,0,0,68,0,0,52,0,30,64,64,0,52,64,0,71
    db 64,90,71,0,0,52,0,0,64,0,30,64,64,0,52,64
    db 0,71,64,90,71,0,0,52,0,0,64,0,30,64,64,0
    db 71,64,0,76,64,0,52,64,90,52,0,0,64,0,0,71
    db 0,0,76,0,30,76,64,0,71,64,0,64,64,0,52,64
    db 30,52,0,0,76,0,0,71,0,0,64,0,30,76,64,0
    db 71,64,0,64,64,0,52,64,30,52,0,0,76,0,0,71
    db 0,0,64,0,30,64,64,0,76,64,0,71,64,0,52,64
    db 90,52,0,0,64,0,0,76,0,0,71,0,30,64,64,0
    db 71,64,0,76,64,0,52,64,90,52,0,0,64,0,0,71
    db 0,0,76,0,129,22,64,64,0,68,64,0,52,64,0,71
    db 64,90,71,0,0,64,0,0,68,0,0,52,0,30,64,64
    db 0,52,64,0,71,64,90,71,0,0,52,0,0,64,0,30
    db 64,64,0,52,64,0,71,64,90,71,0,0,52,0,0,64
    db 0,30,64,64,0,71,64,0,76,64,0,52,64,90,52,0
    db 0,64,0,0,71,0,0,76,0,30,76,64,0,71,64,0
    db 64,64,0,52,64,30,52,0,0,76,0,0,71,0,0,64
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,30,52,0
    db 0,76,0,0,71,0,0,64,0,30,64,64,0,76,64,0
    db 71,64,0,52,64,90,52,0,0,64,0,0,76,0,0,71
    db 0,30,64,64,0,71,64,0,76,64,0,52,64,90,52,0
    db 0,64,0,0,71,0,0,76,0,129,22,64,64,0,68,64
    db 0,52,64,0,71,64,90,71,0,0,64,0,0,68,0,0
    db 52,0,30,64,64,0,52,64,0,71,64,90,71,0,0,52
    db 0,0,64,0,30,64,64,0,52,64,0,71,64,90,71,0
    db 0,52,0,0,64,0,30,69,64,0,64,64,0,57,64,0
    db 52,64,90,52,0,0,69,0,0,64,0,0,57,0,30,69
    db 64,0,64,64,0,57,64,0,52,64,30,52,0,0,69,0
    db 0,64,0,0,57,0,30,69,64,0,64,64,0,57,64,0
    db 52,64,30,52,0,0,69,0,0,64,0,0,57,0,30,69
    db 64,0,64,64,0,57,64,0,52,64,90,52,0,0,69,0
    db 0,64,0,0,57,0,30,69,64,0,64,64,0,57,64,0
    db 52,64,90,52,0,0,69,0,0,64,0,0,57,0,129,22
    db 69,64,0,64,64,0,57,64,0,52,64,90,52,0,0,69
    db 0,0,64,0,0,57,0,30,69,64,0,64,64,0,57,64
    db 90,57,0,0,64,0,0,69,0,30,69,64,0,64,64,0
    db 57,64,0,52,64,90,52,0,0,69,0,0,64,0,0,57
    db 0,30,69,64,0,64,64,0,57,64,0,52,64,90,52,0
    db 0,69,0,0,64,0,0,57,0,30,69,64,0,64,64,0
    db 57,64,0,52,64,30,52,0,0,69,0,0,64,0,0,57
    db 0,30,69,64,0,64,64,0,57,64,0,52,64,30,52,0
    db 0,69,0,0,64,0,0,57,0,30,69,64,0,64,64,0
    db 57,64,0,52,64,90,52,0,0,69,0,0,64,0,0,57
    db 0,30,69,64,0,64,64,0,57,64,0,52,64,90,52,0
    db 0,69,0,0,64,0,0,57,0,129,22,69,64,0,64,64
    db 0,57,64,0,52,64,90,52,0,0,69,0,0,64,0,0
    db 57,0,30,69,64,0,64,64,0,57,64,90,57,0,0,64
    db 0,0,69,0,30,64,64,0,52,64,90,52,0,0,64,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,30,76,64,0,71,64,0,64
    db 64,0,52,64,30,52,0,0,76,0,0,71,0,0,64,0
    db 30,76,64,0,71,64,0,64,64,0,52,64,30,52,0,0
    db 76,0,0,71,0,0,64,0,30,64,64,0,76,64,0,71
    db 64,0,52,64,90,52,0,0,64,0,0,76,0,0,71,0
    db 30,64,64,0,71,64,0,76,64,0,52,64,90,52,0,0
    db 64,0,0,71,0,0,76,0,129,22,64,64,0,68,64,0
    db 52,64,0,71,64,90,71,0,0,64,0,0,68,0,0,52
    db 0,30,64,64,0,52,64,0,71,64,90,71,0,0,52,0
    db 0,64,0,30,64,64,0,52,64,0,71,64,90,71,0,0
    db 52,0,0,64,0,30,64,64,0,71,64,0,76,64,0,52
    db 64,90,52,0,0,64,0,0,71,0,0,76,0,30,76,64
    db 0,71,64,0,64,64,0,52,64,30,52,0,0,76,0,0
    db 71,0,0,64,0,30,76,64,0,71,64,0,64,64,0,52
    db 64,30,52,0,0,76,0,0,71,0,0,64,0,30,64,64
    db 0,76,64,0,71,64,0,52,64,90,52,0,0,64,0,0
    db 76,0,0,71,0,30,64,64,0,71,64,0,76,64,0,52
    db 64,90,52,0,0,64,0,0,71,0,0,76,0,129,22,64
    db 64,0,68,64,0,52,64,0,71,64,90,71,0,0,64,0
    db 0,68,0,0,52,0,30,64,64,0,52,64,0,71,64,90
    db 71,0,0,52,0,0,64,0,30,64,64,0,52,64,0,71
    db 64,90,71,0,0,52,0,0,64,0,30,66,64,0,59,64
    db 0,54,64,90,54,0,0,59,0,0,66,0,30,66,64,0
    db 59,64,0,54,64,90,54,0,0,59,0,0,66,0,30,54
    db 64,0,59,64,0,66,64,90,66,0,0,59,0,0,54,0
    db 30,54,64,0,59,64,0,66,64,90,66,0,0,59,0,0
    db 54,0,30,54,64,0,59,64,0,66,64,90,66,0,0,59
    db 0,0,54,0,30,54,64,0,59,64,0,66,64,90,66,0
    db 0,59,0,0,54,0,30,54,64,0,59,64,0,66,64,90
    db 66,0,0,59,0,0,54,0,30,54,64,0,59,64,0,66
    db 64,90,66,0,0,59,0,0,54,0,30,64,64,0,57,64
    db 0,52,64,90,52,0,0,57,0,0,64,0,30,64,64,0
    db 57,64,0,52,64,90,52,0,0,57,0,0,64,0,30,64
    db 64,0,57,64,0,52,64,90,52,0,0,57,0,0,64,0
    db 30,64,64,0,57,64,0,52,64,90,52,0,0,57,0,0
    db 64,0,30,64,64,0,57,64,0,52,64,90,52,0,0,57
    db 0,0,64,0,30,64,64,0,57,64,0,52,64,90,52,0
    db 0,57,0,0,64,0,30,64,64,0,57,64,0,52,64,90
    db 52,0,0,57,0,0,64,0,30,64,64,0,57,64,0,52
    db 64,90,52,0,0,57,0,0,64,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,64,64,0,76,64,0,71,64,0,52,64,90,52
    db 0,0,64,0,0,76,0,0,71,0,30,64,64,0,71,64
    db 0,76,64,0,52,64,90,52,0,0,64,0,0,71,0,0
    db 76,0,129,22,64,64,0,52,64,0,71,64,0,76,64,90
    db 76,0,0,64,0,0,52,0,0,71,0,30,64,64,0,52
    db 64,0,71,64,0,76,64,90,76,0,0,64,0,0,52,0
    db 0,71,0,30,64,64,0,52,64,0,71,64,0,76,64,90
    db 76,0,0,64,0,0,52,0,0,71,0,30,52,64,0,64
    db 64,0,71,64,0,76,64,90,76,0,0,52,0,0,64,0
    db 0,71,0,134,102,64,64,0,71,64,0,76,64,0,52,64
    db 90,52,0,0,64,0,0,71,0,0,76,0,30,76,64,0
    db 71,64,0,64,64,0,52,64,30,52,0,0,76,0,0,71
    db 0,0,64,0,30,76,64,0,71,64,0,64,64,0,52,64
    db 30,52,0,0,76,0,0,71,0,0,64,0,30,64,64,0
    db 76,64,0,71,64,0,52,64,90,52,0,0,64,0,0,76
    db 0,0,71,0,30,64,64,0,71,64,0,76,64,0,52,64
    db 90,52,0,0,64,0,0,71,0,0,76,0,129,22,64,64
    db 0,68,64,0,52,64,0,71,64,90,71,0,0,64,0,0
    db 68,0,0,52,0,30,64,64,0,52,64,0,71,64,90,71
    db 0,0,52,0,0,64,0,30,64,64,0,52,64,0,71,64
    db 90,71,0,0,52,0,0,64,0,30,64,64,0,71,64,0
    db 76,64,0,52,64,90,52,0,0,64,0,0,71,0,0,76
    db 0,30,76,64,0,71,64,0,64,64,0,52,64,30,52,0
    db 0,76,0,0,71,0,0,64,0,30,76,64,0,71,64,0
    db 64,64,0,52,64,30,52,0,0,76,0,0,71,0,0,64
    db 0,30,64,64,0,76,64,0,71,64,0,52,64,90,52,0
    db 0,64,0,0,76,0,0,71,0,30,64,64,0,71,64,0
    db 76,64,0,52,64,90,52,0,0,64,0,0,71,0,0,76
    db 0,129,22,64,64,0,68,64,0,52,64,0,71,64,90,71
    db 0,0,64,0,0,68,0,0,52,0,30,64,64,0,52,64
    db 0,71,64,90,71,0,0,52,0,0,64,0,30,64,64,0
    db 52,64,0,71,64,90,71,0,0,52,0,0,64,0,30,64
    db 64,0,71,64,0,76,64,0,52,64,90,52,0,0,64,0
    db 0,71,0,0,76,0,30,76,64,0,71,64,0,64,64,0
    db 52,64,30,52,0,0,76,0,0,71,0,0,64,0,30,76
    db 64,0,71,64,0,64,64,0,52,64,30,52,0,0,76,0
    db 0,71,0,0,64,0,30,64,64,0,76,64,0,71,64,0
    db 52,64,90,52,0,0,64,0,0,76,0,0,71,0,30,64
    db 64,0,71,64,0,76,64,0,52,64,90,52,0,0,64,0
    db 0,71,0,0,76,0,129,22,64,64,0,68,64,0,52,64
    db 0,71,64,90,71,0,0,64,0,0,68,0,0,52,0,30
    db 64,64,0,52,64,0,71,64,90,71,0,0,52,0,0,64
    db 0,30,64,64,0,52,64,0,71,64,90,71,0,0,52,0
    db 0,64,0,30,64,64,0,71,64,0,76,64,0,52,64,90
    db 52,0,0,64,0,0,71,0,0,76,0,30,76,64,0,71
    db 64,0,64,64,0,52,64,30,52,0,0,76,0,0,71,0
    db 0,64,0,30,76,64,0,71,64,0,64,64,0,52,64,30
    db 52,0,0,76,0,0,71,0,0,64,0,30,64,64,0,76
    db 64,0,71,64,0,52,64,90,52,0,0,64,0,0,76,0
    db 0,71,0,30,64,64,0,71,64,0,76,64,0,52,64,90
    db 52,0,0,64,0,0,71,0,0,76,0,129,22,64,64,0
    db 68,64,0,52,64,0,71,64,90,71,0,0,64,0,0,68
    db 0,0,52,0,30,64,64,0,52,64,0,71,64,90,71,0
    db 0,52,0,0,64,0,30,64,64,0,52,64,0,71,64,90
    db 71,0,0,52,0,0,64,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,90,52,0,0,69,0,0,64,0,0,57,0
    db 30,69,64,0,57,64,0,64,64,0,52,64,30,52,0,0
    db 69,0,0,57,0,0,64,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,30,52,0,0,69,0,0,64,0,0,57,0
    db 30,69,64,0,57,64,0,64,64,0,52,64,90,52,0,0
    db 69,0,0,57,0,0,64,0,30,69,64,0,64,64,0,57
    db 64,0,52,64,90,52,0,0,69,0,0,64,0,0,57,0
    db 129,22,69,64,0,57,64,0,64,64,0,52,64,90,52,0
    db 0,69,0,0,57,0,0,64,0,30,69,64,0,57,64,0
    db 64,64,90,64,0,0,57,0,0,69,0,30,69,64,0,64
    db 64,0,57,64,0,52,64,90,52,0,0,69,0,0,64,0
    db 0,57,0,30,69,64,0,64,64,0,57,64,0,52,64,90
    db 52,0,0,69,0,0,64,0,0,57,0,30,69,64,0,57
    db 64,0,64,64,0,52,64,30,52,0,0,69,0,0,57,0
    db 0,64,0,30,69,64,0,64,64,0,57,64,0,52,64,30
    db 52,0,0,69,0,0,64,0,0,57,0,30,69,64,0,57
    db 64,0,64,64,0,52,64,90,52,0,0,69,0,0,57,0
    db 0,64,0,30,69,64,0,64,64,0,57,64,0,52,64,90
    db 52,0,0,69,0,0,64,0,0,57,0,129,22,69,64,0
    db 57,64,0,64,64,0,52,64,90,52,0,0,69,0,0,57
    db 0,0,64,0,30,69,64,0,57,64,0,64,64,90,64,0
    db 0,57,0,0,69,0,30,64,64,0,52,64,90,52,0,0
    db 64,0,30,64,64,0,71,64,0,76,64,0,52,64,90,52
    db 0,0,64,0,0,71,0,0,76,0,30,76,64,0,71,64
    db 0,64,64,0,52,64,30,52,0,0,76,0,0,71,0,0
    db 64,0,30,76,64,0,71,64,0,64,64,0,52,64,30,52
    db 0,0,76,0,0,71,0,0,64,0,30,64,64,0,76,64
    db 0,71,64,0,52,64,90,52,0,0,64,0,0,76,0,0
    db 71,0,30,64,64,0,71,64,0,76,64,0,52,64,90,52
    db 0,0,64,0,0,71,0,0,76,0,129,22,64,64,0,68
    db 64,0,52,64,0,71,64,90,71,0,0,64,0,0,68,0
    db 0,52,0,30,64,64,0,52,64,0,71,64,90,71,0,0
    db 52,0,0,64,0,30,64,64,0,52,64,0,71,64,90,71
    db 0,0,52,0,0,64,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,30
    db 76,64,0,71,64,0,64,64,0,52,64,30,52,0,0,76
    db 0,0,71,0,0,64,0,30,76,64,0,71,64,0,64,64
    db 0,52,64,30,52,0,0,76,0,0,71,0,0,64,0,30
    db 64,64,0,76,64,0,71,64,0,52,64,90,52,0,0,64
    db 0,0,76,0,0,71,0,30,64,64,0,71,64,0,76,64
    db 0,52,64,90,52,0,0,64,0,0,71,0,0,76,0,129
    db 22,64,64,0,68,64,0,52,64,0,71,64,90,71,0,0
    db 64,0,0,68,0,0,52,0,30,64,64,0,52,64,0,71
    db 64,90,71,0,0,52,0,0,64,0,30,64,64,0,52,64
    db 0,71,64,90,71,0,0,52,0,0,64,0,30,66,64,0
    db 59,64,0,54,64,90,54,0,0,59,0,0,66,0,30,66
    db 64,0,59,64,0,54,64,0,71,64,90,71,0,0,66,0
    db 0,59,0,0,54,0,30,66,64,0,59,64,0,54,64,90
    db 54,0,0,59,0,0,66,0,30,66,64,0,59,64,0,54
    db 64,0,71,64,90,71,0,0,66,0,0,59,0,0,54,0
    db 30,66,64,0,59,64,0,54,64,90,54,0,0,59,0,0
    db 66,0,30,66,64,0,59,64,0,54,64,0,71,64,90,71
    db 0,0,66,0,0,59,0,0,54,0,30,66,64,0,59,64
    db 0,54,64,90,54,0,0,59,0,0,66,0,30,66,64,0
    db 59,64,0,54,64,0,71,64,90,71,0,0,66,0,0,59
    db 0,0,54,0,30,52,64,0,57,64,0,64,64,90,64,0
    db 0,57,0,0,52,0,30,69,64,0,64,64,0,57,64,0
    db 52,64,90,52,0,0,69,0,0,64,0,0,57,0,30,52
    db 64,0,57,64,0,64,64,90,64,0,0,57,0,0,52,0
    db 30,69,64,0,64,64,0,57,64,0,52,64,90,52,0,0
    db 69,0,0,64,0,0,57,0,30,52,64,0,57,64,0,64
    db 64,90,64,0,0,57,0,0,52,0,30,69,64,0,64,64
    db 0,57,64,0,52,64,90,52,0,0,69,0,0,64,0,0
    db 57,0,30,52,64,0,57,64,0,64,64,90,64,0,0,57
    db 0,0,52,0,30,69,64,0,64,64,0,57,64,0,52,64
    db 90,52,0,0,69,0,0,64,0,0,57,0,30,64,64,0
    db 71,64,0,76,64,0,52,64,90,52,0,0,64,0,0,71
    db 0,0,76,0,30,76,64,0,71,64,0,64,64,0,52,64
    db 30,52,0,0,76,0,0,71,0,0,64,0,30,76,64,0
    db 71,64,0,64,64,0,52,64,30,52,0,0,76,0,0,71
    db 0,0,64,0,30,64,64,0,76,64,0,71,64,0,52,64
    db 90,52,0,0,64,0,0,76,0,0,71,0,30,64,64,0
    db 71,64,0,76,64,0,52,64,90,52,0,0,64,0,0,71
    db 0,0,76,0,129,22,64,64,0,52,64,0,71,64,90,71
    db 0,0,52,0,0,64,0,30,64,64,0,52,64,0,71,64
    db 90,71,0,0,52,0,0,64,0,30,64,64,0,52,64,0
    db 71,64,0,57,64,90,57,0,0,64,0,0,52,0,0,71
    db 0,30,52,64,0,64,64,0,71,64,0,76,64,90,76,0
    db 0,52,0,0,64,0,0,71,0,30,52,64,0,64,64,0
    db 71,64,0,76,64,30,76,0,0,52,0,0,64,0,0,71
    db 0,30,52,64,0,64,64,0,71,64,0,76,64,30,76,0
    db 0,52,0,0,64,0,0,71,0,30,56,64,0,68,64,0
    db 64,64,0,71,64,0,76,64,90,76,0,0,64,0,0,56
    db 0,0,68,0,0,71,0,30,56,64,0,71,64,0,64,64
    db 0,76,64,90,76,0,0,56,0,0,71,0,0,64,0,30
    db 62,64,0,74,64,0,71,64,90,71,0,0,74,0,0,62
    db 0,30,62,64,0,74,64,0,64,64,0,71,64,0,76,64
    db 90,76,0,0,64,0,0,62,0,0,74,0,0,71,0,30
    db 56,64,0,68,64,0,64,64,0,71,64,0,76,64,90,76
    db 0,0,64,0,0,56,0,0,68,0,0,71,0,30,57,64
    db 0,69,64,0,64,64,0,71,64,0,76,64,90,76,0,0
    db 64,0,0,57,0,0,69,0,0,71,0,30,66,64,0,59
    db 64,0,54,64,90,54,0,0,59,0,0,66,0,30,66,64
    db 0,59,64,0,54,64,0,71,64,90,71,0,0,66,0,0
    db 59,0,0,54,0,30,66,64,0,59,64,0,54,64,90,54
    db 0,0,59,0,0,66,0,30,66,64,0,59,64,0,54,64
    db 0,71,64,90,71,0,0,66,0,0,59,0,0,54,0,30
    db 66,64,0,59,64,0,54,64,90,54,0,0,59,0,0,66
    db 0,30,66,64,0,59,64,0,54,64,0,71,64,90,71,0
    db 0,66,0,0,59,0,0,54,0,30,66,64,0,59,64,0
    db 54,64,90,54,0,0,59,0,0,66,0,30,66,64,0,59
    db 64,0,54,64,0,71,64,90,71,0,0,66,0,0,59,0
    db 0,54,0,30,52,64,0,57,64,0,64,64,90,64,0,0
    db 57,0,0,52,0,30,69,64,0,64,64,0,57,64,0,52
    db 64,90,52,0,0,69,0,0,64,0,0,57,0,30,52,64
    db 0,57,64,0,64,64,90,64,0,0,57,0,0,52,0,30
    db 69,64,0,64,64,0,57,64,0,52,64,90,52,0,0,69
    db 0,0,64,0,0,57,0,30,52,64,0,57,64,0,64,64
    db 90,64,0,0,57,0,0,52,0,30,69,64,0,64,64,0
    db 57,64,0,52,64,90,52,0,0,69,0,0,64,0,0,57
    db 0,30,52,64,0,57,64,0,64,64,90,64,0,0,57,0
    db 0,52,0,30,69,64,0,64,64,0,57,64,0,52,64,90
    db 52,0,0,69,0,0,64,0,0,57,0,30,52,64,0,64
    db 64,0,71,64,0,76,64,90,76,0,0,52,0,0,64,0
    db 0,71,0,30,52,64,0,64,64,0,71,64,0,76,64,30
    db 76,0,0,52,0,0,64,0,0,71,0,14,59,64,14,59
    db 0,2,52,64,0,64,64,0,71,64,0,76,64,30,76,0
    db 0,52,0,0,64,0,0,71,0,0,64,64,14,64,0,16
    db 52,64,0,64,64,0,71,64,0,76,64,90,76,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,76,64,90,76,0,0,52,0,0,64,0,0,71,0,129
    db 22,52,64,0,64,64,0,71,64,0,76,64,90,76,0,0
    db 52,0,0,64,0,0,71,0,30,52,64,0,64,64,0,71
    db 64,0,76,64,90,76,0,0,52,0,0,64,0,0,71,0
    db 30,52,64,0,64,64,0,71,64,0,76,64,0,59,64,90
    db 59,0,0,71,0,0,52,0,0,64,0,0,76,0,30,52
    db 64,0,64,64,0,71,64,0,76,64,90,76,0,0,52,0
    db 0,64,0,0,71,0,134,102,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,90,68,0,0,64,0,0,71,0,0,52,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,73,64,0,69,64,90,69,0,0,52
    db 0,0,64,0,0,73,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 64,64,0,71,64,0,52,64,0,68,64,90,68,0,0,64
    db 0,0,71,0,0,52,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,30,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,30,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,52,64,0,64,64,0,73,64
    db 0,69,64,90,69,0,0,52,0,0,64,0,0,73,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,30,64,64,0,71,64,0,52,64
    db 0,68,64,0,179,7,110,90,147,68,0,0,64,0,0,71
    db 0,0,52,0,30,52,64,0,64,64,0,71,64,0,68,64
    db 30,68,0,0,52,0,0,64,0,0,71,0,30,52,64,0
    db 64,64,0,71,64,0,68,64,30,68,0,0,52,0,0,64
    db 0,0,71,0,30,52,64,0,64,64,0,71,64,0,68,64
    db 90,68,0,0,52,0,0,64,0,0,71,0,30,52,64,0
    db 64,64,0,71,64,0,68,64,90,68,0,0,52,0,0,64
    db 0,0,71,0,30,52,64,0,64,64,0,71,64,0,68,64
    db 90,68,0,0,52,0,0,64,0,0,71,0,30,52,64,0
    db 64,64,0,71,64,0,68,64,90,68,0,0,52,0,0,64
    db 0,0,71,0,30,52,64,0,64,64,0,73,64,0,69,64
    db 90,69,0,0,52,0,0,64,0,0,73,0,30,52,64,0
    db 64,64,0,71,64,0,68,64,90,68,0,0,52,0,0,64
    db 0,0,71,0,30,64,64,0,71,64,0,52,64,0,68,64
    db 0,179,7,90,90,147,68,0,0,64,0,0,71,0,0,52
    db 0,30,52,64,0,64,64,0,71,64,0,68,64,30,68,0
    db 0,52,0,0,64,0,0,71,0,30,52,64,0,64,64,0
    db 71,64,0,68,64,30,68,0,0,52,0,0,64,0,0,71
    db 0,30,52,64,0,64,64,0,71,64,0,68,64,90,68,0
    db 0,52,0,0,64,0,0,71,0,30,52,64,0,64,64,0
    db 71,64,0,68,64,90,68,0,0,52,0,0,64,0,0,71
    db 0,30,52,64,0,64,64,0,71,64,0,68,64,90,68,0
    db 0,52,0,0,64,0,0,71,0,30,52,64,0,64,64,0
    db 71,64,0,68,64,90,68,0,0,52,0,0,64,0,0,71
    db 0,30,52,64,0,64,64,0,73,64,0,69,64,90,69,0
    db 0,52,0,0,64,0,0,73,0,30,52,64,0,64,64,0
    db 71,64,0,68,64,90,68,0,0,52,0,0,64,0,0,71
    db 0,30,64,64,0,71,64,0,52,64,0,68,64,0,179,7
    db 70,90,147,68,0,0,64,0,0,71,0,0,52,0,30,52
    db 64,0,64,64,0,71,64,0,68,64,30,68,0,0,52,0
    db 0,64,0,0,71,0,30,52,64,0,64,64,0,71,64,0
    db 68,64,30,68,0,0,52,0,0,64,0,0,71,0,30,52
    db 64,0,64,64,0,71,64,0,68,64,90,68,0,0,52,0
    db 0,64,0,0,71,0,30,52,64,0,64,64,0,71,64,0
    db 68,64,90,68,0,0,52,0,0,64,0,0,71,0,30,52
    db 64,0,64,64,0,71,64,0,68,64,90,68,0,0,52,0
    db 0,64,0,0,71,0,30,52,64,0,64,64,0,71,64,0
    db 68,64,90,68,0,0,52,0,0,64,0,0,71,0,30,52
    db 64,0,64,64,0,73,64,0,69,64,90,69,0,0,52,0
    db 0,64,0,0,73,0,30,52,64,0,64,64,0,71,64,0
    db 68,64,90,68,0,0,52,0,0,64,0,0,71,0,30,64
    db 64,0,71,64,0,52,64,0,68,64,0,179,7,50,90,147
    db 68,0,0,64,0,0,71,0,0,52,0,30,52,64,0,64
    db 64,0,71,64,0,68,64,30,68,0,0,52,0,0,64,0
    db 0,71,0,30,52,64,0,64,64,0,71,64,0,68,64,30
    db 68,0,0,52,0,0,64,0,0,71,0,30,52,64,0,64
    db 64,0,71,64,0,68,64,90,68,0,0,52,0,0,64,0
    db 0,71,0,30,52,64,0,64,64,0,71,64,0,68,64,90
    db 68,0,0,52,0,0,64,0,0,71,0,30,52,64,0,64
    db 64,0,71,64,0,68,64,90,68,0,0,52,0,0,64,0
    db 0,71,0,30,52,64,0,64,64,0,71,64,0,68,64,90
    db 68,0,0,52,0,0,64,0,0,71,0,30,52,64,0,64
    db 64,0,73,64,0,69,64,90,69,0,0,52,0,0,64,0
    db 0,73,0,30,52,64,0,64,64,0,71,64,0,68,64,90
    db 68,0,0,52,0,0,64,0,0,71,0,30,64,64,0,71
    db 64,0,52,64,0,68,64,0,179,7,30,90,147,68,0,0
    db 64,0,0,71,0,0,52,0,30,52,64,0,64,64,0,71
    db 64,0,68,64,30,68,0,0,52,0,0,64,0,0,71,0
    db 30,52,64,0,64,64,0,71,64,0,68,64,30,68,0,0
    db 52,0,0,64,0,0,71,0,30,52,64,0,64,64,0,71
    db 64,0,68,64,90,68,0,0,52,0,0,64,0,0,71,0
    db 30,52,64,0,64,64,0,71,64,0,68,64,90,68,0,0
    db 52,0,0,64,0,0,71,0,30,52,64,0,64,64,0,71
    db 64,0,68,64,90,68,0,0,52,0,0,64,0,0,71,0
    db 30,52,64,0,64,64,0,71,64,0,68,64,90,68,0,0
    db 52,0,0,64,0,0,71,0,30,52,64,0,64,64,0,73
    db 64,0,69,64,90,69,0,0,52,0,0,64,0,0,73,0
    db 30,52,64,0,64,64,0,71,64,0,68,64,90,68,0,0
    db 52,0,0,64,0,0,71,0,30,64,64,0,71,64,0,52
    db 64,0,68,64,0,179,7,20,90,147,68,0,0,64,0,0
    db 71,0,0,52,0,30,52,64,0,64,64,0,71,64,0,68
    db 64,30,68,0,0,52,0,0,64,0,0,71,0,30,52,64
    db 0,64,64,0,71,64,0,68,64,30,68,0,0,52,0,0
    db 64,0,0,71,0,30,52,64,0,64,64,0,71,64,0,68
    db 64,90,68,0,0,52,0,0,64,0,0,71,0,30,52,64
    db 0,64,64,0,71,64,0,68,64,90,68,0,0,52,0,0
    db 64,0,0,71,0,30,52,64,0,64,64,0,71,64,0,68
    db 64,90,68,0,0,52,0,0,64,0,0,71,0,30,52,64
    db 0,64,64,0,71,64,0,68,64,90,68,0,0,52,0,0
    db 64,0,0,71,0,30,52,64,0,64,64,0,73,64,0,69
    db 64,90,69,0,0,52,0,0,64,0,0,73,0,30,52,64
    db 0,64,64,0,71,64,0,68,64,90,68,0,0,52,0,0
    db 64,0,0,71,0,30,64,64,0,71,64,0,52,64,0,68
    db 64,0,179,7,10,90,147,68,0,0,64,0,0,71,0,0
    db 52,0,30,52,64,0,64,64,0,71,64,0,68,64,30,68
    db 0,0,52,0,0,64,0,0,71,0,30,52,64,0,64,64
    db 0,71,64,0,68,64,30,68,0,0,52,0,0,64,0,0
    db 71,0,30,52,64,0,64,64,0,71,64,0,68,64,90,68
    db 0,0,52,0,0,64,0,0,71,0,30,52,64,0,64,64
    db 0,71,64,0,68,64,90,68,0,0,52,0,0,64,0,0
    db 71,0,14,179,7,5,16,147,52,64,0,64,64,0,71,64
    db 0,68,64,90,68,0,0,52,0,0,64,0,0,71,0,30
    db 52,64,0,64,64,0,71,64,0,68,64,90,68,0,0,52
    db 0,0,64,0,0,71,0,14,179,7,2,16,147,52,64,0
    db 64,64,0,73,64,0,69,64,90,69,0,0,52,0,0,64
    db 0,0,73,0,30,52,64,0,64,64,0,71,64,0,68,64
    db 90,68,0,0,52,0,0,64,0,0,71,0,0,255,47,0
    db 77,84,114,107,0,0,13,84,0,255,3,11,76,101,97,100
    db 32,71,117,105,116,97,114,0,192,30,129,217,64,144,93,64
    db 0,85,64,0,81,64,0,74,64,0,69,64,44,69,0,0
    db 81,0,0,93,0,0,85,0,0,74,0,120,92,64,0,83
    db 64,0,80,64,0,71,64,0,68,64,44,68,0,0,80,0
    db 0,92,0,0,83,0,0,71,0,122,88,64,0,85,64,0
    db 76,64,0,74,64,0,64,64,44,64,0,0,76,0,0,88
    db 0,0,85,0,0,74,0,90,90,64,0,81,64,0,78,64
    db 0,66,64,0,62,64,14,62,0,0,78,0,0,90,0,0
    db 81,0,0,66,0,2,92,64,0,83,64,0,80,64,0,68
    db 64,0,64,64,104,64,0,0,80,0,0,92,0,0,83,0
    db 0,68,0,16,90,64,0,81,64,0,78,64,0,66,64,0
    db 62,64,30,66,0,0,78,0,14,90,0,16,88,64,0,76
    db 64,0,64,64,30,64,0,0,88,0,0,62,0,0,81,0
    db 0,76,0,30,90,64,0,80,64,0,78,64,0,66,64,0
    db 59,64,30,59,0,0,78,0,0,90,0,0,80,0,0,66
    db 0,30,76,64,0,88,64,0,64,64,0,57,64,44,57,0
    db 0,76,0,0,88,0,0,64,0,129,8,59,64,0,66,64
    db 0,76,64,0,81,64,0,85,64,0,88,64,0,93,64,2
    db 93,0,0,85,0,0,81,0,0,76,0,0,88,0,12,78
    db 64,0,83,64,0,87,64,0,90,64,0,95,64,133,36,59
    db 0,129,22,57,64,0,64,64,0,69,64,0,73,64,30,73
    db 0,0,69,0,0,57,0,0,64,0,30,57,64,0,64,64
    db 0,69,64,0,73,64,28,95,0,0,83,0,0,87,0,0
    db 90,0,0,78,0,2,66,0,0,73,0,0,69,0,0,57
    db 0,0,64,0,30,57,64,0,64,64,0,69,64,0,73,64
    db 134,102,73,0,0,57,0,0,64,0,0,69,0,30,75,64
    db 0,71,64,0,66,64,0,59,64,30,59,0,0,75,0,0
    db 71,0,0,66,0,30,59,64,0,66,64,0,71,64,0,75
    db 64,134,42,75,0,0,59,0,0,66,0,0,71,0,30,57
    db 64,0,73,64,0,69,64,0,64,64,30,64,0,0,57,0
    db 0,73,0,0,69,0,30,57,64,0,73,64,0,69,64,0
    db 64,64,30,64,0,0,57,0,0,73,0,0,69,0,30,73
    db 64,0,69,64,0,64,64,0,57,64,133,50,64,0,0,73
    db 0,0,69,0,30,69,64,0,73,64,0,76,64,44,76,0
    db 16,78,64,129,22,78,0,0,73,0,0,69,0,0,57,0
    db 30,61,64,0,68,64,0,71,64,0,76,64,0,80,64,135
    db 34,80,0,0,71,0,0,61,0,0,68,0,0,76,0,30
    db 64,64,0,61,64,0,71,64,0,54,64,130,74,71,0,30
    db 70,64,90,70,0,30,70,64,90,70,0,30,66,64,90,66
    db 0,0,61,0,30,61,64,90,61,0,30,66,64,0,70,64
    db 90,70,0,0,54,0,0,64,0,0,66,0,30,57,64,0
    db 64,64,0,69,64,0,73,64,131,66,73,0,0,57,0,0
    db 64,0,0,69,0,30,75,64,0,71,64,0,66,64,0,59
    db 64,131,66,59,0,0,75,0,0,71,0,0,66,0,30,61
    db 64,0,68,64,0,73,64,0,76,64,131,66,76,0,0,61
    db 0,0,68,0,0,73,0,30,76,64,0,73,64,0,68,64
    db 0,61,64,90,61,0,0,76,0,0,73,0,0,68,0,129
    db 22,59,64,0,66,64,0,71,64,0,75,64,90,75,0,0
    db 59,0,0,66,0,0,71,0,129,22,57,64,0,64,64,0
    db 69,64,0,73,64,131,66,73,0,0,57,0,0,64,0,0
    db 69,0,30,75,64,0,71,64,0,66,64,0,59,64,131,66
    db 59,0,0,75,0,0,71,0,0,66,0,30,61,64,0,68
    db 64,0,73,64,0,76,64,131,66,76,0,0,61,0,0,68
    db 0,0,73,0,30,76,64,0,73,64,0,68,64,0,61,64
    db 90,61,0,0,76,0,0,73,0,0,68,0,129,22,59,64
    db 0,66,64,0,71,64,0,75,64,90,75,0,0,59,0,0
    db 66,0,0,71,0,129,22,57,64,0,64,64,0,69,64,0
    db 73,64,131,66,73,0,0,57,0,0,64,0,0,69,0,30
    db 75,64,0,71,64,0,66,64,0,59,64,131,66,59,0,0
    db 75,0,0,71,0,0,66,0,30,52,64,0,64,64,0,71
    db 64,0,76,64,136,26,76,0,0,52,0,0,64,0,0,71
    db 0,130,14,71,64,90,71,0,120,76,64,60,76,0,90,78
    db 64,60,78,0,104,80,64,60,80,0,129,8,80,64,129,112
    db 81,64,30,80,0,90,80,64,30,81,0,129,22,80,0,0
    db 79,64,14,79,0,0,78,64,14,78,0,2,77,64,14,77
    db 0,0,76,64,2,76,0,132,102,71,64,90,71,0,120,76
    db 64,60,76,0,90,78,64,60,78,0,104,80,64,60,80,0
    db 76,80,64,120,81,64,30,80,0,30,80,64,30,81,0,60
    db 80,0,30,76,64,30,76,0,30,71,64,30,71,0,90,80
    db 64,120,81,64,14,80,0,46,80,64,14,81,0,16,80,0
    db 30,76,64,30,76,0,30,71,64,30,71,0,30,69,64,30
    db 69,0,30,68,64,129,82,68,0,0,67,64,14,67,0,0
    db 66,64,2,66,0,132,72,85,64,129,96,86,64,30,85,0
    db 46,85,64,28,86,0,32,85,0,30,81,64,60,81,0,14
    db 76,64,60,76,0,16,74,64,60,74,0,30,73,64,30,73
    db 0,30,74,64,30,74,0,30,73,64,60,73,0,30,69,64
    db 2,69,0,88,64,64,129,6,64,0,0,63,64,14,63,0
    db 2,62,64,14,61,64,2,61,0,14,62,0,132,28,85,64
    db 60,85,0,0,86,64,44,86,0,0,85,64,44,85,0,2
    db 86,64,14,86,0,16,85,64,30,85,0,30,81,64,30,81
    db 0,30,76,64,30,76,0,90,80,64,30,80,0,0,81,64
    db 30,81,0,0,80,64,30,80,0,0,81,64,30,81,0,0
    db 80,64,30,80,0,0,81,64,30,81,0,0,80,64,14,80
    db 0,16,76,64,44,76,0,30,71,64,2,71,0,74,69,64
    db 90,69,0,30,68,64,131,36,68,0,0,67,64,14,67,0
    db 0,66,64,14,66,0,2,65,64,14,65,0,0,64,64,2
    db 64,0,131,94,176,7,100,16,144,71,64,0,75,64,0,66
    db 64,0,59,64,74,58,64,0,65,64,0,70,64,0,74,64
    db 16,59,0,0,66,0,0,71,0,0,75,0,0,57,64,0
    db 64,64,0,69,64,0,73,64,14,58,0,0,70,0,0,74
    db 0,0,65,0,0,56,64,0,63,64,0,68,64,0,72,64
    db 16,57,0,0,69,0,0,73,0,0,64,0,0,55,64,0
    db 62,64,0,67,64,0,71,64,14,56,0,0,68,0,0,72
    db 0,0,63,0,0,54,64,0,61,64,0,66,64,0,70,64
    db 16,55,0,0,67,0,0,71,0,0,62,0,0,53,64,0
    db 60,64,0,65,64,0,69,64,14,54,0,0,66,0,0,70
    db 0,0,61,0,0,52,64,0,59,64,0,64,64,0,68,64
    db 16,53,0,0,65,0,0,69,0,0,60,0,0,51,64,0
    db 58,64,0,63,64,0,67,64,14,52,0,0,64,0,0,68
    db 0,0,59,0,0,50,64,0,57,64,0,62,64,0,66,64
    db 16,51,0,0,63,0,0,67,0,0,58,0,0,49,64,0
    db 56,64,0,61,64,0,65,64,14,50,0,0,62,0,0,66
    db 0,0,57,0,0,48,64,0,55,64,0,60,64,0,64,64
    db 0,176,7,115,16,144,49,0,0,61,0,0,65,0,0,56
    db 0,0,78,64,0,47,64,0,54,64,0,59,64,0,63,64
    db 14,48,0,0,60,0,0,64,0,0,55,0,0,46,64,0
    db 53,64,0,58,64,0,62,64,16,47,0,0,59,0,0,63
    db 0,0,54,0,0,45,64,0,52,64,0,57,64,0,61,64
    db 14,46,0,0,58,0,0,62,0,0,53,0,0,44,64,0
    db 51,64,0,56,64,0,60,64,16,45,0,0,57,0,0,61
    db 0,0,52,0,0,43,64,0,50,64,0,55,64,0,59,64
    db 14,44,0,0,56,0,0,60,0,0,51,0,0,42,64,0
    db 49,64,0,54,64,0,58,64,16,43,0,0,55,0,0,59
    db 0,0,50,0,0,41,64,0,48,64,0,53,64,0,57,64
    db 14,42,0,0,54,0,0,58,0,0,49,0,0,40,64,0
    db 47,64,0,52,64,0,56,64,16,41,0,0,53,0,0,57
    db 0,0,48,0,0,39,64,0,46,64,0,51,64,0,55,64
    db 14,40,0,0,52,0,0,56,0,0,47,0,0,38,64,0
    db 45,64,0,50,64,0,54,64,16,39,0,0,51,0,0,55
    db 0,0,46,0,0,37,64,0,44,64,0,49,64,0,53,64
    db 14,38,0,0,50,0,0,54,0,0,45,0,0,36,64,0
    db 43,64,0,48,64,0,52,64,16,37,0,0,49,0,0,53
    db 0,0,44,0,0,35,64,0,42,64,0,47,64,0,51,64
    db 14,36,0,0,48,0,0,52,0,0,43,0,0,34,64,0
    db 41,64,0,46,64,0,50,64,16,35,0,0,47,0,0,51
    db 0,0,42,0,0,33,64,0,40,64,0,45,64,0,49,64
    db 14,34,0,0,46,0,0,50,0,0,41,0,16,33,0,0
    db 45,0,0,49,0,0,40,0,0,80,64,0,75,64,0,71
    db 64,0,66,64,0,59,64,30,78,0,90,78,64,30,80,0
    db 130,28,75,0,0,78,0,0,77,64,14,77,0,2,76,64
    db 14,76,0,0,75,64,2,75,0,131,80,59,0,0,66,0
    db 0,71,0,30,80,64,120,81,64,30,80,0,90,81,0,0
    db 80,64,14,80,0,30,76,64,14,76,0,32,71,64,14,71
    db 0,16,80,64,129,6,80,0,30,76,64,14,76,0,32,71
    db 64,14,71,0,16,80,64,129,22,80,0,30,76,64,30,76
    db 0,30,71,64,14,71,0,30,68,64,14,68,0,32,68,64
    db 30,68,0,0,69,64,30,69,0,0,70,64,30,70,0,0
    db 69,64,30,69,0,0,70,64,30,70,0,0,69,64,30,69
    db 0,30,68,64,30,68,0,30,64,64,30,64,0,30,59,64
    db 30,59,0,30,57,64,30,57,0,30,56,64,30,56,0,90
    db 67,64,2,67,0,12,69,64,129,36,69,0,2,67,64,14
    db 67,0,30,64,64,30,64,0,16,62,64,14,62,0,16,59
    db 64,30,59,0,14,57,64,14,57,0,32,55,64,30,55,0
    db 0,52,64,131,126,51,64,14,52,0,0,50,64,16,51,0
    db 0,49,64,14,50,0,0,48,64,16,49,0,0,47,64,14
    db 48,0,0,46,64,16,47,0,0,45,64,14,46,0,0,44
    db 64,16,45,0,0,43,64,14,44,0,0,42,64,16,43,0
    db 0,41,64,14,42,0,0,40,64,16,41,0,14,40,0,235
    db 0,52,64,129,82,52,0,141,46,40,64,90,40,0,30,40
    db 64,30,40,0,30,40,64,30,40,0,30,38,64,90,38,0
    db 30,40,64,90,40,0,129,22,38,64,90,38,0,30,38,64
    db 30,38,0,30,40,64,30,40,0,30,44,64,30,44,0,30
    db 40,64,30,40,0,30,40,64,90,40,0,30,40,64,30,40
    db 0,30,40,64,30,40,0,30,38,64,90,38,0,30,40,64
    db 90,40,0,129,22,40,64,90,40,0,30,40,64,90,40,0
    db 129,22,40,64,90,40,0,30,40,64,30,40,0,30,40,64
    db 30,40,0,30,38,64,90,38,0,30,40,64,90,40,0,129
    db 22,40,64,90,40,0,30,38,64,90,38,0,30,40,64,90
    db 40,0,30,40,64,90,40,0,30,40,64,30,40,0,30,40
    db 64,30,40,0,30,38,64,90,38,0,30,40,64,90,40,0
    db 129,22,40,64,90,40,0,30,38,64,90,38,0,30,40,64
    db 90,40,0,30,40,64,90,40,0,30,44,64,30,44,0,30
    db 40,64,30,40,0,30,40,64,90,40,0,30,40,64,90,40
    db 0,129,22,38,64,90,38,0,30,38,64,30,38,0,30,40
    db 64,30,40,0,30,44,64,30,44,0,30,40,64,30,40,0
    db 30,40,64,90,40,0,30,40,64,30,40,0,30,40,64,30
    db 40,0,30,38,64,90,38,0,30,40,64,90,40,0,129,22
    db 40,64,90,40,0,30,40,64,90,40,0,30,40,64,90,40
    db 0,30,40,64,90,40,0,30,40,64,30,40,0,30,40,64
    db 30,40,0,30,40,64,90,40,0,30,40,64,90,40,0,129
    db 22,40,64,90,40,0,30,40,64,90,40,0,30,40,64,90
    db 40,0,30,40,64,90,40,0,30,40,64,30,40,0,30,40
    db 64,30,40,0,30,40,64,90,40,0,30,40,64,90,40,0
    db 129,22,40,64,90,40,0,30,40,64,90,40,0,30,40,64
    db 90,40,0,30,40,64,90,40,0,30,40,64,30,40,0,30
    db 40,64,30,40,0,30,40,64,90,40,0,30,40,64,90,40
    db 0,129,22,40,64,90,40,0,30,40,64,90,40,0,30,40
    db 64,90,40,0,30,40,64,90,40,0,30,44,64,30,44,0
    db 30,40,64,30,40,0,30,35,64,90,35,0,30,40,64,90
    db 40,0,129,22,40,64,90,40,0,30,40,64,90,40,0,30
    db 40,64,90,40,0,30,40,64,90,40,0,30,40,64,30,40
    db 0,30,40,64,30,40,0,30,40,64,90,40,0,30,40,64
    db 90,40,0,129,22,38,64,90,38,0,30,38,64,30,38,0
    db 30,40,64,30,40,0,30,44,64,30,44,0,30,40,64,30
    db 40,0,30,40,64,90,40,0,30,40,64,30,40,0,30,40
    db 64,30,40,0,30,35,64,90,35,0,30,40,64,90,40,0
    db 129,22,40,64,90,40,0,30,40,64,90,40,0,30,40,64
    db 90,40,0,30,40,64,0,176,7,110,90,144,40,0,30,40
    db 64,30,40,0,30,40,64,30,40,0,30,40,64,90,40,0
    db 30,40,64,90,40,0,129,22,38,64,90,38,0,30,38,64
    db 30,38,0,30,40,64,30,40,0,30,44,64,30,44,0,30
    db 40,64,30,40,0,30,40,64,0,176,7,90,90,144,40,0
    db 30,40,64,30,40,0,30,40,64,30,40,0,30,35,64,90
    db 35,0,30,40,64,90,40,0,129,22,40,64,90,40,0,30
    db 40,64,90,40,0,30,40,64,90,40,0,30,40,64,0,176
    db 7,70,90,144,40,0,30,32,64,90,32,0,30,35,64,90
    db 35,0,30,40,64,90,40,0,129,22,40,64,90,40,0,30
    db 40,64,90,40,0,30,40,64,90,40,0,30,40,64,0,176
    db 7,50,90,144,40,0,30,40,64,30,40,0,30,40,64,30
    db 40,0,30,40,64,90,40,0,30,40,64,90,40,0,129,22
    db 40,64,90,40,0,30,40,64,90,40,0,30,40,64,90,40
    db 0,30,40,64,0,176,7,30,90,144,40,0,30,40,64,30
    db 40,0,30,40,64,30,40,0,30,40,64,90,40,0,30,40
    db 64,90,40,0,129,22,40,64,90,40,0,30,40,64,90,40
    db 0,30,40,64,90,40,0,30,40,64,0,176,7,20,90,144
    db 40,0,30,40,64,30,40,0,30,40,64,30,40,0,30,40
    db 64,90,40,0,30,40,64,90,40,0,129,22,38,64,90,38
    db 0,30,38,64,30,38,0,30,40,64,30,40,0,30,44,64
    db 30,44,0,30,40,64,30,40,0,30,40,64,0,176,7,10
    db 90,144,40,0,30,40,64,30,40,0,30,40,64,30,40,0
    db 30,40,64,90,40,0,30,40,64,90,40,0,30,176,7,5
    db 120,144,40,64,90,40,0,14,176,7,2,16,144,40,64,90
    db 40,0,30,40,64,90,40,0,0,255,47,0,77,84,114,107
    db 0,0,5,159,0,255,3,7,83,116,114,105,110,103,115,0
    db 193,44,129,255,0,145,49,64,0,56,64,0,61,64,0,64
    db 64,0,68,64,135,34,68,0,0,56,0,0,49,0,0,64
    db 0,30,66,64,0,59,64,0,52,64,0,42,64,131,66,59
    db 0,30,58,64,131,66,58,0,0,42,0,0,61,0,0,66
    db 0,0,52,0,30,61,64,0,64,64,0,69,64,0,45,64
    db 131,66,45,0,0,61,0,0,64,0,0,69,0,30,47,64
    db 0,63,64,0,66,64,0,71,64,131,66,71,0,0,47,0
    db 0,63,0,0,66,0,30,73,64,0,68,64,0,64,64,0
    db 49,64,133,50,49,0,0,73,0,0,68,0,0,64,0,30
    db 47,64,0,63,64,0,66,64,0,71,64,129,82,71,0,0
    db 47,0,0,63,0,0,66,0,30,61,64,0,64,64,0,69
    db 64,0,45,64,131,66,45,0,0,61,0,0,64,0,0,69
    db 0,30,47,64,0,63,64,0,66,64,0,71,64,131,66,71
    db 0,0,47,0,0,63,0,0,66,0,30,73,64,0,68,64
    db 0,64,64,0,49,64,133,50,49,0,0,73,0,0,68,0
    db 0,64,0,30,47,64,0,63,64,0,66,64,0,71,64,129
    db 82,71,0,0,47,0,0,63,0,0,66,0,30,61,64,0
    db 64,64,0,69,64,0,45,64,131,66,45,0,0,61,0,0
    db 64,0,0,69,0,30,47,64,0,63,64,0,66,64,0,71
    db 64,131,66,71,0,0,47,0,0,63,0,0,66,0,30,68
    db 64,0,71,64,0,76,64,0,52,64,0,40,64,136,26,40
    db 0,0,76,0,0,68,0,0,71,0,0,52,0,130,14,59
    db 64,90,59,0,120,64,64,60,64,0,90,66,64,60,66,0
    db 104,68,64,60,68,0,129,8,68,64,129,112,69,64,30,68
    db 0,90,209,0,0,145,68,64,30,69,0,129,22,68,0,0
    db 67,64,14,67,0,0,66,64,14,66,0,2,65,64,14,65
    db 0,0,64,64,2,64,0,132,102,59,64,90,59,0,120,64
    db 64,60,64,0,90,66,64,60,66,0,104,68,64,60,68,0
    db 76,68,64,120,69,64,30,68,0,30,68,64,30,69,0,60
    db 68,0,30,64,64,30,64,0,30,59,64,30,59,0,90,68
    db 64,120,69,64,14,68,0,46,68,64,14,69,0,16,68,0
    db 30,64,64,30,64,0,30,59,64,30,59,0,30,57,64,30
    db 57,0,30,56,64,129,82,56,0,0,55,64,14,55,0,0
    db 54,64,2,54,0,132,72,73,64,129,96,74,64,30,73,0
    db 46,73,64,28,74,0,32,73,0,30,69,64,60,69,0,14
    db 64,64,60,64,0,16,62,64,60,62,0,30,61,64,30,61
    db 0,30,62,64,30,62,0,30,61,64,60,61,0,30,57,64
    db 2,57,0,88,52,64,129,6,52,0,0,51,64,14,51,0
    db 2,50,64,14,49,64,2,49,0,14,50,0,132,28,73,64
    db 60,73,0,0,74,64,44,74,0,0,73,64,44,73,0,2
    db 74,64,14,74,0,16,73,64,30,73,0,30,69,64,30,69
    db 0,30,64,64,30,64,0,90,68,64,30,68,0,0,69,64
    db 30,69,0,0,68,64,30,68,0,0,69,64,30,69,0,0
    db 68,64,30,68,0,0,69,64,30,69,0,0,68,64,14,68
    db 0,16,64,64,44,64,0,30,59,64,2,59,0,74,57,64
    db 90,57,0,30,56,64,131,36,56,0,0,55,64,14,55,0
    db 0,54,64,14,54,0,2,53,64,14,53,0,0,52,64,2
    db 52,0,133,94,66,64,129,112,68,64,30,66,0,90,66,64
    db 30,68,0,130,28,66,0,0,65,64,14,65,0,2,64,64
    db 14,64,0,0,63,64,2,63,0,131,110,68,64,120,69,64
    db 30,68,0,90,69,0,0,68,64,14,68,0,30,64,64,14
    db 64,0,32,59,64,14,59,0,16,68,64,129,6,68,0,30
    db 64,64,14,64,0,32,59,64,14,59,0,16,68,64,129,22
    db 68,0,30,64,64,30,64,0,30,59,64,14,59,0,30,56
    db 64,14,56,0,32,56,64,30,56,0,0,57,64,30,57,0
    db 0,58,64,30,58,0,0,57,64,30,57,0,0,58,64,30
    db 58,0,0,57,64,30,57,0,30,57,64,30,57,0,30,52
    db 64,30,52,0,30,47,64,30,47,0,30,45,64,30,45,0
    db 30,44,64,30,44,0,90,55,64,2,55,0,12,57,64,129
    db 36,57,0,2,55,64,14,55,0,30,52,64,30,52,0,16
    db 50,64,14,50,0,16,47,64,30,47,0,14,45,64,14,45
    db 0,32,43,64,30,43,0,0,40,64,131,126,39,64,14,40
    db 0,0,38,64,16,39,0,0,37,64,14,38,0,0,36,64
    db 16,37,0,0,35,64,14,36,0,0,34,64,16,35,0,0
    db 33,64,14,34,0,0,32,64,16,33,0,0,31,64,14,32
    db 0,0,30,64,16,31,0,0,29,64,14,30,0,0,28,64
    db 16,29,0,14,28,0,130,0,64,64,0,68,64,0,71,64
    db 0,52,64,140,114,71,0,0,68,0,30,73,64,0,69,64
    db 129,82,69,0,0,73,0,0,64,0,30,71,64,0,68,64
    db 0,64,64,142,98,64,0,0,52,0,0,71,0,0,68,0
    db 30,64,64,0,61,64,0,45,64,140,114,64,0,30,66,64
    db 129,82,66,0,0,45,0,0,61,0,30,68,64,0,64,64
    db 0,52,64,142,98,52,0,0,64,0,0,68,0,30,66,64
    db 0,63,64,0,47,64,135,34,47,0,0,63,0,0,66,0
    db 30,45,64,0,61,64,0,64,64,0,69,64,135,34,69,0
    db 0,45,0,0,61,0,0,64,0,30,68,64,0,64,64,0
    db 59,64,0,52,64,142,98,52,0,0,68,0,0,64,0,0
    db 59,0,30,66,64,0,63,64,0,47,64,135,34,47,0,0
    db 63,0,0,66,0,30,61,64,0,64,64,0,69,64,0,57
    db 64,135,34,57,0,0,61,0,0,64,0,0,69,0,30,68
    db 64,0,71,64,0,76,64,0,64,64,136,26,64,0,0,68
    db 0,0,71,0,0,76,0,134,102,83,64,139,32,71,64,131
    db 66,83,0,135,94,59,64,130,74,71,0,139,62,71,64,90
    db 59,0,135,94,59,64,129,82,71,0,141,16,59,0,145,14
    db 83,64,131,66,83,0,130,14,83,64,129,82,83,0,133,110
    db 83,64,0,177,7,110,131,66,145,83,0,131,126,83,64,0
    db 177,7,90,131,66,145,83,0,131,126,71,64,0,177,7,70
    db 131,66,145,71,0,131,126,59,64,0,177,7,50,131,66,145
    db 59,0,131,126,177,7,30,135,64,7,20,135,64,7,10,0
    db 255,47,0,77,84,114,107,0,0,0,28,0,255,3,20,43
    db 61,43,61,43,61,43,61,43,61,43,61,43,61,43,61,43
    db 61,43,61,0,255,47,0,77,84,114,107,0,0,2,226,0
    db 255,3,12,72,97,114,109,111,110,121,32,76,101,97,100,0
    db 206,84,130,189,104,158,59,64,90,59,0,120,64,64,60,64
    db 0,90,66,64,60,66,0,104,68,64,60,68,0,129,8,68
    db 64,129,112,69,64,30,68,0,90,222,0,0,158,68,64,30
    db 69,0,129,22,68,0,0,67,64,14,67,0,0,66,64,14
    db 66,0,2,65,64,14,65,0,0,64,64,2,64,0,132,102
    db 59,64,90,59,0,120,64,64,60,64,0,90,66,64,60,66
    db 0,104,68,64,60,68,0,76,68,64,120,69,64,30,68,0
    db 30,68,64,30,69,0,60,68,0,30,64,64,30,64,0,30
    db 59,64,30,59,0,90,68,64,120,69,64,14,68,0,46,68
    db 64,14,69,0,16,68,0,30,64,64,30,64,0,30,59,64
    db 30,59,0,30,57,64,30,57,0,30,56,64,129,82,56,0
    db 0,55,64,14,55,0,0,54,64,2,54,0,132,72,73,64
    db 129,96,74,64,30,73,0,46,73,64,28,74,0,32,73,0
    db 30,69,64,60,69,0,14,64,64,60,64,0,16,62,64,60
    db 62,0,30,61,64,30,61,0,30,62,64,30,62,0,30,61
    db 64,60,61,0,30,57,64,2,57,0,88,52,64,129,6,52
    db 0,0,51,64,14,51,0,2,50,64,14,49,64,2,49,0
    db 14,50,0,132,28,73,64,60,73,0,0,74,64,44,74,0
    db 0,73,64,44,73,0,2,74,64,14,74,0,16,73,64,30
    db 73,0,30,69,64,30,69,0,30,64,64,30,64,0,90,68
    db 64,30,68,0,0,69,64,30,69,0,0,68,64,30,68,0
    db 0,69,64,30,69,0,0,68,64,30,68,0,0,69,64,30
    db 69,0,0,68,64,14,68,0,16,64,64,44,64,0,30,59
    db 64,2,59,0,74,57,64,90,57,0,30,56,64,131,36,56
    db 0,0,55,64,14,55,0,0,54,64,14,54,0,2,53,64
    db 14,53,0,0,52,64,2,52,0,133,94,66,64,129,112,68
    db 64,30,66,0,90,66,64,30,68,0,130,28,66,0,0,65
    db 64,14,65,0,2,64,64,14,64,0,0,63,64,2,63,0
    db 131,110,68,64,120,69,64,30,68,0,90,69,0,0,68,64
    db 14,68,0,30,64,64,14,64,0,32,59,64,14,59,0,16
    db 68,64,129,6,68,0,30,64,64,14,64,0,32,59,64,14
    db 59,0,16,68,64,129,22,68,0,30,64,64,30,64,0,30
    db 59,64,14,59,0,30,56,64,14,56,0,32,56,64,30,56
    db 0,0,57,64,30,57,0,0,58,64,30,58,0,0,57,64
    db 30,57,0,0,58,64,30,58,0,0,57,64,30,57,0,30
    db 57,64,30,57,0,30,52,64,30,52,0,30,47,64,30,47
    db 0,30,45,64,30,45,0,30,44,64,30,44,0,90,55,64
    db 2,55,0,12,57,64,129,36,57,0,2,55,64,14,55,0
    db 30,52,64,30,52,0,16,50,64,14,50,0,16,47,64,30
    db 47,0,14,45,64,14,45,0,32,43,64,30,43,0,0,40
    db 64,131,126,39,64,14,40,0,0,38,64,16,39,0,0,37
    db 64,14,38,0,0,36,64,16,37,0,0,35,64,14,36,0
    db 0,34,64,16,35,0,0,33,64,14,34,0,0,32,64,16
    db 33,0,0,31,64,14,32,0,0,30,64,16,31,0,0,29
    db 64,14,30,0,0,28,64,16,29,0,14,28,0,0,255,47
    db 0,77,84,114,107,0,0,0,28,0,255,3,20,73,32,87
    db 97,110,116,32,116,111,32,66,114,101,97,107,32,70,114,101
    db 101,0,255,47,0,77,84,114,107,0,0,0,13,0,255,3
    db 5,81,85,69,69,78,0,255,47,0,77,84,114,107,0,0
    db 0,20,0,255,3,12,83,101,113,117,101,110,99,101,100,32
    db 98,121,0,255,47,0,77,84,114,107,0,0,0,22,0,255
    db 3,14,84,114,105,115,116,97,32,76,121,99,111,115,107,121
    db 0,255,47,0,10

songs_midi ends

END START
