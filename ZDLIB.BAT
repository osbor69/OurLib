echo off
del *.~*
del *.dsk
del ..\georglib\*.~*
del ..\georglib\*.dsk
del forms\*.~*
del forms\*.dsk
del vcl\*.~*
del vcl\*.dsk
cd ..
lha a /x dlib georglib\*.* ourlib\*.* ourlib\forms\*.* ourlib\vcl\*.*
lha d dlib *.dcu *.exe *.bpl *.dcp
lha s /x dlib
verify on
copy dlib.exe a:
verify off
del dlib.*
echo Желательно достать дискету и вставить ее обратно ...
pause > nul
copy a:dlib.exe
del dlib.*
cd ourlib