import React from 'react';
import './ConnectionStatus.css';

const ConnectionStatus = ({ status, error }) => {
  const getStatusInfo = () => {
    switch (status) {
      case 'connected':
        return { text: 'Connected', className: 'status-connected', icon: '🟢' };
      case 'disconnected':
        return { text: 'Disconnected', className: 'status-disconnected', icon: '⚪' };
      case 'error':
        return { text: 'Error', className: 'status-error', icon: '🔴' };
      default:
        return { text: 'Unknown', className: 'status-unknown', icon: '⚪' };
    }
  };

  const statusInfo = getStatusInfo();

  return (
    <div className={`connection-status ${statusInfo.className}`}>
      <span className="status-icon">{statusInfo.icon}</span>
      <span className="status-text">{statusInfo.text}</span>
      {error && <span className="error-message">{error}</span>}
    </div>
  );
};

export default ConnectionStatus;

