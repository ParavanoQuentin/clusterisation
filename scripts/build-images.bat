@echo off
REM Script de construction des images Docker pour Windows
echo Construction des images Docker pour Coach Vitrine

set REGISTRY=coach-vitrine
set VERSION=latest

REM Frontend
echo Construction de l'image frontend...
cd frontend
docker build -f ..\docker\frontend\Dockerfile -t %REGISTRY%/frontend:%VERSION% .
if %errorlevel% neq 0 (
    echo Erreur lors de la construction de l'image frontend
    exit /b 1
)
echo Image frontend construite avec succès
cd ..

REM Users Service
echo Construction de l'image users-service...
cd backend\users-service
docker build -f ..\..\docker\users-service\Dockerfile -t %REGISTRY%/users-service:%VERSION% .
if %errorlevel% neq 0 (
    echo Erreur lors de la construction de l'image users-service
    exit /b 1
)
echo Image users-service construite avec succès
cd ..\..

REM Posts Service
echo Construction de l'image posts-service...
cd backend\posts-service
docker build -f ..\..\docker\posts-service\Dockerfile -t %REGISTRY%/posts-service:%VERSION% .
if %errorlevel% neq 0 (
    echo Erreur lors de la construction de l'image posts-service
    exit /b 1
)
echo Image posts-service construite avec succès
cd ..\..

echo Toutes les images ont été construites avec succès!
echo Images disponibles:
docker images | findstr %REGISTRY%
