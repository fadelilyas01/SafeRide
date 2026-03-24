const http = require('http');

function request(path, method, body, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };
    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data || '{}') });
        } catch(e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function run() {
  console.log('--- REGISTER ---');
  let res = await request('/auth/register', 'POST', {
    email: `test_${Date.now()}@test.com`,
    password: '123',
    name: 'Test Passenger',
    role: 'RIDER'
  });
  console.log(res.status, res.body);

  const token = res.body.access_token;
  const userId = res.body.user.id;

  console.log('\n--- CREATE RIDE ---');
  let rideRes = await request('/rides', 'POST', {
    passengerId: userId,
    pickupLat: 48.8566,
    pickupLng: 2.3522,
    pickupAddress: "Paris, Centre",
    destinationLat: 48.8584,
    destinationLng: 2.2945,
    destinationAddress: "Tour Eiffel",
    estimatedPrice: 15.0
  }, token);
  
  console.log(rideRes.status, rideRes.body);
  
  if (rideRes.status === 500) {
    console.log("500 Error Details:", rideRes.body);
  }
}

run();
