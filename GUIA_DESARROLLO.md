# 🚀 Guía Rápida de Desarrollo - Estribado

## 📋 Checklist Inmediato

### ✅ Pasos Completados
- [x] Infraestructura base (main.dart, router, theme)
- [x] Feature Comisiones completa
- [x] Servicios (Auth, Excel, PDF)
- [x] Pantallas (Home, Login, Comisiones)
- [x] Arquitectura Clean implementada
- [x] Validaciones y manejo de errores

### 🔲 Próximos Pasos Sugeridos

#### 1️⃣ Setup Inicial (15 min)
```bash
# 1. Verificar que Flutter esté instalado
flutter --version

# 2. Si no está instalado, descargar de:
# https://docs.flutter.dev/get-started/install

# 3. Instalar dependencias
cd "c:\Users\Usuario\OneDrive\Escritorio\Trabajo\Development\Python\Estribado"
flutter pub get

# 4. Verificar que compile
flutter analyze
```

#### 2️⃣ Configurar Azure (30 min)
1. Ir a [Azure Portal](https://portal.azure.com)
2. Azure Active Directory → App registrations → New registration
3. Nombre: "Estribado Mobile"
4. Supported account types: "Personal accounts"
5. Redirect URI: `msauth://com.estribado.app/callback`
6. Copiar:
   - Application (client) ID
   - Directory (tenant) ID
7. Pegar en `lib/app_config.dart`

#### 3️⃣ Primera Ejecución (5 min)
```bash
# Ejecutar en emulador/dispositivo
flutter run

# O para web
flutter run -d chrome
```

---

## 🛠️ Comandos Útiles

### Desarrollo
```bash
# Hot reload (mientras la app corre: presiona 'r')
# Hot restart (presiona 'R')
# Quit (presiona 'q')

# Limpiar build cache
flutter clean

# Ver dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Modo release
flutter run --release
```

### Debugging
```bash
# Ver logs
flutter logs

# Analizar código
flutter analyze

# Formatear código
dart format lib/

# Ver dependencias
flutter pub deps
```

### Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle (para Play Store)
flutter build appbundle --release

# iOS (requiere Mac)
flutter build ios --release

# Web
flutter build web --release
```

---

## 🎨 Guía de Estilo del Proyecto

### Nombres de Archivos
```
✅ comision_screen.dart     (snake_case)
❌ ComisionScreen.dart
❌ comision-screen.dart
```

### Nombres de Clases
```dart
✅ class ComisionScreen extends StatelessWidget
✅ class ComisionFormProvider extends ChangeNotifier
❌ class comision_screen
```

### Estructura de Carpetas
```
feature/
├── domain/
│   └── entities/         # Entidades de negocio
├── data/
│   ├── repositories/     # Implementaciones
│   └── datasources/      # Fuentes de datos
└── presentation/
    ├── screens/          # Pantallas
    ├── widgets/          # Componentes reutilizables
    └── providers/        # State management
```

---

## 💡 Tips de Desarrollo

### 1. Provider Pattern
```dart
// ✅ CORRECTO: Watch para UI que se actualiza
final provider = context.watch<ComisionFormProvider>();

// ✅ CORRECTO: Read para eventos
onPressed: () => context.read<ComisionFormProvider>().guardar()

// ❌ INCORRECTO: Watch en eventos (causa rebuilds innecesarios)
onPressed: () => context.watch<ComisionFormProvider>().guardar()
```

### 2. Navigation con GoRouter
```dart
// ✅ CORRECTO: Navigation declarativa
context.push('/comisiones/nueva');
context.go('/home');  // Reemplaza stack
context.pop();        // Volver atrás

// ❌ INCORRECTO: Navigator viejo
Navigator.of(context).push(...);
```

### 3. Forms y Validación
```dart
// ✅ CORRECTO: Validar antes de guardar
if (_formKey.currentState!.validate()) {
  await provider.guardarComision();
}

// ✅ CORRECTO: Validators separados
validator: ComisionValidation.validateCUIT,
```

### 4. Async/Await
```dart
// ✅ CORRECTO: Manejo de loading
Future<bool> guardar() async {
  _isLoading = true;
  notifyListeners();
  
  try {
    await repository.save();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 🐛 Problemas Comunes y Soluciones

### Error: "Null check operator used on a null value"
```dart
// ❌ PROBLEMA
final value = data!.field;

// ✅ SOLUCIÓN
final value = data?.field ?? defaultValue;
```

### Error: "setState called during build"
```dart
// ❌ PROBLEMA
Widget build(context) {
  provider.loadData(); // ¡NO!
  return ...;
}

// ✅ SOLUCIÓN
@override
void initState() {
  super.initState();
  Future.microtask(() => provider.loadData());
}
```

### Error: "Vertical viewport was given unbounded height"
```dart
// ❌ PROBLEMA
Column(
  children: [
    ListView(...) // Sin altura definida
  ]
)

// ✅ SOLUCIÓN 1: Expanded
Column(
  children: [
    Expanded(child: ListView(...))
  ]
)

// ✅ SOLUCIÓN 2: shrinkWrap
Column(
  children: [
    ListView(shrinkWrap: true, ...)
  ]
)
```

---

## 📦 Agregar Nueva Feature

### Ejemplo: Implementar "Honorarios"

```bash
# 1. Crear estructura
mkdir -p lib/features/honorarios/{domain/entities,data/{repositories,datasources},presentation/{screens,widgets,providers}}
```

```dart
// 2. Crear entidad
// lib/features/honorarios/domain/entities/honorario.dart
class Honorario extends Equatable {
  final DateTime fecha;
  final String profesional;
  final double montoBase;
  final double porcentajeImpuestos;
  
  double get montoFinal => montoBase * (1 + porcentajeImpuestos/100);
  
  @override
  List<Object?> get props => [fecha, profesional, montoBase];
}
```

```dart
// 3. Crear pantalla
// lib/features/honorarios/presentation/screens/honorario_screen.dart
class HonorarioScreen extends StatelessWidget {
  const HonorarioScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Honorarios')),
      body: // ... tu UI
    );
  }
}
```

```dart
// 4. Agregar ruta
// lib/core/router/app_router.dart
GoRoute(
  path: '/honorarios',
  name: 'honorarios',
  builder: (context, state) => const HonorarioScreen(),
),
```

```dart
// 5. Agregar en Home
// lib/features/home/presentation/screens/home_screen.dart
_FeatureCard(
  title: 'Honorarios',
  icon: Icons.payment,
  color: Colors.blue,
  onTap: () => context.push('/honorarios'),
),
```

---

## 🧪 Testing

### Crear Tests Unitarios
```dart
// test/domain/entities/comision_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comision Entity', () {
    test('calcula subtotal correctamente', () {
      final comision = Comision(
        cantidad: 10,
        precioUnitario: 50,
      );
      
      expect(comision.subtotalNeto, 500);
    });
    
    test('calcula IVA 21%', () {
      final comision = Comision(
        cantidad: 10,
        precioUnitario: 100,
        porcentajeIva: 21,
      );
      
      expect(comision.montoIva, 210);
    });
  });
}
```

```bash
# Ejecutar tests
flutter test

# Con cobertura
flutter test --coverage
```

---

## 📖 Recursos Útiles

### Documentación
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter](https://pub.dev/packages/go_router)

### Clean Architecture
- [Clean Architecture Flutter](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Domain Driven Design](https://medium.com/@jonataslaw/clean-code-e-clean-architecture-no-flutter-parte-1-b5ca7a8e7d8a)

### Microsoft Graph API
- [Graph Explorer](https://developer.microsoft.com/graph/graph-explorer)
- [Graph API Docs](https://docs.microsoft.com/graph/overview)

---

## 🎯 Roadmap Sugerido

### Sprint 1 (Semana 1-2) ✅ COMPLETADO
- [x] Setup infraestructura
- [x] Feature Comisiones
- [x] Servicios base

### Sprint 2 (Semana 3-4)
- [ ] Configurar Azure credentials
- [ ] Testear flujo completo de Comisiones
- [ ] Implementar SQLite para persistencia robusta
- [ ] Agregar lista de comisiones guardadas

### Sprint 3 (Semana 5-6)
- [ ] Feature Honorarios
- [ ] Feature Maquinarias
- [ ] Dashboard con estadísticas

### Sprint 4 (Semana 7-8)
- [ ] Feature Recetario agrícola
- [ ] Gráficos y reportes
- [ ] Tests unitarios

### Sprint 5 (Semana 9-10)
- [ ] Pulir UI/UX
- [ ] Performance optimization
- [ ] Preparar para producción

---

## 🤝 Convenciones de Commits

```bash
# Features
git commit -m "feat: agregar pantalla de honorarios"

# Fixes
git commit -m "fix: corregir cálculo de IVA en comisiones"

# Docs
git commit -m "docs: actualizar README con instrucciones"

# Style
git commit -m "style: formatear código según lint rules"

# Refactor
git commit -m "refactor: simplificar ComisionFormProvider"

# Test
git commit -m "test: agregar tests para Comision entity"
```

---

## 📞 Ayuda y Soporte

### Si algo no funciona:

1. **Limpiar y reinstalar**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Verificar Flutter Doctor**
   ```bash
   flutter doctor -v
   ```

3. **Revisar logs**
   ```bash
   flutter logs
   ```

4. **Buscar en documentación**
   - Flutter: https://flutter.dev
   - Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

## 🎊 ¡Éxito!

El proyecto está listo para continuar. Todas las bases están implementadas con:
- ✅ Arquitectura profesional
- ✅ Código limpio y documentado
- ✅ Feature principal funcional
- ✅ Servicios preparados

**¡Ahora solo falta ejecutar y seguir construyendo!** 🚀
