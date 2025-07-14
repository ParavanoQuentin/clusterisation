const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3002;

// Configuration de la base de données
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'coach_vitrine',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

// Middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    service: 'posts-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Routes des articles
app.get('/api/posts', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, content, author, created_at FROM posts ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Erreur lors de la récupération des articles' });
  }
});

app.get('/api/posts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id, title, content, author, created_at FROM posts WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Article non trouvé' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching post:', error);
    res.status(500).json({ error: 'Erreur lors de la récupération de l\'article' });
  }
});

app.post('/api/posts', async (req, res) => {
  try {
    const { title, content, author } = req.body;
    
    if (!title || !content || !author) {
      return res.status(400).json({ error: 'Le titre, le contenu et l\'auteur sont requis' });
    }
    
    const result = await pool.query(
      'INSERT INTO posts (title, content, author) VALUES ($1, $2, $3) RETURNING id, title, content, author, created_at',
      [title, content, author]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Erreur lors de la création de l\'article' });
  }
});

// Initialisation de la base de données
const initDatabase = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        author VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insérer des données d'exemple si la table est vide
    const result = await pool.query('SELECT COUNT(*) FROM posts');
    if (parseInt(result.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO posts (title, content, author) VALUES
        ('Les bases de l''entraînement en force', 'Découvrez les principes fondamentaux pour développer votre force musculaire de manière efficace et sécurisée. Nous aborderons la progression, la technique et la récupération.', 'Marie Dupont'),
        ('Nutrition pré et post-entraînement', 'L''alimentation joue un rôle crucial dans vos performances sportives. Apprenez quoi manger avant et après vos séances pour optimiser vos résultats.', 'Jean Martin'),
        ('Yoga pour les sportifs', 'Le yoga n''est pas seulement une pratique de détente. Découvrez comment il peut améliorer votre souplesse, votre équilibre et vos performances sportives.', 'Sophie Bernard'),
        ('Préparation pour votre premier marathon', 'Guide complet pour préparer votre premier marathon en 16 semaines. Plan d''entraînement, nutrition et conseils mentaux pour réussir cette épreuve.', 'Pierre Durand'),
        ('CrossFit : mythes et réalités', 'Le CrossFit fait débat. Séparons les mythes de la réalité pour comprendre les vraies bénéfices et risques de cette pratique sportive populaire.', 'Laura Moreau'),
        ('Récupération active vs passive', 'Quelle est la meilleure stratégie de récupération ? Comparaison entre récupération active et passive avec des recommandations pratiques.', 'Marie Dupont')
      `);
      console.log('Données d\'exemple insérées dans la table posts');
    }
    
    console.log('Base de données initialisée avec succès');
  } catch (error) {
    console.error('Erreur lors de l\'initialisation de la base de données:', error);
  }
};

// Démarrage du serveur
app.listen(PORT, async () => {
  console.log(`Posts Service démarré sur le port ${PORT}`);
  await initDatabase();
});

// Gestion gracieuse de l'arrêt
process.on('SIGTERM', () => {
  console.log('SIGTERM reçu. Arrêt gracieux...');
  pool.end();
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT reçu. Arrêt gracieux...');
  pool.end();
  process.exit(0);
});
