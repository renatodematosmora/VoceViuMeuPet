// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Have you seen my pet?';

  @override
  String get tagline => 'Together we find them all';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get logout => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get city => 'City';

  @override
  String get phone => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get next => 'Next';

  @override
  String get publish => 'Publish';

  @override
  String get petName => 'Pet Name';

  @override
  String get species => 'Species';

  @override
  String get breed => 'Breed';

  @override
  String get color => 'Color';

  @override
  String get size => 'Size';

  @override
  String get age => 'Age';

  @override
  String get description => 'Description';

  @override
  String get reward => 'Reward';

  @override
  String get lostDate => 'Date Lost';

  @override
  String get location => 'Location';

  @override
  String get sighting => 'Sighting';

  @override
  String get addSighting => 'Report Sighting';

  @override
  String get iSawThisAnimal => 'I saw this animal!';

  @override
  String get petFound => 'Pet Found!';

  @override
  String get closeListing => 'Close Search';

  @override
  String get activePets => 'Lost Animals';

  @override
  String get myPets => 'My Pets';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get feed => 'Home';

  @override
  String get map => 'Map';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String get errorGeneric => 'Unexpected error. Please try again.';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get successSighting =>
      'Sighting reported! The owner has been notified.';

  @override
  String get successPetPublished => 'Pet registered! The community will help!';

  @override
  String get dogLabel => 'Dog';

  @override
  String get catLabel => 'Cat';

  @override
  String get birdLabel => 'Bird';

  @override
  String get rabbitLabel => 'Rabbit';

  @override
  String get otherLabel => 'Other';

  @override
  String get smallSize => 'Small';

  @override
  String get mediumSize => 'Medium';

  @override
  String get largeSize => 'Large';

  @override
  String get statusActive => 'Searching';

  @override
  String get statusFound => 'Found';

  @override
  String get statusClosed => 'Closed';

  @override
  String daysLost(int days) {
    return 'Missing for $days days';
  }
}
