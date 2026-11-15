import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latres/models/character.dart';
import 'package:latres/models/episode.dart';
import 'package:latres/models/user.dart';
import 'package:latres/services/database_helper.dart';
import 'package:latres/services/favorite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await DatabaseHelper.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Model Tests', () {
    test('Character.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin': {'name': 'Earth (C-137)', 'url': ''},
        'location': {'name': 'Citadel of Ricks', 'url': ''},
        'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        'episode': ['https://rickandmortyapi.com/api/episode/1'],
      };

      final character = Character.fromJson(json);

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, 'Alive');
      expect(character.species, 'Human');
      expect(character.gender, 'Male');
      expect(character.originName, 'Earth (C-137)');
      expect(character.locationName, 'Citadel of Ricks');
      expect(character.image, 'https://rickandmortyapi.com/api/character/avatar/1.jpeg');
      expect(character.episode.length, 1);

      final map = character.toJson();
      expect(map['id'], 1);
      expect(map['name'], 'Rick Sanchez');
    });

    test('Episode.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
        'characters': ['https://rickandmortyapi.com/api/character/1'],
        'url': 'https://rickandmortyapi.com/api/episode/1',
      };

      final episode = Episode.fromJson(json);

      expect(episode.id, 1);
      expect(episode.name, 'Pilot');
      expect(episode.airDate, 'December 2, 2013');
      expect(episode.episode, 'S01E01');
    });

    test('User.toMap and fromMap work correctly', () {
      final user = User(
        username: 'rick',
        password: 'password123',
        fullName: 'Rick Sanchez',
      );

      final map = user.toMap();
      expect(map['username'], 'rick');
      expect(map['full_name'], 'Rick Sanchez');

      final parsed = User.fromMap(map);
      expect(parsed.username, 'rick');
      expect(parsed.fullName, 'Rick Sanchez');
    });
  });

  group('Hive Local Database Tests (Modul 6)', () {
    test('Register and login user with Hive', () async {
      final db = DatabaseHelper.instance;

      final testUser = User(
        username: 'morty_test',
        password: 'password123',
        fullName: 'Morty Smith',
      );

      // Register
      await db.registerUser(testUser);
      expect(await db.isUsernameExists('morty_test'), isTrue);

      // Login success
      final loggedIn = await db.loginUser('morty_test', 'password123');
      expect(loggedIn, isNotNull);
      expect(loggedIn!.fullName, 'Morty Smith');

      // Login fail wrong password
      final wrongPass = await db.loginUser('morty_test', 'wrong');
      expect(wrongPass, isNull);
    });
  });

  group('FavoriteService Tests (Shared Preferences Modul 6)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('FavoriteService toggle and persistence', () async {
      final service = FavoriteService.instance;
      await service.init();

      final char = Character(
        id: 1,
        name: 'Rick Sanchez',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Male',
        originName: 'Earth',
        locationName: 'Earth',
        image: 'https://example.com/rick.png',
        episode: [],
      );

      // Initially not favorite
      expect(service.isFavorite(1), isFalse);

      // Toggle to add
      final added = await service.toggleFavorite(char);
      expect(added, isTrue);
      expect(service.isFavorite(1), isTrue);
      expect(service.favorites.length, 1);

      // Toggle to remove
      final removed = await service.toggleFavorite(char);
      expect(removed, isFalse);
      expect(service.isFavorite(1), isFalse);
      expect(service.favorites.isEmpty, isTrue);
    });
  });
}
