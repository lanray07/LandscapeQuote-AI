# LandscapeQuote AI

LandscapeQuote AI is a SwiftUI MVP for landscaping contractors who need to turn rough measurements, site notes, and optional photos into professional client-ready estimates.

## Included

- SwiftUI iOS app with onboarding, dashboard, project library, settings, and paywall.
- SwiftData local persistence for projects, line items, photos, quote status, notes, and pricing.
- Local `MockAIQuoteService` with clean service boundaries for a future OpenAI-backed estimator.
- StoreKit 2 subscription manager using placeholder product IDs:
  - `landscapequote.pro.monthly`
  - `landscapequote.pro.yearly`
- PDF export service for client-ready quotes with terms, totals, and a signature line.
- Privacy wording for photos, client details, quote data, and Apple in-app purchase handling.

## MVP Notes

- Real computer vision, LiDAR measurement, and OpenAI integration are intentionally left as TODOs.
- No login is required.
- No external payment links are shown inside the iOS app.
- Photo uploads, PDF export, unlimited quotes, and AI upsells are treated as Pro features.

Open `LandscapeQuoteAI.xcodeproj` in Xcode and run the `LandscapeQuoteAI` scheme on an iPhone simulator or device.
