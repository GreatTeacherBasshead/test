function ClearSolution
{
	param
	(
		[string]$slnFile,
#		[string]$pattern = '^Project\("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}.+Applications\\BH\\.+}"$'
		[string]$pattern = '^Project\("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}.+\\OldVersions\\.+}"$'
	)
	
	Write-Host "Clear $slnFile from OldVersions-projects"
	
	$slnContentOld = Get-Content $slnFile
	$slnContentNew = @()
	
	for ($i = 0; $i -lt $slnContentOld.Length; $i++)
	{
		if ($slnContentOld[$i] -match $pattern)
		{
			Write-Host "Remove string:";
			Write-Host $slnContentOld[$i];
			$i++;
			continue;
		}
		$slnContentNew += $slnContentOld[$i]
	}
	
	Set-Content -Value $slnContentNew -Path $slnFile
}