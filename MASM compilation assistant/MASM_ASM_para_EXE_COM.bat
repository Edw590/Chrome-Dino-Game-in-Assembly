@ECHO OFF
ECHO Assistant of automatic Assembly compilation with MASM
ECHO ---
ECHO:

SET PATH_AND_FILE_NAME=%1
SET PATH=%2
SET BASE_NAME_FILE=%3
SET GENERATE_COM=%4
SET DOSBOX=%5

REM This is to remove the first and last characters - it's supposed to be quotation marks
SET PATH_AND_FILE_NAME=%PATH_AND_FILE_NAME:~1,-1%
SET PATH=%PATH:~1,-1%
SET BASE_NAME_FILE=%BASE_NAME_FILE:~1,-1%

SET continue=1

IF [%1] == [] (
	SET continue=0

	ECHO -----
	ECHO ERROR - ASM file not submitted
	ECHO:
	ECHO Put the ASM file to assemble as parameter of call of this assistant - or drag the file to this assistant.
	ECHO -----
)

IF "%continue%"=="1" (

	REM ECHO %PATH_AND_FILE_NAME%
	REM ECHO %PATH%
	REM ECHO %BASE_NAME_FILE%
	
	del /f "%PATH%\%BASE_NAME_FILE%.lst"
	del /f "%PATH%\%BASE_NAME_FILE%.map"
	del /f "%PATH%\%BASE_NAME_FILE%.obj"
	del /f "%PATH%\%BASE_NAME_FILE%.sbr"
	
	REM To generate the other files with base never with a small path
	REM NOTE: didn't test if the problem is the size of constituition of the path, like accents and spaces.
	copy "%PATH_AND_FILE_NAME%" "C:\MASM615\BIN\"
	
	cd C:\MASM615\BIN\
	
	ECHO:
	ECHO ----------
	ECHO ---MASM---
	ECHO:
	ECHO -----
	ECHO NOTE: For this to show possible compilation errors, it's necessary that there's not any accent in the file name, but there can be spaces - and there can be accents and spaces in folder names, but only because this scripts copies the file with the original name to the folder C:\MASM615\BIN, which has no accents. If it didn't copy, the folders couldn't have accents, only spaces like the file name
	ECHO -----
	ECHO:
	REM IF it's to enable this again - read the note below -, use the option AT on ML.EXE to generate a COM file
	REM C:\MASM615\BIN\ML.EXE /Fl /Fm /FR /Sf /Sc /Zd /Zf /Zi /Zm "%PATH_AND_FILE_NAME%" /link /information
	C:\MASM615\BIN\ml_9.00.21022.08_x86.EXE /omf /Fl /Fm /FR /Sf /Zd /Zf /Zi /Zm "%BASE_NAME_FILE%.asm"
	
	REM mkdir "%PATH%\%BASE_NAME_FILE%\"
	
	ECHO ---MASM---
	ECHO ----------
	ECHO:

	
	IF "%GENERATE_COM%"=="true" (
		ECHO ----------------
		ECHO ---LINK - COM---
	
		C:\MASM615\BIN\LINK.EXE /TINY /CO /MAP /LINENUMBERS /INFORMATION "%BASE_NAME_FILE%.obj", "%BASE_NAME_FILE%.com", "%BASE_NAME_FILE%.map", "%BASE_NAME_FILE%.lib";
		
		ECHO:
		ECHO:
		ECHO ---LINK - COM---
		ECHO ----------------
		
		ECHO:
		
		IF "%DOSBOX%"=="true" (
			ECHO ATTENTION - This moves the file to the following path: C:\DOSBox_C\Asm\stuff.exe. Which means, mount C:\DOSBox_C\ as the C unit inside DOSBox
			ECHO:

			del /f "C:\DOSBox_C\Asm\stuff.com"

			move "C:\MASM615\BIN\%BASE_NAME_FILE%.com" "C:\DOSBox_C\Asm\stuff.com"
		) ELSE (
			del /f "%PATH%\%BASE_NAME_FILE%.com"

			move "C:\MASM615\BIN\%BASE_NAME_FILE%.com" "%PATH%\"
		)
	) ELSE (
		ECHO ----------------
		ECHO ---LINK - EXE---
		
		REM NOTE!!!!!!!!!!!!!!!!
		REM If it's to use ML.EXE - the original -, comment the part of LINK because ML.EXE calls itZ with the correct commands. The new ML doesn't - incompatibility with the old LINK, since the new LINK one doesn't work on 16 bits anymore.
		
		REM /CO – Adds symbolic data and line numbers needed by the Microsoft CodeView debugger. Not sure if this does anything on this version - which doesn't have /CO on the Help -, but doesn't throw an error - with one it doesn't know it throws an error -, so could do something.
		C:\MASM615\BIN\LINK.EXE /CO /MAP /LINENUMBERS /INFORMATION "%BASE_NAME_FILE%.obj", "%BASE_NAME_FILE%.exe", "%BASE_NAME_FILE%.map", "%BASE_NAME_FILE%.lib";
		
		ECHO:
		ECHO ---LINK - EXE---
		ECHO ----------------
		ECHO:

		IF "%DOSBOX%"=="true" (
			ECHO ATTENTION - This moves the file to the following path: C:\DOSBox_C\Asm\stuff.exe. Which means, mount C:\DOSBox_C\ as the C unit inside DOSBox
			ECHO:

			del /f "C:\DOSBox_C\Asm\stuff.exe"

			move "C:\MASM615\BIN\%BASE_NAME_FILE%.exe" "C:\DOSBox_C\Asm\stuff.exe"
		) ELSE (
			del /f "%PATH%\%BASE_NAME_FILE%.exe"

			move "C:\MASM615\BIN\%BASE_NAME_FILE%.exe" "%PATH%\"
		)
	)

	del /f "C:\MASM615\BIN\%BASE_NAME_FILE%.asm"
	
	move "C:\MASM615\BIN\%BASE_NAME_FILE%.lst" "%PATH%\"
	move "C:\MASM615\BIN\%BASE_NAME_FILE%.map" "%PATH%\"
	move "C:\MASM615\BIN\%BASE_NAME_FILE%.obj" "%PATH%\"
	move "C:\MASM615\BIN\%BASE_NAME_FILE%.sbr" "%PATH%\"
)

REM This was commented so any errors appear more below to be more easily seen
REM ECHO:
REM ECHO --------------------
REM ECHO ----All finished----
REM ECHO --------------------
REM ECHO:

REM Commented because this is used with Sublime Text, and it doesn't have console with user-machine interaction, only the contrary
REM PAUSE