const app = require('./app');
const config = require('./config');

const server = app.listen(config.port, '0.0.0.0', () => {
    console.log(`
╔═══════════════════════════════════════════════════════════╗
║  ${config.appName.padEnd(55)}  ║
╠═══════════════════════════════════════════════════════════╣
║  Environment: ${config.nodeEnv.padEnd(44)}  ║
║  Port:        ${String(config.port).padEnd(44)}  ║
║  Debug Mode:  ${String(config.debug).padEnd(44)}  ║
║  Log Level:   ${config.logLevel.padEnd(44)}  ║
║  Database:    ${config.dbUrl.padEnd(44)}  ║
╚═══════════════════════════════════════════════════════════╝
  `);
    console.log(`Server is running on http://0.0.0.0:${config.port}`);
    console.log(`Health check: http://localhost:${config.port}/health`);
    console.log(`Info endpoint: http://localhost:${config.port}/info\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('\nSIGINT signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        process.exit(0);
    });
});

module.exports = server;
