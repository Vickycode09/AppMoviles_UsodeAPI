# PrismarineJS

Aplicación Flutter en español para explorar objetos de Minecraft. Obtiene los
nombres originales en inglés, los identificadores y las recetas de Minecraft
Java Edition 1.21.4 desde la API
[PrismarineJS/minecraft-data](https://github.com/PrismarineJS/minecraft-data).
Muestra sprites de
[PrismarineJS/minecraft-assets](https://github.com/PrismarineJS/minecraft-assets),
con descripciones y usos en español.

La app consulta los datos y los sprites remotos mediante solicitudes **GET**;
los sprites de cofre y escudo se incluyen localmente para evitar fallos de
carga. No crea ni modifica contenido.

## Funcionalidades

- Lista de objetos con imagen, nombre y descripción breve.
- Búsqueda por nombre, descripción y uso.
- Detalle de cada objeto con imagen, descripción, uso y cómo obtenerlo.
- Cuadrícula visual 3×3 con los ingredientes y el resultado de la receta
  cuando está disponible, incluidas las mejoras con mesa de herrería.
- Fallback a texturas de bloque para ingredientes sin sprite de inventario;
  sprites de cofre y escudo de
  [Minecraft Item IDs](https://static.minecraftitemids.com/), incluidos en
  `assets/items/`.
- Estados de carga, error y reintento; validación de respuestas HTTP y JSON.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Probar

```bash
flutter test
flutter analyze
```
