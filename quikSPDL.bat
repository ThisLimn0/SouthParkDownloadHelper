@ECHO OFF & SETLOCAL EnableDelayedExpansion
TITLE quikSPDL - South Park Episode Downloader
:START 
CLS
SET /P "LINK=South Park Episode URL> "
ECHO.Magic!
.\yt-dlp.exe -P ".\SouthPark" --fixup force --ffmpeg-location C:\ffmpeg -o "%%(series)s - S%%(season_number)sE%%(episode_number)s.%%(ext)s" %LINK%
IF NOT %ERRORLEVEL% EQU 0 (
	ECHO.There was some kind of error while downloading. You may need to try it again.
) ELSE (
	ECHO.Finished^^!
)
PAUSE >NUL
SET "LINK="
GOTO :START
