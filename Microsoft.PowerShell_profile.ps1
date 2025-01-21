
Import-Module 'C:\Users\Muhammad\dev\vcpkg\scripts\posh-vcpkg'

# Set vcpkg environment variables
$env:VCPKG_ROOT = "C:\Users\Muhammad\dev\vcpkg"
$env:VCPKG_DEFAULT_TRIPLET = "x64-windows"

# Add Clang and LLD to PATH
$env:Path += ";C:\Program Files\LLVM\bin"

# Set include and library paths for Clang
$env:CPLUS_INCLUDE_PATH = "$env:VCPKG_ROOT\installed\x64-windows\include"
$env:LIBRARY_PATH = "$env:VCPKG_ROOT\installed\x64-windows\lib"

# Set the LIB environment variable to include vcpkg libraries
$env:LIB = "$env:VCPKG_ROOT\installed\x64-windows\lib;$env:LIB"

# Add MSVC library paths to the LIB environment variable
$env:LIB += ";C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.42.34433\lib\x64"

# Add Windows SDK library paths to the LIB environment variable
$env:LIB += ";C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x64"
