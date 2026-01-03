const request = require('supertest');
const app = require('../src/app');

describe('DevOps Application Tests', () => {
    describe('GET /', () => {
        it('should return welcome message', async () => {
            const response = await request(app).get('/');
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('message');
            expect(response.body).toHaveProperty('environment');
        });
    });

    describe('GET /health', () => {
        it('should return health status', async () => {
            const response = await request(app).get('/health');
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('status', 'healthy');
            expect(response.body).toHaveProperty('timestamp');
            expect(response.body).toHaveProperty('environment');
        });
    });

    describe('GET /info', () => {
        it('should return application info', async () => {
            const response = await request(app).get('/info');
            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('appName');
            expect(response.body).toHaveProperty('environment');
            expect(response.body).toHaveProperty('port');
            expect(response.body).toHaveProperty('debug');
            expect(response.body).toHaveProperty('logLevel');
            expect(response.body).toHaveProperty('dbUrl');
            expect(response.body).toHaveProperty('apiKey');
        });

        it('should mask API key in response', async () => {
            const response = await request(app).get('/info');
            expect(response.body.apiKey).toMatch(/\.\.\.$/);
        });
    });

    describe('GET /nonexistent', () => {
        it('should return 404 for unknown routes', async () => {
            const response = await request(app).get('/nonexistent');
            expect(response.status).toBe(404);
            expect(response.body).toHaveProperty('error', 'Not Found');
        });
    });

    describe('Environment Variables', () => {
        it('should load environment-specific configuration', () => {
            const config = require('../src/config');
            expect(config).toHaveProperty('nodeEnv');
            expect(config).toHaveProperty('port');
            expect(config).toHaveProperty('logLevel');
            expect(config).toHaveProperty('dbUrl');
        });
    });
});
