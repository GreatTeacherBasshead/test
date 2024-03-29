function ClearSolution
{
	param
	(
		[string]$slnFilePath,
		[string]$cfgName
	)
	
	# Preferences
	$ErrorActionPreference = "Stop"
	$VerbosePreference = "Continue"
	
	
	$slnFileInfo = New-Object -TypeName System.IO.FileInfo -ArgumentList $slnFilePath
	$slnDirectoryPath = $slnFileInfo.DirectoryName
	
	ClearSolutionFromCfg $slnFilePath $cfgName
	ClearProjectsFromCfg $slnDirectoryPath $cfgName
	RemoveConfigs $slnDirectoryPath $cfgName
}

function ClearProjectsFromCfg
{
	param
	(
		[string]$workingDir,
		[string]$cfgName
	)
	
		
	Write-Verbose ""
	Write-Verbose "******************************************"
	Write-Verbose "Clear projects from $cfgName configuration"
	Write-Verbose "******************************************"
	
	$files = Get-ChildItem -Path $workingDir -Filter *.csproj -Recurse
	
	foreach ($file in $files)
	{
		ClearProjFromCfg $($file.Fullname) $cfgName
	}
}


function ClearProjFromCfg
{
	param
	(
		[string]$projPath,
		[string]$cfgName
	)
	
	
	$configurationPattern = $cfgName + "\|"
	$configsPattern = "\." + $cfgName + "\.config"
	
	Write-Verbose "Processing $projPath"
	
	$xml = New-Object -TypeName XML
	$xml.Load($projPath)
	$ns = new-object Xml.XmlNamespaceManager $xml.NameTable
	$ns.AddNamespace('n', 'http://schemas.microsoft.com/developer/msbuild/2003')
	
	$configurationNode = @()
	$configurationNode = $xml.Project.PropertyGroup | ? {$_.Condition -match $configurationPattern}
	if ($configurationNode -ne $null)
	{
		Write-Verbose "Remove $cfgName configuration"
		foreach($node in $configurationNode)
		{
			$xml.Project.RemoveChild($node)
		}
	}

	$xml.SelectNodes("/n:Project/n:ItemGroup/n:Content", $ns) |
		Where-Object { $_.Include -match $configsPattern } |
		ForEach-Object {	
			Write-Verbose "Remove $($_.Include)";
			$_.ParentNode.RemoveChild($_)
		}
	$xml.SelectNodes("/n:Project/n:ItemGroup/n:None", $ns) |
		Where-Object { $_.Include -match $configsPattern } |
		ForEach-Object {
			Write-Verbose "Remove $($_.Include)";
			$_.ParentNode.RemoveChild($_)
		}

	$xml.Save($projPath)
}


function RemoveConfigs
{
	param
	(
		[string]$workingDir,
		[string]$cfgName		
	)
	
	
	Write-Verbose ""
	Write-Verbose "***********************"
	Write-Verbose "Remove $cfgName configs"
	Write-Verbose "***********************"
	
	Get-ChildItem $workingDir -Filter *.$cfgName.config -Recurse |
		ForEach-Object {
			Write-Verbose "Remove $($_.Fullname)";
			Remove-Item $_.Fullname
		}
}

function ClearSolutionFromCfg
{
	param
	(
		[string]$slnFilePath,
		[string]$cfgName
	)
	
	
	$configurationPattern = $cfgName + "\|"
	
	Get-Content $slnFilePath |
		Where-Object {$_ -notmatch $configurationPattern} |
		Set-Content .\tmp.txt
	
	Get-Content .\tmp.txt | Set-Content $slnFilePath
	
	Remove-Item -Path .\tmp.txt -Force
}