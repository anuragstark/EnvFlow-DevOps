// Map NODE_ENV to .env file suffix
const envFileMap = {
  development: 'dev',
  test: 'test',
  production: 'prod'
};

const envSuffix = envFileMap[process.env.NODE_ENV] || 'dev';

require('dotenv').config({
  path: `.env.${envSuffix}`
});

const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  debug: process.env.DEBUG === 'true',
  logLevel: process.env.LOG_LEVEL || 'info',
  dbUrl: process.env.DB_URL || 'mongodb://localhost:27017/devops-default',
  apiKey: process.env.API_KEY || 'default-api-key',
  appName: process.env.APP_NAME || 'DevOps App'
};

// Validate required environment variables
const requiredEnvVars = ['PORT', 'LOG_LEVEL', 'DB_URL'];
const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);

if (missingEnvVars.length > 0) {
  console.error(`Missing required environment variables: ${missingEnvVars.join(', ')}`);
  process.exit(1);
}

module.exports = config;
