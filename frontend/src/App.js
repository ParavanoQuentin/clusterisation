import React, { useState } from 'react';
import Home from './components/Home';
import Posts from './components/Posts';
import Users from './components/Users';
import './App.css';

function App() {
  const [currentView, setCurrentView] = useState('home');

  const renderContent = () => {
    switch (currentView) {
      case 'posts':
        return <Posts />;
      case 'users':
        return <Users />;
      default:
        return <Home />;
    }
  };

  return (
    <div className="App">
      <div className="container">
        <header className="header">
          <h1>Coach Vitrine</h1>
          <p>Votre coach personnel pour atteindre vos objectifs</p>
        </header>

        <nav className="nav">
          <button 
            className={currentView === 'home' ? 'active' : ''}
            onClick={() => setCurrentView('home')}
          >
            Accueil
          </button>
          <button 
            className={currentView === 'posts' ? 'active' : ''}
            onClick={() => setCurrentView('posts')}
          >
            Articles
          </button>
          <button 
            className={currentView === 'users' ? 'active' : ''}
            onClick={() => setCurrentView('users')}
          >
            Équipe
          </button>
        </nav>

        <main className="content">
          {renderContent()}
        </main>
      </div>
    </div>
  );
}

export default App;
