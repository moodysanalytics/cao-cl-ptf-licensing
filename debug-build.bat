@ECHO OFF

IF NOT DEFINED LOCAL_NUGET (
  ECHO Please Create a local folder as debug nuget server and set to to your environment variable: LOCAL_NUGET
  EXIT /B 1
)

SET /P VERSION=<version
git submodule update --init
dotnet pack src\Standard.Licensing.sln -o dist /p:DebugSymbols=true /p:DebugType=full /p:Optimize=false -p:Configuration=Debug -p:Version=%VERSION% -p:PackageVersion=%VERSION%
dotnet nuget push dist\*.nupkg --source %LOCAL_NUGET%