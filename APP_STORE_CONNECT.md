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
- App privacy: Data Not Collected for this MVP, because photos, client details, quote notes, and project data are stored locally on-device and are not sent to a developer server.

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

Capture client details, site address, project type, rough measurements, and optional photos. The MVP includes a local quote generator that produces editable materials, labour, waste allowance, margin, timeline, upsell ideas, and contractor notes.

Build clean estimates for lawn mowing, artificial grass, patio paving, garden clearance, fencing, decking, hedge trimming, drainage, and full garden makeovers.

Key features:
- Create and save landscaping quotes locally
- Track draft, sent, approved, and rejected projects
- Edit line items, quantities, labour, markup, VAT/tax, discounts, and final price
- Export professional PDF quotes with terms and signature line
- Manage business profile, labour rate, profit margin, tax rate, and currency
- Upgrade to Pro for unlimited quotes, PDF export, photo uploads, and AI upsell suggestions

This MVP does not perform real computer vision measurement or send project photos to an external AI service.
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
LandscapeQuote AI is a SwiftUI MVP for contractors to create local landscaping estimates.

No login is required.
No external payment links are included.
Subscriptions use StoreKit 2.
The app stores client details, quote data, and project photos locally on-device for this MVP.
The current AI estimator is a local mock service. It does not send photos or client details to an external AI API.

Debug builds include a demo Pro access button on the paywall. Release builds do not include that debug-only control.
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
5. In Xcode on macOS, set the correct Apple Development Team.
6. Archive the `LandscapeQuoteAI` scheme.
7. Upload the archive to App Store Connect.
8. Fill screenshots, age rating, pricing, privacy questionnaire, and subscription availability.
9. Attach subscriptions to the first app version before submitting for review.

## Local Release Helpers

This repo includes:

- `LandscapeQuoteAI/Resources/PrivacyInfo.xcprivacy` for the app privacy manifest.
- `LandscapeQuoteAI/Resources/LandscapeQuoteAI.storekit` for local StoreKit product testing in Xcode.
- `ExportOptions.plist` for App Store Connect upload exports.
- `fastlane/Fastfile` with:
  - `fastlane ios metadata` to upload metadata only.
  - `fastlane ios beta` to archive and upload to TestFlight/App Store Connect from macOS.
  - `fastlane ios release_candidate` to run both.

Before using fastlane, fill in `fastlane/Appfile` with the Apple ID, Apple Developer Team ID, and App Store Connect team ID.

## Current Local Limits

Codex prepared the repository and metadata but cannot create the App Store Connect app record or upload a binary from this Windows workspace because those steps require Apple Developer account access and macOS/Xcode signing tools.
