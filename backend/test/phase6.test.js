// test/phase6.test.js — Phase 6 (Events & Vibhags) API suite.
//
// Run against your real database after migrating:
//   npm run migrate
//   npm run test:phase6
//
// It uses the seeded admin (9876767676 / admin@123), creates a throwaway
// member to exercise the vibhag-head permission path, and deactivates that
// member when finished. supertest drives the Express app in-process, so no
// server needs to be running.
const request = require('supertest');

let passed = 0;
let failed = 0;

function check(name, condition) {
  if (condition) {
    passed += 1;
    console.log(`  PASS  ${name}`);
  } else {
    failed += 1;
    console.log(`  FAIL  ${name}`);
  }
}

/**
 * Runs the full Phase 6 assertion sequence against an Express `app`.
 * Returns { passed, failed }.
 */
async function runSuite(app) {
  const api = request(app);

  // 1. Admin login -----------------------------------------------------------
  const adminLogin = await api
    .post('/api/auth/login')
    .send({ mobile: '9876767676', password: 'admin@123' });
  check('admin can log in', adminLogin.status === 200 && !!adminLogin.body.token);
  const adminToken = adminLogin.body.token;
  const auth = (token) => ({ Authorization: `Bearer ${token}` });

  // 2. Vibhag catalogue ------------------------------------------------------
  const vibhags = await api.get('/api/vibhags').set(auth(adminToken));
  check('GET /vibhags returns the six vibhags',
    vibhags.status === 200 && vibhags.body.items.length === 6);
  check('admin sees is_admin = true', vibhags.body.is_admin === true);

  // 3. Admin creates an event ------------------------------------------------
  const createEvent = await api.post('/api/events').set(auth(adminToken)).send({
    vibhag_type: 'paryushan',
    name: 'Paryushan Mahaparv',
    date: futureDate(7),
    time: '18:00',
    venue: 'Jain Upashraya',
  });
  check('admin creates an event (201)', createEvent.status === 201);
  const eventId = createEvent.body.event && createEvent.body.event.id;
  check('created event carries vibhag display data',
    createEvent.body.event && createEvent.body.event.vibhag_name === 'Paryushan');

  // 4. List + validation -----------------------------------------------------
  const upcoming = await api.get('/api/events?scope=upcoming').set(auth(adminToken));
  check('upcoming list includes the new event',
    upcoming.status === 200 && upcoming.body.items.some((e) => e.id === eventId));

  const badEvent = await api.post('/api/events').set(auth(adminToken)).send({
    vibhag_type: 'paryushan',
    date: futureDate(3),
  });
  check('event without a name is rejected (400)', badEvent.status === 400);

  // 5. Throwaway member ------------------------------------------------------
  const mobile = randomMobile();
  const addMember = await api
    .post('/api/admin/members')
    .set(auth(adminToken))
    .send({ mobile });
  check('admin adds a member', addMember.status === 201 && !!addMember.body.tempPassword);
  const memberId = addMember.body.id;

  const memberLogin = await api
    .post('/api/auth/login')
    .send({ mobile, password: addMember.body.tempPassword });
  check('new member can log in', memberLogin.status === 200);
  let memberToken = memberLogin.body.token;

  // 6. Open policy: any logged-in member can create events for any vibhag -----
  const memberCreate = await api
    .post('/api/events')
    .set(auth(memberToken))
    .send({ vibhag_type: 'sangeet', name: 'Bhakti Night', date: futureDate(10), time: '19:00' });
  check('member can create an event (open policy, 201)', memberCreate.status === 201);
  const memberEventId = memberCreate.body.event && memberCreate.body.event.id;

  const memberCreateOther = await api
    .post('/api/events')
    .set(auth(memberToken))
    .send({
      vibhag_type: 'seva',
      name: 'Seva Camp',
      date: futureDate(12),
      end_date: futureDate(14),
      time: '09:00',
    });
  check('member can create a multi-day event (201)', memberCreateOther.status === 201);

  const missingTime = await api
    .post('/api/events')
    .set(auth(memberToken))
    .send({ vibhag_type: 'aangi', name: 'No Time', date: futureDate(8) });
  check('event without a time is rejected (400)', missingTime.status === 400);

  const memberEdit = await api
    .put(`/api/events/${memberEventId}`)
    .set(auth(memberToken))
    .send({ name: 'Bhakti Night (updated)', date: futureDate(10), time: '19:30' });
  check('member can edit an event (200)', memberEdit.status === 200);

  const memberDelete = await api
    .delete(`/api/events/${memberCreateOther.body.event.id}`)
    .set(auth(memberToken));
  check('member can delete an event (200)', memberDelete.status === 200);

  const memberVibhags = await api.get('/api/vibhags').set(auth(memberToken));
  check('plain member sees is_admin = false', memberVibhags.body.is_admin === false);

  // 7. Head APPOINTMENT remains admin-only -----------------------------------
  const memberAssignBlocked = await api
    .post('/api/vibhags/seva/heads')
    .set(auth(memberToken))
    .send({ member_id: memberId });
  check('member cannot appoint vibhag heads (403)', memberAssignBlocked.status === 403);

  const addHead = await api
    .post('/api/vibhags/sangeet/heads')
    .set(auth(adminToken))
    .send({ member_id: memberId });
  check('admin appoints a vibhag head (201)', addHead.status === 201);
  check('head list now includes the member',
    addHead.body.heads.some((h) => h.member_id === memberId));

  // 10. Labarthi records (member-entered; amounts private) -------------------
  const addLab = await api
    .post(`/api/events/${eventId}/labarthis`)
    .set(auth(memberToken))
    .send({ name: 'Shah Family', amount: 2100, note: 'Snatra puja' });
  check('member adds a labarthi record (201)', addLab.status === 201);
  const labarthiId = addLab.body.id;

  const noName = await api
    .post(`/api/events/${eventId}/labarthis`)
    .set(auth(memberToken))
    .send({ amount: 500 });
  check('labarthi without a name is rejected (400)', noName.status === 400);

  const memberView = await api.get(`/api/events/${eventId}`).set(auth(memberToken));
  const memberLab = memberView.body.labarthis.find((l) => l.id === labarthiId);
  check('non-admin sees the labarthi name', !!memberLab && memberLab.name === 'Shah Family');
  check('non-admin does NOT see the amount', !!memberLab && memberLab.amount === undefined);
  check('non-admin can_view_amounts = false', memberView.body.can_view_amounts === false);

  const adminView = await api.get(`/api/events/${eventId}`).set(auth(adminToken));
  const adminLab = adminView.body.labarthis.find((l) => l.id === labarthiId);
  check('admin can_view_amounts = true', adminView.body.can_view_amounts === true);
  check('admin sees the amount', !!adminLab && Number(adminLab.amount) === 2100);
  check('event labarthi_count reflects the record',
    adminView.body.event.labarthi_count === 1);

  const removeLab = await api
    .delete(`/api/events/${eventId}/labarthis/${labarthiId}`)
    .set(auth(memberToken));
  check('member removes the labarthi (200)', removeLab.status === 200);

  // 11. Delete event ---------------------------------------------------------
  const del = await api.delete(`/api/events/${eventId}`).set(auth(adminToken));
  check('admin deletes the event', del.status === 200);
  const gone = await api.get(`/api/events/${eventId}`).set(auth(adminToken));
  check('deleted event returns 404', gone.status === 404);

  // 12. Cleanup --------------------------------------------------------------
  await api.delete(`/api/vibhags/sangeet/heads/${memberId}`).set(auth(adminToken));
  await api
    .patch(`/api/admin/members/${memberId}/status`)
    .set(auth(adminToken))
    .send({ status: 'inactive' });

  return { passed, failed };
}

function futureDate(daysAhead) {
  const d = new Date();
  d.setDate(d.getDate() + daysAhead);
  return d.toISOString().substring(0, 10);
}

function randomMobile() {
  let m = '9';
  for (let i = 0; i < 9; i += 1) m += Math.floor(Math.random() * 10);
  return m;
}

// Run directly against the real database (via the app's own pool).
if (require.main === module) {
  const app = require('../server');
  runSuite(app)
    .then(({ passed: p, failed: f }) => {
      console.log(`\nPhase 6: ${p} passed, ${f} failed.`);
      process.exit(f === 0 ? 0 : 1);
    })
    .catch((err) => {
      console.error('Suite crashed:', err);
      process.exit(1);
    });
}

module.exports = { runSuite };
