const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse incoming JSON request bodies
app.use(express.json());


// Root route to confirm that the API is accessible
app.get('/', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Welcome to C.A.P.S. - Campus Placement & Academic System',
        documentation: 'API endpoints are being developed.',
        healthCheck: '/api/health'
    });
});

// Basic route to verify that the API is running
app.get('/api/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'C.A.P.S. API is running successfully.',
        status: 'healthy'
    });
});

// Start the Express server
app.listen(PORT, () => {
    console.log(`C.A.P.S. server is running at http://localhost:${PORT}`);
});