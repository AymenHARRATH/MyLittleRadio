# MyLittleRadio Test Project With TCA

## Overview
This README outlines the changes made in the project, detailing the skill development undertaken with the Swift Composable Architecture (TCA). It also highlights the decisions and trade-offs encountered during the implementation.

## Skills Development on TCA Architecture
To successfully implement the project, I engaged in skills development focused on the Swift Composable Architecture (TCA) using the following references:

### References
- [Swift Composable Architecture Tutorial](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/meetcomposablearchitecture)
- [Swift Composable Architecture GitHub Repository](https://github.com/pointfreeco/swift-composable-architecture)

## Features Implemented

- **API Call Management**: Replaced mock data with server API calls and refactored the `ApiManager` class for improved testability.
  
- **Station List View Development**: Created a view that displays a list of stations with the following features:
  - A loading indicator while fetching the stations list.
  - An alert shown in case of an API call failure, providing an option to retry the request.

- **Station Cell Information**:
  - Station image; if unavailable, a placeholder with the station's short title is displayed.
  - Title of the station.
  - Animation indicating the the stations is being played.
  - An icon to differentiate between music and non-music stations.
  - On tapping a station, a details page of the selected station is pushed to the navigation stack.

- **Station Detail Page**: Developed the station detail page and its corresponding `StationDetailsFeature` following TCA principles, including:
  - Station image.
  - Station title.
  - A play button to initiate playback of the station.
  - A loader that appears while the audio stream is loading.
  - An animation displayed during radio playback.
  - A custom back button that returns to the station list page and stops the player.

- **Player Client**: Created a player client as a dependency to isolate player-related logic and adhere to TCA architecture.

- **Unit Testing**: Implemented unit tests for both `StationsFeature` and `StationDetailsFeature`, as well as for the `ApiManager` dependency.

## Decisions

- **Stopping the Player on Back from the Detail Page**:
- A decision was made to keep the player active on the stations list view and indicate the currently playing station in its corresponding cell.

## Planned Tasks Not Achieved Due to Time Limitations

- Refactor and implement unit tests for the player manager (similar to what was done for the API manager).
- Develop advanced player functionalities such as pause and time-shifting for supported stations.
- Silence runtime warnings: `Perceptible state was accessed but is not being tracked`.
- Handle player manager errors.
- Etc...
