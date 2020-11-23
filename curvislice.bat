@echo off

set gurobi=0

set volumic=0
set nozzle=0.4
set layer=0.3
set filament=1.75
set ironing=0
set model=

set arg=none

for %%A in (%*) do call :Loop %%A
goto :EndLoop

:Loop
  if "%arg%" EQU "none"
  ( set arg=%1 )
	else (
    set %arg%=%1
    set arg=none
  )
  goto :End
:EndLoop

if "%arg%" EQU "none" (
  echo Drag the stl file to here:
  set /p arg=
)

set path=%arg%
for %%f in ("%path%") do set model=%%~dpnf
set model=%model:\=/%

echo Generate tetmesh "from %model%.stl" ...
call toTetmesh.bat %model%
echo Tetmesh Called
pause

echo Optimize...
.\out\build\x64-Release\curvislice_osqp.exe %model%.msh -l %layer% --theta 50
echo curvislice_osqp Called
pause

echo Prepare lua for IceSL
call luaGenerator.bat %model% %volumic% %nozzle% %layer% %filament% %ironing%
if not exist %appdata%\IceSL\icesl-printers\fff\curvi (
  echo Create 'curvi' printer profile for IceSL
  xcopy /S /I /Q /Y .\resources\curvi "%AppData%\IceSL\icesl-printers\fff\curvi"
)
.\tools\icesl\bin\icesl-slicer.exe settings.lua --service
echo IceSL called
pause

.\out\build\x64-Release\uncurve.exe -l %layer% --gcode %model%
echo Uncurve called
pause

rem clean files
rem call clean.bat

echo "  ______                                  __            __  __                     
echo " /      \                                /  |          /  |/  |                    
echo "/$$$$$$  | __    __   ______   __     __ $$/   _______ $$ |$$/   _______   ______  
echo "$$ |  $$/ /  |  /  | /      \ /  \   /  |/  | /       |$$ |/  | /       | /      \ 
echo "$$ |      $$ |  $$ |/$$$$$$  |$$  \ /$$/ $$ |/$$$$$$$/ $$ |$$ |/$$$$$$$/ /$$$$$$  |
echo "$$ |   __ $$ |  $$ |$$ |  $$/  $$  /$$/  $$ |$$      \ $$ |$$ |$$ |      $$    $$ |
echo "$$ \__/  |$$ \__$$ |$$ |        $$ $$/   $$ | $$$$$$  |$$ |$$ |$$ \_____ $$$$$$$$/ 
echo "$$    $$/ $$    $$/ $$ |         $$$/    $$ |/     $$/ $$ |$$ |$$       |$$       |
echo " $$$$$$/   $$$$$$/  $$/           $/     $$/ $$$$$$$/  $$/ $$/  $$$$$$$/  $$$$$$$/ 

echo "===================================================================================
echo "==>
echo "     Gcode generated at: %model%.gcode      
echo "==>
echo "===================================================================================

:End
