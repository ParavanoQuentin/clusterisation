import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/users');
        setUsers(response.data);
        setLoading(false);
      } catch (err) {
        setError('Erreur lors du chargement de l\'équipe');
        setLoading(false);
        console.error('Error fetching users:', err);
      }
    };

    fetchUsers();
  }, []);

  if (loading) return <div className="loading">Chargement de l'équipe...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div>
      <h2>Notre Équipe</h2>
      <p>Rencontrez nos coachs experts qui vous accompagneront dans votre parcours.</p>
      
      <div className="users-grid">
        {users.map((user) => (
          <div key={user.id} className="user-card">
            <h3>{user.name}</h3>
            <p><strong>Email:</strong> {user.email}</p>
            <p><strong>Spécialité:</strong> {user.specialty || 'Coach général'}</p>
            <p><strong>Membre depuis:</strong> {new Date(user.created_at).toLocaleDateString('fr-FR')}</p>
          </div>
        ))}
      </div>
      
      {users.length === 0 && (
        <div style={{ textAlign: 'center', opacity: 0.7, marginTop: '2rem' }}>
          Aucun membre de l'équipe disponible pour le moment.
        </div>
      )}
    </div>
  );
};

export default Users;
