# 📐 Arquitectura del Proyecto Estribado

## 🏗️ Clean Architecture - Capas

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Screens    │  │   Widgets    │  │   Providers  │         │
│  │   (UI)       │──│   (Components)│──│(State Mgmt)  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  Entities    │  │  Use Cases   │  │  Repository  │         │
│  │(Business Logic)│ │  (Actions)   │  │  Interfaces  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Repositories │  │  DataSources │  │   Models     │         │
│  │(Implementation)│─│(Local/Remote)│──│(Serialization)        │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos - Feature Comisiones

```
┌─────────────────┐
│  ComisionScreen │ 👤 Usuario ingresa datos
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ ComisionFormProvider │ 🧮 Gestiona estado
└────────┬─────────────┘
         │
         ▼
┌──────────────┐
│  Comision    │ 💡 Entidad con lógica de negocio
│  (Entity)    │    - Calcula IVA
└────────┬─────┘    - Calcula comisión
         │          - Valida datos
         ▼
┌─────────────────────┐
│ ComisionRepository  │ 📦 Abstracción de datos
└────────┬────────────┘
         │
         ├─────────────────────────┬──────────────────────────┐
         ▼                         ▼                          ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│ LocalDataSource  │    │ RemoteDataSource │    │   Services       │
│                  │    │                  │    │                  │
│ SharedPreferences│    │ Excel Service    │    │ • Auth Service   │
│                  │    │ PDF Service      │    │ • Graph API      │
└──────────────────┘    └──────────────────┘    └──────────────────┘
         │                         │                          │
         ▼                         ▼                          ▼
   💾 Storage              ☁️ OneDrive              🔐 Azure AD
```

## 🎭 Separación de Responsabilidades

### 📱 PRESENTATION
**Responsabilidad**: Solo renderizar UI y capturar eventos
```dart
ComisionScreen (Widget)
  ├──> Muestra formulario
  ├──> Captura input del usuario
  └──> NO calcula nada
       └──> Delega a Provider

ComisionFormProvider (State Management)
  ├──> Recibe eventos de UI
  ├──> Actualiza estado
  ├──> Notifica a observers
  └──> Llama al Repository
```

### 💼 DOMAIN
**Responsabilidad**: Lógica de negocio pura
```dart
Comision (Entity)
  ├──> double get subtotalNeto => cantidad * precio
  ├──> double get montoIva => subtotal * (iva/100)
  ├──> double get total => subtotal + iva
  └──> double get valorComision => total * (comision/100)

ComisionValidation
  ├──> validateCUIT()
  ├──> validatePrecio()
  └──> validateCantidad()
```

### 💾 DATA
**Responsabilidad**: Persistencia y comunicación externa
```dart
ComisionRepositoryImpl
  ├──> Coordina Local y Remote DataSources
  └──> Maneja errores

LocalDataSource
  └──> SharedPreferences / SQLite

RemoteDataSource
  ├──> ExcelGraphService → OneDrive
  └──> PdfGeneratorService → Archivos
```

## 🌐 Servicios Compartidos (Core)

```
core/
├── router/
│   └── app_router.dart          🧭 Navegación global
│
├── theme/
│   └── app_theme.dart           🎨 Estilos y colores
│
└── services/
    ├── microsoft_auth_service.dart   🔐 OAuth 2.0
    ├── excel_graph_service.dart      📊 Microsoft Graph API
    └── pdf_generator_service.dart    📄 Generación PDF
```

## 🔐 Flujo de Autenticación

```
┌──────────────┐
│ LoginScreen  │
└──────┬───────┘
       │ Tap "Login con Microsoft"
       ▼
┌──────────────────┐
│  AuthProvider    │
└──────┬───────────┘
       │ Llama
       ▼
┌───────────────────────┐
│ MicrosoftAuthService  │
└──────┬────────────────┘
       │ OAuth 2.0 Flow
       ▼
┌───────────────┐
│  Azure AD     │ 🌐 Microsoft Login Page
└──────┬────────┘
       │ Token
       ▼
┌──────────────────┐
│  Access Token    │ 🎫 Guardado en memoria
└──────────────────┘
       │
       └───> Usado por ExcelGraphService
```

## 📊 Flujo de Exportación a Excel

```
Usuario presiona "Exportar a Excel"
       │
       ▼
Provider.exportarAExcel()
       │
       ▼
Repository.exportToExcel([comisiones])
       │
       ▼
RemoteDataSource.uploadToExcel()
       │
       ▼
ExcelGraphService
       ├──> 1. Genera archivo .xlsx localmente
       ├──> 2. Obtiene AccessToken (AuthService)
       ├──> 3. POST a Microsoft Graph API
       └──> 4. Sube a OneDrive

☁️  OneDrive: /Estribado/comisiones_timestamp.xlsx
```

## 🎯 Patrones de Diseño Implementados

| Patrón | Ubicación | Propósito |
|--------|-----------|-----------|
| **Repository** | `ComisionRepository` | Abstracción de datos |
| **Provider (Observer)** | `ComisionFormProvider` | State management |
| **Factory** | `ExcelGraphService` | Crear archivos Excel |
| **Singleton** | `MicrosoftAuthService` | Única instancia de auth |
| **Strategy** | Local vs Remote DataSource | Múltiples estrategias de guardado |
| **Dependency Injection** | Constructor injection | Testabilidad |

## 🧪 Testabilidad

```dart
// ✅ FÁCIL DE TESTEAR
test('Comision calcula IVA correctamente', () {
  final comision = Comision(
    cantidad: 10,
    precioUnitario: 100,
    porcentajeIva: 21,
  );
  
  expect(comision.subtotalNeto, 1000);
  expect(comision.montoIva, 210);
  expect(comision.totalConImpuestos, 1210);
});

// ✅ MOCK DE REPOSITORIO
test('Provider guarda comisión', () async {
  final mockRepo = MockComisionRepository();
  final provider = ComisionFormProvider(repository: mockRepo);
  
  await provider.guardarComision();
  
  verify(mockRepo.saveComision(any)).called(1);
});
```

## 🚀 Escalabilidad

### Para agregar nueva feature (ej: Honorarios):

1. Crear estructura similar:
```
features/honorarios/
├── domain/entities/honorario.dart
├── data/repositories/...
└── presentation/
    ├── screens/honorario_screen.dart
    └── providers/honorario_provider.dart
```

2. Agregar ruta en `app_router.dart`
3. Agregar card en `home_screen.dart`
4. ¡Listo! La arquitectura lo soporta

## 📈 Ventajas de esta Arquitectura

✅ **Separación de responsabilidades** - Cada capa tiene un propósito claro
✅ **Testeable** - Lógica de negocio independiente de UI
✅ **Mantenible** - Cambios localizados en capas específicas
✅ **Escalable** - Fácil agregar nuevas features
✅ **Reutilizable** - Servicios compartibles entre features
✅ **Type-safe** - Tipos fuertes en Dart
✅ **Clean** - Código legible y documentado

## 🔄 Ciclo de Vida Completo

```
1. Usuario abre app
   └──> main.dart inicializa MultiProvider

2. HomeScreen se renderiza
   └──> Muestra opciones de features

3. Usuario navega a Comisiones
   └──> app_router.dart carga ComisionScreen

4. ComisionScreen crea Provider con Repository
   └──> Repository tiene acceso a LocalDataSource y RemoteDataSource

5. Usuario completa formulario
   └──> Provider actualiza Comision entity
   └──> Entity calcula automáticamente totales

6. Usuario presiona "Guardar"
   └──> Provider valida datos
   └──> Repository.saveComision()
   └──> LocalDataSource persiste en SharedPreferences
   └──> UI muestra confirmación

7. Usuario presiona "Exportar Excel"
   └──> RemoteDataSource.uploadToExcel()
   └──> ExcelGraphService genera .xlsx
   └──> AuthService obtiene token
   └──> Microsoft Graph API sube a OneDrive
   └──> UI muestra éxito
```

---

**Esta arquitectura garantiza que el código sea profesional, escalable y fácil de mantener a largo plazo.** 🏆
