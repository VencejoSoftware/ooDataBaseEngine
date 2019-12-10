SET test_path=..\test\
SET Zip7Exe="C:\Program Files\7-Zip\7z.exe"
SET DependFile="%test_path%dependencies.zip"

if not exist %test_path%build\ (
  @echo "Creating build path..."
  mkdir %test_path%build\
)
if not exist %test_path%build\debug\ (
  @echo "Creating build debug path..."
  mkdir %test_path%build\debug\
)

if not exist %test_path%build\release\ (
  @echo "Creating build release path..."
  mkdir %test_path%build\release\
)

call %Zip7Exe% x %DependFile% -oc:%test_path%build\debug\ *.* -r -y
call %Zip7Exe% x %DependFile% -oc:%test_path%build\release\ *.* -r -y
