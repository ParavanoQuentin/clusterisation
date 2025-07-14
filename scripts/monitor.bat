@echo off
REM Script de monitoring simple pour Coach Vitrine (Windows)
echo Monitoring Coach Vitrine - %date% %time%
echo ==========================================

REM Vérifier l'état du cluster
echo État du cluster:
kubectl cluster-info
echo.

REM Vérifier les nœuds
echo Nœuds du cluster:
kubectl get nodes -o wide
echo.

REM Vérifier l'état des pods
echo État des pods:
kubectl get pods -n coach-vitrine -o wide
echo.

REM Vérifier les services
echo Services:
kubectl get services -n coach-vitrine
echo.

REM Vérifier l'ingress
echo Ingress:
kubectl get ingress -n coach-vitrine
echo.

REM Vérifier les HPA (si activés)
echo Horizontal Pod Autoscalers:
kubectl get hpa -n coach-vitrine 2>nul || echo Aucun HPA configuré
echo.

REM Utilisation des ressources
echo Utilisation des ressources:
echo Nœuds:
kubectl top nodes 2>nul || echo Metrics-server non disponible
echo.
echo Pods:
kubectl top pods -n coach-vitrine 2>nul || echo Metrics-server non disponible
echo.

REM Vérifier la connectivité des services
echo Tests de connectivité:

REM Test frontend
curl -s --max-time 5 http://app.local/ >nul 2>&1
if %errorlevel% equ 0 (
    echo Frontend accessible
) else (
    echo Frontend inaccessible
)

REM Test API Users
curl -s --max-time 5 http://app.local/api/users >nul 2>&1
if %errorlevel% equ 0 (
    echo API Users accessible
) else (
    echo API Users inaccessible
)

REM Test API Posts
curl -s --max-time 5 http://app.local/api/posts >nul 2>&1
if %errorlevel% equ 0 (
    echo API Posts accessible
) else (
    echo API Posts inaccessible
)
echo.

REM Vérifier les événements récents
echo Événements récents:
kubectl get events --sort-by=.metadata.creationTimestamp -n coach-vitrine
echo.

echo Monitoring terminé - %date% %time%
