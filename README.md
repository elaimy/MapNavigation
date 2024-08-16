# iOS Navigation App

This iOS application allows users to input a starting and destination address and then displays the pedestrian route between these two locations on a Google Map. The app is built using Swift, Google Maps SDK, and Google Places SDK, and it demonstrates key features like real-time geocoding and route visualization.

### Prerequisites - Xcode 12 or later - CocoaPods (for managing dependencies)

### Installation Steps 1. Clone the repository: `git clone https://github.com/yourusername/ios-navigation-app.git` 2. Navigate to the project directory: `cd ios-navigation-app` 3. Install dependencies using CocoaPods: `pod install` 4. Open the project in Xcode: `open ios-navigation-app.xcworkspace` 5. Add your Google Maps API key to the project: - Open `AppDelegate.swift`. - Replace `"YOUR_API_KEY"` with your actual API key in: `GMSServices.provideAPIKey("YOUR_API_KEY")` `GMSPlacesClient.provideAPIKey("YOUR_API_KEY")` 6. Build and run the project on a simulator or connected device.

### Usage 1. Open the app on your device or simulator. 2. Enter a starting address in the first text field. 3. Enter a destination address in the second text field. 4. Tap the "Show Route" button. 5. The map will display the route between the two addresses, with markers indicating the start and destination points.

### Features - Display pedestrian routes on Google Maps. - Convert addresses to coordinates in real-time using Google Geocoding API. - Visualize routes on the map with custom markers for start and destination points. - Supports walking mode for route calculation.

### Technologies Used - Swift: The programming language used for iOS development. - Google Maps SDK: Provides the map functionality. - Google Places SDK: Used for geocoding and place searches. - UIKit: The UI framework for iOS.

### Contributing Contributions are welcome! If you have any improvements, suggestions, or bug fixes, please follow these steps: 1. Fork the repository. 2. Create a new branch (`git checkout -b feature-branch`). 3. Commit your changes (`git commit -am 'Add new feature'`). 4. Push to the branch (`git push origin feature-branch`). 5. Open a Pull Request.

### Acknowledgments - [Google Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk/overview) - For the map and geocoding services. - [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager) - For managing the keyboard appearance in the app. - Special thanks to all the contributors of open-source libraries used in this project.

### Created by [Ahmed Elelaimy]
