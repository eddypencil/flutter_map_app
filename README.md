# MapExplorer

MapExplorer is a Flutter-based interactive map application that provides a seamless user experience for exploring and adding markers to a map. The app is fully responsive and optimized for mobile devices, ensuring smooth navigation and interactions on various screen sizes.

---

## Features

- **Real-time Location Tracking**: Automatically centers the map on the user's current location.
- **Add Markers**: Users can tap on the map to add custom markers with titles and descriptions.
- **Responsive Design**: Optimized for both small screens (mobile) and larger devices (tablets/desktops).
- **Interactive Marker Details**: View detailed information for markers via a bottom sheet.


---

## Screenshots

![Screenshot_1735038814-portrait](https://github.com/user-attachments/assets/58e5627f-a550-4cae-be3a-7ee56d9fe7e1 | width=400)
![Screenshot_1735038847-portrait](https://github.com/user-attachments/assets/187fc82f-6701-4967-8e7f-8893da2f8e0e | width=400)



---


## Usage

1. Open the app to see the map centered on your current location.
2. Tap on the map to open the "Add Marker" bottom sheet.
3. Fill in the marker title and description, then tap **Add Marker**.
4. Tap on existing markers to view their details in a bottom sheet.

---

## Code Highlights

### Main Components

- **Location Tracking**: Managed using `LocationCubit`.
- **Marker Management**: Markers are handled by `MarkersCubit`.
- **Responsive Map**:
  - Utilizes `MediaQuery` for adapting UI elements to screen sizes.
  - Dynamically resizes markers and zoom controls for mobile usability.

---

## Technologies Used

- **Flutter**: For building cross-platform UI.
- **flutter_map**: For integrating OpenStreetMap.
- **Bloc**: For state management.
- **latlong2**: For handling geolocation data.


Happy Mapping! 🌍

