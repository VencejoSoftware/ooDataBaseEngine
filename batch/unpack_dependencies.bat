SET test_path=..\
SET Zip7Exe="C:\Program Files\7-Zip\7z.exe"
SET DependFile="%test_path%dependencies.zip"

call %Zip7Exe% x %DependFile% -oc:%test_path% *.* -r -y
call %Zip7Exe% x %DependFile% -oc:%test_path% *.* -r -y
