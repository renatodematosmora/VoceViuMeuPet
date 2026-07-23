import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Você viu meu pet?'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In pt, this message translates to:
  /// **'Juntos encontramos cada um'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar-se'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @city.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get city;

  /// No description provided for @phone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get next;

  /// No description provided for @publish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get publish;

  /// No description provided for @petName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do animal'**
  String get petName;

  /// No description provided for @species.
  ///
  /// In pt, this message translates to:
  /// **'Espécie'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In pt, this message translates to:
  /// **'Raça'**
  String get breed;

  /// No description provided for @color.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get color;

  /// No description provided for @size.
  ///
  /// In pt, this message translates to:
  /// **'Porte'**
  String get size;

  /// No description provided for @age.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get age;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @reward.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa'**
  String get reward;

  /// No description provided for @lostDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do desaparecimento'**
  String get lostDate;

  /// No description provided for @location.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get location;

  /// No description provided for @sighting.
  ///
  /// In pt, this message translates to:
  /// **'Avistamento'**
  String get sighting;

  /// No description provided for @addSighting.
  ///
  /// In pt, this message translates to:
  /// **'Registrar avistamento'**
  String get addSighting;

  /// No description provided for @iSawThisAnimal.
  ///
  /// In pt, this message translates to:
  /// **'Vi este animal!'**
  String get iSawThisAnimal;

  /// No description provided for @petFound.
  ///
  /// In pt, this message translates to:
  /// **'Pet encontrado!'**
  String get petFound;

  /// No description provided for @closeListing.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar busca'**
  String get closeListing;

  /// No description provided for @activePets.
  ///
  /// In pt, this message translates to:
  /// **'Animais perdidos'**
  String get activePets;

  /// No description provided for @myPets.
  ///
  /// In pt, this message translates to:
  /// **'Meus animais'**
  String get myPets;

  /// No description provided for @notifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @feed.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get feed;

  /// No description provided for @map.
  ///
  /// In pt, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get noResults;

  /// No description provided for @errorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado. Tente novamente.'**
  String get errorGeneric;

  /// No description provided for @errorNoInternet.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com internet'**
  String get errorNoInternet;

  /// No description provided for @successSighting.
  ///
  /// In pt, this message translates to:
  /// **'Avistamento registrado! O dono foi notificado.'**
  String get successSighting;

  /// No description provided for @successPetPublished.
  ///
  /// In pt, this message translates to:
  /// **'Animal cadastrado! A comunidade vai ajudar!'**
  String get successPetPublished;

  /// No description provided for @dogLabel.
  ///
  /// In pt, this message translates to:
  /// **'Cachorro'**
  String get dogLabel;

  /// No description provided for @catLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gato'**
  String get catLabel;

  /// No description provided for @birdLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pássaro'**
  String get birdLabel;

  /// No description provided for @rabbitLabel.
  ///
  /// In pt, this message translates to:
  /// **'Coelho'**
  String get rabbitLabel;

  /// No description provided for @otherLabel.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get otherLabel;

  /// No description provided for @smallSize.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno'**
  String get smallSize;

  /// No description provided for @mediumSize.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get mediumSize;

  /// No description provided for @largeSize.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get largeSize;

  /// No description provided for @statusActive.
  ///
  /// In pt, this message translates to:
  /// **'Procurando'**
  String get statusActive;

  /// No description provided for @statusFound.
  ///
  /// In pt, this message translates to:
  /// **'Encontrado'**
  String get statusFound;

  /// No description provided for @statusClosed.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado'**
  String get statusClosed;

  /// No description provided for @daysLost.
  ///
  /// In pt, this message translates to:
  /// **'{days} dias desaparecido'**
  String daysLost(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
