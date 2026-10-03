# IPTV Player Free

Player only. Bring your own playlist. No channels included.

## Apps

- Android: Flutter in `lib`, package `com.iptvplayer.app`
- Web: Next.js in `web`, hls.js player

## Run Android

```
flutter pub get
flutter run
```

## Run Web

```
cd web
npm install
npm run dev
```

## Backend

Local-first v1. Supabase optional via `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Schema in `supabase/schema.sql`.
