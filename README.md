# Estribado - Software Agropecuario

Software agropecuario donde podrás generar hojas de cálculo y archivos PDFs compartibles para cada uno de tus trabajos y servicios. Arma recetas agrícolas, calcula comisiones de servicios, lleva el registro de tus trabajos y mucho más desde un solo lugar.

## 🚀 Features Implementadas

### ✅ Infraestructura
- ✅ Arquitectura Clean (Domain/Data/Presentation)
- ✅ Sistema de rutas con GoRouter
- ✅ Theme personalizado
- ✅ State management con Provider
- ✅ Configuración de app

### ✅ Feature: Comisiones
- ✅ Entidad Comision con lógica de negocio
- ✅ Validaciones completas
- ✅ Formulario con UI declarativa
- ✅ Persistencia local (SharedPreferences)
- ✅ Generación de PDF
- ✅ Exportación a Excel
- ✅ Integración con Microsoft Graph API

### ✅ Feature: Home
- ✅ Dashboard con cards de navegación
- ✅ Acceso rápido a features

### ✅ Feature: Auth
- ✅ Pantalla de login
- ✅ Integración con Microsoft Azure AD
- ✅ Provider de autenticación

## 📦 Dependencias

```yaml
dependencies:
  - provider (State Management)
  - go_router (Navigation)
  - equatable (Domain)  
  - aad_oauth (Microsoft Auth)
  - pdf (PDF Generation)
  - printing (PDF Preview)
  - excel (Excel Generation)
  - shared_preferences (Local Storage)
```

## 🏗️ Arquitectura

```
lib/
├── core/
│   ├── router/         # Navegación
│   ├── theme/          # Temas
│   └── services/       # Servicios compartidos
├── features/
│   ├── auth/           # Autenticación
│   ├── comisiones/     # Gestión de comisiones
│   │   ├── domain/     # Entidades y lógica
│   │   ├── data/       # Repositorios y datasources
│   │   └── presentation/ # UI y Providers
│   └── home/           # Pantalla principal
```

## 🔧 Setup

1. Instalar dependencias:
```bash
flutter pub get
```

2. Configurar credenciales de Microsoft Azure en `app_config.dart`:
```dart
static const String microsoftClientId = 'YOUR_CLIENT_ID_HERE';
static const String microsoftTenantId = 'YOUR_TENANT_ID_HERE';
```

3. Ejecutar:
```bash
flutter run
```

## 📝 TODO

- [ ] Implementar features: Honorarios, Maquinarias, Recetario
- [ ] Agregar base de datos SQLite
- [ ] Tests unitarios y de integración
- [ ] Subida real a OneDrive
- [ ] Modo offline robusto
- [ ] Sincronización automática

## 🎯 Próximos Pasos

1. Configurar credenciales de Azure
2. Testear flujo completo de comisiones
3. Implementar features restantes
4. Deploy en stores
