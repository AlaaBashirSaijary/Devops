const test = require('node:test');
const assert = require('node:assert');
const server = require('./server');

let base;
test.before(async () => {
  await new Promise((r) => server.listen(0, r));
  base = `http://localhost:${server.address().port}`;
});
test.after(() => server.close());

test('GET /health returns 200 and status ok', async () => {
  const res = await fetch(`${base}/health`);
  assert.strictEqual(res.status, 200);
  assert.deepStrictEqual(await res.json(), { status: 'ok' });
});

test('GET / serves the HTML site', async () => {
  const res = await fetch(`${base}/`);
  assert.strictEqual(res.status, 200);
  assert.match(res.headers.get('content-type'), /text\/html/);
  assert.match(await res.text(), /Hello DevOps/);
});

test('GET /api/info returns version and hostname', async () => {
  const body = await (await fetch(`${base}/api/info`)).json();
  assert.ok(body.version);
  assert.ok(body.hostname);
});
