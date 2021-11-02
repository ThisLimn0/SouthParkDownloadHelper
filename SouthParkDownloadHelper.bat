@ECHO OFF & SETLOCAL ENABLEDELAYEDEXPANSION
TITLE SouthPark.de Episode Download Helper
REM // Instructions:
REM // Needs ffmpeg and yt-dlp in same folder as script
REM // Just put the link to the episode into the script
REM // It should download into the same folder as the script while downloading fragments into a temporary sub-folder first.
REM // No input checks, use with caution. /!\

:Main
CLS
TITLE SouthPark.de Episode Download Helper - Checking for available Updates
REM // Checking yt-dlp for available updates.
yt-dlp.exe -U
TITLE SouthPark.de Episode Download Helper - Idle
REM // If temporary file exists after download, delete.
IF EXIST !LocalTempFolder! (
  DEL /F /Q /S "!LocalFolder!!LocalTempFolder!"
  RMDIR "!LocalFolder!!LocalTempFolder!" >NUL
)
REM // Initialisation of variables after start or new cycle.
SET "QualitySetting=best"
SET "SessionSeed=%RANDOM%"
SET "LocalFolder=%~dp0"
SET "LocalTempFolder=SoPaDo!SessionSeed!"
SET "LocalLinkFile=linklist.txt"
SET "LocalFileList=mylist.txt"
SET "ThisClip="
SET "PastClip="
SET "ACnt=0"
SET "BCnt=0"
REM // Folder checks.
CD "!LocalFolder!"
IF NOT EXIST "!LocalTempFolder!" (
  MKDIR "!LocalTempFolder!"
)
CD !LocalTempFolder!
IF NOT EXIST "!LocalLinkFile!" (
	ECHO.>"!LocalLinkFile!"
)
IF NOT EXIST "!LocalFileList!" (
	ECHO.>"!LocalFileList!"
)

IF NOT DEFINED URL (
	ECHO.Input your link please. Example URL: https://www.southpark.de/folgen/er4a32/south-park-wie-werde-ich-ein-kampfkoloss-staffel-1-ep-3
) ELSE (
	ECHO.Input your link please. Example URL: !URL!
)
ECHO.Input quit to cleanup and quit.
SET "URL="
SET /P "URL=URL> "
IF NOT DEFINED URL (
  GOTO :Main
)
IF /I "!URL!" EQU "quit" (
	CALL :CleanUp
	EXIT
)
TITLE SouthPark.de Episode Download Helper - Gathering info
REM // Gather info from link.
ECHO.Gathering info...
!LocalFolder!yt-dlp.exe !URL! -f best -g --get-filename -o "SouthPark.S%%(season_number)s.E%%(episode_number)s.%%(playlist_index)s.%%(ext)s" >> !LocalLinkFile!
FOR /F "usebackq delims=" %%A in ("!LocalLinkFile!") DO (
  SET "TMPVAR=%%A"
  SET "TMPVAR2=!TMPVAR:~0,5!"
  IF "!TMPVAR2!"=="https" (
    SET /A ACnt+=1
    SET "Link!ACnt!=!TMPVAR!"
  ) ELSE IF "!TMPVAR2!"=="South" (
    SET /A BCnt+=1
    SET "Filename!BCnt!=!TMPVAR!"
    SET "FILENAME=!TMPVAR!"
    SET "FILENAME=!FILENAME:~0,-6!.mp4"
  )
)
ECHO.!URL!>>"!LocalFolder!!FILENAME!.txt"
ECHO.!FILENAME!>>"!LocalFolder!!FILENAME!.txt"
IF DEFINED ACnt (
  ECHO.!ACnt! fragments found.
)
FOR /L %%A in (1,1,10) DO (
  IF DEFINED Link%%A (
    TITLE SouthPark.de Episode Download Helper - Downloading fragment %%A of !ACnt!
    ECHO.Downloading fragment %%A/!ACnt!...
    !LocalFolder!yt-dlp.exe !Link%%A! -o "!Filename%%A!"
    TITLE SouthPark.de Episode Download Helper - Adding fragment to file list
    ECHO.Adding fragment to file list...
    ECHO.file '!Filename%%A!' >> "!LocalFileList!"
  )
)
TITLE SouthPark.de Episode Download Helper - Concatenating Episode
!LocalFolder!ffmpeg.exe -f concat -safe 0 -i !LocalFileList! -c copy "!LocalFolder!!FILENAME!"
CALL :CleanUp
TIMEOUT /T 2 >NUL
GOTO :Main

:CleanUp
FOR /L %%A in (1,1,10) DO (
	IF DEFINED Link%%A (
		SET "Link%%A="
		SET "Filename%%A="
	)
)
CD "!LocalFolder!"
IF EXIST !LocalTempFolder! (
  DEL /F /Q /S "!LocalFolder!!LocalTempFolder!"
)
IF EXIST "!LocalLinkFile!" (
	DEL /F /Q "!LocalLinkFile!" >NUL
)
IF EXIST "!LocalFileList!" (
	DEL /F /Q "!LocalFileList!" >NUL
)
DEL /F /Q "!LocalTempFolder!\" >NUL
RMDIR "!LocalFolder!!LocalTempFolder!\" >NUL

EXIT /B
