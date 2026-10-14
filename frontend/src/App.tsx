import React, { useEffect, useState, useCallback } from 'react';
import EnvironmentCard from './components/EnvironmentCard';
import { ENVIRONMENTS, EnvironmentStatus, fetchEnvironmentStatus } from './api';

declare const __APP_VERSION__: string;

const App: React.FC = () => {
  const [environments, setEnvironments] = useState<EnvironmentStatus[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadAll = useCallback(async () => {
    setRefreshing(true);
    // Start with loading placeholders
    setEnvironments(
      ENVIRONMENTS.map((e) => ({
        name: e.name,
        label: e.label,
        frontendUrl: '',
        backendUrl: '',
        health: null,
        info: null,
        backendStatus: null,
        backendReachable: false,
        frontendReachable: false,
        loading: true,
        error: null,
      }))
    );

    const results = await Promise.all(ENVIRONMENTS.map(fetchEnvironmentStatus));
    setEnvironments(results);
    setRefreshing(false);
  }, []);

  useEffect(() => {
    loadAll();
  }, [loadAll]);

  const onlineCount = environments.filter((e) => e.backendReachable).length;

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <div className="header-inner">
          <div>
            <h1 className="header-title">🚀 DevOps Environment Manager</h1>
            <p className="header-subtitle">
              Multi-environment container deployment dashboard &mdash; FA1 Academic Demonstration
            </p>
          </div>
          <button
            className="refresh-btn"
            onClick={loadAll}
            disabled={refreshing}
            title="Refresh all environments"
          >
            {refreshing ? '⟳ Checking…' : '⟳ Refresh'}
          </button>
        </div>
      </header>

      {/* Summary bar */}
      <div className="summary-bar">
        <span>
          <strong>{onlineCount}</strong> of <strong>3</strong> environments online
        </span>
        <span className="summary-version">v{__APP_VERSION__}</span>
      </div>

      {/* Environment cards */}
      <main className="cards-grid">
        {environments.map((env) => (
          <EnvironmentCard key={env.name} env={env} />
        ))}
      </main>

      {/* Footer */}
      <footer className="footer">
        <p>
          <strong>DevOps Environment Manager</strong> &mdash; Built by Vijay Dhame
        </p>
        <p className="footer-note">
          ⚠️ This is an <strong>academic demonstration</strong> for FA1 assessment.
          Not a production infrastructure control plane.
        </p>
        <p className="footer-tech">
          React + TypeScript + Vite &bull; FastAPI + Python &bull; Docker &bull; Terraform
        </p>
      </footer>
    </div>
  );
};

export default App;
