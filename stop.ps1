# Script d'arrêt de l'application Real Estate

Write-Host "🛑 Arrêt de l'application Real Estate..." -ForegroundColor Cyan
Write-Host ""

# Arrêter tous les processus Node.js (backend)
Write-Host "🔧 Arrêt du backend..." -ForegroundColor Yellow
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force
        Write-Host "   ✅ Backend arrêté (PID: $($_.Id))" -ForegroundColor Green
    }
} else {
    Write-Host "   ℹ️  Aucun processus backend en cours" -ForegroundColor Gray
}

Write-Host ""

# Libérer le port 5000
Write-Host "🔓 Libération du port 5000..." -ForegroundColor Yellow
try {
    $port5000 = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
    if ($port5000) {
        $processId = $port5000.OwningProcess
        Stop-Process -Id $processId -Force
        Write-Host "   ✅ Port 5000 libéré" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Port 5000 déjà libre" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ℹ️  Port 5000 libre" -ForegroundColor Gray
}

Write-Host ""

# Libérer le port 8080
Write-Host "🔓 Libération du port 8080..." -ForegroundColor Yellow
try {
    $port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port8080) {
        $processId = $port8080.OwningProcess
        Stop-Process -Id $processId -Force
        Write-Host "   ✅ Port 8080 libéré" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Port 8080 déjà libre" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ℹ️  Port 8080 libre" -ForegroundColor Gray
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Application Real Estate arrêtée" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
