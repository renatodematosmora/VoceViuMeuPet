import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/features/auth/data/datasources/auth_datasource.dart';
import 'package:voce_viu_meu_pet/features/auth/data/models/profile_model.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/providers/auth_provider.dart'
    as auth_provider_module;

// Mock classes
class MockAuthDataSource extends Mock implements AuthDataSource {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthNotifier', () {
    late MockAuthDataSource mockAuthDataSource;
    late auth_provider_module.AuthNotifier authNotifier;

    setUp(() {
      mockAuthDataSource = MockAuthDataSource();

      // Mock currentUser
      when(() => mockAuthDataSource.currentUser).thenReturn(null);

      authNotifier = auth_provider_module.AuthNotifier(mockAuthDataSource);
    });

    test('initial state is AuthState with default values', () {
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.profile, isNull);
      expect(authNotifier.state.error, isNull);
    });

    test('signIn with valid credentials succeeds', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();
      final mockProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        fullName: 'Test User',
        avatarUrl: null,
        city: null,
        phone: null,
        createdAt: DateTime.now(),
      );

      when(() => mockUser.id).thenReturn('123');
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(() => mockAuthDataSource.signInWithEmail(email, password))
          .thenAnswer((_) async => mockAuthResponse);
      when(() => mockAuthDataSource.fetchProfile('123'))
          .thenAnswer((_) async => mockProfile);

      // Act
      final error = await authNotifier.signIn(email: email, password: password);

      // Assert
      expect(error, isNull);
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.profile, isNotNull);
      expect(authNotifier.state.profile?.id, '123');
      verify(() => mockAuthDataSource.signInWithEmail(email, password)).called(1);
    });

    test('signIn with invalid credentials sets error', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';

      when(() => mockAuthDataSource.signInWithEmail(email, password))
          .thenThrow(Exception('Invalid login'));

      // Act
      final error = await authNotifier.signIn(email: email, password: password);

      // Assert
      expect(error, isNotNull);
      expect(authNotifier.state.isLoading, false);
    });

    test('signUp creates new user and loads profile', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'password123';
      const fullName = 'New User';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();
      final mockProfile = ProfileModel(
        id: '456',
        username: 'newuser',
        fullName: fullName,
        avatarUrl: null,
        city: null,
        phone: null,
        createdAt: DateTime.now(),
      );

      when(() => mockUser.id).thenReturn('456');
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(() => mockAuthDataSource.signUpWithEmail(email, password, fullName))
          .thenAnswer((_) async => mockAuthResponse);
      when(() => mockAuthDataSource.fetchProfile('456'))
          .thenAnswer((_) async => mockProfile);

      // Act
      final error = await authNotifier.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Assert
      expect(error, isNull);
      expect(authNotifier.state.profile?.id, '456');
      verify(() => mockAuthDataSource.signUpWithEmail(email, password, fullName))
          .called(1);
    });

    test('signOut clears user state', () async {
      // Arrange
      final mockProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        fullName: 'Test User',
        avatarUrl: null,
        city: null,
        phone: null,
        createdAt: DateTime.now(),
      );
      authNotifier = auth_provider_module.AuthNotifier(mockAuthDataSource)
        ..state = auth_provider_module.AuthState(profile: mockProfile);

      when(() => mockAuthDataSource.signOut()).thenAnswer((_) async {});

      // Act
      await authNotifier.signOut();

      // Assert
      expect(authNotifier.state.profile, isNull);
      expect(authNotifier.state.isLoading, false);
      verify(() => mockAuthDataSource.signOut()).called(1);
    });

    test('signInWithGoogle handles OAuth', () async {
      // Arrange
      when(() => mockAuthDataSource.signInWithGoogle())
          .thenAnswer((_) async => true);

      // Act
      final error = await authNotifier.signInWithGoogle();

      // Assert
      expect(error, isNull);
      expect(authNotifier.state.isLoading, false);
      verify(() => mockAuthDataSource.signInWithGoogle()).called(1);
    });

    test('error parsing for network error', () async {
      // Arrange
      when(() => mockAuthDataSource.signInWithEmail(any(), any()))
          .thenThrow(Exception('network error'));

      // Act
      final error = await authNotifier.signIn(
        email: 'test@example.com',
        password: 'password',
      );

      // Assert
      expect(error, contains('conexão'));
    });

    test('error parsing for weak password', () async {
      // Arrange
      when(() => mockAuthDataSource.signUpWithEmail(any(), any(), any()))
          .thenThrow(Exception('weak password'));

      // Act
      final error = await authNotifier.signUp(
        email: 'test@example.com',
        password: '123',
        fullName: 'Test',
      );

      // Assert
      expect(error, contains('fraca'));
    });
  });
}
