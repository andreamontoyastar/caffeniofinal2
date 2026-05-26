# Obtiene SHA-1 y SHA-256 del keystore de debug (el que usa flutter run).
$keytoolPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe",
    "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
    "${env:ProgramFiles(x86)}\Android\Android Studio\jbr\bin\keytool.exe"
)
$keytool = $keytoolPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
$keystore = "$env:USERPROFILE\.android\debug.keystore"

if (-not $keytool) {
    Write-Host "No se encontro keytool. Abre Android Studio o instala el JDK del SDK." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $keystore)) {
    Write-Host "No existe debug.keystore en $keystore" -ForegroundColor Red
    exit 1
}

Write-Host "`nHuellas para Firebase (app com.caffenio.caffenio):`n" -ForegroundColor Cyan
& $keytool -list -v -keystore $keystore -alias androiddebugkey -storepass android -keypass android |
    Select-String -Pattern "SHA1:|SHA256:"

Write-Host "`nCopia el SHA1 en Firebase Console -> Configuracion del proyecto -> Tus apps -> Android -> Agregar huella digital`n" -ForegroundColor Yellow
