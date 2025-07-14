import React from 'react';

const Home = () => {
  return (
    <div>
      <h2>Bienvenue chez Coach Vitrine</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '2rem', marginTop: '2rem' }}>
        <div style={{ background: 'rgba(255, 255, 255, 0.1)', padding: '1.5rem', borderRadius: '10px' }}>
          <h3>Coaching Personnel</h3>
          <p>Programmes d'entraînement personnalisés adaptés à vos objectifs et votre niveau.</p>
        </div>
        <div style={{ background: 'rgba(255, 255, 255, 0.1)', padding: '1.5rem', borderRadius: '10px' }}>
          <h3>Nutrition</h3>
          <p>Conseils nutritionnels et plans alimentaires pour optimiser vos résultats.</p>
        </div>
        <div style={{ background: 'rgba(255, 255, 255, 0.1)', padding: '1.5rem', borderRadius: '10px' }}>
          <h3>Suivi de Progression</h3>
          <p>Monitoring de vos performances et ajustements de vos programmes.</p>
        </div>
      </div>
      
      <div style={{ marginTop: '3rem', textAlign: 'center' }}>
        <h3>Architecture Microservices</h3>
        <p>Cette application démontre une architecture microservices avec :</p>
        <ul style={{ textAlign: 'left', maxWidth: '600px', margin: '0 auto' }}>
          <li>Frontend React (SPA) - 3 replicas</li>
          <li>Service Users (Node.js/Express) - 2 replicas</li>
          <li>Service Posts (Node.js/Express) - 2 replicas</li>
          <li>Base de données PostgreSQL - 1 replica avec persistance</li>
          <li>Orchestration Kubernetes avec ingress et load balancing</li>
        </ul>
      </div>
    </div>
  );
};

export default Home;
