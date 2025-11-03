import React from 'react';
import { formatDistanceToNow } from 'date-fns';
import './NewsCard.css';

const NewsCard = ({ article, sentimentColor }) => {
  const {
    title,
    description,
    url,
    publishedAt,
    sentiment,
    affectedTickers,
    source
  } = article;

  const formatDate = (dateString) => {
    if (!dateString) return 'Just now';
    try {
      return formatDistanceToNow(new Date(dateString), { addSuffix: true });
    } catch {
      return dateString;
    }
  };

  const getSentimentIcon = (sentiment) => {
    switch (sentiment?.toLowerCase()) {
      case 'bullish':
        return '📈';
      case 'bearish':
        return '📉';
      default:
        return '➡️';
    }
  };

  return (
    <div className="news-card">
      <div className="news-card-header">
        <div className="sentiment-badge" style={{ backgroundColor: sentimentColor + '20', color: sentimentColor }}>
          <span className="sentiment-icon">{getSentimentIcon(sentiment)}</span>
          <span className="sentiment-text">{sentiment || 'Neutral'}</span>
        </div>
        <div className="news-meta">
          <span className="source">{source || 'Unknown'}</span>
          <span className="time">{formatDate(publishedAt)}</span>
        </div>
      </div>

      <h3 className="news-title">{title}</h3>
      
      {description && (
        <p className="news-description">{description}</p>
      )}

      {affectedTickers && Object.keys(affectedTickers).length > 0 && (
        <div className="tickers-section">
          <h4 className="tickers-title">Affected Tickers & Strategies</h4>
          {Object.entries(affectedTickers).map(([ticker, data]) => (
            <div key={ticker} className="ticker-item">
              <div className="ticker-header">
                <span className="ticker-symbol">{ticker}</span>
                <span 
                  className="ticker-sentiment"
                  style={{ 
                    color: data.sentiment === 'bullish' ? '#10b981' : 
                           data.sentiment === 'bearish' ? '#ef4444' : '#6b7280'
                  }}
                >
                  {data.sentiment || 'neutral'}
                </span>
              </div>
              
              {data.reasoning && (
                <p className="ticker-reasoning">{data.reasoning}</p>
              )}

              {data.strategies && data.strategies.length > 0 && (
                <div className="strategies-list">
                  <strong>Recommended Actions:</strong>
                  <ul>
                    {data.strategies.map((strategy, idx) => (
                      <li key={idx}>{strategy}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {url && (
        <a 
          href={url} 
          target="_blank" 
          rel="noopener noreferrer" 
          className="news-link"
        >
          Read full article →
        </a>
      )}
    </div>
  );
};

export default NewsCard;

