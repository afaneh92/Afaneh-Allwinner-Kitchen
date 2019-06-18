@echo off
title Afaneh Allwinner Kitchen ~ Eng afaneh92@xda
setlocal enabledelayedexpansion
set no=1
set "tab=	"
for /l %%a in (1,1,1000) do set "bck=!bck!"
:: Properties
set mainmax=7
set selcolor=9F
set defcolor=07
set sel=1
call :reset

:main
call :setmainmenu
:: Redraw window
mode con cols=80
CLS
echo %tab%%bck% 2>nul&set /p=<nul
call :recolor
call :title
call :menu
call :below
set sel2=!sel!
"tools/ckey" 38 40 13
if errorlevel 3 call :mainaction&goto main
if errorlevel 2 set /a sel+=1&goto main
if errorlevel 1 set /a sel-=1&goto main

:firm
call :setfirmmenu
:: Redraw window
mode con cols=80
CLS
echo %tab%%bck% 2>nul&set /p=<nul
call :recolor
call :title
call :menu
call :below
set sel2=!sel!
"tools/ckey" 38 40 13
if errorlevel 3 call :firmaction&goto firm
if errorlevel 2 set /a sel+=1&goto firm
if errorlevel 1 set /a sel-=1&goto firm

:reset
:: Reset variable
set version=v1.0
set choice=null
set img_file=null
set dump_folder=null
set options=

for /l %%i in (1 1 !mainmax!) do set color%%i=!defcolor!
for /l %%i in (1 1 !mainmax!) do set menu%%i=undefined
exit /b

:title
color !defcolor!
:: Display title
"tools/cecho"  {0C}***{#}{0A}                    ,                                                   {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}                  /'/                                          /'       {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}                /' /      /')                                /'         {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}             ,/'  /     /' /' ____     ,____     ____      /'__         {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}            /`--,/   -/'--' /'    )   /'    )  /'    )   /'    )        {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}          /'    /   /'    /'    /'  /'    /' /(___,/'  /'    /'         {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}      (,/'     (_,/(_____(___,/(__/'    /(__(________/'    /(__         {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}                 /'                                                     {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}               /'          Kitchen V1.03                                {#}{0C}***{#}
echo.
"tools/cecho"  {0C}***{#}{0A}             /'                                                         {#}{0C}***{#}
echo.
echo. 
exit /b

:menu
:: Display menu
for /l %%i in (1 1 !mainmax!) do (
  set /p =" !left! "<nul&"tools/chgcolor" !color%%i!&set /p ="!menu%%i!"<nul&"tools/chgcolor" !defcolor!&echo.!right!
)
exit /b

:below
:: Display below menu
set LF=^


:: The above 2 blank lines are critical - do not remove them
call :hexPrint "0x18" upArrow
call :hexPrint "0x19" downArrow
echo.
echo  Use the %upArrow% and %downArrow% to highlight an entry.
exit /b

:hexPrint  string  [rtnVar]
:: Display special characters
for /f eol^=^%LF%%LF%^ delims^= %%A in (
  'forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(%~1"'
) do if "%~2" neq "" (set %~2=%%A) else echo(%%A
exit /b
 
:recolor
:: Reset color
if !sel! lss 1 set sel=!mainmax!
if !sel! gtr !mainmax! set sel=1
  set color!sel!=!selcolor!
if not !sel!==!sel2! (
  set color!sel2!=!defcolor!
)
exit /b

:setmainmenu
:: Set menu caption
set menu1=Unpack Firmware
set menu2=Repack Firmware Dump
set menu3=Firmware tools
set menu4=Help
set menu5=Refresh
set menu6=Clear All Files
set menu7=Quit
set left={ 
set right= }
exit /b

:mainaction
:: Selection actions
if !sel!==1 (
  goto unpack_img
) else if !sel!==2 (
  goto repack_dump
) else if !sel!==3 (
  goto firm
) else if !sel!==4 (
  goto help
) else if !sel!==5 (
  call :reset
  call :setmainmenu
  goto main
) else if !sel!==6 (
  goto confirmclear
) else if !sel!==7 (
  goto quit
)

:setfirmmenu
:: Set menu caption
set menu1=Unpack iso
set menu2=Repack iso
set menu3=bin2fex
set menu4=fex2bin
set menu5=Refresh
set menu6=Back to Main
set menu7=Quit
set left={ 
set right= }
exit /b

:firmaction
:: Selection actions
if !sel!==1 (
  goto unpack_iso
) else if !sel!==2 (
  goto repack_iso
) else if !sel!==3 (
  goto bin2fex
) else if !sel!==4 (
  goto fex2bin
) else if !sel!==5 (
  call :reset
  call :setfirmmenu
  goto firm
) else if !sel!==6 (
  goto main
) else if !sel!==7 (
  goto quit
)

:unpack_img
call :choose_file img_file
for %%F in (echo %img_file%) do set ext=%%~xF
if "%ext%"==".img" (
if exist "%img_file%.dump" rmdir %img_file%.dump /s /q
call :options options
cls
"tools/imgRePacker" "%options%" "%img_file%"
) else "tools/cecho" {0C}THIS IS NOT FIRMWARE IMG.{#}
echo.
goto done

:unpack_iso
call :choose_file iso_file
for %%F in (echo %iso_file%) do set ext=%%~xF
if "%ext%"==".iso" (
if exist "%iso_file%_extracted" rmdir %iso_file%_extracted /s /q
"tools/UltraISO" -input "%iso_file%" -extract "%iso_file%_extracted"
) else "tools/cecho" {0C}THIS IS NOT ISO FILE.{#}
echo.
goto done

:bin2fex
call :choose_file bin_file
for %%F in (echo %bin_file%) do set ext=%%~xF
if "%ext%"==".bin" (
echo Transform script.bin to script.fex
"tools/fexc" -I bin -O fex %bin_file% !bin_file:~0,-3!fex
) else "tools/cecho" {0C}THIS IS NOT SCRIPT.BIN FILE.{#}
echo.
goto done

:fex2bin
call :choose_file fex_file
for %%F in (echo %fex_file%) do set ext=%%~xF
if "%ext%"==".fex" (
echo Transform script.bin to script.fex
"tools/fexc" -O bin -I fex %fex_file% !fex_file:~0,-4!-new.bin
) else "tools/cecho" {0C}THIS IS NOT SCRIPT.BIN FILE.{#}
echo.
goto done


:choose_file
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%F in ('mshta.exe %dialog%') do set "file=%%F"
if not "%file%" == "" set "%1=%file%"
exit /b

:repack_dump
call :choose_folder dump_folder
for %%F in (echo %dump_folder%) do set ext=%%~xF
if "%ext%"==".dump" (
"tools/cecho" {0A}Creating checksum files{#}
echo.
del %dump_folder%\vboot.fex > nul
"tools/FileAddSum" %dump_folder%\boot.fex %dump_folder%\vboot.fex
del %dump_folder%\vbootloader.fex > nul
"tools/FileAddSum" %dump_folder%\bootloader.fex %dump_folder%\vbootloader.fex
del %dump_folder%\venv.fex > nul
"tools/FileAddSum" %dump_folder%\env.fex %dump_folder%\venv.fex
del %dump_folder%\vrecovery.fex > nul
"tools/FileAddSum" %dump_folder%\recovery.fex %dump_folder%\vrecovery.fex
del %dump_folder%\vsystem.fex > nul
"tools/FileAddSum" %dump_folder%\system.fex %dump_folder%\vsystem.fex
call :options options
cls
"tools/imgRePacker" "%option%" %dump_folder%
) else "tools/cecho" {0C}THIS IS NOT FIRMWARE DUMP FOLDER.{#}
echo.
goto done

:repack_iso
call :choose_folder iso_folder
if "%iso_folder%"=="%iso_folder:_extracted=%" (
"tools/cecho" {0C}THIS IS NOT FIRMWARE DUMP FOLDER.{#}
echo.
) else (
"tools/UltraISO" -imainmax -l -d "%iso_folder%" -out "!iso_folder:~0,-14!-new.iso"
)
goto done

:choose_folder
for /f "tokens=* delims=" %%p in ('"tools\choose_folder"') do set "folder=%%p"
if not "%folder%" == "" set "%1=%folder%"
exit /b

:options
cls
"tools/cecho" {0A} Usage example: {#}
echo.
echo    imgRePacker.exe /skip [path_name].img       - for unpacking
echo    imgRePacker.exe /log [path_name].img.dump   - for packing
"tools/cecho" {0A} Options: {#}
echo.
echo    /log        - write log
echo    /debug      - debug mode on (works with /log option)
echo    /quiet      - don't output to console
echo    /mono       - monochrome mode on
echo    /noiso      - don't save/load disk image (iso)
echo    /8600       - pack fw for old SC8600
echo    /smt        - zdisk.img packed by SMT (unpack option)
echo    /latin      - replace non-latin symbols in path (unpack option)
echo    /skip       - skip image size check (unpack option)
echo    /2nd        - unpack/pack 2-nd layer files
echo    /ini        - rewrite *.ini-file with new parameters
echo.
set /p %1=Enter options or leave it blank:
exit /b

:help
cls
"tools/imgRePacker" /help
goto done

:confirmclear
:: Confirm clear all folders
"tools/cecho"  {0C}BE CAREFULL THIS WILL WIPE ALL *.IMG FILES AND *.DUMP FOLDERS.{#}
echo.
set /P choice=Do you want to continue?(y):
if %choice%==y goto clear
goto main

:clear
:: Clear all img files and dump folders
for /f "usebackq tokens=*" %%i in (`dir /a:d /b /s ^| findstr /v /i tools` ) do rd /s /q %%i > nul
del *.img > nul
del *.img.bak > nul
goto done

:done
"tools/cecho" {0A} Done! Press any key to back main menu {#}
pause > nul
goto main

:quit
exit