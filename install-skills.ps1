Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:RepositoryUrl = "https://github.com/beibingyangliuying/skills"
$script:ArchiveUrl = "https://github.com/beibingyangliuying/skills/archive/refs/heads/main.zip"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-UsageText {
    return @"
Usage:
  ./install-skills.ps1 --region <name> [--include <skill1,skill2>] [--exclude <skill1,skill2>] [--agent <codex|claude|path>]

Options:
  --region   Required. Install skills from a single region, for example: python
  --include  Optional. Comma-separated skill names to include
  --exclude  Optional. Comma-separated skill names to exclude
  --agent    Optional. codex (default), claude, or a custom agent root path
  --help     Show this help text
"@
}

function Split-NameList {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @(
        $Value -split "," |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" }
    )
}

function Add-UniqueString {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string[]]$Values
    )

    foreach ($value in $Values) {
        if (-not $List.Contains($value)) {
            $null = $List.Add($value)
        }
    }
}

function Parse-Arguments {
    param(
        [string[]]$Tokens
    )

    $include = [System.Collections.Generic.List[string]]::new()
    $exclude = [System.Collections.Generic.List[string]]::new()
    $region = $null
    $agent = "codex"
    $showHelp = $false

    for ($index = 0; $index -lt $Tokens.Count; $index++) {
        $token = $Tokens[$index]

        if ($token -eq "--help" -or $token -eq "-h") {
            $showHelp = $true
            continue
        }

        $optionName = $null
        $optionValue = $null

        if ($token -match "^(--region|--include|--exclude|--agent)=(.+)$") {
            $optionName = $Matches[1]
            $optionValue = $Matches[2]
        }
        else {
            $optionName = $token
            if ($optionName -in @("--region", "--include", "--exclude", "--agent")) {
                if ($index + 1 -ge $Tokens.Count) {
                    throw "Missing value for $optionName.`n`n$(Get-UsageText)"
                }

                $index++
                $optionValue = $Tokens[$index]
            }
        }

        switch ($optionName) {
            "--region" {
                if (-not [string]::IsNullOrWhiteSpace($region)) {
                    throw "Only one --region value is supported.`n`n$(Get-UsageText)"
                }

                $region = $optionValue.Trim()
                if ($region -eq "") {
                    throw "--region cannot be empty.`n`n$(Get-UsageText)"
                }
            }
            "--include" {
                Add-UniqueString -List $include -Values (Split-NameList -Value $optionValue)
            }
            "--exclude" {
                Add-UniqueString -List $exclude -Values (Split-NameList -Value $optionValue)
            }
            "--agent" {
                $agent = $optionValue.Trim()
                if ($agent -eq "") {
                    throw "--agent cannot be empty.`n`n$(Get-UsageText)"
                }
            }
            default {
                throw "Unknown argument: $token`n`n$(Get-UsageText)"
            }
        }
    }

    if ($showHelp) {
        return [pscustomobject]@{
            ShowHelp = $true
            Region   = $null
            Include  = @()
            Exclude  = @()
            Agent    = $agent
        }
    }

    if ([string]::IsNullOrWhiteSpace($region)) {
        throw "--region is required.`n`n$(Get-UsageText)"
    }

    return [pscustomobject]@{
        ShowHelp = $false
        Region   = $region
        Include  = $include.ToArray()
        Exclude  = $exclude.ToArray()
        Agent    = $agent
    }
}

function Resolve-AgentRoot {
    param(
        [string]$AgentValue
    )

    switch ($AgentValue.ToLowerInvariant()) {
        "codex" {
            return [System.IO.Path]::GetFullPath((Join-Path $HOME ".codex"))
        }
        "claude" {
            return [System.IO.Path]::GetFullPath((Join-Path $HOME ".claude"))
        }
        default {
            return [System.IO.Path]::GetFullPath(
                $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AgentValue)
            )
        }
    }
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
        [string]$ArchiveUrl
    )

    $workspace = New-TemporaryWorkspace
    $null = New-Item -ItemType Directory -Path $workspace.ExtractPath -Force

    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $workspace.ArchivePath
    Expand-Archive -LiteralPath $workspace.ArchivePath -DestinationPath $workspace.ExtractPath -Force

    $archiveEntries = @(Get-ChildItem -LiteralPath $workspace.ExtractPath)
    if ($archiveEntries.Count -ne 1 -or -not $archiveEntries[0].PSIsContainer) {
        throw "Unexpected archive structure downloaded from $ArchiveUrl."
    }

    return [pscustomobject]@{
        WorkspaceRoot = $workspace.RootPath
        ArchiveRoot   = $archiveEntries[0].FullName
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
        throw "Unknown skill name(s) in --include: $($unknownInclude -join ', '). Available skills: $($availableNames -join ', ')"
    }

    if ($unknownExclude.Count -gt 0) {
        throw "Unknown skill name(s) in --exclude: $($unknownExclude -join ', '). Available skills: $($availableNames -join ', ')"
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
        throw "No skills remain after applying --include/--exclude."
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
        [string]$AgentRoot
    )

    $conflicts = [System.Collections.Generic.List[object]]::new()
    $skillsTargetRoot = Join-Path $AgentRoot "skills"

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

    $agentsTarget = Join-Path $AgentRoot "AGENTS.md"
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
        [string]$AgentRoot,
        [object[]]$Skills,
        [object[]]$Conflicts,
        [string[]]$Notes
    )

    $skillsTargetRoot = Join-Path $AgentRoot "skills"
    $agentsTarget = Join-Path $AgentRoot "AGENTS.md"
    $notesList = @($Notes)
    $conflictList = @($Conflicts)

    Write-Host ""
    Write-Host "Execution plan"
    Write-Host "=============="
    Write-Host "Repository : $script:RepositoryUrl"
    Write-Host "Archive     : $script:ArchiveUrl"
    Write-Host "Region      : $($Config.Region)"
    Write-Host "Agent root  : $AgentRoot"
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
    while ($true) {
        $answer = Read-Host "Continue with installation? [Y/N]"
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
        $answer = Read-Host "$ItemType '$Name' already exists at '$Path'. Choose [O]verwrite or [S]kip"
        switch ($answer.Trim().ToLowerInvariant()) {
            "o" { return "Overwrite" }
            "overwrite" { return "Overwrite" }
            "s" { return "Skip" }
            "skip" { return "Skip" }
            default { Write-Host "Please enter O or S." }
        }
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
        [pscustomobject]$Result
    )

    $destination = Join-Path $SkillsTargetRoot $Skill.Name

    try {
        $action = "Install"
        if (Test-Path -LiteralPath $destination) {
            $action = Confirm-Replace -ItemType "Skill" -Name $Skill.Name -Path $destination
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
        [pscustomobject]$Result
    )

    try {
        $action = "Install"
        if (Test-Path -LiteralPath $TargetPath -PathType Leaf) {
            $action = Confirm-Replace -ItemType "File" -Name "AGENTS.md" -Path $TargetPath
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
        [string]$AgentRoot
    )

    Write-Host ""
    Write-Host "Execution summary"
    Write-Host "================="
    Write-Host "Agent root : $AgentRoot"
    Write-Host "Skills dir : $(Join-Path $AgentRoot 'skills')"
    Write-Host "AGENTS.md  : $(Join-Path $AgentRoot 'AGENTS.md')"
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
        [string]$AgentRoot
    )

    $result = New-ExecutionResult
    $skillsTargetRoot = Join-Path $AgentRoot "skills"

    $null = New-Item -ItemType Directory -Path $AgentRoot -Force
    $null = New-Item -ItemType Directory -Path $skillsTargetRoot -Force

    foreach ($skill in $Skills) {
        Install-Skill -Skill $skill -SkillsTargetRoot $skillsTargetRoot -Result $result
    }

    Install-AgentsFile -SourcePath $AgentsSourcePath -TargetPath (Join-Path $AgentRoot "AGENTS.md") -Result $result
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
    $config = Parse-Arguments -Tokens $args
    if ($config.ShowHelp) {
        Write-Host (Get-UsageText)
        exit 0
    }

    $agentRoot = Resolve-AgentRoot -AgentValue $config.Agent
    $archive = Get-RepoArchive -ArchiveUrl $script:ArchiveUrl
    $workspaceRoot = $archive.WorkspaceRoot

    $layout = Get-RegionLayout -ArchiveRoot $archive.ArchiveRoot -Region $config.Region
    $availableSkills = Get-AvailableSkills -SkillsRoot $layout.SkillsRoot
    $selection = Resolve-SelectedSkills -AvailableSkills $availableSkills -Include $config.Include -Exclude $config.Exclude
    $conflicts = Get-Conflicts -Skills $selection.Skills -AgentRoot $agentRoot

    Show-ExecutionPlan -Config $config -AgentRoot $agentRoot -Skills $selection.Skills -Conflicts $conflicts -Notes $selection.Notes

    if (-not (Confirm-Execution)) {
        Write-Host ""
        Write-Host "Installation cancelled. No changes were made."
        exit 0
    }

    $result = Invoke-Installation -Skills $selection.Skills -AgentsSourcePath $layout.AgentsPath -AgentRoot $agentRoot
    Write-ExecutionSummary -Result $result -AgentRoot $agentRoot

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
