Privacy Policy

Equiv is designed with a "privacy-first" approach. We believe that your data belongs to you, and our app is built to function with minimal external data requirements.

1. Data Collection and Tracking

No Personal Data Collection: Equiv does not collect, store, or transmit any personally identifiable information (PII).

No Tracking: The app does not include any third-party tracking or analytics SDKs. We do not track your location, device ID, or usage patterns.

2. Information Usage
   
Local Processing: All unit conversions (length, mass, temperature, etc.) are performed locally on your device using Apple's Foundation frameworks.

Currency Exchange Rates: To provide accurate currency conversions, the app periodically connects to the internet to fetch the latest exchange rates from the Open ER API (open.er-api.com). No user information or unique identifiers are sent during these requests.

3. Data Storage
   
On-Device Storage: Your conversion history and favourite categories are stored locally on your device using SwiftData and UserDefaults. This data is never uploaded to any external servers.

History Management: You can clear your entire conversion history at any time from within the app's settings.

4. System Integrations
   
Equiv utilises standard iOS features to enhance your experience, all of which operate within Apple's secure environment:

Widgets: Used to display your most recent conversions on your Home Screen

Spotlight: Used to allow you to search for unit categories directly from the iOS Home Screen.

App Groups: Used solely to share your latest conversion data between the main app and its widgets.

6. Third-Party Services

Open ER API: Currency data is provided by Open ER API. Their service receives a standard web request for exchange rate data but does not receive any data from the user.
