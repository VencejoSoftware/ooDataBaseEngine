@echo off

if not exist %delphiooLib%\ooBatch\ (
  @echo "Clonning ooBatch..."
  git clone https://github.com/VencejoSoftware/ooBatch.git %delphiooLib%\ooBatch\
  call %delphiooLib%\ooBatch\code\get_dependencies.bat
)

if not exist %delphi3rdParty%\generics.collections\ (
  @echo "Clonning generics.collections..."
  git clone https://github.com/VencejoSoftware/generics.collections.git %delphi3rdParty%\generics.collections\
)

if not exist %delphi3rdParty%\zeosdbo\ (
  @echo "Clonning zeosdbo..."
  git clone https://github.com/VencejoSoftware/zeosdbo.git %delphi3rdParty%\zeosdbo\
)

if not exist %delphiooLib%\ooCipher\ (
  @echo "Clonning ooCipher..."
  git clone https://github.com/VencejoSoftware/ooCipher.git %delphiooLib%\ooCipher\
  call %delphiooLib%\ooCipher\code\get_dependencies.bat
)

if not exist %delphiooLib%\ooGeneric\ (
  @echo "Clonning ooGeneric..."
  git clone https://github.com/VencejoSoftware/ooCipher.git %delphiooLib%\ooGeneric\
  call %delphiooLib%\ooGeneric\code\get_dependencies.bat
)

if not exist %delphiooLib%\ooLog\ (
  @echo "Clonning ooLog..."
  git clone https://github.com/VencejoSoftware/ooCipher.git %delphiooLib%\ooLog\
  call %delphiooLib%\ooLog\code\get_dependencies.bat
)