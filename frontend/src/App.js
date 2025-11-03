import React, { useState, useEffect, useRef } from 'react';
import './App.css';
import NewsCard from './components/NewsCard';
import ConnectionStatus from './components/ConnectionStatus';

// Configure these after deployment
const WS_ENDPOINT = process.env.REACT_APP_WS_ENDPOINT || 'wss://your-api-id.execute-api.us-east-1.amazonaws.com/prod';
const REST_API_ENDPOINT = process.env.REACT_APP_REST_API_ENDPOINT || 'https://your-api-id.execute-api.us-east-1.amazonaws.com/prod';

function App() {
  const [articles, setArticles] = useState([]);
  const [connectionStatus, setConnectionStatus] = useState('disconnected');
  const [error, setError] = useState(null);
  const wsRef = useRef(null);
  const reconnectTimeoutRef = useRef(null);

  useEffect(() => {
    connectWebSocket();
    
    // Also fetch latest articles via REST API as fallback
    fetchLatestArticles();

    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
  }, []);

  const connectWebSocket = () => {
    try {
      const ws = new WebSocket(WS_ENDPOINT);
      wsRef.current = ws;

      ws.onopen = () => {
        console.log('WebSocket connected');
        setConnectionStatus('connected');
        setError(null);
        
        // Request latest news
        ws.send(JSON.stringify({ action: 'get_latest' }));
      };

      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          
          if (data.type === 'news_update') {
            // New article received
            setArticles(prev => {
              // Avoid duplicates
              const exists = prev.find(a => a.articleId === data.articleId);
              if (exists) return prev;
              return [data, ...prev].slice(0, 100); // Keep last 100
            });
          } else if (data.type === 'latest_news') {
            // Initial news load
            setArticles(data.articles || []);
          }
        } catch (err) {
          console.error('Error parsing WebSocket message:', err);
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        setConnectionStatus('error');
        setError('WebSocket connection error');
      };

      ws.onclose = () => {
        console.log('WebSocket disconnected');
        setConnectionStatus('disconnected');
        
        // Attempt to reconnect after 3 seconds
        reconnectTimeoutRef.current = setTimeout(() => {
          connectWebSocket();
        }, 3000);
      };
    } catch (err) {
      console.error('Error connecting WebSocket:', err);
      setConnectionStatus('error');
      setError('Failed to connect to WebSocket');
    }
  };

  const fetchLatestArticles = async () => {
    try {
      const response = await fetch(`${REST_API_ENDPOINT}/news?limit=50`);
      if (response.ok) {
        const data = await response.json();
        setArticles(data.articles || []);
      } else {
        console.error(`Failed to fetch articles: ${response.status} ${response.statusText}`);
      }
    } catch (err) {
      console.error('Error fetching articles:', err);
      setError('Failed to fetch articles from API');
    }
  };

  const getSentimentColor = (sentiment) => {
    switch (sentiment?.toLowerCase()) {
      case 'bullish':
        return '#10b981'; // green
      case 'bearish':
        return '#ef4444'; // red
      default:
        return '#6b7280'; // gray
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>📈 Financial News Analysis Dashboard</h1>
        <p>Real-time market sentiment analysis & trading strategies</p>
        <ConnectionStatus status={connectionStatus} error={error} />
      </header>

      <main className="App-main">
        {articles.length === 0 ? (
          <div className="empty-state">
            <p>Waiting for news articles...</p>
            <p className="subtitle">Articles will appear here as they are analyzed</p>
          </div>
        ) : (
          <div className="articles-grid">
            {articles.map((article) => (
              <NewsCard
                key={article.articleId}
                article={article}
                sentimentColor={getSentimentColor(article.sentiment)}
              />
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;

