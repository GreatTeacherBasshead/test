Get-ChildItem C:\Projects\TRccfSoftwarePlatform\Sources -Include *.prod.config -Recurse |
	foreach {"[" + $_.FullName + "]`n@ext =`n"} |
	Out-File D:\temp\cfgz.txt