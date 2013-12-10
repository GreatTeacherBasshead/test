$workingDir = 'C:\Projects\TRccfSoftwarePlatform\Sources'

Get-ChildItem $workingDir -Filter *.Test.config -Recurse |
	% {Remove-Item $_}

<#
Get-ChildItem $workingDir -Filter*.Dev.config -Recurse |
	% {Copy-Item $_ $_.FullName.Replace("Dev","Integr")}
#>

Get-ChildItem $workingDir -Filter *.csproj -Recurse |
	% {
		(Get-Content $_) `
			-replace "Risk\|", "Integr|" `
			-replace "'Risk'", "'Integr'" `
			-replace "bin\\Risk\\", "bin\Integr\" `
			-replace "Risk\.config", "Integr.config" |
		Set-Content $_
	}

Get-ChildItem $workingDir -Filter *.Integr.config -Recurse |
	% {
		(Get-Content $_) -replace "srvbwmdev1", "srvintegration" |
		Set-Content $_
	}

(Get-Content $workingDir\RccfSoftwarePlatform.sln) -replace "Risk\|", "Integr|" |
	Set-Content $workingDir\RccfSoftwarePlatform.sln