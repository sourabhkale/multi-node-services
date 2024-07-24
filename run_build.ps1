# Set the base directory
$BaseDir = Get-Location

# Load dependencies from JSON file
$DependenciesPath = Join-Path -Path $BaseDir -ChildPath "dependencies.json"
$Dependencies = Get-Content -Path $DependenciesPath | ConvertFrom-Json

# Get the list of changed files in the last commit
$ChangedFiles = git diff --name-only HEAD HEAD~1

# Function to run npm install and build
function Run-NpmCommands {
    param (
        [string]$DirPath
    )

    Write-Output "Running npm install and npm build for $DirPath"
    Set-Location -Path $DirPath
    npm install
    npm run build
    Set-Location -Path $BaseDir
}

# List of main folders
$MainFolders = "A", "B", "C", "D", "E"

# Loop through each main folder
foreach ($MainFolder in $MainFolders) {
    # Loop through each service folder
    foreach ($ServiceFolder in "service1", "service2", "service3") {
        
        $DirPath = Join-Path -Path $BaseDir -ChildPath "$MainFolder\$ServiceFolder"
        $PackageJsonPath = Join-Path -Path $DirPath -ChildPath "package.json"

        # Check if any of the changed files are in the current service folder
        if ($ChangedFiles -match "^$MainFolder/$ServiceFolder/") {
            Write-Output "Changes detected in $DirPath"

            # Get the dependencies for the current service folder
            $DependenciesForService = $Dependencies.$ServiceFolder.$MainFolder

            # Run npm install and build for dependencies first
            if ($DependenciesForService) {
                foreach ($Dependency in $DependenciesForService) {
                    $DependencyDirPath = Join-Path -Path $BaseDir -ChildPath "$Dependency\$ServiceFolder"
                    $DependencyPackageJsonPath = Join-Path -Path $DependencyDirPath -ChildPath "package.json"

                    if (Test-Path $DependencyPackageJsonPath) {
                        $DependencyPackageJson = Get-Content -Path $DependencyPackageJsonPath | ConvertFrom-Json

                        if ($DependencyPackageJson.scripts.PSObject.Properties.Name -contains "build") {
                            Run-NpmCommands -DirPath $DependencyDirPath
                        } else {
                            Write-Output "Build script not found in $DependencyDirPath"
                            Write-Output "Running npm install for $DependencyDirPath"
                            Set-Location -Path $DependencyDirPath
                            npm install
                            Set-Location -Path $BaseDir
                        }
                    } else {
                        Write-Output "package.json not found in $DependencyDirPath"
                    }
                }
            }

            # Run npm install and build for the current service folder
            if (Test-Path $PackageJsonPath) {
                $PackageJson = Get-Content -Path $PackageJsonPath | ConvertFrom-Json

                if ($PackageJson.scripts.PSObject.Properties.Name -contains "build") {
                    Run-NpmCommands -DirPath $DirPath
                } else {
                    Write-Output "Build script not found in $DirPath"
                    Write-Output "Running npm install for $DirPath"
                    Set-Location -Path $DirPath
                    npm install
                    Set-Location -Path $BaseDir
                }
            } else {
                Write-Output "package.json not found in $DirPath"
            }
        }
    }
}
