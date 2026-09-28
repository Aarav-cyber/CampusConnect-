const http = require('http');
const assert = require('assert');
const WebSocket = require('ws');
const { app, server } = require('../src/index');

const PORT = 5055;

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: 'localhost',
        port: PORT,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (chunk) => (raw += chunk));
        res.on('end', () => {
          try {
            const data = raw ? JSON.parse(raw) : null;
            resolve({ status: res.statusCode, data });
          } catch (e) {
            resolve({ status: res.statusCode, raw });
          }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting CampusConnect Backend Tests...\n');

  await new Promise((res) => server.listen(PORT, res));
  console.log(`Test server running on port ${PORT}`);

  try {
    // 1. Health check
    const health = await request('GET', '/health');
    assert.strictEqual(health.status, 200);
    console.log('✅ 1. Health check passed');

    // 2. Login existing seeded user
    const loginRes = await request('POST', '/api/auth/login', {
      email: 'aarav@university.edu',
      password: 'password123',
    });
    assert.strictEqual(loginRes.status, 200);
    assert.ok(loginRes.data.token);
    const aaravToken = loginRes.data.token;
    console.log('✅ 2. User login passed with JWT generation');

    // 3. Register a new student
    const regRes = await request('POST', '/api/auth/register', {
      email: `test_${Date.now()}@university.edu`,
      password: 'password123',
      fullName: 'Vikram Mehta',
      department: 'Electrical Engineering',
      year: '2nd Year',
      university: 'SRM University-AP',
    });
    assert.strictEqual(regRes.status, 201);
    assert.ok(regRes.data.token);
    const vikramToken = regRes.data.token;
    const vikramId = regRes.data.user.id;
    console.log('✅ 3. Student registration & profile creation passed');

    // 4. Student discovery & search
    const searchRes = await request('GET', '/api/users?search=Machine%20Learning', null, aaravToken);
    assert.strictEqual(searchRes.status, 200);
    assert.ok(searchRes.data.data.length > 0);
    console.log(`✅ 4. Student discovery passed (${searchRes.data.data.length} matches found)`);

    // 5. Connect with student
    const connectRes = await request('POST', `/api/users/${vikramId}/connect`, null, aaravToken);
    assert.strictEqual(connectRes.status, 201);
    console.log('✅ 5. Student connection request passed');

    // 6. Communities discovery
    const commsRes = await request('GET', '/api/communities', null, aaravToken);
    assert.strictEqual(commsRes.status, 200);
    assert.ok(commsRes.data.data.length >= 4);
    console.log(`✅ 6. Communities discovery passed (${commsRes.data.data.length} communities)`);

    // 7. Events & registration
    const eventsRes = await request('GET', '/api/events', null, aaravToken);
    assert.strictEqual(eventsRes.status, 200);
    assert.ok(eventsRes.data.data.length >= 4);
    const eventId = eventsRes.data.data[0].id;

    const eventRegRes = await request('POST', `/api/events/${eventId}/register`, null, vikramToken);
    assert.strictEqual(eventRegRes.status, 200);
    console.log('✅ 7. Campus event discovery & student registration passed');

    // 8. Conversations & Messages
    const convInit = await request(
      'POST',
      '/api/chat/conversations/direct',
      { recipientId: vikramId },
      aaravToken
    );
    assert.strictEqual(convInit.status, 200);
    const convId = convInit.data.id;
    console.log('✅ 8. Direct conversation channel initialized');

    // 9. WebSocket Real-Time Message Exchange
    await new Promise((resolve, reject) => {
      const wsAarav = new WebSocket(`ws://localhost:${PORT}/ws?token=${aaravToken}`);
      const wsVikram = new WebSocket(`ws://localhost:${PORT}/ws?token=${vikramToken}`);

      let vikramAuthenticated = false;
      let aaravAuthenticated = false;

      wsVikram.on('message', (raw) => {
        const msg = JSON.parse(raw);
        if (msg.type === 'authenticated') {
          vikramAuthenticated = true;
          if (aaravAuthenticated) {
            sendMessage();
          }
        } else if (msg.type === 'message.created') {
          assert.strictEqual(msg.message.content, 'Hello Vikram! Welcome to CampusConnect.');
          console.log('✅ 9. Real-Time WebSocket message sent and received successfully!');
          wsAarav.close();
          wsVikram.close();
          resolve();
        }
      });

      wsAarav.on('message', (raw) => {
        const msg = JSON.parse(raw);
        if (msg.type === 'authenticated') {
          aaravAuthenticated = true;
          if (vikramAuthenticated) {
            sendMessage();
          }
        }
      });

      function sendMessage() {
        wsAarav.send(
          JSON.stringify({
            type: 'message.send',
            conversationId: convId,
            content: 'Hello Vikram! Welcome to CampusConnect.',
            messageType: 'TEXT',
          })
        );
      }

      wsAarav.on('error', reject);
      wsVikram.on('error', reject);
    });

    console.log('\n🎉 ALL BACKEND API & WEBSOCKET TESTS PASSED SUCCESSFULLY! 🎉\n');
  } catch (err) {
    console.error('❌ Test failed:', err);
    process.exit(1);
  } finally {
    server.close();
  }
}

runTests();
