const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

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
    service: 'users-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Routes des utilisateurs
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, email, specialty, created_at FROM users ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Erreur lors de la récupération des utilisateurs' });
  }
});

app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id, name, email, specialty, created_at FROM users WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Erreur lors de la récupération de l\'utilisateur' });
  }
});

app.post('/api/users', async (req, res) => {
  try {
    const { name, email, specialty } = req.body;
    
    if (!name || !email) {
      return res.status(400).json({ error: 'Le nom et l\'email sont requis' });
    }
    
    const result = await pool.query(
      'INSERT INTO users (name, email, specialty) VALUES ($1, $2, $3) RETURNING id, name, email, specialty, created_at',
      [name, email, specialty || null]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating user:', error);
    if (error.code === '23505') { // Unique violation
      res.status(409).json({ error: 'Un utilisateur avec cet email existe déjà' });
    } else {
      res.status(500).json({ error: 'Erreur lors de la création de l\'utilisateur' });
    }
  }
});

// Initialisation de la base de données
const initDatabase = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        specialty VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insérer des données d'exemple si la table est vide
    const result = await pool.query('SELECT COUNT(*) FROM users');
    if (parseInt(result.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO users (name, email, specialty) VALUES
        ('Marie Dupont', 'marie.dupont@coach-vitrine.com', 'Fitness & Musculation'),
        ('Jean Martin', 'jean.martin@coach-vitrine.com', 'Nutrition Sportive'),
        ('Sophie Bernard', 'sophie.bernard@coach-vitrine.com', 'Yoga & Pilates'),
        ('Pierre Durand', 'pierre.durand@coach-vitrine.com', 'Course à pied'),
        ('Laura Moreau', 'laura.moreau@coach-vitrine.com', 'CrossFit')
      `);
      console.log('Données d\'exemple insérées dans la table users');
    }
    
    console.log('Base de données initialisée avec succès');
  } catch (error) {
    console.error('Erreur lors de l\'initialisation de la base de données:', error);
  }
};

// Démarrage du serveur
app.listen(PORT, async () => {
  console.log(`Users Service démarré sur le port ${PORT}`);
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
