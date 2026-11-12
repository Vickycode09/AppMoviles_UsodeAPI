import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _appTitle = 'PrismarineJS';

void main() {
  runApp(const MyApp());
}

const _alternativeItemImages = <String, String>{
  'oak_planks':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/oak_planks.png',
  'torch':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/torch.png',
  'anvil':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/anvil.png',
  'obsidian':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/obsidian.png',
  'crafting_table':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/crafting_table_front.png',
  'furnace':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/furnace_front.png',
  'compass':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/items/compass_00.png',
  'enchanting_table':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/enchanting_table_top.png',
  'clock':
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/items/clock_00.png',
};

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.minecraftService});

  final MinecraftService? minecraftService;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF387A3B);

    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        scaffoldBackgroundColor: const Color(0xFFF4F6F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F6F1),
          centerTitle: false,
        ),
      ),
      home: ItemsPage(minecraftService: minecraftService ?? MinecraftService()),
    );
  }
}

class MinecraftItem {
  const MinecraftItem({
    required this.id,
    required this.name,
    required String displayName,
  }) : _apiDisplayName = displayName;

  factory MinecraftItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final displayName = json['displayName'];

    if (id is! int || name is! String || displayName is! String) {
      throw const FormatException(
        'Un objeto de Minecraft tiene campos con formato inválido.',
      );
    }

    return MinecraftItem(id: id, name: name, displayName: displayName);
  }

  final int id;
  final String name;
  final String _apiDisplayName;

  String get imageUrl =>
      _alternativeItemImages[name] ??
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
          'master/data/${MinecraftService.version}/items/$name.png';

  String get blockImageUrl =>
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-assets/'
      'master/data/${MinecraftService.version}/blocks/$name.png';

  String? get localImageAsset => switch (name) {
    'chest' => 'assets/items/chest.png',
    'shield' => 'assets/items/shield.png',
    _ => null,
  };

  String get displayName => _apiDisplayName;
}

class ItemDetails {
  const ItemDetails({
    required this.summary,
    required this.description,
    required this.use,
    this.obtainedFrom,
  });

  final String summary;
  final String description;
  final String use;
  final String? obtainedFrom;
}

const _itemDetails = <String, ItemDetails>{
  'oak_planks': ItemDetails(
    summary: 'Bloques de madera procesada para construir y fabricar.',
    description: 'Se obtienen al colocar troncos de roble en la cuadrícula de fabricación.',
    use:
        'Se usan para construir estructuras y fabricar mesas, cofres, palos y '
        'muchos otros objetos.',
  ),
  'stick': ItemDetails(
    summary: 'Material básico para herramientas, armas y antorchas.',
    description:
        'Palo fabricado con tablones de madera y utilizado como componente '
        'en numerosas recetas.',
    use:
        'Forma los mangos de picos, espadas y arcos, y permite fabricar '
        'antorchas y herramientas.',
  ),
  'crafting_table': ItemDetails(
    summary: 'Amplía la fabricación a una cuadrícula de tres por tres.',
    description:
        'Bloque de trabajo fabricado con cuatro tablones de cualquier tipo '
        'de madera.',
    use:
        'Permite fabricar herramientas, bloques y objetos cuyas recetas '
        'necesitan más de cuatro espacios.',
  ),
  'torch': ItemDetails(
    summary: 'Fuente de luz portátil para cuevas y construcciones.',
    description: 'Se fabrica combinando un palo con carbón o carbón vegetal.',
    use:
        'Ilumina espacios oscuros y ayuda a evitar la aparición de criaturas '
        'hostiles en zonas iluminadas.',
  ),
  'chest': ItemDetails(
    summary: 'Contenedor para guardar bloques y objetos.',
    description:
        'Cofre fabricado con ocho tablones colocados alrededor del espacio '
        'central de la cuadrícula.',
    use:
        'Guarda objetos; dos cofres juntos forman un cofre doble con más '
        'espacio de almacenamiento.',
  ),
  'furnace': ItemDetails(
    summary: 'Bloque que funde minerales y cocina alimentos.',
    description: 'Horno fabricado con ocho bloques de roca, como adoquín.',
    use:
        'Usa combustible para fundir minerales, cocinar alimentos y '
        'procesar otros materiales.',
  ),
  'iron_ingot': ItemDetails(
    summary: 'Lingote metálico utilizado en equipos y mecanismos.',
    description:
        'Material de fabricación que se obtiene principalmente al fundir '
        'mineral de hierro.',
    use:
        'Se usa para fabricar herramientas, armaduras, cubos, escudos, '
        'yunques y componentes de redstone.',
    obtainedFrom: 'También puedes obtenerlo fundiendo mineral de hierro.',
  ),
  'gold_ingot': ItemDetails(
    summary: 'Lingote brillante utilizado en recetas y trueques.',
    description:
        'Metal que se obtiene al fundir mineral de oro o al procesar '
        'materiales de oro.',
    use:
        'Sirve para fabricar objetos de oro, manzanas doradas, relojes y '
        'otros componentes.',
    obtainedFrom: 'También puedes obtenerlo fundiendo mineral de oro.',
  ),
  'diamond': ItemDetails(
    summary: 'Gema rara para fabricar equipo resistente.',
    description:
        'Recurso valioso que se encuentra al extraer mineral de diamante '
        'con un pico adecuado.',
    use:
        'Permite fabricar herramientas, armas, armadura y mesas de '
        'encantamientos.',
    obtainedFrom:
        'Se extrae de las menas de diamante que aparecen bajo tierra.',
  ),
  'emerald': ItemDetails(
    summary: 'Gema utilizada principalmente para comerciar.',
    description:
        'Recurso poco común asociado a las aldeas y a las ofertas de sus '
        'habitantes.',
    use: 'Se intercambia con aldeanos por objetos, alimentos y otros recursos.',
    obtainedFrom:
        'Se encuentra al extraer mineral de esmeralda o comerciar '
        'con aldeanos.',
  ),
  'coal': ItemDetails(
    summary: 'Combustible común para hornos y antorchas.',
    description:
        'Material que se obtiene al extraer mineral de carbón con un pico.',
    use: 'Alimenta hornos y se combina con un palo para fabricar antorchas.',
    obtainedFrom: 'Se extrae de las menas de carbón.',
  ),
  'lapis_lazuli': ItemDetails(
    summary: 'Material azul necesario para encantar equipo.',
    description: 'Recurso azul que se obtiene al minar mineral de lapislázuli.',
    use: 'Se consume al aplicar encantamientos en una mesa de encantamientos.',
    obtainedFrom: 'Se obtiene al extraer mineral de lapislázuli.',
  ),
  'redstone': ItemDetails(
    summary: 'Polvo conductor para circuitos y mecanismos.',
    description:
        'Recurso de mineral que sirve para transmitir señales de redstone.',
    use:
        'Se usa en circuitos, mecanismos, repetidores, brújulas y recetas '
        'de automatización.',
    obtainedFrom: 'Se obtiene al minar mineral de redstone.',
  ),
  'wooden_pickaxe': ItemDetails(
    summary: 'Pico inicial para extraer los primeros bloques.',
    description: 'Herramienta fabricada con tres tablones y dos palos.',
    use:
        'Permite empezar a extraer roca y otros bloques; tiene menos '
        'durabilidad que los picos de piedra o metal.',
  ),
  'stone_pickaxe': ItemDetails(
    summary: 'Pico resistente para extraer minerales básicos.',
    description: 'Herramienta de tres bloques de roca y dos palos.',
    use:
        'Permite extraer hierro, lapislázuli y otros recursos que un pico '
        'de madera no puede recoger.',
  ),
  'iron_pickaxe': ItemDetails(
    summary: 'Pico versátil para minar minerales valiosos.',
    description:
        'Herramienta fabricada con tres lingotes de hierro y dos palos.',
    use:
        'Permite extraer diamantes, oro, redstone y otros minerales '
        'resistentes.',
  ),
  'diamond_pickaxe': ItemDetails(
    summary: 'Pico de gran durabilidad para minería avanzada.',
    description: 'Herramienta fabricada con tres diamantes y dos palos.',
    use: 'Extrae obsidiana y una amplia variedad de minerales con rapidez.',
  ),
  'netherite_pickaxe': ItemDetails(
    summary: 'Pico avanzado resistente al fuego y muy duradero.',
    description:
        'Herramienta de netherita que se obtiene mejorando un pico de '
        'diamante en una mesa de herrería.',
    use:
        'Se utiliza para minería avanzada y conserva su durabilidad al '
        'caer en lava.',
    obtainedFrom:
        'Mejora un pico de diamante en una mesa de herrería con '
        'una plantilla de mejora y un lingote de netherita.',
  ),
  'wooden_sword': ItemDetails(
    summary: 'Arma básica para los primeros combates.',
    description: 'Espada fabricada con dos tablones de madera y un palo.',
    use: 'Se usa para atacar criaturas y otros objetivos cuerpo a cuerpo.',
  ),
  'iron_sword': ItemDetails(
    summary: 'Arma de hierro eficaz para el combate cuerpo a cuerpo.',
    description: 'Espada fabricada con dos lingotes de hierro y un palo.',
    use: 'Inflige más daño y dura más que una espada de madera o de piedra.',
  ),
  'diamond_sword': ItemDetails(
    summary: 'Arma de diamante potente y muy duradera.',
    description: 'Espada fabricada con dos diamantes y un palo.',
    use:
        'Sirve para combatir criaturas y otros enemigos; puede mejorarse '
        'a netherita en una mesa de herrería.',
  ),
  'shield': ItemDetails(
    summary: 'Equipo defensivo para bloquear ataques.',
    description:
        'Escudo fabricado con tablones de madera y un lingote de hierro.',
    use:
        'Al levantarlo bloquea muchos ataques y proyectiles que vienen de '
        'frente.',
  ),
  'bow': ItemDetails(
    summary: 'Arma a distancia que se utiliza con flechas.',
    description: 'Arco fabricado con tres palos y tres unidades de cuerda.',
    use:
        'Permite atacar desde lejos; cuanto más se tensa, más lejos y fuerte '
        'viaja la flecha.',
  ),
  'arrow': ItemDetails(
    summary: 'Proyectil para arcos y ballestas.',
    description: 'Flecha fabricada con un pedernal, un palo y una pluma.',
    use: 'Se dispara con un arco o una ballesta para atacar a distancia.',
  ),
  'bread': ItemDetails(
    summary: 'Alimento fabricado con trigo.',
    description:
        'Pan preparado en una mesa de fabricación con tres unidades de trigo.',
    use: 'Se consume para recuperar hambre durante la exploración.',
    obtainedFrom: 'También puedes conseguirlo mediante cultivo o comercio.',
  ),
  'golden_apple': ItemDetails(
    summary: 'Alimento especial que concede efectos beneficiosos.',
    description: 'Manzana preparada con una manzana y lingotes de oro.',
    use: 'Al comerla proporciona absorción y regeneración temporal.',
  ),
  'bucket': ItemDetails(
    summary: 'Recipiente para transportar líquidos y criaturas acuáticas.',
    description: 'Cubo de hierro fabricado con tres lingotes.',
    use: 'Sirve para recoger y colocar agua, lava y leche, entre otros usos.',
  ),
  'compass': ItemDetails(
    summary: 'Instrumento que señala el punto de aparición del mundo.',
    description:
        'Brújula fabricada con lingotes de hierro y polvo de redstone.',
    use:
        'Su aguja indica el punto de aparición del mundo o el imán al que '
        'se haya vinculado.',
  ),
  'enchanting_table': ItemDetails(
    summary: 'Bloque de trabajo para aplicar encantamientos.',
    description: 'Mesa fabricada con diamantes, obsidiana y un libro.',
    use:
        'Permite encantar herramientas, armas y armaduras usando niveles '
        'de experiencia y lapislázuli.',
  ),
  'anvil': ItemDetails(
    summary: 'Bloque para reparar, combinar y renombrar objetos.',
    description: 'Yunque fabricado con bloques y lingotes de hierro.',
    use:
        'Combina encantamientos, repara equipo y permite cambiar el nombre '
        'de objetos a cambio de experiencia.',
  ),
  'elytra': ItemDetails(
    summary: 'Alas que permiten planear desde lugares elevados.',
    description:
        'Equipo poco común que se encuentra en barcos de las ciudades del End.',
    use:
        'Al planear, los cohetes de fuegos artificiales permiten ganar '
        'velocidad y recorrer grandes distancias.',
    obtainedFrom: 'Se encuentra en los barcos de las ciudades del End.',
  ),
  'obsidian': ItemDetails(
    summary: 'Bloque resistente que se forma cuando el agua toca lava.',
    description:
        'Bloque duro que requiere un pico de diamante o de netherita para '
        'obtenerse.',
    use:
        'Se emplea para construir portales al Nether y mesas de '
        'encantamientos.',
    obtainedFrom:
        'Se forma al hacer que el agua fluya sobre un bloque de lava.',
  ),
  'fishing_rod': ItemDetails(
    summary: 'Herramienta para pescar y atraer objetos del agua.',
    description: 'Caña fabricada con tres palos y dos unidades de cuerda.',
    use: 'Se usa para pescar, recoger tesoros y atraer algunas criaturas.',
  ),
  'clock': ItemDetails(
    summary: 'Muestra si es de día o de noche.',
    description: 'Reloj fabricado con lingotes de oro y polvo de redstone.',
    use:
        'Su indicador permite conocer el ciclo del día y la noche, incluso '
        'cuando estás bajo tierra.',
  ),
};

class MinecraftRecipe {
  const MinecraftRecipe({
    required this.slots,
    required this.outputCount,
    this.stationName = 'la mesa de trabajo',
  });

  factory MinecraftRecipe.fromJson(
    Map<String, dynamic> json,
    Map<int, MinecraftItem> itemsById,
  ) {
    final result = json['result'];
    if (result is! Map<String, dynamic> ||
        result['id'] is! int ||
        result['count'] is! int) {
      throw const FormatException('Una receta tiene un resultado inválido.');
    }

    final grid = List<List<int?>>.generate(
      3,
      (_) => List<int?>.filled(3, null),
    );
    final shape = json['inShape'];
    final ingredients = json['ingredients'];

    if (shape is List<dynamic>) {
      final parsedShape = shape
          .map((row) {
            if (row is! List<dynamic>) {
              throw const FormatException(
                'La cuadrícula de receta no es válida.',
              );
            }
            return row.map(_readIngredientId).toList(growable: false);
          })
          .toList(growable: false);
      final width = parsedShape.fold<int>(
        0,
        (largest, row) => row.length > largest ? row.length : largest,
      );
      final rowOffset = ((3 - parsedShape.length) / 2).floor();
      final columnOffset = ((3 - width) / 2).floor();

      for (
        var row = 0;
        row < parsedShape.length && row + rowOffset < 3;
        row++
      ) {
        for (
          var column = 0;
          column < parsedShape[row].length && column + columnOffset < 3;
          column++
        ) {
          grid[row + rowOffset][column + columnOffset] =
              parsedShape[row][column];
        }
      }
    } else if (ingredients is List<dynamic>) {
      var index = 0;
      for (final ingredient in ingredients) {
        final itemId = _readIngredientId(ingredient);
        if (itemId == null || !itemsById.containsKey(itemId)) continue;
        if (index >= 9) break;
        grid[index ~/ 3][index % 3] = itemId;
        index++;
      }
    } else {
      throw const FormatException(
        'La receta no contiene ingredientes válidos.',
      );
    }

    return MinecraftRecipe(slots: grid, outputCount: result['count'] as int);
  }

  final List<List<int?>> slots;
  final int outputCount;
  final String stationName;

  static int? _readIngredientId(dynamic value) {
    if (value is int) return value;
    if (value is Map<String, dynamic>) {
      return _readIngredientId(value['id']);
    }
    if (value is List<dynamic>) {
      for (final candidate in value) {
        final id = _readIngredientId(candidate);
        if (id != null) return id;
      }
    }
    return null;
  }
}

class MinecraftCatalog {
  const MinecraftCatalog({
    required this.items,
    required this.itemsById,
    required this.recipes,
  });

  final List<MinecraftItem> items;
  final Map<int, MinecraftItem> itemsById;
  final Map<String, dynamic> recipes;

  MinecraftRecipe? recipeFor(MinecraftItem item) {
    final rawRecipes = recipes['${item.id}'];
    if (rawRecipes is List<dynamic>) {
      for (final rawRecipe in rawRecipes) {
        if (rawRecipe is! Map<String, dynamic>) continue;
        if (!rawRecipe.containsKey('inShape') &&
            !rawRecipe.containsKey('ingredients')) {
          continue;
        }
        return MinecraftRecipe.fromJson(rawRecipe, itemsById);
      }
    }

    if (item.name == 'netherite_pickaxe') {
      final itemsByName = {
        for (final entry in itemsById.values) entry.name: entry,
      };
      const ingredients = [
        'netherite_upgrade_smithing_template',
        'diamond_pickaxe',
        'netherite_ingot',
      ];
      final ingredientIds = ingredients
          .map((name) => itemsByName[name]?.id)
          .toList(growable: false);
      if (ingredientIds.any((id) => id == null)) {
        throw const FormatException(
          'Faltan ingredientes para mostrar la mejora de netherita.',
        );
      }
      return MinecraftRecipe(
        slots: [ingredientIds],
        outputCount: 1,
        stationName: 'la mesa de herrería',
      );
    }

    return null;
  }
}

class MinecraftService {
  MinecraftService({http.Client? client}) : _client = client ?? http.Client();

  static const version = '1.21.4';
  static const _rawBase =
      'https://raw.githubusercontent.com/PrismarineJS/minecraft-data/'
      'master/data/pc/$version';
  static final _itemsUri = Uri.parse('$_rawBase/items.json');
  static final _recipesUri = Uri.parse('$_rawBase/recipes.json');
  final http.Client _client;

  Future<MinecraftCatalog> fetchCatalog() async {
    final responses = await Future.wait([
      _getJson(_itemsUri),
      _getJson(_recipesUri),
    ]);
    final rawItems = responses[0];
    final rawRecipes = responses[1];

    if (rawItems is! List<dynamic> || rawRecipes is! Map<String, dynamic>) {
      throw const FormatException(
        'El catálogo de Minecraft tiene un formato inesperado.',
      );
    }

    final allItems = rawItems
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'El catálogo contiene un objeto con formato inválido.',
            );
          }
          return MinecraftItem.fromJson(item);
        })
        .toList(growable: false);
    final allItemsById = {for (final item in allItems) item.id: item};
    final allItemsByName = {for (final item in allItems) item.name: item};
    final selectedItems = _itemDetails.keys
        .map((name) => allItemsByName[name])
        .whereType<MinecraftItem>()
        .toList(growable: false);

    if (selectedItems.isEmpty) {
      throw const FormatException(
        'La API no devolvió los objetos destacados de Minecraft.',
      );
    }

    return MinecraftCatalog(
      items: selectedItems,
      itemsById: allItemsById,
      recipes: rawRecipes,
    );
  }

  Future<dynamic> _getJson(Uri uri) async {
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'La API de Minecraft respondió con el código ${response.statusCode}.',
        uri,
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.minecraftService});

  final MinecraftService minecraftService;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _searchController = TextEditingController();
  MinecraftCatalog? _catalog;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final catalog = await widget.minecraftService.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  List<MinecraftItem> get _filteredItems {
    final items = _catalog?.items ?? const <MinecraftItem>[];
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final details = _itemDetails[item.name]!;
      return item.displayName.toLowerCase().contains(query) ||
          details.summary.toLowerCase().contains(query) ||
          details.use.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          _appTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar objetos',
            onPressed: _isLoading ? null : _loadCatalog,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCatalog,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const _WelcomeCard(),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar un objeto de Minecraft',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar búsqueda',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading && catalog == null)
              const _LoadingState()
            else if (_error != null && catalog == null)
              _ErrorState(error: _error!, onRetry: _loadCatalog)
            else if (catalog != null) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Objetos del juego',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredItems.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_error != null)
                _InlineError(error: _error!, onRetry: _loadCatalog),
              const SizedBox(height: 12),
              if (filteredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No encontramos objetos con esa búsqueda.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...filteredItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ItemCard(
                      item: item,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ItemDetailPage(item: item, catalog: catalog),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF397E3D), Color(0xFF23572C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OBJETOS DE MINECRAFT JAVA 1.21.4',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Conoce cada objeto.',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre para qué sirve y cómo fabricarlo.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onPrimary.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});

  final MinecraftItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = _itemDetails[item.name]!;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ItemImage(item: item, size: 62),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      details.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.item, required this.size});

  final MinecraftItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.17),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _MinecraftSprite(
        item: item,
        fit: BoxFit.contain,
        errorIcon: Icon(
          Icons.inventory_2_outlined,
          color: colors.onPrimaryContainer,
          size: size * 0.55,
        ),
      ),
    );
  }
}

class _MinecraftSprite extends StatelessWidget {
  const _MinecraftSprite({
    required this.item,
    required this.fit,
    required this.errorIcon,
  });

  final MinecraftItem item;
  final BoxFit fit;
  final Widget errorIcon;

  @override
  Widget build(BuildContext context) {
    final localImageAsset = item.localImageAsset;
    if (localImageAsset != null) {
      return Image.asset(
        localImageAsset,
        fit: fit,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => errorIcon,
      );
    }

    return Image.network(
      item.imageUrl,
      fit: fit,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => Image.network(
        item.blockImageUrl,
        fit: fit,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => errorIcon,
      ),
    );
  }
}

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key, required this.item, required this.catalog});

  final MinecraftItem item;
  final MinecraftCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final details = _itemDetails[item.name]!;
    final recipe = catalog.recipeFor(item);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del objeto')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(child: _ItemImage(item: item, size: 142)),
          const SizedBox(height: 18),
          Text(
            item.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            details.summary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Sobre este objeto',
            description: details.description,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.sports_esports_rounded,
            title: 'Uso en Minecraft',
            description: details.use,
          ),
          if (details.obtainedFrom case final obtainedFrom?) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.landscape_outlined,
              title: 'Cómo obtenerlo',
              description: obtainedFrom,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'CÓMO FABRICARLO',
            style: TextStyle(
              color: colors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (recipe == null)
            const _InfoCard(
              icon: Icons.search_rounded,
              title: 'No se fabrica en la mesa de trabajo',
              description:
                  'Consulta la sección «Cómo obtenerlo» para ver dónde '
                  'encontrarlo o qué otro método usar.',
            )
          else
            _RecipeCard(item: item, catalog: catalog, recipe: recipe),
          const SizedBox(height: 12),
          const Text(
            'Datos del juego: Minecraft Java Edition 1.21.4. '
            'Los objetos pueden variar en otras ediciones o versiones.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.item,
    required this.catalog,
    required this.recipe,
  });

  final MinecraftItem item;
  final MinecraftCatalog catalog;
  final MinecraftRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Coloca los ingredientes en ${recipe.stationName}.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 174,
                height: 174 * recipe.slots.length / 3,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.slots.length * recipe.slots.first.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: recipe.slots.first.length,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final columnCount = recipe.slots.first.length;
                    final ingredientId =
                        recipe.slots[index ~/ columnCount][index % columnCount];
                    final ingredient = ingredientId == null
                        ? null
                        : catalog.itemsById[ingredientId];
                    return Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: ingredient == null
                          ? const SizedBox.expand()
                          : Tooltip(
                              message: ingredient.displayName,
                              child: _MinecraftSprite(
                                item: ingredient,
                                fit: BoxFit.contain,
                                errorIcon: Icon(
                                  Icons.inventory_2_outlined,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward_rounded, color: colors.primary),
              const SizedBox(width: 16),
              Column(
                children: [
                  _ItemImage(item: item, size: 68),
                  const SizedBox(height: 4),
                  Text(
                    recipe.outputCount > 1
                        ? '×${recipe.outputCount}'
                        : '1 objeto',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Cada cuadro representa un espacio de ${recipe.stationName}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando objetos de Minecraft...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar los objetos',
      message: '$error',
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reintentar'),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_off_rounded),
        title: const Text('No se pudo actualizar'),
        subtitle: Text('$error'),
        trailing: IconButton(
          tooltip: 'Reintentar',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}
