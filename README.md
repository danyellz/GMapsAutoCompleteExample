# GMapsAutoCompleteExample
Created a Google Maps project that imitates Google's built-in autocomplete functionality, and allows user to select from addresses populated within a custom drop-down tableview. However, this functionality is achieved without the use of GMSPlacesClient: autoComplete SDK, but is instead manually parsed from the Places API endpoint. Locations selected from the results table are marked on a GMSMapView (multiple addresses can be selected and marked on the map).

1.) Navigate to the project directory in terminal

2.) Input $pod install to download Google Maps frameworks

3.) Warning: iOS versions below 9.0 may have issues crashing when loading the GMSMapView. To fix this, in Xcode navigate to Product/Scheme/Edit Scheme and switch rendering to OpenGL.
