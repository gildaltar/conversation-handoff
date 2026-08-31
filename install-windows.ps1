$ErrorActionPreference = 'Stop'

$PluginName = 'conversation-handoff'
$RepoZip = 'https://github.com/gildaltar/conversation-handoff/archive/refs/heads/main.zip'
$PluginDestination = Join-Path $HOME '.codex\plugins\conversation-handoff'
$MarketplacePath = Join-Path $HOME '.agents\plugins\marketplace.json'
$MarketplaceDirectory = Split-Path -Parent $MarketplacePath
$CacheRoot = Join-Path $HOME '.codex\plugins\cache'
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('conversation-handoff-' + [guid]::NewGuid().ToString('N'))
$ZipPath = Join-Path $TempRoot 'repo.zip'
$ExtractPath = Join-Path $TempRoot 'repo'

function Write-Step([string]$Message) {
    Write-Host "[Conversation Handoff] $Message"
}

try {
    Write-Step 'Downloading the latest plugin from GitHub...'
    New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
    Invoke-WebRequest -Uri $RepoZip -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    $SourcePlugin = Join-Path $ExtractPath 'conversation-handoff-main\plugins\conversation-handoff'
    $SourceManifest = Join-Path $SourcePlugin '.codex-plugin\plugin.json'

    if (-not (Test-Path $SourceManifest)) {
        throw 'Downloaded repository does not contain plugins/conversation-handoff/.codex-plugin/plugin.json.'
    }

    $Manifest = Get-Content -Raw -Path $SourceManifest | ConvertFrom-Json
    if ($Manifest.name -ne $PluginName) {
        throw "Unexpected plugin manifest name: $($Manifest.name)"
    }

    Write-Step 'Installing the plugin into your personal ChatGPT/Codex plugin directory...'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PluginDestination) | Out-Null
    if (Test-Path $PluginDestination) {
        Remove-Item -Recurse -Force $PluginDestination
    }
    Copy-Item -Recurse -Force -Path $SourcePlugin -Destination $PluginDestination

    Write-Step 'Updating your personal plugin marketplace...'
    New-Item -ItemType Directory -Force -Path $MarketplaceDirectory | Out-Null

    $Marketplace = $null
    if (Test-Path $MarketplacePath) {
        try {
            $Marketplace = Get-Content -Raw -Path $MarketplacePath | ConvertFrom-Json
        }
        catch {
            $Backup = "$MarketplacePath.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
            Copy-Item -Path $MarketplacePath -Destination $Backup -Force
            Write-Step "Existing marketplace JSON was invalid; backed it up to $Backup"
        }
    }

    if ($null -eq $Marketplace) {
        $Marketplace = [pscustomobject]@{
            name = 'personal-plugins'
            interface = [pscustomobject]@{
                displayName = 'Personal Plugins'
            }
            plugins = @()
        }
    }

    if (-not $Marketplace.PSObject.Properties['name']) {
        $Marketplace | Add-Member -NotePropertyName name -NotePropertyValue 'personal-plugins'
    }
    if (-not $Marketplace.PSObject.Properties['interface']) {
        $Marketplace | Add-Member -NotePropertyName interface -NotePropertyValue ([pscustomobject]@{ displayName = 'Personal Plugins' })
    }
    if (-not $Marketplace.PSObject.Properties['plugins']) {
        $Marketplace | Add-Member -NotePropertyName plugins -NotePropertyValue @()
    }

    $ExistingPlugins = @($Marketplace.plugins | Where-Object { $_.name -ne $PluginName })
    $PluginEntry = [pscustomobject]@{
        name = $PluginName
        source = [pscustomobject]@{
            source = 'local'
            path = './.codex/plugins/conversation-handoff'
        }
        policy = [pscustomobject]@{
            installation = 'INSTALLED_BY_DEFAULT'
            authentication = 'ON_INSTALL'
        }
        category = 'Productivity'
    }
    $Marketplace.plugins = @($ExistingPlugins + $PluginEntry)

    $Json = $Marketplace | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText($MarketplacePath, $Json + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))

    # Remove stale cached copies of this plugin so ChatGPT Desktop reloads the current local package.
    if (Test-Path $CacheRoot) {
        Get-ChildItem -Path $CacheRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $Candidate = Join-Path $_.FullName $PluginName
            if (Test-Path $Candidate) {
                Remove-Item -Recurse -Force $Candidate -ErrorAction SilentlyContinue
            }
        }
    }

    $InstalledManifest = Join-Path $PluginDestination '.codex-plugin\plugin.json'
    $InstalledSkill = Join-Path $PluginDestination 'skills\conversation-handoff\SKILL.md'
    $InstalledTransport = Join-Path $PluginDestination 'MOBILE.md'

    if (-not (Test-Path $InstalledManifest)) { throw 'Installed manifest verification failed.' }
    if (-not (Test-Path $InstalledSkill)) { throw 'Installed skill verification failed.' }
    if (-not (Test-Path $InstalledTransport)) { throw 'Installed transport verification failed.' }

    Write-Host ''
    Write-Host 'Conversation Handoff is installed in your personal plugin marketplace.' -ForegroundColor Green
    Write-Host "Plugin:      $PluginDestination"
    Write-Host "Marketplace: $MarketplacePath"
    Write-Host ''
    Write-Host 'NEXT: Completely quit ChatGPT Desktop, reopen it, then use @conversation-handoff in a chat.' -ForegroundColor Cyan
    Write-Host 'If the plugin is not immediately visible, open Plugins and select the Personal Plugins source once.' -ForegroundColor Cyan
}
finally {
    if (Test-Path $TempRoot) {
        Remove-Item -Recurse -Force $TempRoot -ErrorAction SilentlyContinue
    }
}
