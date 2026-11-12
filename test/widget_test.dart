import 'dart:convert';

import 'package:api_appsmoviles/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _itemsJson = '''
[
  {"id": 1, "name": "diamond", "displayName": "Diamond", "stackSize": 64},
  {"id": 2, "name": "diamond_pickaxe", "displayName": "Diamond Pickaxe", "stackSize": 1},
  {"id": 3, "name": "stick", "displayName": "Stick", "stackSize": 64},
  {"id": 4, "name": "oak_planks", "displayName": "Oak Planks", "stackSize": 64},
  {"id": 5, "name": "chest", "displayName": "Chest", "stackSize": 64},
  {"id": 6, "name": "netherite_pickaxe", "displayName": "Netherite Pickaxe", "stackSize": 1},
  {"id": 7, "name": "netherite_upgrade_smithing_template", "displayName": "Netherite Upgrade", "stackSize": 64},
  {"id": 8, "name": "netherite_ingot", "displayName": "Netherite Ingot", "stackSize": 64},
  {"id": 9, "name": "oak_log", "displayName": "Oak Log", "stackSize": 64},
  {"id": 10, "name": "shield", "displayName": "Shield", "stackSize": 1}
]
''';

const _recipesJson = '''
{
  "2": [
    {
      "inShape": [
        [1, 1, 1],
        [null, 3, null],
        [null, 3, null]
      ],
      "result": {"id": 2, "count": 1}
    }
  ],
  "3": [
    {
      "inShape": [
        [4],
        [4]
      ],
      "result": {"id": 3, "count": 4}
    }
  ]
}
''';

void main() {
  group('MinecraftService', () {
    test('consulta el catálogo y las recetas usando solo GET', () async {
      final client = _FakeClient({
        'items.json': _itemsJson,
        'recipes.json': _recipesJson,
      });

      final catalog = await MinecraftService(client: client).fetchCatalog();

      expect(client.methods, ['GET', 'GET']);
      expect(
        client.urls.every((uri) => uri.host == 'raw.githubusercontent.com'),
        isTrue,
      );
      expect(
        client.urls.any((uri) => uri.path.endsWith('/items.json')),
        isTrue,
      );
      expect(
        client.urls.any((uri) => uri.path.endsWith('/recipes.json')),
        isTrue,
      );
      expect(catalog.items.map((item) => item.name), [
        'oak_planks',
        'stick',
        'chest',
        'diamond',
        'diamond_pickaxe',
        'netherite_pickaxe',
        'shield',
      ]);
      expect(
        catalog.items.singleWhere((item) => item.name == 'diamond').displayName,
        'Diamond',
      );
      final diamond = catalog.items.singleWhere(
        (item) => item.name == 'diamond',
      );
      expect(diamond.imageUrl, contains('/items/diamond.png'));
      final chest = catalog.items.singleWhere((item) => item.name == 'chest');
      expect(chest.localImageAsset, 'assets/items/chest.png');
      final shield = catalog.items.singleWhere((item) => item.name == 'shield');
      expect(shield.localImageAsset, 'assets/items/shield.png');
      final oakLog = catalog.itemsById[9]!;
      expect(oakLog.imageUrl, contains('/items/oak_log.png'));
      expect(oakLog.blockImageUrl, contains('/blocks/oak_log.png'));
      expect(
        catalog.items.every(
          (item) => item.imageUrl.startsWith(
            'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/',
          ),
        ),
        isTrue,
      );
    });

    test(
      'convierte la receta de una herramienta en una cuadrícula 3x3',
      () async {
        final client = _FakeClient({
          'items.json': _itemsJson,
          'recipes.json': _recipesJson,
        });
        final catalog = await MinecraftService(client: client).fetchCatalog();
        final pickaxe = catalog.items.singleWhere(
          (item) => item.name == 'diamond_pickaxe',
        );
        final recipe = catalog.recipeFor(pickaxe);

        expect(recipe, isNotNull);
        expect(recipe!.outputCount, 1);
        expect(recipe.slots, [
          [1, 1, 1],
          [null, 3, null],
          [null, 3, null],
        ]);
        expect(catalog.itemsById[recipe.slots[0][0]!]!.displayName, 'Diamond');
      },
    );

    test('representa recetas pequeñas centradas en la mesa 3x3', () async {
      final client = _FakeClient({
        'items.json': _itemsJson,
        'recipes.json': _recipesJson,
      });
      final catalog = await MinecraftService(client: client).fetchCatalog();
      final stick = catalog.items.singleWhere((item) => item.name == 'stick');
      final recipe = catalog.recipeFor(stick);

      expect(recipe!.outputCount, 4);
      expect(recipe.slots, [
        [null, 4, null],
        [null, 4, null],
        [null, null, null],
      ]);
    });

    test('muestra la mejora de netherita en la mesa de herrería', () async {
      final client = _FakeClient({
        'items.json': _itemsJson,
        'recipes.json': _recipesJson,
      });
      final catalog = await MinecraftService(client: client).fetchCatalog();
      final pickaxe = catalog.items.singleWhere(
        (item) => item.name == 'netherite_pickaxe',
      );
      final recipe = catalog.recipeFor(pickaxe);

      expect(recipe, isNotNull);
      expect(recipe!.stationName, 'la mesa de herrería');
      expect(recipe.outputCount, 1);
      expect(recipe.slots, [
        [7, 2, 8],
      ]);
    });

    test('informa los errores HTTP sin ocultarlos como listas vacías', () {
      final client = _FakeClient({
        'items.json': 'Error',
        'recipes.json': '{}',
      }, statusCode: 503);

      expect(
        MinecraftService(client: client).fetchCatalog(),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  testWidgets('muestra objetos y abre el detalle con su receta visual', (
    tester,
  ) async {
    final service = MinecraftService(
      client: _FakeClient({
        'items.json': _itemsJson,
        'recipes.json': _recipesJson,
      }),
    );
    await tester.pumpWidget(MyApp(minecraftService: service));
    await tester.pumpAndSettle();

    expect(find.text('PrismarineJS'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Diamond Pickaxe'), findsOneWidget);
    expect(
      find.text('Pico de gran durabilidad para minería avanzada.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Diamond Pickaxe'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle del objeto'), findsOneWidget);
    expect(find.text('Uso en Minecraft'), findsOneWidget);
    expect(
      find.text(
        'Extrae obsidiana y una amplia variedad de minerales con rapidez.',
      ),
      findsOneWidget,
    );
    expect(find.text('CÓMO FABRICARLO'), findsOneWidget);
    expect(
      find.text('Cada cuadro representa un espacio de la mesa de trabajo.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra el error de la API y permite reintentar', (
    tester,
  ) async {
    final client = _FakeClient({
      'items.json': 'Error',
      'recipes.json': '{}',
    }, statusCode: 503);
    await tester.pumpWidget(
      MyApp(minecraftService: MinecraftService(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar los objetos'), findsOneWidget);
    expect(find.textContaining('503'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}

class _FakeClient extends http.BaseClient {
  _FakeClient(this.responses, {this.statusCode = 200});

  final Map<String, String> responses;
  final int statusCode;
  final List<String> methods = [];
  final List<Uri> urls = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    methods.add(request.method);
    urls.add(request.url);
    final fileName = request.url.pathSegments.last;
    final response = responses[fileName];
    if (response == null) {
      throw StateError('No hay respuesta de prueba para ${request.url}.');
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(response)),
      statusCode,
      request: request,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
