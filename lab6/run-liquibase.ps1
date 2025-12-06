param(
    [ValidateSet('update','status','validate','rollbackCount')]
    [string]$Action = 'update',
    [int]$RollbackCount = 1
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$liquibaseDir = Join-Path $root 'liquibase'
$cli = Join-Path $root 'tools/liquibase-4.30.0/liquibase.bat'
$defaults = Join-Path $liquibaseDir 'liquibase.properties'

if (-not (Test-Path $cli)) {
    Write-Error "Liquibase CLI not found at $cli"
    exit 1
}
if (-not (Test-Path $defaults)) {
    Write-Error "Missing liquibase.properties at $defaults"
    exit 1
}

Push-Location $liquibaseDir
try {
    $arguments = @('--defaultsFile=liquibase.properties', $Action)
    if ($Action -eq 'rollbackCount') {
        $arguments += $RollbackCount
    }

    & $cli @arguments
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
