<#
.SYNOPSIS
Validate a skill folder's SKILL.md frontmatter.

.DESCRIPTION
Lightweight PowerShell implementation aligned with the system quick_validate.py behavior.
It validates YAML frontmatter presence, top-level keys, required fields, and naming rules
for any skill folder passed to the script.

.PARAMETER SkillPath
Path to the target skill directory.

.PARAMETER Help
Show usage text.

.EXAMPLE
./quick_validate.ps1 .\python\.agents\skills\repo-workflow

.EXAMPLE
./quick_validate.ps1 -SkillPath .\python\.agents\skills\repo-workflow
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$SkillPath,

    [Parameter()]
    [Alias("h")]
    [switch]$Help,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:MaxSkillNameLength = 64
$script:AllowedProperties = @("allowed-tools", "description", "license", "metadata", "name")

function Get-UsageText {
    return @"
Usage:
  ./quick_validate.ps1 <path-to-skill-folder>
  ./quick_validate.ps1 -SkillPath <path-to-skill-folder>
"@
}

function New-ValidationResult {
    param(
        [bool]$Valid,
        [string]$Message
    )

    return [pscustomobject]@{
        Valid   = $Valid
        Message = $Message
    }
}

function Get-PythonTypeName {
    param(
        $Value
    )

    if ($null -eq $Value) {
        return "NoneType"
    }

    if ($Value -is [string]) {
        return "str"
    }

    if ($Value -is [bool]) {
        return "bool"
    }

    if ($Value -is [int] -or $Value -is [long]) {
        return "int"
    }

    if ($Value -is [double] -or $Value -is [decimal] -or $Value -is [single]) {
        return "float"
    }

    if ($Value -is [System.Collections.IDictionary]) {
        return "dict"
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        return "list"
    }

    return $Value.GetType().Name
}

function Convert-InlineYamlValue {
    param(
        [string]$ValueText
    )

    $trimmed = $ValueText.Trim()
    if ($trimmed -eq "") {
        return $null
    }

    if (($trimmed.StartsWith("'") -and $trimmed.EndsWith("'")) -or ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"'))) {
        if ($trimmed.Length -lt 2) {
            throw "Invalid YAML in frontmatter: unterminated quoted string"
        }

        return $trimmed.Substring(1, $trimmed.Length - 2)
    }

    if ($trimmed -match '^(null|Null|NULL|~)$') {
        return $null
    }

    if ($trimmed -match '^(true|True|TRUE)$') {
        return $true
    }

    if ($trimmed -match '^(false|False|FALSE)$') {
        return $false
    }

    if ($trimmed -match '^[+-]?\d+$') {
        try {
            return [long]::Parse($trimmed, [System.Globalization.CultureInfo]::InvariantCulture)
        }
        catch {
            return $trimmed
        }
    }

    if ($trimmed -match '^[+-]?(?:\d+\.\d*|\d*\.\d+)$') {
        try {
            return [double]::Parse($trimmed, [System.Globalization.CultureInfo]::InvariantCulture)
        }
        catch {
            return $trimmed
        }
    }

    if ($trimmed.StartsWith("[") -and $trimmed.EndsWith("]")) {
        return @()
    }

    if ($trimmed.StartsWith("{") -and $trimmed.EndsWith("}")) {
        return @{}
    }

    return $trimmed
}

function Get-NextMeaningfulLine {
    param(
        [string[]]$Lines,
        [int]$StartIndex
    )

    for ($i = $StartIndex; $i -lt $Lines.Count; $i++) {
        $candidate = $Lines[$i]
        if ($candidate -match '^\s*$') {
            continue
        }

        if ($candidate -match '^\s*#') {
            continue
        }

        return [pscustomobject]@{
            Index = $i
            Line  = $candidate
        }
    }

    return $null
}

function Get-IndentedContainerPlaceholder {
    param(
        [string[]]$Lines,
        [int]$StartIndex
    )

    $nextMeaningful = Get-NextMeaningfulLine -Lines $Lines -StartIndex $StartIndex
    if ($null -eq $nextMeaningful) {
        return $null
    }

    $line = $nextMeaningful.Line
    if ($line -notmatch '^[ \t]+') {
        return $null
    }

    $trimmed = $line.TrimStart()
    if ($trimmed.StartsWith("- ")) {
        return @()
    }

    return @{}
}

function Convert-FrontmatterToHashtable {
    param(
        [string]$FrontmatterText
    )

    $normalized = $FrontmatterText -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = @($normalized -split "`n", 0, "SimpleMatch")
    $result = [ordered]@{}
    $sawTopLevelEntry = $false
    $currentTopLevelKey = $null

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '^\s*$' -or $line -match '^\s*#') {
            continue
        }

        if ($line -match "^\t+") {
            throw "Invalid YAML in frontmatter: tabs are not supported in indentation"
        }

        if ($line -match '^[^ ]') {
            if ($line -match '^([A-Za-z0-9_-]+):(.*)$') {
                $sawTopLevelEntry = $true
                $currentTopLevelKey = $Matches[1]
                $remainder = $Matches[2]

                if ($remainder -match '^\s*$') {
                    $result[$currentTopLevelKey] = Get-IndentedContainerPlaceholder -Lines $lines -StartIndex ($i + 1)
                }
                else {
                    $result[$currentTopLevelKey] = Convert-InlineYamlValue -ValueText $remainder
                }

                continue
            }

            throw "Frontmatter must be a YAML dictionary"
        }

        if ($null -eq $currentTopLevelKey) {
            throw "Frontmatter must be a YAML dictionary"
        }
    }

    if (-not $sawTopLevelEntry) {
        throw "Frontmatter must be a YAML dictionary"
    }

    return $result
}

function Test-StartsWithYamlFrontmatter {
    param(
        [string]$Content
    )

    return $Content.StartsWith("---")
}

function Validate-Skill {
    param(
        [string]$TargetSkillPath
    )

    try {
        $resolvedSkillPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetSkillPath)
    }
    catch {
        $resolvedSkillPath = $TargetSkillPath
    }

    $skillMdPath = Join-Path $resolvedSkillPath "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillMdPath -PathType Leaf)) {
        return New-ValidationResult -Valid $false -Message "SKILL.md not found"
    }

    $content = Get-Content -LiteralPath $skillMdPath -Raw
    if (-not (Test-StartsWithYamlFrontmatter -Content $content)) {
        return New-ValidationResult -Valid $false -Message "No YAML frontmatter found"
    }

    $normalizedContent = $content -replace "`r`n", "`n" -replace "`r", "`n"
    $match = [regex]::Match($normalizedContent, '^(?s)---\n(.*?)\n---(?:\n|$)')
    if (-not $match.Success) {
        return New-ValidationResult -Valid $false -Message "Invalid frontmatter format"
    }

    $frontmatterText = $match.Groups[1].Value

    try {
        $frontmatter = Convert-FrontmatterToHashtable -FrontmatterText $frontmatterText
    }
    catch {
        return New-ValidationResult -Valid $false -Message $_.Exception.Message
    }

    if ($null -eq $frontmatter -or -not ($frontmatter -is [System.Collections.IDictionary])) {
        return New-ValidationResult -Valid $false -Message "Frontmatter must be a YAML dictionary"
    }

    $unexpectedKeys = @($frontmatter.Keys | Where-Object { $_ -notin $script:AllowedProperties } | Sort-Object)
    if ($unexpectedKeys.Count -gt 0) {
        $allowed = ($script:AllowedProperties | Sort-Object) -join ", "
        $unexpected = $unexpectedKeys -join ", "
        return New-ValidationResult -Valid $false -Message "Unexpected key(s) in SKILL.md frontmatter: $unexpected. Allowed properties are: $allowed"
    }

    if (-not $frontmatter.Contains("name")) {
        return New-ValidationResult -Valid $false -Message "Missing 'name' in frontmatter"
    }

    if (-not $frontmatter.Contains("description")) {
        return New-ValidationResult -Valid $false -Message "Missing 'description' in frontmatter"
    }

    $name = $frontmatter["name"]
    if (-not ($name -is [string])) {
        $typeName = Get-PythonTypeName -Value $name
        return New-ValidationResult -Valid $false -Message "Name must be a string, got $typeName"
    }

    $trimmedName = $name.Trim()
    if ($trimmedName -ne "") {
        if ($trimmedName -notmatch '^[a-z0-9-]+$') {
            return New-ValidationResult -Valid $false -Message "Name '$trimmedName' should be hyphen-case (lowercase letters, digits, and hyphens only)"
        }

        if ($trimmedName.StartsWith("-") -or $trimmedName.EndsWith("-") -or $trimmedName.Contains("--")) {
            return New-ValidationResult -Valid $false -Message "Name '$trimmedName' cannot start/end with hyphen or contain consecutive hyphens"
        }

        if ($trimmedName.Length -gt $script:MaxSkillNameLength) {
            return New-ValidationResult -Valid $false -Message "Name is too long ($($trimmedName.Length) characters). Maximum is $($script:MaxSkillNameLength) characters."
        }
    }

    $description = $frontmatter["description"]
    if (-not ($description -is [string])) {
        $typeName = Get-PythonTypeName -Value $description
        return New-ValidationResult -Valid $false -Message "Description must be a string, got $typeName"
    }

    $trimmedDescription = $description.Trim()
    if ($trimmedDescription -ne "") {
        if ($trimmedDescription.Contains("<") -or $trimmedDescription.Contains(">")) {
            return New-ValidationResult -Valid $false -Message "Description cannot contain angle brackets (< or >)"
        }

        if ($trimmedDescription.Length -gt 1024) {
            return New-ValidationResult -Valid $false -Message "Description is too long ($($trimmedDescription.Length) characters). Maximum is 1024 characters."
        }
    }

    return New-ValidationResult -Valid $true -Message "Skill is valid!"
}

try {
    if ($Help.IsPresent) {
        Write-Output (Get-UsageText)
        exit 0
    }

    $remaining = @($RemainingArgs | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($remaining.Count -gt 0 -or [string]::IsNullOrWhiteSpace($SkillPath)) {
        Write-Output (Get-UsageText)
        exit 1
    }

    $validation = Validate-Skill -TargetSkillPath $SkillPath
    Write-Output $validation.Message
    if ($validation.Valid) {
        exit 0
    }

    exit 1
}
catch {
    Write-Output $_.Exception.Message
    exit 1
}
