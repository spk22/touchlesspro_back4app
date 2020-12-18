enum PopupOption { openingTimes, location, nearestLibraries, feedback }

class PopupMenuConstants {
  static const Map<PopupOption, String> optionsToString = {
    PopupOption.openingTimes: 'Opening Timings',
    PopupOption.location: 'Location',
    PopupOption.nearestLibraries: 'Nearby Libraries',
    PopupOption.feedback: 'Feedback',
  };

  static const List<PopupOption> choices = <PopupOption>[
    PopupOption.openingTimes,
    PopupOption.location,
    PopupOption.nearestLibraries,
    PopupOption.feedback
  ];
}
