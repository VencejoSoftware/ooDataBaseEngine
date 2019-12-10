call %delphiooLib%\ooBatch\code\build_project.bat ..\test test.dproj Debug
call %delphiooLib%\ooBatch\code\build_project.bat ..\test test.dproj Release
call "unpack_dependencies.bat"