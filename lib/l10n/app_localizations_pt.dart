// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Você viu meu pet?';

  @override
  String get tagline => 'Juntos encontramos cada um';

  @override
  String get login => 'Entrar';

  @override
  String get register => 'Cadastrar-se';

  @override
  String get logout => 'Sair';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get fullName => 'Nome completo';

  @override
  String get city => 'Cidade';

  @override
  String get phone => 'Telefone';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get next => 'Próximo';

  @override
  String get publish => 'Publicar';

  @override
  String get petName => 'Nome do animal';

  @override
  String get species => 'Espécie';

  @override
  String get breed => 'Raça';

  @override
  String get color => 'Cor';

  @override
  String get size => 'Porte';

  @override
  String get age => 'Idade';

  @override
  String get description => 'Descrição';

  @override
  String get reward => 'Recompensa';

  @override
  String get lostDate => 'Data do desaparecimento';

  @override
  String get location => 'Localização';

  @override
  String get sighting => 'Avistamento';

  @override
  String get addSighting => 'Registrar avistamento';

  @override
  String get iSawThisAnimal => 'Vi este animal!';

  @override
  String get petFound => 'Pet encontrado!';

  @override
  String get closeListing => 'Encerrar busca';

  @override
  String get activePets => 'Animais perdidos';

  @override
  String get myPets => 'Meus animais';

  @override
  String get notifications => 'Notificações';

  @override
  String get profile => 'Perfil';

  @override
  String get feed => 'Início';

  @override
  String get map => 'Mapa';

  @override
  String get search => 'Buscar';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String get errorGeneric => 'Erro inesperado. Tente novamente.';

  @override
  String get errorNoInternet => 'Sem conexão com internet';

  @override
  String get successSighting =>
      'Avistamento registrado! O dono foi notificado.';

  @override
  String get successPetPublished =>
      'Animal cadastrado! A comunidade vai ajudar!';

  @override
  String get dogLabel => 'Cachorro';

  @override
  String get catLabel => 'Gato';

  @override
  String get birdLabel => 'Pássaro';

  @override
  String get rabbitLabel => 'Coelho';

  @override
  String get otherLabel => 'Outro';

  @override
  String get smallSize => 'Pequeno';

  @override
  String get mediumSize => 'Médio';

  @override
  String get largeSize => 'Grande';

  @override
  String get statusActive => 'Procurando';

  @override
  String get statusFound => 'Encontrado';

  @override
  String get statusClosed => 'Encerrado';

  @override
  String daysLost(int days) {
    return '$days dias desaparecido';
  }
}
