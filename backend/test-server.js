const http = require('http');

// Test the server health endpoint
const testServer = () => {
    const options = {
        hostname: 'localhost',
        port: 4000,
        path: '/stats',
        method: 'GET'
    };

    const req = http.request(options, (res) => {
        console.log(`Status: ${res.statusCode}`);

        let data = '';
        res.on('data', (chunk) => {
            data += chunk;
        });

        res.on('end', () => {
            console.log('Response:', JSON.parse(data));
            console.log('✅ Server is running and responding!');
        });
    });

    req.on('error', (error) => {
        console.error('❌ Server test failed:', error.message);
    });

    req.end();
};

console.log('Testing server connection...');
testServer(); 