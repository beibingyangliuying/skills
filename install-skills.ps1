<#
.SYNOPSIS
Downloads and installs skills from a selected region into a project's .agents directory.

.DESCRIPTION
Supports two subcommands:
- install: download a region and install selected skills plus AGENTS.md
- list: download a region and print the available skill names

The script uses native PowerShell parameters and supports tab completion for:
- the command name
- region names from the local repository layout
- skill names for -Include and -Exclude after -Region is chosen
- download methods

.PARAMETER Command
The subcommand to run. Use either 'install' or 'list'.

.PARAMETER Region
The region to download and inspect, for example 'python'.

.PARAMETER Include
Only for 'install'. One or more skill names to include. PowerShell array syntax is supported, for example:
-Include pandas-dataframe,repo-workflow

.PARAMETER Exclude
Only for 'install'. One or more skill names to exclude after include filtering.

.PARAMETER RootPath
Only for 'install'. Project root path. Skills are installed into '<RootPath>\.agents'.

.PARAMETER DownloadMethod
Optional download method. Valid values are auto, iwr, curl, bits, and webclient.

.PARAMETER OverwriteAll
Only for 'install'. Overwrite all existing skills and AGENTS.md without prompting.

.PARAMETER SkipExisting
Only for 'install'. Skip all existing skills and AGENTS.md without prompting.

.PARAMETER Help
Show help text.

.EXAMPLE
./install-skills.ps1 install -Region python

.EXAMPLE
./install-skills.ps1 install -Region python -Include pandas-dataframe,repo-workflow

.EXAMPLE
./install-skills.ps1 list -Region python
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("install", "list")]
    [string]$Command,

    [Parameter()]
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $scriptPath = $null
            try {
                $scriptReference = $null
                if ($null -ne $commandAst -and $commandAst.CommandElements.Count -gt 0) {
                    $scriptReference = $commandAst.CommandElements[0].Extent.Text
                }

                if (-not [string]::IsNullOrWhiteSpace($scriptReference)) {
                    $scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptReference)
                }
            }
            catch {
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                $commandInfo = Get-Command -Name $commandName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($null -ne $commandInfo) {
                    $scriptPath = $commandInfo.Path
                }
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                return
            }

            $scriptRoot = Split-Path -Parent $scriptPath
            Get-ChildItem -LiteralPath $scriptRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                (Test-Path -LiteralPath (Join-Path $_.FullName ".agents\skills") -PathType Container) -and
                (Test-Path -LiteralPath (Join-Path $_.FullName "AGENTS.md") -PathType Leaf)
            } |
            Sort-Object -Property Name |
            Where-Object { $_.Name -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Name)
            }
        })]
    [string]$Region,

    [Parameter()]
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            if (-not $fakeBoundParameters.ContainsKey("Region")) {
                return
            }

            $region = [string]$fakeBoundParameters["Region"]
            if ([string]::IsNullOrWhiteSpace($region)) {
                return
            }

            $scriptPath = $null
            try {
                $scriptReference = $null
                if ($null -ne $commandAst -and $commandAst.CommandElements.Count -gt 0) {
                    $scriptReference = $commandAst.CommandElements[0].Extent.Text
                }

                if (-not [string]::IsNullOrWhiteSpace($scriptReference)) {
                    $scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptReference)
                }
            }
            catch {
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                $commandInfo = Get-Command -Name $commandName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($null -ne $commandInfo) {
                    $scriptPath = $commandInfo.Path
                }
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                return
            }

            $scriptRoot = Split-Path -Parent $scriptPath
            $skillsRoot = Join-Path (Join-Path (Join-Path $scriptRoot $region) ".agents") "skills"
            if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
                return
            }

            $replacementPrefix = ""
            $fragment = $wordToComplete
            if ($wordToComplete -match "^(.*?,)([^,]*)$") {
                $replacementPrefix = $Matches[1]
                $fragment = $Matches[2]
            }

            $alreadySelected = @()
            if (-not [string]::IsNullOrWhiteSpace($replacementPrefix)) {
                $alreadySelected = @(
                    $replacementPrefix.TrimEnd(",") -split "," |
                    ForEach-Object { $_.Trim() } |
                    Where-Object { $_ -ne "" }
                )
            }

            Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf
            } |
            Sort-Object -Property Name |
            Where-Object {
                $_.Name -like "$fragment*" -and $_.Name -notin $alreadySelected
            } |
            ForEach-Object {
                $completionText = "$replacementPrefix$($_.Name)"
                [System.Management.Automation.CompletionResult]::new($completionText, $_.Name, "ParameterValue", $_.Name)
            }
        })]
    [string[]]$Include,

    [Parameter()]
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            if (-not $fakeBoundParameters.ContainsKey("Region")) {
                return
            }

            $region = [string]$fakeBoundParameters["Region"]
            if ([string]::IsNullOrWhiteSpace($region)) {
                return
            }

            $scriptPath = $null
            try {
                $scriptReference = $null
                if ($null -ne $commandAst -and $commandAst.CommandElements.Count -gt 0) {
                    $scriptReference = $commandAst.CommandElements[0].Extent.Text
                }

                if (-not [string]::IsNullOrWhiteSpace($scriptReference)) {
                    $scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptReference)
                }
            }
            catch {
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                $commandInfo = Get-Command -Name $commandName -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($null -ne $commandInfo) {
                    $scriptPath = $commandInfo.Path
                }
            }

            if ([string]::IsNullOrWhiteSpace($scriptPath)) {
                return
            }

            $scriptRoot = Split-Path -Parent $scriptPath
            $skillsRoot = Join-Path (Join-Path (Join-Path $scriptRoot $region) ".agents") "skills"
            if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
                return
            }

            $replacementPrefix = ""
            $fragment = $wordToComplete
            if ($wordToComplete -match "^(.*?,)([^,]*)$") {
                $replacementPrefix = $Matches[1]
                $fragment = $Matches[2]
            }

            $alreadySelected = @()
            if (-not [string]::IsNullOrWhiteSpace($replacementPrefix)) {
                $alreadySelected = @(
                    $replacementPrefix.TrimEnd(",") -split "," |
                    ForEach-Object { $_.Trim() } |
                    Where-Object { $_ -ne "" }
                )
            }

            Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf
            } |
            Sort-Object -Property Name |
            Where-Object {
                $_.Name -like "$fragment*" -and $_.Name -notin $alreadySelected
            } |
            ForEach-Object {
                $completionText = "$replacementPrefix$($_.Name)"
                [System.Management.Automation.CompletionResult]::new($completionText, $_.Name, "ParameterValue", $_.Name)
            }
        })]
    [string[]]$Exclude,

    [Parameter()]
    [string]$RootPath,

    [Parameter()]
    [ValidateSet("auto", "iwr", "curl", "bits", "webclient")]
    [string]$DownloadMethod = "auto",

    [Parameter()]
    [switch]$OverwriteAll,

    [Parameter()]
    [switch]$SkipExisting,

    [Parameter()]
    [Alias("h")]
    [switch]$Help,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:RepositoryUrl = "https://github.com/beibingyangliuying/skills"
$script:ArchiveUrl = "https://github.com/beibingyangliuying/skills/archive/refs/heads/main.zip"
$script:DefaultRootPath = $PSScriptRoot
$script:DefaultDownloadMethod = "auto"
$script:DefaultConflictMode = "interactive"
$script:AlwaysConfirmBeforeInstall = $true

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-UsageText {
    return @"
Usage:
  ./install-skills.ps1 install -Region <name> [-Include <skill1,skill2>] [-Exclude <skill1,skill2>] [-RootPath <path>] [-DownloadMethod <auto|iwr|curl|bits|webclient>] [-OverwriteAll] [-SkipExisting]
  ./install-skills.ps1 list -Region <name> [-DownloadMethod <auto|iwr|curl|bits|webclient>]
  ./install-skills.ps1 -Help

Subcommands:
  install           Download a region from the repository and install its skills
  list              Download a region from the repository and print its available skill names

PowerShell parameters:
  -Region           Required. Install or list a single region, for example: python
  -Include          Optional, install only. Use PowerShell array syntax, for example: -Include skill1,skill2
  -Exclude          Optional, install only. Exclude skill names after include filtering
  -RootPath         Optional, install only. Project root path; installs into its .agents folder
  -DownloadMethod   Optional. $($script:DefaultDownloadMethod) (default), iwr, curl, bits, or webclient
  -OverwriteAll     Optional, install only. Overwrite all existing skills and AGENTS.md without prompting
  -SkipExisting     Optional, install only. Skip all existing skills and AGENTS.md without prompting
  -Help             Show this help text

Compatibility:
  - Legacy GNU-style options such as --region and --download-method are no longer supported
  - Use PowerShell syntax instead, for example: ./install-skills.ps1 install -Region python

Defaults:
  - If -RootPath is omitted, the project root defaults to the script directory and files are installed into its .agents folder
  - Existing skills and AGENTS.md use per-item interactive confirmation unless -OverwriteAll or -SkipExisting is passed
  - In interactive conflict prompts, pressing Enter defaults to Skip
  - The script always shows the execution plan and asks for confirmation before writing files
  - In the final confirmation prompt, pressing Enter defaults to Yes
"@
}

function Get-UniqueStringValues {
    param(
        [AllowNull()]
        [string[]]$Values
    )

    $result = [System.Collections.Generic.List[string]]::new()
    foreach ($value in @($Values)) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        $trimmed = $value.Trim()
        if (-not $result.Contains($trimmed)) {
            $null = $result.Add($trimmed)
        }
    }

    return $result.ToArray()
}

function Get-ResolvedConflictMode {
    param(
        [bool]$UseOverwriteAll,
        [bool]$UseSkipExisting
    )

    if ($UseOverwriteAll) {
        return "overwrite-all"
    }

    if ($UseSkipExisting) {
        return "skip-existing"
    }

    return $script:DefaultConflictMode
}

function Get-ValidatedConfiguration {
    param(
        [AllowNull()]
        [string]$CommandValue,
        [AllowNull()]
        [string]$RegionValue,
        [AllowNull()]
        [string[]]$IncludeValues,
        [AllowNull()]
        [string[]]$ExcludeValues,
        [AllowNull()]
        [string]$RootPathValue,
        [bool]$RootPathWasSpecified,
        [string]$DownloadMethodValue,
        [bool]$UseOverwriteAll,
        [bool]$UseSkipExisting,
        [bool]$ShowHelp,
        [AllowNull()]
        [string[]]$ExtraArguments
    )

    $remaining = @($ExtraArguments | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($remaining.Count -gt 0) {
        $legacyOptions = @($remaining | Where-Object { $_ -like "--*" })
        if ($legacyOptions.Count -gt 0) {
            $example = "./install-skills.ps1 install -Region python"
            throw "Unsupported legacy GNU-style option(s): $($legacyOptions -join ', '). Use PowerShell parameter syntax instead, for example: $example`n`n$(Get-UsageText)"
        }

        throw "Unknown argument(s): $($remaining -join ' ').`n`n$(Get-UsageText)"
    }

    if ($ShowHelp) {
        return [pscustomobject]@{
            ShowHelp       = $true
            Command        = $CommandValue
            Region         = $null
            Include        = @()
            Exclude        = @()
            RootPath       = $script:DefaultRootPath
            DownloadMethod = $DownloadMethodValue.ToLowerInvariant()
            ConflictMode   = $script:DefaultConflictMode
        }
    }

    if ([string]::IsNullOrWhiteSpace($CommandValue)) {
        throw "A subcommand is required. Expected 'install' or 'list'.`n`n$(Get-UsageText)"
    }

    $normalizedCommand = $CommandValue.Trim().ToLowerInvariant()
    $normalizedRegion = $null
    if (-not [string]::IsNullOrWhiteSpace($RegionValue)) {
        $normalizedRegion = $RegionValue.Trim()
    }

    if ([string]::IsNullOrWhiteSpace($normalizedRegion)) {
        throw "-Region is required for '$normalizedCommand'.`n`n$(Get-UsageText)"
    }

    $normalizedRootPath = $script:DefaultRootPath
    if (-not [string]::IsNullOrWhiteSpace($RootPathValue)) {
        $normalizedRootPath = $RootPathValue.Trim()
        if ($normalizedRootPath -eq "") {
            throw "-RootPath cannot be empty.`n`n$(Get-UsageText)"
        }
    }

    if ($UseOverwriteAll -and $UseSkipExisting) {
        throw "-OverwriteAll and -SkipExisting cannot be used together.`n`n$(Get-UsageText)"
    }

    if ($normalizedCommand -eq "list") {
        if ($IncludeValues.Count -gt 0) {
            throw "Parameter -Include is only supported for the 'install' subcommand.`n`n$(Get-UsageText)"
        }

        if ($ExcludeValues.Count -gt 0) {
            throw "Parameter -Exclude is only supported for the 'install' subcommand.`n`n$(Get-UsageText)"
        }

        if ($RootPathWasSpecified) {
            throw "Parameter -RootPath is only supported for the 'install' subcommand.`n`n$(Get-UsageText)"
        }

        if ($UseOverwriteAll) {
            throw "Parameter -OverwriteAll is only supported for the 'install' subcommand.`n`n$(Get-UsageText)"
        }

        if ($UseSkipExisting) {
            throw "Parameter -SkipExisting is only supported for the 'install' subcommand.`n`n$(Get-UsageText)"
        }
    }

    return [pscustomobject]@{
        ShowHelp       = $false
        Command        = $normalizedCommand
        Region         = $normalizedRegion
        Include        = Get-UniqueStringValues -Values $IncludeValues
        Exclude        = Get-UniqueStringValues -Values $ExcludeValues
        RootPath       = $normalizedRootPath
        DownloadMethod = $DownloadMethodValue.Trim().ToLowerInvariant()
        ConflictMode   = Get-ResolvedConflictMode -UseOverwriteAll $UseOverwriteAll -UseSkipExisting $UseSkipExisting
    }
}

function Get-InnerExceptionMessage {
    param(
        [AllowNull()]
        [System.Exception]$Exception
    )

    if ($null -eq $Exception) {
        return "Unknown error."
    }

    $current = $Exception
    while ($null -ne $current.InnerException) {
        $current = $current.InnerException
    }

    return $current.Message
}

function Get-PowerShellRuntimeLabel {
    $edition = $PSVersionTable.PSEdition
    if ([string]::IsNullOrWhiteSpace($edition)) {
        $edition = "Desktop"
    }

    return "PowerShell $($PSVersionTable.PSVersion) ($edition)"
}

function Use-Tls12ForLegacyClients {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
}

function Test-CommandAvailable {
    param(
        [string]$Name
    )

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-DownloadWithInvokeWebRequest {
    param(
        [string]$Url,
        [string]$OutFile
    )

    Use-Tls12ForLegacyClients

    $parameters = @{
        Uri     = $Url
        OutFile = $OutFile
    }

    $command = Get-Command Invoke-WebRequest -ErrorAction Stop
    if ($command.Parameters.ContainsKey("SslProtocol")) {
        $parameters["SslProtocol"] = "Tls12"
    }

    Invoke-WebRequest @parameters | Out-Null
}

function Invoke-DownloadWithCurl {
    param(
        [string]$Url,
        [string]$OutFile
    )

    if (-not (Test-CommandAvailable -Name "curl.exe")) {
        throw "curl.exe is not available on this system."
    }

    & curl.exe --fail --location --silent --show-error --output $OutFile $Url
    if ($LASTEXITCODE -ne 0) {
        throw "curl.exe failed with exit code $LASTEXITCODE."
    }
}

function Invoke-DownloadWithBits {
    param(
        [string]$Url,
        [string]$OutFile
    )

    if (-not (Test-CommandAvailable -Name "Start-BitsTransfer")) {
        throw "Start-BitsTransfer is not available on this system."
    }

    Start-BitsTransfer -Source $Url -Destination $OutFile
}

function Invoke-DownloadWithWebClient {
    param(
        [string]$Url,
        [string]$OutFile
    )

    Use-Tls12ForLegacyClients

    $client = New-Object System.Net.WebClient
    try {
        $client.DownloadFile($Url, $OutFile)
    }
    finally {
        $client.Dispose()
    }
}

function Invoke-DownloadMethod {
    param(
        [string]$Method,
        [string]$Url,
        [string]$OutFile
    )

    switch ($Method) {
        "iwr" { Invoke-DownloadWithInvokeWebRequest -Url $Url -OutFile $OutFile }
        "curl" { Invoke-DownloadWithCurl -Url $Url -OutFile $OutFile }
        "bits" { Invoke-DownloadWithBits -Url $Url -OutFile $OutFile }
        "webclient" { Invoke-DownloadWithWebClient -Url $Url -OutFile $OutFile }
        default { throw "Unsupported download method '$Method'." }
    }
}

function Get-DownloadMethodSequence {
    param(
        [string]$RequestedMethod
    )

    if ($RequestedMethod -ne "auto") {
        return @($RequestedMethod)
    }

    $methods = [System.Collections.Generic.List[string]]::new()
    $null = $methods.Add("iwr")

    if (Test-CommandAvailable -Name "curl.exe") {
        $null = $methods.Add("curl")
    }

    if (Test-CommandAvailable -Name "Start-BitsTransfer") {
        $null = $methods.Add("bits")
    }

    $null = $methods.Add("webclient")
    return $methods.ToArray()
}

function New-DownloadFailureMessage {
    param(
        [string]$Url,
        [string]$RequestedMethod,
        [object[]]$Attempts
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $null = $lines.Add("Failed to download archive from '$Url'.")
    $null = $lines.Add("Runtime: $(Get-PowerShellRuntimeLabel)")
    $null = $lines.Add("Requested download method: $RequestedMethod")
    $null = $lines.Add("Attempt summary:")

    $sslHintNeeded = $false
    foreach ($attempt in $Attempts) {
        $null = $lines.Add("  - $($attempt.Method): $($attempt.Message)")
        $inner = "$($attempt.InnerMessage)"
        if ($inner -match "SSL|TLS|certificate|trust|secure channel|authentication|handshake") {
            $sslHintNeeded = $true
        }
    }

    if ($sslHintNeeded) {
        $null = $lines.Add("Possible causes:")
        $null = $lines.Add("  - The current PowerShell runtime and GitHub TLS negotiation do not agree.")
        $null = $lines.Add("  - A proxy or HTTPS interception certificate is rewriting the connection.")
        $null = $lines.Add("  - The local trust store does not trust the certificate chain.")
        $null = $lines.Add("Troubleshooting tips:")
        $null = $lines.Add("  - Try '-DownloadMethod curl' if curl.exe works on this machine.")
        $null = $lines.Add("  - Compare the result in Windows PowerShell 5.1 versus PowerShell 7+.")
        $null = $lines.Add("  - Test the URL manually: curl.exe -L $Url -o test.zip")
        $null = $lines.Add("  - If you are on a corporate network, verify proxy and certificate requirements.")
    }

    return ($lines -join [Environment]::NewLine)
}

function Download-Archive {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$RequestedMethod
    )

    $methods = Get-DownloadMethodSequence -RequestedMethod $RequestedMethod
    $attempts = [System.Collections.Generic.List[object]]::new()

    foreach ($method in $methods) {
        if (Test-Path -LiteralPath $OutFile) {
            Remove-Item -LiteralPath $OutFile -Force
        }

        try {
            Invoke-DownloadMethod -Method $method -Url $Url -OutFile $OutFile
            if (-not (Test-Path -LiteralPath $OutFile -PathType Leaf)) {
                throw "The downloader reported success, but '$OutFile' was not created."
            }

            return [pscustomobject]@{
                Method = $method
                Path   = $OutFile
            }
        }
        catch {
            $exceptionMessage = $_.Exception.Message
            $innerMessage = Get-InnerExceptionMessage -Exception $_.Exception
            $null = $attempts.Add([pscustomobject]@{
                    Method       = $method
                    Message      = $exceptionMessage
                    InnerMessage = $innerMessage
                })
        }
    }

    throw (New-DownloadFailureMessage -Url $Url -RequestedMethod $RequestedMethod -Attempts $attempts.ToArray())
}

function Resolve-ProjectRoot {
    param(
        [AllowNull()]
        [string]$RootPathValue
    )

    $projectRoot = $RootPathValue
    if ([string]::IsNullOrWhiteSpace($projectRoot)) {
        $projectRoot = $script:DefaultRootPath
    }

    return [System.IO.Path]::GetFullPath(
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($projectRoot)
    )
}

function Resolve-AgentsRoot {
    param(
        [string]$ProjectRoot
    )

    return [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot ".agents"))
}

function New-TemporaryWorkspace {
    $workspaceRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("install-skills-" + [guid]::NewGuid().ToString("N"))
    $null = New-Item -ItemType Directory -Path $workspaceRoot -Force

    return [pscustomobject]@{
        RootPath    = $workspaceRoot
        ArchivePath = Join-Path $workspaceRoot "skills-main.zip"
        ExtractPath = Join-Path $workspaceRoot "extract"
    }
}

function Get-RepoArchive {
    param(
        [string]$ArchiveUrl,
        [string]$DownloadMethod
    )

    $workspace = New-TemporaryWorkspace
    $null = New-Item -ItemType Directory -Path $workspace.ExtractPath -Force

    $download = Download-Archive -Url $ArchiveUrl -OutFile $workspace.ArchivePath -RequestedMethod $DownloadMethod
    Expand-Archive -LiteralPath $workspace.ArchivePath -DestinationPath $workspace.ExtractPath -Force

    $archiveEntries = @(Get-ChildItem -LiteralPath $workspace.ExtractPath)
    if ($archiveEntries.Count -ne 1 -or -not $archiveEntries[0].PSIsContainer) {
        throw "Unexpected archive structure downloaded from $ArchiveUrl."
    }

    return [pscustomobject]@{
        WorkspaceRoot  = $workspace.RootPath
        ArchiveRoot    = $archiveEntries[0].FullName
        DownloadMethod = $download.Method
    }
}

function Get-RegionLayout {
    param(
        [string]$ArchiveRoot,
        [string]$Region
    )

    $regionRoot = Join-Path $ArchiveRoot $Region
    if (-not (Test-Path -LiteralPath $regionRoot -PathType Container)) {
        throw "Region '$Region' was not found in the downloaded repository."
    }

    $skillsRoot = Join-Path $regionRoot ".agents\skills"
    if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
        throw "Region '$Region' does not contain '.agents\skills'."
    }

    $agentsPath = Join-Path $regionRoot "AGENTS.md"
    if (-not (Test-Path -LiteralPath $agentsPath -PathType Leaf)) {
        throw "Region '$Region' does not contain AGENTS.md."
    }

    return [pscustomobject]@{
        RegionRoot = $regionRoot
        SkillsRoot = $skillsRoot
        AgentsPath = $agentsPath
    }
}

function Get-AvailableSkills {
    param(
        [string]$SkillsRoot
    )

    $skills = @(
        Get-ChildItem -LiteralPath $SkillsRoot -Directory |
        Where-Object {
            Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf
        } |
        Sort-Object -Property Name |
        ForEach-Object {
            [pscustomobject]@{
                Name       = $_.Name
                SourcePath = $_.FullName
            }
        }
    )

    if ($skills.Count -eq 0) {
        throw "No installable skills were found under $SkillsRoot."
    }

    return $skills
}

function Show-SkillList {
    param(
        [string]$Region,
        [object[]]$Skills
    )

    Write-Host ""
    Write-Host "Available skills"
    Write-Host "================"
    Write-Host "Region : $Region"
    Write-Host "Count  : $($Skills.Count)"
    Write-Host ""
    Write-Host "Skills:"
    foreach ($skill in $Skills) {
        Write-Host "  - $($skill.Name)"
    }
}

function Resolve-SelectedSkills {
    param(
        [object[]]$AvailableSkills,
        [string[]]$Include,
        [string[]]$Exclude
    )

    $availableNames = @($AvailableSkills.Name)
    $unknownInclude = @($Include | Where-Object { $_ -notin $availableNames })
    $unknownExclude = @($Exclude | Where-Object { $_ -notin $availableNames })

    if ($unknownInclude.Count -gt 0) {
        throw "Unknown skill name(s) in -Include: $($unknownInclude -join ', '). Available skills: $($availableNames -join ', ')"
    }

    if ($unknownExclude.Count -gt 0) {
        throw "Unknown skill name(s) in -Exclude: $($unknownExclude -join ', '). Available skills: $($availableNames -join ', ')"
    }

    if ($Include.Count -gt 0) {
        $selected = @($AvailableSkills | Where-Object { $_.Name -in $Include })
    }
    else {
        $selected = @($AvailableSkills)
    }

    if ($Exclude.Count -gt 0) {
        $selected = @($selected | Where-Object { $_.Name -notin $Exclude })
    }

    if ($selected.Count -eq 0) {
        throw "No skills remain after applying -Include/-Exclude."
    }

    $notes = [System.Collections.Generic.List[string]]::new()
    $overlap = @($Include | Where-Object { $_ -in $Exclude })
    if ($overlap.Count -gt 0) {
        $null = $notes.Add("Exclude takes precedence over include for: $($overlap -join ', ')")
    }

    return [pscustomobject]@{
        Skills = $selected
        Notes  = $notes.ToArray()
    }
}

function Get-Conflicts {
    param(
        [object[]]$Skills,
        [string]$AgentsRoot
    )

    $conflicts = [System.Collections.Generic.List[object]]::new()
    $skillsTargetRoot = Join-Path $AgentsRoot "skills"

    foreach ($skill in $Skills) {
        $destination = Join-Path $skillsTargetRoot $skill.Name
        if (Test-Path -LiteralPath $destination) {
            $null = $conflicts.Add([pscustomobject]@{
                    Type = "Skill"
                    Name = $skill.Name
                    Path = $destination
                })
        }
    }

    $agentsTarget = Join-Path $AgentsRoot "AGENTS.md"
    if (Test-Path -LiteralPath $agentsTarget -PathType Leaf) {
        $null = $conflicts.Add([pscustomobject]@{
                Type = "AGENTS"
                Name = "AGENTS.md"
                Path = $agentsTarget
            })
    }

    return $conflicts.ToArray()
}

function Show-ExecutionPlan {
    param(
        [pscustomobject]$Config,
        [string]$ProjectRoot,
        [string]$AgentsRoot,
        [object[]]$Skills,
        [object[]]$Conflicts,
        [string[]]$Notes,
        [string]$ResolvedDownloadMethod
    )

    $skillsTargetRoot = Join-Path $AgentsRoot "skills"
    $agentsTarget = Join-Path $AgentsRoot "AGENTS.md"
    $notesList = @($Notes)
    $conflictList = @($Conflicts)

    Write-Host ""
    Write-Host "Execution plan"
    Write-Host "=============="
    Write-Host "Repository : $script:RepositoryUrl"
    Write-Host "Archive     : $script:ArchiveUrl"
    Write-Host "Download    : requested=$($Config.DownloadMethod), used=$ResolvedDownloadMethod"
    Write-Host "Conflicts   : $($Config.ConflictMode)"
    Write-Host "Region      : $($Config.Region)"
    Write-Host "Project root: $ProjectRoot"
    Write-Host "Agents root : $AgentsRoot"
    Write-Host "Skills dir  : $skillsTargetRoot"
    Write-Host "AGENTS.md   : $agentsTarget"
    Write-Host ""
    Write-Host "Skills to install:"
    foreach ($skill in $Skills) {
        Write-Host "  - $($skill.Name)"
    }

    $printedNotes = $false
    foreach ($note in $notesList) {
        if (-not [string]::IsNullOrWhiteSpace($note)) {
            if (-not $printedNotes) {
                Write-Host ""
                Write-Host "Notes:"
                $printedNotes = $true
            }

            Write-Host "  - $note"
        }
    }

    Write-Host ""
    Write-Host "Potential conflicts:"
    $printedConflicts = $false
    foreach ($conflict in $conflictList) {
        if ($null -eq $conflict) {
            continue
        }

        if ($conflict.Type -eq "Skill") {
            Write-Host "  - skill '$($conflict.Name)' already exists at $($conflict.Path)"
            $printedConflicts = $true
            continue
        }

        if ($conflict.Type -eq "AGENTS") {
            Write-Host "  - AGENTS.md already exists at $($conflict.Path)"
            $printedConflicts = $true
        }
    }

    if (-not $printedConflicts) {
        Write-Host "  - none"
    }
}

function Confirm-Execution {
    if (-not $script:AlwaysConfirmBeforeInstall) {
        return $true
    }

    while ($true) {
        $answer = Read-Host "Continue with installation? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $true
        }

        switch ($answer.Trim().ToLowerInvariant()) {
            "y" { return $true }
            "yes" { return $true }
            "n" { return $false }
            "no" { return $false }
            default { Write-Host "Please enter Y or N." }
        }
    }
}

function Confirm-Replace {
    param(
        [string]$ItemType,
        [string]$Name,
        [string]$Path
    )

    while ($true) {
        $answer = Read-Host "$ItemType '$Name' already exists at '$Path'. Choose [O/s]"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return "Skip"
        }

        switch ($answer.Trim().ToLowerInvariant()) {
            "o" { return "Overwrite" }
            "overwrite" { return "Overwrite" }
            "s" { return "Skip" }
            "skip" { return "Skip" }
            default { Write-Host "Please enter O or S." }
        }
    }
}

function Resolve-ConflictAction {
    param(
        [string]$ConflictMode,
        [string]$ItemType,
        [string]$Name,
        [string]$Path
    )

    switch ($ConflictMode) {
        "overwrite-all" { return "Overwrite" }
        "skip-existing" { return "Skip" }
        "interactive" { return (Confirm-Replace -ItemType $ItemType -Name $Name -Path $Path) }
        default { throw "Unsupported conflict mode '$ConflictMode'." }
    }
}

function New-ExecutionResult {
    return [pscustomobject]@{
        InstalledSkills   = [System.Collections.Generic.List[string]]::new()
        OverwrittenSkills = [System.Collections.Generic.List[string]]::new()
        SkippedSkills     = [System.Collections.Generic.List[string]]::new()
        FailedItems       = [System.Collections.Generic.List[string]]::new()
        AgentsStatus      = "NotStarted"
    }
}

function Install-Skill {
    param(
        [pscustomobject]$Skill,
        [string]$SkillsTargetRoot,
        [pscustomobject]$Result,
        [string]$ConflictMode
    )

    $destination = Join-Path $SkillsTargetRoot $Skill.Name

    try {
        $action = "Install"
        if (Test-Path -LiteralPath $destination) {
            $action = Resolve-ConflictAction -ConflictMode $ConflictMode -ItemType "Skill" -Name $Skill.Name -Path $destination
        }

        if ($action -eq "Skip") {
            $null = $Result.SkippedSkills.Add($Skill.Name)
            return
        }

        if (Test-Path -LiteralPath $destination) {
            Remove-Item -LiteralPath $destination -Recurse -Force
            Copy-Item -LiteralPath $Skill.SourcePath -Destination $destination -Recurse -Force
            $null = $Result.OverwrittenSkills.Add($Skill.Name)
            return
        }

        Copy-Item -LiteralPath $Skill.SourcePath -Destination $destination -Recurse -Force
        $null = $Result.InstalledSkills.Add($Skill.Name)
    }
    catch {
        $null = $Result.FailedItems.Add("skill:$($Skill.Name) - $($_.Exception.Message)")
    }
}

function Install-AgentsFile {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [pscustomobject]$Result,
        [string]$ConflictMode
    )

    try {
        $action = "Install"
        if (Test-Path -LiteralPath $TargetPath -PathType Leaf) {
            $action = Resolve-ConflictAction -ConflictMode $ConflictMode -ItemType "File" -Name "AGENTS.md" -Path $TargetPath
        }

        if ($action -eq "Skip") {
            $Result.AgentsStatus = "Skipped"
            return
        }

        Copy-Item -LiteralPath $SourcePath -Destination $TargetPath -Force
        if ($action -eq "Overwrite") {
            $Result.AgentsStatus = "Overwritten"
        }
        else {
            $Result.AgentsStatus = "Installed"
        }
    }
    catch {
        $Result.AgentsStatus = "Failed"
        $null = $Result.FailedItems.Add("AGENTS.md - $($_.Exception.Message)")
    }
}

function Write-ExecutionSummary {
    param(
        [pscustomobject]$Result,
        [string]$ProjectRoot,
        [string]$AgentsRoot,
        [string]$DownloadMethodUsed,
        [string]$ConflictMode
    )

    Write-Host ""
    Write-Host "Execution summary"
    Write-Host "================="
    Write-Host "Project root: $ProjectRoot"
    Write-Host "Agents root : $AgentsRoot"
    Write-Host "Download   : $DownloadMethodUsed"
    Write-Host "Conflicts  : $ConflictMode"
    Write-Host "Skills dir : $(Join-Path $AgentsRoot 'skills')"
    Write-Host "AGENTS.md  : $(Join-Path $AgentsRoot 'AGENTS.md')"
    Write-Host ""

    Write-Host "Installed skills:"
    if ($Result.InstalledSkills.Count -eq 0) {
        Write-Host "  - none"
    }
    else {
        foreach ($name in $Result.InstalledSkills) {
            Write-Host "  - $name"
        }
    }

    Write-Host ""
    Write-Host "Overwritten skills:"
    if ($Result.OverwrittenSkills.Count -eq 0) {
        Write-Host "  - none"
    }
    else {
        foreach ($name in $Result.OverwrittenSkills) {
            Write-Host "  - $name"
        }
    }

    Write-Host ""
    Write-Host "Skipped skills:"
    if ($Result.SkippedSkills.Count -eq 0) {
        Write-Host "  - none"
    }
    else {
        foreach ($name in $Result.SkippedSkills) {
            Write-Host "  - $name"
        }
    }

    Write-Host ""
    Write-Host "AGENTS.md status:"
    Write-Host "  - $($Result.AgentsStatus)"

    Write-Host ""
    Write-Host "Failed items:"
    if ($Result.FailedItems.Count -eq 0) {
        Write-Host "  - none"
    }
    else {
        foreach ($item in $Result.FailedItems) {
            Write-Host "  - $item"
        }
    }
}

function Invoke-Installation {
    param(
        [object[]]$Skills,
        [string]$AgentsSourcePath,
        [string]$AgentsRoot,
        [string]$ConflictMode
    )

    $result = New-ExecutionResult
    $skillsTargetRoot = Join-Path $AgentsRoot "skills"

    $null = New-Item -ItemType Directory -Path $AgentsRoot -Force
    $null = New-Item -ItemType Directory -Path $skillsTargetRoot -Force

    foreach ($skill in $Skills) {
        Install-Skill -Skill $skill -SkillsTargetRoot $skillsTargetRoot -Result $result -ConflictMode $ConflictMode
    }

    Install-AgentsFile -SourcePath $AgentsSourcePath -TargetPath (Join-Path $AgentsRoot "AGENTS.md") -Result $result -ConflictMode $ConflictMode
    return $result
}

function Remove-WorkspaceSafely {
    param(
        [AllowNull()]
        [string]$WorkspaceRoot
    )

    if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot) -and (Test-Path -LiteralPath $WorkspaceRoot)) {
        Remove-Item -LiteralPath $WorkspaceRoot -Recurse -Force
    }
}

$workspaceRoot = $null

try {
    $config = Get-ValidatedConfiguration `
        -CommandValue $Command `
        -RegionValue $Region `
        -IncludeValues $Include `
        -ExcludeValues $Exclude `
        -RootPathValue $RootPath `
        -RootPathWasSpecified ($PSBoundParameters.ContainsKey("RootPath")) `
        -DownloadMethodValue $DownloadMethod `
        -UseOverwriteAll ($OverwriteAll.IsPresent) `
        -UseSkipExisting ($SkipExisting.IsPresent) `
        -ShowHelp ($Help.IsPresent) `
        -ExtraArguments $RemainingArgs

    if ($config.ShowHelp) {
        Write-Host (Get-UsageText)
        exit 0
    }

    $archive = Get-RepoArchive -ArchiveUrl $script:ArchiveUrl -DownloadMethod $config.DownloadMethod
    $workspaceRoot = $archive.WorkspaceRoot

    $layout = Get-RegionLayout -ArchiveRoot $archive.ArchiveRoot -Region $config.Region
    $availableSkills = Get-AvailableSkills -SkillsRoot $layout.SkillsRoot

    if ($config.Command -eq "list") {
        Show-SkillList -Region $config.Region -Skills $availableSkills
        exit 0
    }

    $projectRoot = Resolve-ProjectRoot -RootPathValue $config.RootPath
    $agentsRoot = Resolve-AgentsRoot -ProjectRoot $projectRoot
    $selection = Resolve-SelectedSkills -AvailableSkills $availableSkills -Include $config.Include -Exclude $config.Exclude
    $conflicts = Get-Conflicts -Skills $selection.Skills -AgentsRoot $agentsRoot

    Show-ExecutionPlan -Config $config -ProjectRoot $projectRoot -AgentsRoot $agentsRoot -Skills $selection.Skills -Conflicts $conflicts -Notes $selection.Notes -ResolvedDownloadMethod $archive.DownloadMethod

    if (-not (Confirm-Execution)) {
        Write-Host ""
        Write-Host "Installation cancelled. No changes were made."
        exit 0
    }

    $result = Invoke-Installation -Skills $selection.Skills -AgentsSourcePath $layout.AgentsPath -AgentsRoot $agentsRoot -ConflictMode $config.ConflictMode
    Write-ExecutionSummary -Result $result -ProjectRoot $projectRoot -AgentsRoot $agentsRoot -DownloadMethodUsed $archive.DownloadMethod -ConflictMode $config.ConflictMode

    if ($result.FailedItems.Count -gt 0) {
        exit 1
    }

    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    Remove-WorkspaceSafely -WorkspaceRoot $workspaceRoot
}
