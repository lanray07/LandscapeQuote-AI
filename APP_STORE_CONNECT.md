# App Store Connect Setup

Use this file when creating the App Store Connect app record and subscription products.

## App Record

- Platform: iOS
- Name: LandscapeQuote AI
- Bundle ID: `com.landscapequoteai.app`
- SKU: `LANDSCAPEQUOTEAI-IOS-001`
- Primary language: English (U.S.)
- Category: Business
- Pricing: Free with auto-renewable subscriptions
- App privacy: Data Not Collected for this release, because photos, client details, quote notes, and project data are stored locally on-device and are not sent to a developer server.

Important: The Bundle ID in App Store Connect must match the Xcode project bundle ID before uploading a build.

## Product Page

Subtitle:

```text
Fast landscaping quotes
```

Promotional text:

```text
Create professional landscaping estimates from rough measurements, site notes, and project photos in minutes.
```

Description:

```text
LandscapeQuote AI helps landscaping contractors, gardeners, paving installers, artificial grass installers, and grounds maintenance teams prepare client-ready quotes faster.

Capture client details, site address, project type, rough measurements, and optional photos. The app includes a local quote generator that produces editable materials, labour, waste allowance, margin, timeline, upsell ideas, and contractor notes.

Build clean estimates for lawn mowing, artificial grass, patio paving, garden clearance, fencing, decking, hedge trimming, drainage, and full garden makeovers.

Key features:
- Create and save landscaping quotes locally
- Track draft, sent, approved, and rejected projects
- Edit line items, quantities, labour, markup, VAT/tax, discounts, and final price
- Export professional PDF quotes with terms and signature line
- Manage business profile, labour rate, profit margin, tax rate, and currency
- Upgrade to Pro for unlimited quotes, PDF export, photo uploads, and AI upsell suggestions

This version does not perform real computer vision measurement or send project photos to an external AI service.
```

Keywords:

```text
landscaping,quote,estimate,garden,paving,contractor,lawn,fencing,decking
```

Support URL:

```text
https://github.com/lanray07/LandscapeQuote-AI
```

Privacy Policy URL:

```text
https://github.com/lanray07/LandscapeQuote-AI/blob/main/PRIVACY_POLICY.md
```

Marketing URL:

```text
https://github.com/lanray07/LandscapeQuote-AI
```

## Review Notes

```text
LandscapeQuote AI is a SwiftUI app for contractors to create local landscaping estimates.

No login is required.
No external payment links are included.
Subscriptions use StoreKit 2.
The app stores client details, quote data, and project photos locally on-device.
The current estimate generator runs locally. It does not send photos or client details to an external AI API.
```

## Auto-Renewable Subscriptions

Subscription group:

```text
LandscapeQuote AI Pro
```

Products:

| Reference Name | Product ID | Duration | Benefits |
| --- | --- | --- | --- |
| Pro Monthly | `landscapequote.pro.monthly` | 1 month | Unlimited quotes, PDF export, photo uploads, AI upsells |
| Pro Yearly | `landscapequote.pro.yearly` | 1 year | Same Pro features with yearly discount |

Subscription review notes:

```text
Pro unlocks unlimited quote creation, PDF export, site photo uploads, and AI upsell suggestions. The free plan allows 3 quotes per month.
```

## Build Upload Checklist

1. Register the Bundle ID `com.landscapequoteai.app` in Apple Developer Certificates, Identifiers & Profiles.
2. Create the App Store Connect app record with the Bundle ID and SKU above.
3. Add the two auto-renewable subscription products and their localizations.
4. Add support and privacy policy URLs.
5. In Xcode on macOS, set the correct Apple Development Team, or configure the GitHub Actions secrets below.
6. Archive the `LandscapeQuoteAI` scheme locally or run the GitHub `Upload to TestFlight` workflow.
7. Upload the archive to App Store Connect.
8. Fill screenshots, age rating, pricing, privacy questionnaire, and subscription availability.
9. Attach subscriptions to the first app version before submitting for review.

## GitHub Xcode Build and TestFlight Upload

This repo includes GitHub Actions workflows that run on Apple's hosted macOS/Xcode runners:

- `iOS Xcode Build`: builds the app for an iOS Simulator on every push, pull request, or manual run. It does not require code signing.
- `Upload to TestFlight`: manually archives a release build and uploads it to App Store Connect using StoreKit-ready App Store signing.

Add these repository secrets in GitHub under Settings > Secrets and variables > Actions:

| Secret | Purpose |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developer Team ID used for automatic signing |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect API issuer ID |
| `ASC_API_KEY_P8_BASE64` | Base64-encoded contents of the App Store Connect `.p8` private key |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64-encoded `.p12` Apple Distribution certificate and private key |
| `IOS_DISTRIBUTION_CERTIFICATE_CER_BASE64` | Base64-encoded `.cer` Apple Distribution certificate matching the `.p12` private key |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password for the `.p12` distribution certificate |
| `SIGNING_KEYCHAIN_PASSWORD` | Temporary CI keychain password used while importing the distribution certificate |

Optional secrets:

| Secret | Purpose |
| --- | --- |
| `APPLE_ID` | Apple ID email used by fastlane metadata tools |
| `ITC_TEAM_ID` | App Store Connect provider/team ID if your account has more than one team |

To create `ASC_API_KEY_P8_BASE64` on macOS:

```sh
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

To create it on Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Set-Clipboard
```

To create `IOS_DISTRIBUTION_CERTIFICATE_BASE64` on Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios_distribution.p12")) | Set-Clipboard
```

To create `IOS_DISTRIBUTION_CERTIFICATE_CER_BASE64` on Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios_distribution.cer")) | Set-Clipboard
```

After the secrets are set:

1. Go to GitHub Actions.
2. Open `Upload to TestFlight`.
3. Choose `Run workflow`.
4. Wait for the uploaded build to appear in App Store Connect, then attach the build and subscriptions to version `1.0`.

The Bundle ID must already exist in Apple Developer, and the App Store Connect API key must have permission to manage apps and provisioning.

## Local Release Helpers

This repo includes:

- `LandscapeQuoteAI/Resources/PrivacyInfo.xcprivacy` for the app privacy manifest.
- `LandscapeQuoteAI/Resources/LandscapeQuoteAI.storekit` for local StoreKit product testing in Xcode.
- `ExportOptions.plist` for App Store Connect upload exports.
- `fastlane/Fastfile` with:
  - `fastlane ios ci_build` to run an unsigned simulator build in CI.
  - `fastlane ios metadata` to upload metadata only.
  - `fastlane ios beta` to archive and upload to TestFlight/App Store Connect from macOS.
  - `fastlane ios release_candidate` to run both.

Before using fastlane, set the relevant environment variables or GitHub Actions secrets described above.

## Current Local Limits

Codex prepared the repository, metadata, screenshots, and GitHub Actions automation. This Windows workspace still cannot create the App Store Connect app record or upload a binary directly because those steps require Apple Developer account access and macOS/Xcode signing tools, but the GitHub `Upload to TestFlight` workflow can do the macOS/Xcode build once the secrets are configured.
