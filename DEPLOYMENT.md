# AYA — Making the release APK work with Railway + Supabase

The code is now fixed (see "What I changed" at the bottom). The remaining steps
need your Railway and Supabase dashboards and your machine's Flutter SDK — they
can't be done from here. Do them in order.

> **STATUS (2026-06-23):** Database connection, migrations, and **admin login
> are working live** (verified). The items below labelled "NEW FEATURES" (the
> WhatsApp credential share and the first-login authenticator) are written into
> the code but require you to push the code, redeploy, and rebuild the APK.

---

## NEW FEATURES — what you must do to activate them

Two features were added in code: (1) a "Send on WhatsApp" button after adding a
member, and (2) an authenticator-app (Google Authenticator/Authy) OTP that every
member sets up on their **first** login. To turn them on:

1. **Push the code to GitHub** (from the project folder):
   `git add -A && git commit -m "TOTP + WhatsApp credential share + Supabase SSL fixes" && git push`
   Railway auto-redeploys and runs `npm install` (picks up the new `otplib`
   backend dependency).
2. **Run migration 013** (adds the `totp_secret` / `totp_enabled` columns).
   In Railway → service → **Console**: `npm run migrate`
3. **Rebuild the app** on your machine (picks up the new `qr_flutter` dependency
   and the new screens):
   `cd aya_app && flutter pub get && flutter analyze && flutter build apk --release`
   Install `aya_app/build/app/outputs/flutter-apk/app-release.apk`.

After this, the **first** time anyone (including the admin) logs in, they will be
asked to scan a QR into an authenticator app and enter a 6-digit code once; later
logins are password-only.

---

## 1. Set the backend environment variables on Railway

In the Railway project → your backend service → **Variables**, set:

| Variable             | Value                                                                 |
| -------------------- | --------------------------------------------------------------------- |
| `DATABASE_URL`       | Your Supabase connection string (Supabase → Project → Connect → URI)  |
| `JWT_SECRET`         | A long random string                                                  |
| `JWT_REFRESH_SECRET` | A different long random string                                        |
| `NODE_ENV`           | `production`                                                           |
| `ALLOWED_ORIGINS`    | Leave empty (the phone app sends no Origin header, so it's allowed)   |

SSL to Supabase is now handled automatically in code — you do **not** need to
add `?sslmode=require`.

## 2. Create the tables and the admin user in Supabase

The Supabase database is empty until the migrations run.

> **CRITICAL — use the IPv4 Session pooler, not the Direct connection.**
> The `DATABASE_URL` was set to Supabase's *Direct* connection
> (`db.kmknifwifoqwkrenudev.supabase.co`), which is **IPv6-only**. Neither a
> home network nor Railway could route to it — that is the `ETIMEDOUT` /
> `ENETUNREACH` on the `2406:...` address. Switch `DATABASE_URL` (in Railway →
> Variables, and locally) to the IPv4 Session pooler:
>
> ```
> postgresql://postgres.kmknifwifoqwkrenudev:[YOUR-PASSWORD]@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres
> ```
>
> Keep your existing password. Easiest edit: change the username `postgres` →
> `postgres.kmknifwifoqwkrenudev` and the host
> `db.kmknifwifoqwkrenudev.supabase.co` → `aws-1-ap-northeast-1.pooler.supabase.com`.

**Option A — run the migration on Railway (no connection-string changes):**

1. Push the code and let Railway redeploy.
2. Railway → service → **Console** tab.
3. Run `npm run migrate`. Railway's network has IPv6, so it reaches Supabase.

**Option B — run it locally via the IPv4 pooler:**

In Supabase → **Connect** → **Session pooler** (port 5432, IPv4). Format:

```
postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres
```

Put that in `backend/.env` as `DATABASE_URL`, then:

```bash
cd backend
npm install
npm run migrate
```

Use this same pooler string for Railway's `DATABASE_URL` too — it is the more
reliable long-term choice. This creates every table and seeds the admin account.

## 3. Verify the backend is healthy

Open this in a browser:

```
https://aya-production-b4e9.up.railway.app/api/health
```

- `{"status":"ok","database":"connected"}` → backend + Supabase are working.
- `{"status":"degraded","database":"unavailable"}` → `DATABASE_URL` is wrong or
  the migration hasn't run. Fix step 1/2 before continuing.

## 4. Rebuild and install the APK

The app's `.env` already points at Railway (`API_BASE_URL=aya-production-b4e9.up.railway.app`).
Rebuild so it picks up the fixes:

```bash
cd aya_app
flutter clean
flutter pub get
flutter build apk --release
```

Install `aya_app/build/app/outputs/flutter-apk/app-release.apk` on your phone.

## 5. Log in

- **Mobile:** `9313774645`
- **Password:** `Jin@24`

This account is the administrator (it now lands on the Admin Panel).

---

## What I changed in the code

- **`backend/src/config/env.js`, `db.js`, `scripts/migrate.js`** — the Postgres
  pool had no SSL setting, so it could not connect to Supabase. SSL is now
  enabled automatically for any non-local database host.
- **`backend/server.js`** — `/api/health` now actually queries the database, so
  a broken connection is visible immediately instead of failing silently on
  every request.
- **`backend/migrations/001_initial.sql`** — the seeded admin had role `admin`,
  which the app and backend don't recognise as an administrator (only
  `president`/`secretary`). Changed to `president`, and an existing row is
  corrected on the next migration run.
- **`aya_app/lib/main.dart`** — screen-wakelock setup no longer blocks app
  launch if it fails.
- **`aya_app/lib/features/auth/auth_provider.dart`** and **`splash_screen.dart`**
  — startup now tolerates any auth/storage/network failure and always routes to
  the login screen, so a backend problem can never leave a blank screen.
