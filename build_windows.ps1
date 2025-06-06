# build_windows.ps1

param (
    [string]$exeName = "Media Commerce",
    [string]$iconPath = "assets/icons/MC_logo.ico"
)

$cmakeFile = "windows/runner/CMakeLists.txt"
$iconDest = "windows/runner/resources/app_icon.ico"

Write-Host "🔧 Cambiando el nombre del ejecutable a '$exeName'..."

# Actualizar el EXE_NAME en CMakeLists.txt
(Get-Content $cmakeFile) -replace 'set\(EXE_NAME\s+".*"\)', "set(EXE_NAME `"$exeName`")" | Set-Content $cmakeFile

Write-Host "🎨 Copiando el ícono desde '$iconPath'..."
Copy-Item -Path $iconPath -Destination $iconDest -Force

Write-Host "🚀 Ejecutando flutter build windows..."
flutter build windows

Write-Host "✅ Build completado. Revisa build/windows/runner/Release/$exeName.exe"
