[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $RootDirectory,

    [Parameter()]
    [int] $GracePeriodInSeconds = 0,

    [Parameter()]
    [string] $IncludeFilters,

    [Parameter()]
    [string] $ExcludeFilters
)

function EntryIsInFilter
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $Entry,
        [Parameter(Mandatory)][string[]] $FilterList
    )

    foreach($filter in $FilterList)
    {
        if($Entry -like $filter)
        {
            return $true
        }
    }
    return $false
}

function PurgeDirectory
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $RootDirectory,
        [Parameter(Mandatory)][string] $Directory,
        [Parameter(Mandatory)][datetime] $FilesOlderThan,
        [Parameter()][string[]] $IncludeFilters,
        [Parameter()][string[]] $ExcludeFilters
    )

    Write-Host "Checking $Directory"

    if($IncludeFilters)
    {
        if(!(EntryIsInFilter -Entry $Directory -FilterList $IncludeFilters))
        {
            Write-Host "$Directory is not in include filter. Skipping..."
            return;
        }
    }

    # Return if we need to skip this directory
    if(EntryIsInFilter -Entry $Directory -FilterList $ExcludeFilters)
    {
        Write-Host "$Directory is in exclude filter. Skipping..."
        return;
    }

    # First recurse through subdirectories
    $subDirectories = Get-ChildItem -Path $Directory -Directory
    foreach ($subDirectory in $subDirectories) {
        PurgeDirectory -RootDirectory $RootDirectory -Directory $subDirectory -FilesOlderThan $FilesOlderThan -IncludeFilters $IncludeFilters -ExcludeFilters $ExcludeFilters
    }

    # Get all files and see if we need to upload them.
    $files = Get-ChildItem -Path $Directory -File | Where-Object {$_.Lastwritetime -lt $FilesOlderThan}
    foreach ($file in $files) {
        Write-Host "Purging $file..."
        try{
            $file.Delete();
            Write-Host "Purged $file"
        }
        catch
        {
            Write-Error "Purging failed for $file"
        }
    }

    # Check if directory is empty. If yes: delete.
    if((Get-ChildItem $Directory | Measure-Object).count -eq 0)
    {
        Write-Host "Deleting empty directory: $Directory"
        Remove-Item $Directory -Force
        Write-Host "Deleted empty directory: $Directory"
    }

}


$cutOffDate = (Get-date).AddSeconds($GracePeriodInSeconds * -1)
$IncludeFiltersSplitted = $IncludeFilters -split ';'
$ExcludeFiltersSplitted = $ExcludeFilters -split ';'
Write-Host "Purging files older than $cutOffDate"
Set-Location $RootDirectory
PurgeDirectory -RootDirectory $RootDirectory -Directory $RootDirectory -FilesOlderThan $cutOffDate -IncludeFilters $IncludeFiltersSplitted -ExcludeFilters $ExcludeFiltersSplitted
Write-Host "Purged files older than $cutOffDate"
