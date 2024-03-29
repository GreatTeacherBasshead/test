function validateSolution([string]$slnFileName) {

    "Validating solution: " + $slnFileName

    # Extract all the c# projects from the solution file
    $solutionProjects = 
        Get-Content $slnFileName | Select-String 'Project\(' | ForEach-Object {
            $projectParts = $_ -Split '[,=]' ;
            New-Object PSObject -Property @{
                Kind = $projectParts[0].Replace('Project("', '').Replace('") ','');
                Name = $projectParts[1].Trim('" ');
                File = $projectParts[2].Trim('" ');
                Guid = $projectParts[3].Trim('" ');
            }; 
        } | Where-Object { $_.Kind -eq "{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}" } # Kind = C# project

    # Output list of C# projects to console
    # $solutionProjects

    # Create HashTable keyed on project GUID
    $solutionProjectGuids = @{}
    foreach ($project in $solutionProjects) {
        $solutionProjectGuids.Add($project.Guid, $project)
    }

    # Loop through each c# project in the solution
    foreach ($project in $solutionProjects) {
        [xml]$projectXml = Get-Content $project.File
        $projectReferences = $projectXml.Project.ItemGroup | Where-Object { $_.ProjectReference -ne $null }

        # Loop through each ProjectReference
        foreach($reference in $projectReferences.ChildNodes | Where-Object { $_.Project -ne $null } ) {
            # Check the project reference GUID exists in hash table of project GUIDS; if not write error
            if (!$solutionProjectGuids.ContainsKey($reference.Project)) {
                ""
                "Bad ProjectReference: Project GUID not found in solution " 
                "Solution:  " + $slnFileName
                "Project:   " + $project.File
                "Reference: " + $reference.Name
                "Bad GUID:  " + $reference.Project
            }
        }
    }
    "Completed solution:  " + $slnFileName
}

foreach ($solutionFile in ls *.sln) {
    validateSolution $solutionFile
}