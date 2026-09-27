# RepForge

Local-first iOS strength-training log built with SwiftUI + SwiftData + Swift Charts.

## Current features

- Workout templates with a large built-in exercise catalog
- Active workout logging for weight/reps and completed sets
- Previous-set lookup and per-exercise best weight
- Full completed-workout history and session volume
- Local profile with training statistics
- Exercise guide pages with programmatic movement animations and technique cues
- Per-exercise history, weight chart, estimated 1RM chart and records
- GitHub Actions workflow that builds an **unsigned IPA** on a macOS runner, so no local Mac/Xcode is required

## Build locally on macOS

```bash
brew install xcodegen
xcodegen generate
open RepForge.xcodeproj
```

## Windows workflow

Every push to `main` triggers **Actions → iOS build**. When the run succeeds, download the `RepForge-unsigned-ipa` artifact.

An unsigned IPA must be signed before normal installation on an iPhone. The project can later be configured for App Store/TestFlight or certificate-based CI signing.

## Data

Workout/profile data is stored locally using SwiftData. The exercise catalog ships with the app and does not require an account or network connection.
