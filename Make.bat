"C:\Program Files (x86)\AutoIt3\aut2exe\aut2exe.exe"  /in "Updater.au3" /out "Updater.exe" /nopack /icon "Icons\updater.ico" /comp 2
"C:\Program Files (x86)\AutoIt3\aut2exe\upx.exe"" --best --compress-icons=0 -qq "\Updater.exe"
"C:\Program Files (x86)\AutoIt3\aut2exe\aut2exe.exe"  /in "CoD4 Connect.au3" /out "CoD4 Connect.exe" /nopack /icon "Icons\connect.ico" /comp 2
"C:\Program Files (x86)\AutoIt3\aut2exe\upx.exe"" --best --compress-icons=0 -qq "CoD4 Connect.exe"
del Updater.exe
pause