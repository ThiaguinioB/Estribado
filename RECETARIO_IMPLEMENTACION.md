# Implementación del Módulo Recetario

## ✅ Completado

Se ha implementado completamente el módulo **Recetario** siguiendo la arquitectura Clean Architecture establecida en el proyecto.

## 📁 Estructura Creada

### Domain Layer (Entidades y Lógica de Negocio)
- ✅ `lib/features/recetario/domain/entities/producto_receta.dart`
  - Entidad ProductoReceta con propiedades: nombre, dosisPorHa, unidad, total, unidadTotal
  - Métodos: toJson, fromJson, copyWith
  - Implementa Equatable para comparaciones

- ✅ `lib/features/recetario/domain/entities/receta.dart`
  - Entidad principal Receta con 10 propiedades
  - Incluye lista de productos (List<ProductoReceta>)
  - Métodos: toJson, fromJson, copyWith
  - Implementa Equatable

- ✅ `lib/features/recetario/domain/entities/receta_validation.dart`
  - Validadores para todos los campos del formulario
  - Cálculos bidireccionales: dosis ↔ total
  - Conversión automática de unidades (cc→L, g→Kg cuando ≥1000)
  - Helpers: calcularTotalDesdeDosis, calcularDosisDesdeTot, obtenerUnidadConvertida, parsearNumero

### Data Layer (Persistencia y Servicios)
- ✅ `lib/features/recetario/data/repositories/recetario_repository.dart`
  - Interface con métodos: getAllRecetas, getRecetaById, saveReceta, updateReceta, deleteReceta
  - Gestión de números de receta: getNextNumeroReceta, setNumeroReceta

- ✅ `lib/features/recetario/data/repositories/recetario_repository_impl.dart`
  - Implementación del repository
  - Coordina entre datasources locales y remotos
  - Métodos adicionales: generarPdf, compartirPdf

- ✅ `lib/features/recetario/data/datasources/recetario_local_datasource.dart`
  - Persistencia con SharedPreferences
  - Almacena lista de recetas y contador de números
  - Auto-incremento del número de receta
  - CRUD completo: save, update, delete, getAll, getById

- ✅ `lib/features/recetario/data/datasources/recetario_remote_datasource.dart`
  - Generación de PDF con formato profesional
  - Incluye logo, encabezado con número de receta
  - Tabla de productos formateada
  - Sección de observaciones
  - Nombre de archivo: Cliente-Establecimiento-Contratista-NroXXXXX.pdf
  - Funcionalidad de compartir PDF via share_plus

### Presentation Layer (UI y Estado)
- ✅ `lib/features/recetario/presentation/providers/recetario_form_provider.dart`
  - State management con ChangeNotifier
  - Gestión completa del formulario (todos los campos)
  - Control del número de receta (incrementar/decrementar)
  - Gestión de lista de productos (agregar, editar, eliminar)
  - Recálculo automático de totales al cambiar hectáreas
  - CRUD de recetas: cargar, guardar, actualizar, eliminar
  - Generación y compartir PDFs
  - Validación del formulario completo

- ✅ `lib/features/recetario/presentation/screens/receta_screen.dart`
  - Formulario completo con todos los campos
  - Card con número de receta y botones +/-
  - Selector de fecha con DatePicker
  - Campos validados (cliente, establecimiento, contratista, hectáreas, lote, cultivo)
  - Sección de productos con:
    * Lista de productos agregados
    * Botón "Agregar Producto"
    * Diálogo para agregar/editar producto
    * Cálculo bidireccional dosis/total con botón de intercambio
    * Selector de unidad (cc/g)
    * Mostrar conversiones automáticas
  - Campo de observaciones (multiline)
  - Botón guardar en AppBar
  - Soporte para modo edición (numeroRecetaEditar)

- ✅ `lib/features/recetario/presentation/screens/receta_list_screen.dart`
  - Lista de recetas ordenadas por número descendente
  - Cards con información resumida:
    * Número de receta destacado
    * Cliente, fecha, establecimiento
    * Hectáreas, cultivo, contratista
    * Cantidad de productos
  - Menú contextual por receta:
    * Editar
    * Generar PDF
    * Compartir
    * Eliminar (con confirmación)
  - Diálogo de detalle al tocar card
  - RefreshIndicator para recargar
  - Estados: loading, error, vacío
  - FloatingActionButton "Nueva Receta"

## 🔧 Integraciones

### Router
- ✅ Actualizado `lib/core/router/app_router.dart`:
  - `/recetario` → RecetaListScreen
  - `/recetario/nueva` → RecetaScreen
  - `/recetario/editar/:numeroReceta` → RecetaScreen(numeroRecetaEditar)

### Home Screen
- ✅ Activado FeatureCard de Recetario:
  - isAvailable: true (por defecto)
  - onTap: navigate to /recetario
  - Color morado, icono spa

### Main App
- ✅ Registrado RecetarioFormProvider en MultiProvider
- ✅ Inyección de dependencias completa:
  - RecetarioRepositoryImpl
  - RecetarioLocalDataSource
  - RecetarioRemoteDataSource

### Assets
- ✅ Creado directorio `assets/`
- ✅ Agregado `assets/logo.jpg` en pubspec.yaml
- ✅ Creado placeholder para logo
- ✅ README con instrucciones para logo

## 🎯 Funcionalidades Implementadas

### Gestión de Números de Receta
- ✅ Auto-incremento automático
- ✅ Control manual con botones +/-
- ✅ Formato con padding: 00001, 00002...
- ✅ Persistencia en SharedPreferences

### Gestión de Productos
- ✅ Agregar productos con nombre, dosis, unidad
- ✅ Editar productos existentes
- ✅ Eliminar productos
- ✅ Cálculo bidireccional:
  - Ingresar dosis → calcular total
  - Ingresar total → calcular dosis
- ✅ Botón de intercambio entre modos
- ✅ Conversión automática de unidades:
  - cc → L cuando ≥ 1000
  - g → Kg cuando ≥ 1000
- ✅ Recálculo al cambiar hectáreas

### PDF Profesional
- ✅ Encabezado con logo y número
- ✅ Información completa de la receta
- ✅ Tabla de productos formateada
- ✅ Sección de observaciones con borde
- ✅ Nombre de archivo descriptivo
- ✅ Opción de imprimir/vista previa
- ✅ Opción de compartir

### CRUD Completo
- ✅ **Create**: Guardar nueva receta con auto-incremento
- ✅ **Read**: Lista y detalle de recetas
- ✅ **Update**: Editar receta existente
- ✅ **Delete**: Eliminar con confirmación

### Validaciones
- ✅ Cliente (obligatorio, no vacío)
- ✅ Establecimiento (obligatorio)
- ✅ Contratista (obligatorio)
- ✅ Cantidad de hectáreas (número > 0)
- ✅ Lote (obligatorio)
- ✅ Cultivo (obligatorio)
- ✅ Al menos un producto

## 📦 Dependencias Utilizadas
- provider: State management
- shared_preferences: Persistencia local
- pdf: Generación de PDFs
- printing: Vista previa e impresión
- share_plus: Compartir archivos
- intl: Formateo de fechas
- equatable: Comparación de entidades
- go_router: Navegación
- path_provider: Directorios del sistema

## 🚀 Cómo Usar

### Crear una Receta
1. Ir a Home → Recetario
2. Presionar botón "Nueva Receta"
3. Ajustar número de receta con +/-
4. Completar campos obligatorios
5. Agregar productos:
   - Nombre del producto
   - Seleccionar unidad (cc o g)
   - Ingresar dosis por Ha o total (intercambiable)
6. Agregar observaciones (opcional)
7. Presionar icono guardar

### Ver Lista de Recetas
1. Pantalla principal muestra todas las recetas
2. Tocar card para ver detalle completo
3. Pull to refresh para actualizar

### Editar Receta
1. Menú contextual (⋮) → Editar
2. Modificar campos necesarios
3. Guardar cambios

### Generar PDF
1. Menú contextual → Generar PDF
2. Vista previa del documento
3. Opción de imprimir o guardar

### Compartir PDF
1. Menú contextual → Compartir
2. Seleccionar app para compartir
3. PDF enviado como archivo adjunto

### Eliminar Receta
1. Menú contextual → Eliminar
2. Confirmar eliminación
3. Receta removida permanentemente

## 📝 Notas Técnicas

### Arquitectura
El módulo sigue estrictamente Clean Architecture:
- **Domain**: Entidades puras sin dependencias
- **Data**: Repositorios e implementaciones
- **Presentation**: UI y state management

### Separación de Responsabilidades
- **RecetarioFormProvider**: Solo estado y lógica de negocio
- **RecetaScreen**: Solo UI del formulario
- **RecetaListScreen**: Solo UI de la lista
- **RecetarioLocalDataSource**: Solo persistencia
- **RecetarioRemoteDataSource**: Solo generación de PDFs

### Inmutabilidad
Todas las entidades son inmutables usando:
- `final` en propiedades
- Métodos `copyWith()` para actualizaciones
- Equatable para comparaciones

## 🔜 Posibles Mejoras Futuras
- [ ] Búsqueda y filtros en lista
- [ ] Exportar a Excel
- [ ] Backup en la nube (OneDrive)
- [ ] Campos personalizados adicionales
- [ ] Historial de cambios
- [ ] Duplicar receta
- [ ] Estadísticas de productos más usados
- [ ] Integración con módulo Maquinaria
- [ ] Firma digital en PDF
- [ ] Modo offline robusto

## ✅ Estado del Proyecto
- **Comisiones**: ✅ Completo
- **Recetario**: ✅ Completo
- **Honorarios**: ⏳ Pendiente
- **Maquinaria**: ⏳ Pendiente
- **Login/Auth**: ⏳ Pendiente

## 📸 Capturas de Pantalla
(Proximamente cuando se pruebe en dispositivo)
