# Dockerfile pour le frontend React
FROM node:18-alpine AS build

WORKDIR /app

# Copier les fichiers de dépendances
COPY frontend/package*.json ./

# Installer les dépendances
RUN npm install

# Copier le code source
COPY frontend/ .

# Construire l'application
RUN npm run build

# Étape de production avec nginx
FROM nginx:alpine

# Copier les fichiers buildés
COPY --from=build /app/build /usr/share/nginx/html

# Copier la configuration nginx personnalisée
COPY docker/frontend/nginx.conf /etc/nginx/nginx.conf

# Exposer le port 80
EXPOSE 80

# Démarrer nginx
CMD ["nginx", "-g", "daemon off;"]
