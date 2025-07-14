#!/bin/bash

# Script de construction des images Docker
echo "Construction des images Docker pour Coach Vitrine"

# Variables
REGISTRY="coach-vitrine"
VERSION="latest"

# Frontend
echo "Construction de l'image frontend..."
cd frontend
docker build -f ../docker/frontend/Dockerfile -t ${REGISTRY}/frontend:${VERSION} .
if [ $? -eq 0 ]; then
    echo "Image frontend construite avec succès"
else
    echo "Erreur lors de la construction de l'image frontend"
    exit 1
fi
cd ..

# Users Service
echo "Construction de l'image users-service..."
cd backend/users-service
docker build -f ../../docker/users-service/Dockerfile -t ${REGISTRY}/users-service:${VERSION} .
if [ $? -eq 0 ]; then
    echo "Image users-service construite avec succès"
else
    echo "Erreur lors de la construction de l'image users-service"
    exit 1
fi
cd ../..

# Posts Service
echo "Construction de l'image posts-service..."
cd backend/posts-service
docker build -f ../../docker/posts-service/Dockerfile -t ${REGISTRY}/posts-service:${VERSION} .
if [ $? -eq 0 ]; then
    echo "Image posts-service construite avec succès"
else
    echo "Erreur lors de la construction de l'image posts-service"
    exit 1
fi
cd ../..

echo "Toutes les images ont été construites avec succès!"
echo "Images disponibles:"
docker images | grep ${REGISTRY}
