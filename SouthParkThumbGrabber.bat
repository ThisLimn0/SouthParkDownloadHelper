@if (@CodeSection == @Batch) @then
@ECHO OFF & SETLOCAL ENABLEDELAYEDEXPANSION & Title South Park Website Thumbnail Grabber
SET "getClipCmd=cscript /nologo /e:JScript "%~f0""
IF NOT EXIST "%~dp0SouthPark\" MKDIR "%~dp0SouthPark\"
IF NOT EXIST "%~dp0dl.js" CALL :DropDownloadJS
:MAIN
SET "Website="
FOR /f "tokens=*" %%I IN ('%getClipCmd%') DO (
	SET "Website=%%I"
)
IF EXIST "%~dp0temp.html" DEL /F /Q "%~dp0temp.html" >NUL
CLS
IF DEFINED LastEpisode (
	ECHO.Last Episode was %LastEpisode%
) ELSE (
	ECHO.
)
ECHO.Automatically grabbing southpark.de link from clipboard:
IF NOT "%Website:~0,1%"=="h" (
	ECHO.Invalid Website.
	TIMEOUT /T 2 >NUL 
	GOTO :MAIN
)
IF "%Website%"=="%WebsiteOld%" (
	ECHO.Valid Website. But same as before.
	TIMEOUT /T 2 >NUL 
	GOTO :MAIN
)
SET "WebsiteOld=%Website%"
cscript //NoLogo //e:Jscript "%~dp0dl.js" "%Website%" "%~dp0temp.html"
SET "A=1"
FOR /L %%A IN (1,1,400) DO (
	IF "!Website:~%%A,1!"=="-" (
		SET /A A+=1
	)
)
SET /A A2=A-2
FOR /F "tokens=%A2% delims=-" %%A IN ("%Website%") DO SET "ST=%%A"
FOR /F "tokens=%A% delims=-" %%A IN ("%Website%") DO SET "EP=%%A"
ECHO.[Identified Episode] S%ST%E%EP%
SET "LastEpisode=S%ST%E%EP%"
IF EXIST "%~dp0SouthPark\S!ST!E!EP!.png" (
	ECHO.Episode thumbnail is already downloaded.
	TIMEOUT /T 2 >NUL 
	GOTO :MAIN
)
FOR /F "tokens=14 delims=^<" %%A IN ('TYPE "%~dp0temp.html" ^| FIND "search:imageUrl" ') DO (
	SET "URL=%%A"
)
SET "URL=!URL:~10!"
SET "URL=!URL:~10!"
SET "URL=!URL:~10!"
SET "URL=!URL:~10!"
SET "URL=!URL:~16!"
SET "URL=!URL:~0,-15!"
ECHO.[Downloading] S%ST%E%EP%
cscript //NoLogo //e:Jscript "%~dp0dl.js" "%URL%" "%~dp0SouthPark\S!ST!E!EP!.png"
GOTO :MAIN

:DropDownloadJS
ECHO ////BgetVersion 0.1.1 by Jahwi>"%~dp0dl.js"
ECHO  var url = WScript.Arguments(0),>>"%~dp0dl.js"
ECHO    filename = WScript.Arguments(1),>>"%~dp0dl.js"
ECHO    fso = WScript.CreateObject('Scripting.FileSystemObject'),>>"%~dp0dl.js"
ECHO    request, stream;>>"%~dp0dl.js"
ECHO  if (fso.FileExists(filename)) {>>"%~dp0dl.js"
ECHO    WScript.Echo('Already got ' + filename);>>"%~dp0dl.js"
ECHO  } else {>>"%~dp0dl.js"
ECHO    request = WScript.CreateObject('MSXML2.ServerXMLHTTP');>>"%~dp0dl.js"
ECHO    request.open('GET', url, false); // not async>>"%~dp0dl.js"
ECHO    request.send();>>"%~dp0dl.js"
ECHO    if (request.status === 200) { // OK>>"%~dp0dl.js"
ECHO      WScript.Echo("Size: " + request.getResponseHeader("Content-Length") + " bytes");>>"%~dp0dl.js"
ECHO      stream = WScript.CreateObject('ADODB.Stream');>>"%~dp0dl.js"
ECHO      stream.Open();>>"%~dp0dl.js"
ECHO      stream.Type = 1; // adTypeBinary>>"%~dp0dl.js"
ECHO      stream.Write(request.responseBody);>>"%~dp0dl.js"
ECHO      stream.Position = 0; // rewind>>"%~dp0dl.js"
ECHO      stream.SaveToFile(filename, 1); // adSaveCreateNotExist>>"%~dp0dl.js"
ECHO      stream.Close();>>"%~dp0dl.js"
ECHO    } else {>>"%~dp0dl.js"
ECHO      WScript.Echo('Failed');>>"%~dp0dl.js"
ECHO      WScript.Quit(1);>>"%~dp0dl.js"
ECHO    }>>"%~dp0dl.js"
ECHO  }>>"%~dp0dl.js"
ECHO  WScript.Quit(0);>>"%~dp0dl.js"
EXIT /B

@end
WSH.Echo(WSH.CreateObject('htmlfile').parentWindow.clipboardData.getData('text'));
