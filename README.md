# Multi-Node Services Project

This repository contains multiple Node.js services organized into main folders A, B, C, D, and E. Each main folder contains service subfolders (service1, service2, service3), each with its own `package.json` and node_modules directory.

## Dependencies

Dependencies between services are specified in a `dependencies.json` file. This file indicates which services are dependent on other services, ensuring that dependencies are installed and built first.

### Example `dependencies.json`

```json
{
  "service1": {
    "C": ["A"],
    "D": ["B"],
    "E": ["C"]
  },
  "service2": {
    "C": ["A"],
    "D": ["B"],
    "E": ["C"]
  },
  "service3": {
    "C": ["A"],
    "D": ["B"],
    "E": ["C"]
  }
}
```

## Scripts

run_build.ps1
This PowerShell script checks for changes in the last git commit and runs npm install and npm build commands for the changed services and their dependencies.

Usage
Ensure dependencies.json is present in the root directory.

Run the PowerShell script: ./run_build.ps1

## The script performs the following steps:

1) Sets the base directory.
2) Loads dependencies from dependencies.json.
3) Gets the list of changed files from the last git commit.
4) Loops through each main folder and service folder.
5) Checks for changes in the current service folder.
6) Runs npm install and npm build for dependencies first.
7) Runs npm install and npm build for the changed service folder.


### Azure Pipelines
An Azure Pipelines YAML file is included to automate the build process using Azure DevOps.

azure-pipelines.yml
This pipeline checks for changes in the repository and runs npm install and npm build for the affected services also created classic pipelines and running then from source path for acheiving same output.