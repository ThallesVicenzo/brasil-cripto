import 'package:brasil_cripto/model/models/coin_animation_model.dart';
import 'package:brasil_cripto/view_model/falling_coins_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FallingCoinsViewModel Tests', () {
    late FallingCoinsViewModel viewModel;

    setUp(() {
      viewModel = FallingCoinsViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should initialize with correct default values', () {
      // Assert
      expect(viewModel.isInitialized, isFalse);
      expect(viewModel.controllers, isEmpty);
      expect(viewModel.animations, isEmpty);
      expect(viewModel.coins, isEmpty);
      expect(viewModel.screenWidth, equals(0));
      expect(viewModel.screenHeight, equals(0));
    });

    test('should update screen dimensions', () {
      // Arrange
      const width = 400.0;
      const height = 800.0;

      // Act
      viewModel.updateScreenDimensions(width, height);

      // Assert
      expect(viewModel.screenWidth, equals(width));
      expect(viewModel.screenHeight, equals(height));
    });

    test('should not update screen dimensions if same values', () {
      // Arrange
      const width = 400.0;
      const height = 800.0;
      viewModel.updateScreenDimensions(width, height);

      var notificationCount = 0;
      viewModel.addListener(() => notificationCount++);

      // Act
      viewModel.updateScreenDimensions(width, height);

      // Assert
      expect(notificationCount, equals(0));
    });

    test('should return invisible position for invalid index', () {
      // Act
      final position = viewModel.calculateCoinPosition(-1);

      // Assert
      expect(position.isVisible, isFalse);
      expect(position.x, equals(0));
      expect(position.y, equals(0));
    });

    test('should return invisible position for empty lists', () {
      // Act
      final position = viewModel.calculateCoinPosition(0);

      // Assert
      expect(position.isVisible, isFalse);
      expect(position.x, equals(0));
      expect(position.y, equals(0));
    });

    test('should dispose properly', () {
      // Arrange
      viewModel.addListener(() {});

      // Act
      viewModel.dispose();
      expect(() => viewModel.updateScreenDimensions(100, 200), returnsNormally);
      expect(() => viewModel.calculateCoinPosition(0), returnsNormally);
    });

    test('should handle multiple dispose calls safely', () {
      // Act & Assert
      expect(() {
        viewModel.dispose();
        viewModel.dispose();
      }, returnsNormally);
    });

    test('should handle keyboard visibility changes', () {
      // Arrange
      viewModel.updateScreenDimensions(400, 800);

      // Add some coins for testing
      for (int i = 0; i < 5; i++) {
        viewModel.coins.add(
          CoinAnimationModel(
            x: 0.5,
            size: 40,
            coinType: CoinType.bitcoin,
            rotationSpeed: 1.0,
          ),
        );
      }

      // Act - Show keyboard
      viewModel.setKeyboardVisibility(true);

      // Assert
      expect(viewModel.isKeyboardVisible, isTrue);
      expect(viewModel.activeCoinsCount, lessThan(viewModel.coins.length));

      // Act - Hide keyboard
      viewModel.setKeyboardVisibility(false);

      // Assert
      expect(viewModel.isKeyboardVisible, isFalse);
    });

    test('should reduce active coins count when keyboard is visible', () {
      // Arrange
      for (int i = 0; i < 10; i++) {
        viewModel.coins.add(
          CoinAnimationModel(
            x: 0.5,
            size: 40,
            coinType: CoinType.bitcoin,
            rotationSpeed: 1.0,
          ),
        );
      }

      // Act & Assert - Keyboard hidden
      viewModel.setKeyboardVisibility(false);
      expect(viewModel.activeCoinsCount, equals(10));

      // Act & Assert - Keyboard visible
      viewModel.setKeyboardVisibility(true);
      expect(viewModel.activeCoinsCount, equals(6)); // 60% of 10
    });

    test('should not change state if keyboard visibility is same', () {
      // Arrange
      var notificationCount = 0;
      viewModel.addListener(() => notificationCount++);
      viewModel.setKeyboardVisibility(true);
      notificationCount = 0;

      // Act - Set same visibility
      viewModel.setKeyboardVisibility(true);

      // Assert
      expect(notificationCount, equals(0));
    });
  });

  group('CoinPosition Tests', () {
    test('should create CoinPosition with correct values', () {
      // Arrange & Act
      const position = CoinPosition(
        x: 100,
        y: 200,
        isVisible: true,
        rotation: 1.5,
      );

      // Assert
      expect(position.x, equals(100));
      expect(position.y, equals(200));
      expect(position.isVisible, isTrue);
      expect(position.rotation, equals(1.5));
    });

    test('should have default rotation value', () {
      // Arrange & Act
      const position = CoinPosition(x: 100, y: 200, isVisible: true);

      // Assert
      expect(position.rotation, equals(0.0));
    });

    test('should implement equality correctly', () {
      // Arrange
      const position1 = CoinPosition(x: 100, y: 200, isVisible: true);
      const position2 = CoinPosition(x: 100, y: 200, isVisible: true);
      const position3 = CoinPosition(x: 100, y: 200, isVisible: false);

      // Assert
      expect(position1, equals(position2));
      expect(position1, isNot(equals(position3)));
    });

    test('should implement toString correctly', () {
      // Arrange
      const position = CoinPosition(
        x: 100,
        y: 200,
        isVisible: true,
        rotation: 1.5,
      );

      // Act
      final stringRepresentation = position.toString();

      // Assert
      expect(
        stringRepresentation,
        equals(
          'CoinPosition(x: 100.0, y: 200.0, isVisible: true, rotation: 1.5)',
        ),
      );
    });
  });
}
