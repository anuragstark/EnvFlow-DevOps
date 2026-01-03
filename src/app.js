const express = require('express');
const config = require('./config');

const app = express();

// Middleware
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
    const logLevels = { debug: 0, info: 1, warn: 2, error: 3 };
    const currentLevel = logLevels[config.logLevel] || 1;

    if (currentLevel <= logLevels.info) {
        console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    }
    next();
});

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to DevOps Project!',
        environment: config.nodeEnv,
        appName: config.appName
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        environment: config.nodeEnv
    });
});

app.get('/info', (req, res) => {
    res.json({
        appName: config.appName,
        environment: config.nodeEnv,
        port: config.port,
        debug: config.debug,
        logLevel: config.logLevel,
        dbUrl: config.dbUrl,
        apiKey: config.apiKey.substring(0, 10) + '...' // Only show first 10 chars for security
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        path: req.path
    });
});

// Error handler
app.use((err, req, res, next) => {
    const logLevels = { debug: 0, info: 1, warn: 2, error: 3 };
    const currentLevel = logLevels[config.logLevel] || 1;

    if (currentLevel <= logLevels.error) {
        console.error(`[ERROR] ${err.message}`);
    }

    res.status(500).json({
        error: config.debug ? err.message : 'Internal Server Error'
    });
});

module.exports = app;
