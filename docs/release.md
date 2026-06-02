# Release Guide — purenote

## Prerequisites

| Requirement | Tool/Command |
|---|---|
| Flutter SDK 3.41+ | `flutter --version` |
| Java 17 | `java --version` |
| Android SDK 34+ | `flutter doctor -v` |
| Google Play Console account | \$25 one-time registration fee |
| Sentry auth token (optional) | `SENTRY_AUTH_TOKEN` env var for debug symbol upload |

## 1. Generate Keystore

Run this **on your machine** (never commit the keystore):

```bash
keytool -genkey -v \
  -keystore C:/Users/<you>/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You'll be prompted for:
- Keystore password (remember this securely)
- Key password (can be same as keystore)
- Name, org, location (any real values)

## 2. Create Signing Config File

Create `android/key.properties` (never commit this):

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=C:/Users/<you>/upload-keystore.jks
```

## 3. Register with Google Play App Signing

**Google Play will strip the upload key and resign with its own key.** This is the recommended approach.

1. Go to [Play Console](https://play.google.com/console) → Create app
2. Choose "Let Google manage and protect your app signing key (recommended)"
3. Generate the upload key certificate (next step)

```bash
keytool -export -rfc \
  -keystore C:/Users/<you>/upload-keystore.jks \
  -alias upload \
  -file upload-cert.pem
```

Upload `upload-cert.pem` when prompted in Play Console.

## 4. Build & Upload

```bash
# Clean
flutter clean && flutter pub get

# Analyze
flutter analyze

# Test
flutter test

# Codegen (if schema/providers changed)
dart run build_runner build --delete-conflicting-outputs

# Build release AAB
flutter build appbundle --release --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# The AAB is at:
# build/app/outputs/bundle/release/app-release.aab
```

Upload `app-release.aab` to Play Console → Internal Testing track.

## 5. Upload Debug Symbols to Sentry

If Sentry crash reporting is enabled, upload debug symbols so stack traces are symbolicated:

```bash
# Install sentry-cli
# See https://docs.sentry.io/product/cli/installation/

# Set your auth token (or use the env var)
export SENTRY_AUTH_TOKEN=your-auth-token
export SENTRY_ORG=your-org
export SENTRY_PROJECT=purenote

# Upload debug symbols
sentry-cli upload-dif --include-sources build/app/outputs/symbols/
```

The CI workflow (`.github/workflows/flutter-release.yml`) automatically uploads the symbols as a build artifact. You can download them from GitHub Actions and run `sentry-cli upload-dif` manually, or add a step in CI.

## 6. Play Console Checklist

### App content
- [ ] App name: **purenote**
- [ ] Short description (80 char): Minimal offline note-taking app. Rich text, tasks, labels, PIN lock, and backups.
- [ ] Full description (4000 char): Expand on all features (rich text, task lists, labels, search, reminders, attachments, audio recording, import from Keep/Evernote/Quillpad, backup/restore with optional AES encryption, biometric PIN lock, per-note encryption, home screen widget)
- [ ] Screenshots (2–8): 1080×1920 or 1080×2400 PNG
- [ ] Feature graphic: 1024×500 PNG
- [ ] Icon: 512×512 PNG (Play Store icon, can differ from app icon)

### Store listing
- [ ] App category: **Productivity**
- [ ] Tags: note-taking, notes, productivity, offline
- [ ] Content rating: **Everyone**
- [ ] Target audience: no children under 13
- [ ] Privacy policy — see below

### Data Safety
- [ ] No data collected (all local)
- [ ] No sharing with third parties
- [ ] No account or login system

### Pricing & Distribution
- [ ] Free
- [ ] Available in all countries (or select)
- [ ] No ads (enable "Contains ads" if you add any)

## 7. Privacy Policy

Since purenote has **no internet permission and collects no data**, use a minimal hosted policy:

Option A — Free hosted: Use [Privacy Policy Generator](https://privacypolicygenerator.info/) or similar.
Option B — GitHub Pages: Create `docs/PRIVACY.md` and serve via GitHub Pages:

```md
# Privacy Policy — purenote

**Last updated:** 2026-06-02

purenote does not collect, store, or transmit any personal data.

All notes, tasks, settings, and attachments are stored locally on your device.

The app has no internet permission and makes no network requests.

No third-party services receive data from purenote.

If you have questions, contact: your-email@example.com
```

Enable GitHub Pages on the repo (Settings → Pages → deploy from `main` /docs folder → URL will be `https://<user>.github.io/purenote/PRIVACY.html`).

## 8. Tag Release

```bash
git add . && git commit -m "chore: bump to v1.0.0"
git tag v1.0.0
git push && git push --tags
```

This triggers the CI workflow (`.github/workflows/flutter-release.yml`) which builds the AAB and uploads it as a GitHub Actions artifact.

## 9. Internal Testing

1. In Play Console → Release → Testing → Internal testing
2. Create a new release, upload AAB, fill in release notes
3. Add up to 100 testers via email
4. Testers install from the opt-in link
5. Smoke test on physical devices for 48h before promoting to Closed/Open track

## 10. Production Rollout

1. After 48h of internal testing with zero crashes → promote to Closed Testing
2. Start with 20% staged rollout
3. Monitor Sentry crash-free rate (target > 99.7%)
4. After 24h → promote to Production
5. Rollout: 1% → 10% → 50% → 100% over 72h
6. Post-release: monitor first-week crash-free sessions
