# Script de démarrage de l'application Real Estate

Write-Host "🏠 Démarrage de l'application Real Estate..." -ForegroundColor Cyan
Write-Host ""

# Vérifier que MongoDB est en cours d'exécution
Write-Host "🔍 Vérification de MongoDB..." -ForegroundColor Yellow
try {
    $mongoStatus = Get-Service -Name "MongoDB" -ErrorAction SilentlyContinue
    if ($mongoStatus -and $mongoStatus.Status -eq "Running") {
        Write-Host "✅ MongoDB est en cours d'exécution" -ForegroundColor Green
    } else {
        Write-Host "⚠️  MongoDB n'est pas démarré. Tentative de démarrage..." -ForegroundColor Yellow
        Start-Service -Name "MongoDB" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "✅ MongoDB démarré" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Impossible de vérifier l'état de MongoDB. Assurez-vous qu'il est installé." -ForegroundColor Red
}

Write-Host ""
Write-Host "🚀 Démarrage du backend (Node.js)..." -ForegroundColor Yellow
Write-Host "   📍 http://localhost:5000" -ForegroundColor Gray

# Démarrer le backend dans une nouvelle fenêtre PowerShell
$backendPath = Join-Path $PSScriptRoot "backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host '🔧 Backend Server' -ForegroundColor Cyan; node server.js"

Write-Host "✅ Backend démarré" -ForegroundColor Green
Write-Host ""

# Attendre quelques secondes pour que le backend démarre
Write-Host "⏳ Attente du démarrage du backend..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host "🎨 Démarrage du frontend (Flutter)..." -ForegroundColor Yellow
Write-Host "   📍 http://localhost:8080" -ForegroundColor Gray

# Démarrer le frontend dans une nouvelle fenêtre PowerShell
$frontendPath = Join-Path $PSScriptRoot "mobile_app"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host '🎨 Flutter App' -ForegroundColor Cyan; flutter run -d chrome --web-port=8080"

Write-Host "✅ Frontend démarré" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✨ Application Real Estate démarrée avec succès!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔐 Credentials de test:" -ForegroundColor Yellow
Write-Host "   Email    : ahmed@example.com" -ForegroundColor White
Write-Host "   Password : password123" -ForegroundColor White
Write-Host ""
Write-Host "📡 URLs:" -ForegroundColor Yellow
Write-Host "   Backend  : http://localhost:5000" -ForegroundColor White
Write-Host "   Frontend : http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "   CREDENTIALS.md  - Tous les comptes de test" -ForegroundColor White
Write-Host "   QUICK_START.md  - Guide de démarrage rapide" -ForegroundColor White
Write-Host "   README.md       - Documentation complète" -ForegroundColor White
Write-Host ""
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
