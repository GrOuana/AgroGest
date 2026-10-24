# Compila o WAR e publica-o no Tomcat local (Windows).
# Uso:  .\scripts\publicar.ps1            (usa C:\tomcat ou $env:CATALINA_HOME)
#       .\scripts\publicar.ps1 -SemArrancar
param(
    [string]$Tomcat = $(if ($env:CATALINA_HOME) { $env:CATALINA_HOME } else { 'C:\tomcat' }),
    [switch]$SemArrancar
)
$ErrorActionPreference = 'Stop'
$projecto = Split-Path -Parent $PSScriptRoot

Write-Host '1/4 A compilar (mvn clean package)...'
Push-Location $projecto
try {
    & mvn -q -B clean package
    if ($LASTEXITCODE -ne 0) { throw 'A compilação falhou.' }
} finally {
    Pop-Location
}

Write-Host '2/4 A parar o Tomcat (se estiver a correr)...'
$aCorrer = Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue
if ($aCorrer) {
    & "$Tomcat\bin\shutdown.bat" | Out-Null
    for ($i = 0; $i -lt 30 -and (Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue); $i++) {
        Start-Sleep -Seconds 1
    }
}

Write-Host '3/4 A publicar agrogest.war...'
Remove-Item "$Tomcat\webapps\agrogest" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$Tomcat\work\Catalina\localhost\agrogest" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$projecto\target\agrogest.war" "$Tomcat\webapps\agrogest.war" -Force

if (-not $SemArrancar) {
    Write-Host '4/4 A arrancar o Tomcat...'
    Start-Process -FilePath "$Tomcat\bin\startup.bat" -WorkingDirectory "$Tomcat\bin" -WindowStyle Minimized
    Write-Host 'Pronto: http://localhost:8081/agrogest'
}
