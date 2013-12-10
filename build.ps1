Task Default -Depends Build

Task Build {
   Exec { msbuild "C:\Projects\TRccfSoftwarePlatform\Sources\RccfSoftwarePlatform.sln" }
}