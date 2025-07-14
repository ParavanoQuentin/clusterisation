import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Posts = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const response = await axios.get('/api/posts');
        setPosts(response.data);
        setLoading(false);
      } catch (err) {
        setError('Erreur lors du chargement des articles');
        setLoading(false);
        console.error('Error fetching posts:', err);
      }
    };

    fetchPosts();
  }, []);

  if (loading) return <div className="loading">Chargement des articles...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div>
      <h2>Articles de Blog</h2>
      <p>Découvrez nos derniers conseils et articles sur le fitness et la nutrition.</p>
      
      <div className="posts-grid">
        {posts.map((post) => (
          <div key={post.id} className="post-card">
            <h3>{post.title}</h3>
            <p>{post.content}</p>
            <div className="author">
              Par {post.author} • {new Date(post.created_at).toLocaleDateString('fr-FR')}
            </div>
          </div>
        ))}
      </div>
      
      {posts.length === 0 && (
        <div style={{ textAlign: 'center', opacity: 0.7, marginTop: '2rem' }}>
          Aucun article disponible pour le moment.
        </div>
      )}
    </div>
  );
};

export default Posts;
