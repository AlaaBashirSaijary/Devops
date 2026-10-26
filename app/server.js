const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

const VERSION = '1.1.0';
const page = fs.readFileSync(path.join(__dirname, 'index.html'));
const startedAt = Date.now();
let requests = 0;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok' }));
  }
  if (req.url === '/metrics') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    return res.end(`http_requests_total ${requests}\n`);
  }
  if (req.url === '/api/info') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      version: VERSION,
      hostname: os.hostname(),
      uptimeSeconds: Math.round((Date.now() - startedAt) / 1000),
      requests,
    }));
  }
  requests++;
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(page);
});

if (require.main === module) {
  server.listen(3000, () => console.log('listening on 3000'));
}

module.exports = server;
