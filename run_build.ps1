# Set base directory 
$BaseDir = Get-Location

# Get the list of changed files in the last commit
$ChangedFiles = git diff --name-only HEAD HEAD~1

$MainFolders = "A", "B", "C", "D", "E"

# Loop through each main folder
foreach ($MainFolder in $MainFolders) {
   
    foreach ($ServiceFolder in "service1", "service2", "service3") {
        # directory path
        $DirPath = Join-Path -Path $BaseDir -ChildPath "$MainFolder\$ServiceFolder"
        $PackageJsonPath = Join-Path -Path $DirPath -ChildPath "package.json"

        # Check if any of the changed files are in the current service folder
        if ($ChangedFiles -match "^$MainFolder/$ServiceFolder/") {
            Write-Output "Changes detected in $DirPath"

            # Check if package.json exists and contains a build script
            if (Test-Path $PackageJsonPath) {
                $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json

                if ($PackageJson.scripts.PSObject.Properties.Name -contains "build") {
                    Write-Output "Running npm install and npm build for $DirPath"
                    Set-Location -Path $DirPath
                    npm install
                    npm run build
                    # Return to base directory
                    Set-Location -Path $BaseDir
                } else {
                    Write-Output "Build script not found in $DirPath"
                }
            } else {
                Write-Output "package.json not found in $DirPath"
            }
        }
    }
}
