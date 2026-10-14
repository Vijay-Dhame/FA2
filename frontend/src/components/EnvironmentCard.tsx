import React from 'react';
import { EnvironmentStatus } from '../api';

interface Props {
  env: EnvironmentStatus;
}

const StatusDot: React.FC<{ ok: boolean; loading: boolean }> = ({ ok, loading }) => {
  const color = loading ? '#94a3b8' : ok ? '#22c55e' : '#ef4444';
  const label = loading ? 'Checking…' : ok ? 'Available' : 'Unavailable';
  return (
    <span className="status-dot-wrapper">
      <span className="status-dot" style={{ backgroundColor: color }} />
      <span className="status-label" style={{ color }}>{label}</span>
    </span>
  );
};

const EnvironmentCard: React.FC<Props> = ({ env }) => {
  const borderColor = env.loading
    ? '#475569'
    : env.backendReachable
    ? '#22c55e'
    : '#ef4444';

  return (
    <div className="env-card" style={{ borderTopColor: borderColor }}>
      {/* Header */}
      <div className="env-card-header">
        <h2 className="env-card-title">{env.label} Environment</h2>
        <span className={`env-badge env-badge--${env.name}`}>{env.label}</span>
      </div>

      {/* Services */}
      <div className="env-services">
        {/* Frontend */}
        <div className="service-row">
          <span className="service-name">🖥️ Frontend</span>
          <StatusDot ok={env.frontendReachable} loading={env.loading} />
        </div>
        <div className="service-url">
          <a href={env.frontendUrl} target="_blank" rel="noopener noreferrer">
            {env.frontendUrl}
          </a>
        </div>

        {/* Backend */}
        <div className="service-row">
          <span className="service-name">⚙️ Backend</span>
          <StatusDot ok={env.backendReachable} loading={env.loading} />
        </div>
        <div className="service-url">
          <a href={`${env.backendUrl}/docs`} target="_blank" rel="noopener noreferrer">
            {env.backendUrl}
          </a>
        </div>
      </div>

      {/* Backend info (when available) */}
      {env.backendStatus && (
        <div className="env-info-table">
          <div className="info-row"><span>App</span><span>{env.backendStatus.application}</span></div>
          <div className="info-row"><span>Version</span><span>{env.backendStatus.version}</span></div>
          <div className="info-row"><span>Environment</span><span>{env.backendStatus.environment}</span></div>
          <div className="info-row"><span>Status</span><span>{env.backendStatus.status}</span></div>
          <div className="info-row"><span>Uptime</span><span>{env.backendStatus.uptime_check}</span></div>
          <div className="info-row"><span>Host</span><span>{env.backendStatus.host_info}</span></div>
        </div>
      )}

      {/* Health timestamp */}
      {env.health && (
        <p className="env-timestamp">
          Last checked: {new Date(env.health.timestamp).toLocaleTimeString()}
        </p>
      )}

      {!env.backendReachable && !env.loading && (
        <p className="env-offline-msg">
          Environment not running. Deploy with Terraform to activate.
        </p>
      )}
    </div>
  );
};

export default EnvironmentCard;
