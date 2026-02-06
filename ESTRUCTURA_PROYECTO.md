# 📁 Estructura del Proyecto - Estribado

## 🌳 Árbol de Directorios Completo

```
estribado/
│
├── 📄 README.md                      # Documentación principal del proyecto
├── 📄 ARQUITECTURA.md                # Explicación de arquitectura Clean
├── 📄 DIAGRAMA_CLASES.md             # Diagramas Mermaid del sistema
├── 📄 ESTRUCTURA_PROYECTO.md         # Este archivo
├── 📄 GUIA_DESARROLLO.md             # Guía de desarrollo y setup
├── 📄 IMPLEMENTACION_COMPLETADA.md   # Checklist de features
├── 📄 pubspec.yaml                   # Dependencias del proyecto
├── 📄 analysis_options.yaml          # Reglas de análisis estático
│
├── 📂 android/                       # Configuración Android
│   └── app/
│       └── build.gradle              # Configuración de build Android
│
├── 📂 ios/                           # Configuración iOS
│   └── Runner/
│       └── Info.plist                # Configuración iOS
│
├── 📂 lib/                           # 🔥 CÓDIGO PRINCIPAL DE LA APP
│   │
│   ├── 📄 main.dart                  # Entry point de la aplicación
│   ├── 📄 app_config.dart            # Configuración global (Azure IDs)
│   │
│   ├── 📂 core/                      # ⚙️ FUNCIONALIDAD COMPARTIDA
│   │   │
│   │   ├── 📂 router/                # 🗺️ Navegación
│   │   │   └── 📄 app_router.dart    # GoRouter configuration
│   │   │
│   │   ├── 📂 theme/                 # 🎨 Temas visuales
│   │   │   └── 📄 app_theme.dart     # ThemeData (light/dark)
│   │   │
│   │   ├── 📂 services/              # 🔧 Servicios compartidos
│   │   │   ├── 📄 microsoft_auth_service.dart        # OAuth Microsoft
│   │   │   ├── 📄 excel_graph_service.dart           # Microsoft Graph API
│   │   │   ├── 📄 pdf_generator_service.dart         # Generación de PDFs
│   │   │   └── 📄 storage_service.dart               # Gestión de archivos
│   │   │
│   │   ├── 📂 utils/                 # 🛠️ Utilidades
│   │   │   ├── 📄 constants.dart     # Constantes globales
│   │   │   ├── 📄 validators.dart    # Validaciones comunes
│   │   │   └── 📄 formatters.dart    # Formateadores (fecha, moneda)
│   │   │
│   │   └── 📂 widgets/               # 🧩 Widgets reutilizables
│   │       ├── 📄 custom_button.dart
│   │       ├── 📄 custom_text_field.dart
│   │       ├── 📄 loading_indicator.dart
│   │       ├── 📄 error_message.dart
│   │       └── 📄 confirmation_dialog.dart
│   │
│   └── 📂 features/                  # 🚀 MÓDULOS DE LA APP
│       │
│       ├── 📂 auth/                  # 🔐 AUTENTICACIÓN
│       │   ├── 📂 data/
│       │   │   ├── 📂 datasources/
│       │   │   │   └── 📄 auth_local_datasource.dart
│       │   │   └── 📂 repositories/
│       │   │       └── 📄 auth_repository_impl.dart
│       │   │
│       │   ├── 📂 domain/
│       │   │   ├── 📂 entities/
│       │   │   │   └── 📄 user.dart
│       │   │   └── 📂 repositories/
│       │   │       └── 📄 auth_repository.dart
│       │   │
│       │   └── 📂 presentation/
│       │       ├── 📂 providers/
│       │       │   └── 📄 auth_provider.dart
│       │       ├── 📂 screens/
│       │       │   └── 📄 login_screen.dart
│       │       └── 📂 widgets/
│       │           ├── 📄 login_button.dart
│       │           └── 📄 guest_mode_warning.dart
│       │
│       ├── 📂 home/                  # 🏠 PANTALLA PRINCIPAL
│       │   └── 📂 presentation/
│       │       ├── 📂 screens/
│       │       │   └── 📄 home_screen.dart
│       │       └── 📂 widgets/
│       │           ├── 📄 feature_card.dart
│       │           ├── 📄 user_header.dart
│       │           └── 📄 sync_status_indicator.dart
│       │
│       ├── 📂 comisiones/            # 💰 MÓDULO COMISIONES
│       │   ├── 📂 data/
│       │   │   ├── 📂 datasources/
│       │   │   │   ├── 📄 comision_local_datasource.dart
│       │   │   │   └── 📄 comision_remote_datasource.dart
│       │   │   ├── 📂 models/
│       │   │   │   └── 📄 comision_model.dart
│       │   │   └── 📂 repositories/
│       │   │       └── 📄 comision_repository_impl.dart
│       │   │
│       │   ├── 📂 domain/
│       │   │   ├── 📂 entities/
│       │   │   │   ├── 📄 comision.dart
│       │   │   │   └── 📄 comision_validation.dart
│       │   │   ├── 📂 repositories/
│       │   │   │   └── 📄 comision_repository.dart
│       │   │   └── 📂 usecases/
│       │   │       ├── 📄 create_comision.dart
│       │   │       ├── 📄 get_comisiones.dart
│       │   │       ├── 📄 update_comision.dart
│       │   │       └── 📄 delete_comision.dart
│       │   │
│       │   └── 📂 presentation/
│       │       ├── 📂 providers/
│       │       │   └── 📄 comision_form_provider.dart
│       │       ├── 📂 screens/
│       │       │   ├── 📄 comision_screen.dart
│       │       │   ├── 📄 comision_list_screen.dart
│       │       │   └── 📄 comision_detail_screen.dart
│       │       └── 📂 widgets/
│       │           ├── 📄 comision_form.dart
│       │           ├── 📄 comision_card.dart
│       │           └── 📄 comision_summary.dart
│       │
│       ├── 📂 recetario/             # 🌾 MÓDULO RECETAS AGRONÓMICAS
│       │   ├── 📂 data/
│       │   │   ├── 📂 datasources/
│       │   │   │   ├── 📄 recetario_local_datasource.dart
│       │   │   │   └── 📄 recetario_remote_datasource.dart
│       │   │   ├── 📂 models/
│       │   │   │   ├── 📄 receta_model.dart
│       │   │   │   └── 📄 producto_receta_model.dart
│       │   │   └── 📂 repositories/
│       │   │       └── 📄 recetario_repository_impl.dart
│       │   │
│       │   ├── 📂 domain/
│       │   │   ├── 📂 entities/
│       │   │   │   ├── 📄 receta.dart
│       │   │   │   ├── 📄 producto_receta.dart
│       │   │   │   └── 📄 receta_validation.dart
│       │   │   ├── 📂 repositories/
│       │   │   │   └── 📄 recetario_repository.dart
│       │   │   └── 📂 usecases/
│       │   │       ├── 📄 create_receta.dart
│       │   │       ├── 📄 get_recetas.dart
│       │   │       ├── 📄 update_receta.dart
│       │   │       └── 📄 delete_receta.dart
│       │   │
│       │   └── 📂 presentation/
│       │       ├── 📂 providers/
│       │       │   └── 📄 recetario_form_provider.dart
│       │       ├── 📂 screens/
│       │       │   ├── 📄 recetario_screen.dart
│       │       │   ├── 📄 receta_list_screen.dart
│       │       │   └── 📄 receta_detail_screen.dart
│       │       └── 📂 widgets/
│       │           ├── 📄 receta_form.dart
│       │           ├── 📄 receta_card.dart
│       │           ├── 📄 producto_list.dart
│       │           └── 📄 receta_summary.dart
│       │
│       ├── 📂 honorarios/            # 💼 MÓDULO HONORARIOS PROFESIONALES
│       │   ├── 📂 data/
│       │   │   ├── 📂 datasources/
│       │   │   │   ├── 📄 honorarios_local_datasource.dart
│       │   │   │   └── 📄 honorarios_remote_datasource.dart
│       │   │   ├── 📂 models/
│       │   │   │   └── 📄 honorario_model.dart
│       │   │   └── 📂 repositories/
│       │   │       └── 📄 honorarios_repository_impl.dart
│       │   │
│       │   ├── 📂 domain/
│       │   │   ├── 📂 entities/
│       │   │   │   ├── 📄 honorario.dart
│       │   │   │   └── 📄 honorario_validation.dart
│       │   │   ├── 📂 repositories/
│       │   │   │   └── 📄 honorarios_repository.dart
│       │   │   └── 📂 usecases/
│       │   │       ├── 📄 create_honorario.dart
│       │   │       ├── 📄 get_honorarios.dart
│       │   │       ├── 📄 update_honorario.dart
│       │   │       └── 📄 delete_honorario.dart
│       │   │
│       │   └── 📂 presentation/
│       │       ├── 📂 providers/
│       │       │   └── 📄 honorarios_form_provider.dart
│       │       ├── 📂 screens/
│       │       │   ├── 📄 honorarios_screen.dart
│       │       │   ├── 📄 honorario_list_screen.dart
│       │       │   └── 📄 honorario_detail_screen.dart
│       │       └── 📂 widgets/
│       │           ├── 📄 honorario_form.dart
│       │           ├── 📄 honorario_card.dart
│       │           └── 📄 honorario_summary.dart
│       │
│       └── 📂 maquinaria/            # 🚜 MÓDULO MAQUINARIA AGRÍCOLA
│           ├── 📂 data/
│           │   ├── 📂 datasources/
│           │   │   ├── 📄 maquinaria_local_datasource.dart
│           │   │   └── 📄 maquinaria_remote_datasource.dart
│           │   ├── 📂 models/
│           │   │   └── 📄 maquinaria_model.dart
│           │   └── 📂 repositories/
│           │       └── 📄 maquinaria_repository_impl.dart
│           │
│           ├── 📂 domain/
│           │   ├── 📂 entities/
│           │   │   ├── 📄 maquinaria.dart
│           │   │   └── 📄 maquinaria_validation.dart
│           │   ├── 📂 repositories/
│           │   │   └── 📄 maquinaria_repository.dart
│           │   └── 📂 usecases/
│           │       ├── 📄 create_maquinaria.dart
│           │       ├── 📄 get_maquinarias.dart
│           │       ├── 📄 update_maquinaria.dart
│           │       └── 📄 delete_maquinaria.dart
│           │
│           └── 📂 presentation/
│               ├── 📂 providers/
│               │   └── 📄 maquinaria_form_provider.dart
│               ├── 📂 screens/
│               │   ├── 📄 maquinaria_screen.dart
│               │   ├── 📄 maquinaria_list_screen.dart
│               │   └── 📄 maquinaria_detail_screen.dart
│               └── 📂 widgets/
│                   ├── 📄 maquinaria_form.dart
│                   ├── 📄 maquinaria_card.dart
│                   └── 📄 maquinaria_summary.dart
│
├── 📂 test/                          # 🧪 TESTS UNITARIOS
│   ├── 📂 core/
│   │   └── 📂 services/
│   │       ├── 📄 microsoft_auth_service_test.dart
│   │       ├── 📄 excel_graph_service_test.dart
│   │       └── 📄 pdf_generator_service_test.dart
│   │
│   └── 📂 features/
│       ├── 📂 comisiones/
│       │   ├── 📂 domain/
│       │   │   └── 📄 comision_test.dart
│       │   └── 📂 presentation/
│       │       └── 📄 comision_form_provider_test.dart
│       │
│       ├── 📂 recetario/
│       │   ├── 📂 domain/
│       │   │   └── 📄 receta_test.dart
│       │   └── 📂 presentation/
│       │       └── 📄 recetario_form_provider_test.dart
│       │
│       ├── 📂 honorarios/
│       │   └── 📂 domain/
│       │       └── 📄 honorario_test.dart
│       │
│       └── 📂 maquinaria/
│           └── 📂 domain/
│               └── 📄 maquinaria_test.dart
│
└── 📂 assets/                        # 🖼️ RECURSOS ESTÁTICOS
    ├── 📂 images/
    │   ├── 📄 logo.png
    │   ├── 📄 splash.png
    │   └── 📂 icons/
    │       ├── 📄 comisiones_icon.png
    │       ├── 📄 recetario_icon.png
    │       ├── 📄 honorarios_icon.png
    │       └── 📄 maquinaria_icon.png
    │
    └── 📂 fonts/
        └── 📄 CustomFont.ttf
```

## 📊 Resumen de Estructura

### Por Números

```
Total Módulos (Features): 5
  ├── Auth (Autenticación)
  ├── Home (Pantalla Principal)
  ├── Comisiones
  ├── Recetario
  ├── Honorarios
  └── Maquinaria

Archivos por Feature (promedio): 15-20
  ├── Data Layer: 4-6 archivos
  ├── Domain Layer: 5-7 archivos
  └── Presentation Layer: 6-10 archivos

Servicios Compartidos (Core): 4
  ├── MicrosoftAuthService
  ├── ExcelGraphService
  ├── PDFGeneratorService
  └── StorageService

Widgets Reutilizables: 10+
Tests Unitarios: 50+ (objetivo)
```

## 🗂️ Convenciones de Nomenclatura

### Archivos
- **Screens**: `*_screen.dart` (ej: `comision_screen.dart`)
- **Providers**: `*_provider.dart` (ej: `comision_form_provider.dart`)
- **Repositories**: `*_repository.dart` + `*_repository_impl.dart`
- **DataSources**: `*_datasource.dart` (ej: `comision_local_datasource.dart`)
- **Entities**: Sin sufijo (ej: `comision.dart`, `receta.dart`)
- **Models**: `*_model.dart` (ej: `comision_model.dart`)
- **Services**: `*_service.dart` (ej: `excel_graph_service.dart`)
- **Widgets**: Descriptivos (ej: `custom_button.dart`, `feature_card.dart`)

### Clases
- **Screens**: `*Screen` (ej: `ComisionScreen`)
- **Providers**: `*Provider` (ej: `ComisionFormProvider`)
- **Repositories**: `*Repository` + `*RepositoryImpl`
- **Services**: `*Service` (ej: `ExcelGraphService`)
- **Entities**: Nombre directo (ej: `Comision`, `Receta`)

### Carpetas
- Siempre en **snake_case**
- Nombres en plural cuando contienen múltiples elementos (ej: `datasources`, `repositories`)
- Nombres específicos del módulo (ej: `comisiones`, `recetario`)

## 🎯 Roadmap de Implementación

### ✅ Fase 1: Completado
- [x] Core (Router, Theme, Services)
- [x] Auth Feature
- [x] Home Feature
- [x] Comisiones Feature

### 🔄 Fase 2: En Progreso
- [ ] Recetario Feature
- [ ] Honorarios Feature
- [ ] Maquinaria Feature

### 📅 Fase 3: Futuro
- [ ] Tests completos
- [ ] CI/CD
- [ ] Analytics
- [ ] Notificaciones push
- [ ] Modo offline mejorado

## 📝 Notas Importantes

### Reglas de Dependencias

1. **Presentation** solo puede depender de **Domain**
2. **Domain** NO depende de nadie (capa más interna)
3. **Data** implementa las interfaces de **Domain**
4. **Core** puede ser usado por todas las capas
5. Features NO se conocen entre sí (comunicación vía Core)

### Gestión de Estado

- **Provider**: Para gestión de estado local y de features
- **Riverpod** (futuro): Considerar migrar para mejor testabilidad
- **Bloc** (opcional): Para features muy complejas

### Persistencia

- **SharedPreferences**: Datos simples y configuración
- **SQLite**: Datos estructurados y relacionales (futuro)
- **OneDrive**: Sincronización con Excel en la nube

### Generación de Documentos

- **PDF**: Usando `pdf` + `printing` packages
- **Excel**: Usando `excel` package + Microsoft Graph API
- **Templates**: Plantillas personalizables por tipo de documento
