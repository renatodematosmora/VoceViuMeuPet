import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/services/storage_service.dart';
import 'package:voce_viu_meu_pet/features/auth/data/datasources/auth_datasource.dart';
import 'package:voce_viu_meu_pet/features/auth/data/models/profile_model.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGotrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  group('AuthDataSource', () {
    late MockSupabaseClient mockClient;
    late MockGotrueClient mockGotrueClient;
    late MockStorageService mockStorageService;
    late AuthDataSource authDataSource;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockGotrueClient = MockGotrueClient();
      mockStorageService = MockStorageService();
      when(() => mockClient.auth).thenReturn(mockGotrueClient);
      authDataSource = AuthDataSource(mockClient, mockStorageService);
    });

    test('signInWithEmail returns AuthResponse on success', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('123');
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(() => mockGotrueClient.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await authDataSource.signInWithEmail(email, password);

      // Assert
      expect(result, isNotNull);
      expect(result.user?.id, '123');
      verify(() => mockGotrueClient.signInWithPassword(
            email: email,
            password: password,
          )).called(1);
    });

    test('signInWithEmail throws exception on failure', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';

      when(() => mockGotrueClient.signInWithPassword(
            email: email,
            password: password,
          )).thenThrow(Exception('Invalid login'));

      // Act & Assert
      expect(
        () => authDataSource.signInWithEmail(email, password),
        throwsException,
      );
    });

    test('signUpWithEmail creates new user', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'password123';
      const fullName = 'New User';
      final mockUser = MockUser();
      final mockAuthResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('456');
      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(() => mockGotrueClient.signUp(
            email: email,
            password: password,
            data: {'full_name': fullName},
          )).thenAnswer((_) async => mockAuthResponse);

      // Act
      final result = await authDataSource.signUpWithEmail(
        email,
        password,
        fullName,
      );

      // Assert
      expect(result.user?.id, '456');
      verify(() => mockGotrueClient.signUp(
            email: email,
            password: password,
            data: {'full_name': fullName},
          )).called(1);
    });

    test('signUpWithEmail throws exception on failure', () async {
      // Arrange
      when(() => mockGotrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenThrow(Exception('Email already exists'));

      // Act & Assert
      expect(
        () => authDataSource.signUpWithEmail('test@example.com', 'pass', 'User'),
        throwsException,
      );
    });

    test('signOut calls auth signOut', () async {
      // Arrange
      when(() => mockGotrueClient.signOut()).thenAnswer((_) async {});

      // Act
      await authDataSource.signOut();

      // Assert
      verify(() => mockGotrueClient.signOut()).called(1);
    });

    test('currentUser returns current authenticated user', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('123');
      when(() => mockGotrueClient.currentUser).thenReturn(mockUser);

      // Act
      final result = authDataSource.currentUser;

      // Assert
      expect(result, isNotNull);
      expect(result?.id, '123');
    });

    test('currentSession returns current session', () {
      // Arrange
      final mockSession = MockSession();
      when(() => mockGotrueClient.currentSession).thenReturn(mockSession);

      // Act
      final result = authDataSource.currentSession;

      // Assert
      expect(result, isNotNull);
    });
  });
}
