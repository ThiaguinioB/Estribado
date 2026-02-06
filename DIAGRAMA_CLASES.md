# 📊 Diagrama de Clases - Sistema Estribado

## 🎯 Diagrama de Clases Completo (Mermaid)

```mermaid
classDiagram
    %% ========================================
    %% CAPA DE PRESENTACIÓN (UI)
    %% ========================================
    
    class App {
        +main()
        +build()
    }
    
    class AppRouter {
        +GoRouter router
        +routes: List~RouteBase~
        +initialLocation: String
    }
    
    %% AUTH FEATURE
    class LoginScreen {
        +build(context)
        -onLoginWithMicrosoft()
        -onLoginAsGuest()
    }
    
    class AuthProvider {
        -MicrosoftAuthService authService
        +User? currentUser
        +bool isAuthenticated
        +bool isGuest
        +loginWithMicrosoft()
        +loginAsGuest()
        +logout()
        +checkAuthStatus()
    }
    
    %% HOME FEATURE
    class HomeScreen {
        +build(context)
        -navigateToRecetario()
        -navigateToComisiones()
        -navigateToHonorarios()
        -navigateToMaquinaria()
    }
    
    %% COMISIONES FEATURE
    class ComisionScreen {
        +build(context)
        -buildForm()
        -onSubmit()
        -onGeneratePDF()
        -onExportExcel()
    }
    
    class ComisionFormProvider {
        -ComisionRepository repository
        +Comision? currentComision
        +bool isLoading
        +String? errorMessage
        +createComision(data)
        +updateComision(id, data)
        +deleteComision(id)
        +loadComisiones()
        +generatePDF(comision)
        +exportToExcel(comisiones)
    }
    
    %% RECETARIO FEATURE
    class RecetarioScreen {
        +build(context)
        -buildForm()
        -onSubmit()
        -onGeneratePDF()
        -onExportExcel()
    }
    
    class RecetarioFormProvider {
        -RecetarioRepository repository
        +Receta? currentReceta
        +bool isLoading
        +String? errorMessage
        +createReceta(data)
        +updateReceta(id, data)
        +deleteReceta(id)
        +loadRecetas()
        +generatePDF(receta)
        +exportToExcel(recetas)
    }
    
    %% HONORARIOS FEATURE
    class HonorariosScreen {
        +build(context)
        -buildForm()
        -onSubmit()
        -onGeneratePDF()
        -onExportExcel()
    }
    
    class HonorariosFormProvider {
        -HonorariosRepository repository
        +Honorario? currentHonorario
        +bool isLoading
        +String? errorMessage
        +createHonorario(data)
        +updateHonorario(id, data)
        +deleteHonorario(id)
        +loadHonorarios()
        +generatePDF(honorario)
        +exportToExcel(honorarios)
    }
    
    %% MAQUINARIA FEATURE
    class MaquinariaScreen {
        +build(context)
        -buildForm()
        -onSubmit()
        -onGeneratePDF()
        -onExportExcel()
    }
    
    class MaquinariaFormProvider {
        -MaquinariaRepository repository
        +Maquinaria? currentMaquinaria
        +bool isLoading
        +String? errorMessage
        +createMaquinaria(data)
        +updateMaquinaria(id, data)
        +deleteMaquinaria(id)
        +loadMaquinarias()
        +generatePDF(maquinaria)
        +exportToExcel(maquinarias)
    }
    
    %% ========================================
    %% CAPA DE DOMINIO (Business Logic)
    %% ========================================
    
    %% AUTH DOMAIN
    class User {
        +String id
        +String name
        +String email
        +String? photoUrl
        +bool isGuest
        +DateTime? lastLogin
        +toJson()
        +fromJson()
    }
    
    %% COMISIONES DOMAIN
    class Comision {
        +String id
        +String numeroComprobante
        +DateTime fecha
        +String razonSocial
        +String cuit
        +double cantidad
        +double precio
        +double iva
        +double comision
        +double subtotalNeto
        +double montoIva
        +double total
        +double valorComision
        +toJson()
        +fromJson()
        +copyWith()
    }
    
    class ComisionValidation {
        +validateCUIT(String cuit)
        +validatePrecio(double precio)
        +validateCantidad(double cantidad)
        +validateComision(double comision)
        +validateIVA(double iva)
    }
    
    %% RECETARIO DOMAIN
    class Receta {
        +String id
        +String numeroReceta
        +DateTime fecha
        +String productor
        +String establecimiento
        +String cultivo
        +double superficieHa
        +List~ProductoReceta~ productos
        +String profesional
        +String matricula
        +double totalHectareas
        +double costoTotal
        +toJson()
        +fromJson()
        +copyWith()
    }
    
    class ProductoReceta {
        +String nombre
        +String principioActivo
        +double dosisPorHa
        +String unidad
        +double precioUnitario
        +double total
    }
    
    class RecetaValidation {
        +validateNumeroReceta(String numero)
        +validateSuperficie(double superficie)
        +validateDosis(double dosis)
        +validateMatricula(String matricula)
    }
    
    %% HONORARIOS DOMAIN
    class Honorario {
        +String id
        +String numeroFactura
        +DateTime fecha
        +String cliente
        +String cuit
        +String servicioPrestado
        +double horasTrabajadas
        +double tarifaHora
        +double iva
        +double subtotal
        +double montoIva
        +double total
        +toJson()
        +fromJson()
        +copyWith()
    }
    
    class HonorarioValidation {
        +validateCUIT(String cuit)
        +validateHoras(double horas)
        +validateTarifa(double tarifa)
    }
    
    %% MAQUINARIA DOMAIN
    class Maquinaria {
        +String id
        +String numeroRemito
        +DateTime fecha
        +String cliente
        +String tipoMaquina
        +String marca
        +String modelo
        +String tipoTrabajo
        +double hectareasTrabajadas
        +double tarifaPorHa
        +double costosCombustible
        +double costosMantenimiento
        +double subtotal
        +double total
        +toJson()
        +fromJson()
        +copyWith()
    }
    
    class MaquinariaValidation {
        +validateHectareas(double hectareas)
        +validateTarifa(double tarifa)
        +validateCostos(double costos)
    }
    
    %% REPOSITORY INTERFACES
    class ComisionRepository {
        <<interface>>
        +Future~List~Comision~~ getAll()
        +Future~Comision~ getById(id)
        +Future~void~ create(comision)
        +Future~void~ update(comision)
        +Future~void~ delete(id)
    }
    
    class RecetarioRepository {
        <<interface>>
        +Future~List~Receta~~ getAll()
        +Future~Receta~ getById(id)
        +Future~void~ create(receta)
        +Future~void~ update(receta)
        +Future~void~ delete(id)
    }
    
    class HonorariosRepository {
        <<interface>>
        +Future~List~Honorario~~ getAll()
        +Future~Honorario~ getById(id)
        +Future~void~ create(honorario)
        +Future~void~ update(honorario)
        +Future~void~ delete(id)
    }
    
    class MaquinariaRepository {
        <<interface>>
        +Future~List~Maquinaria~~ getAll()
        +Future~Maquinaria~ getById(id)
        +Future~void~ create(maquinaria)
        +Future~void~ update(maquinaria)
        +Future~void~ delete(id)
    }
    
    %% ========================================
    %% CAPA DE DATOS (Data Access)
    %% ========================================
    
    %% REPOSITORY IMPLEMENTATIONS
    class ComisionRepositoryImpl {
        -ComisionLocalDataSource localDataSource
        -ComisionRemoteDataSource remoteDataSource
        +getAll()
        +getById(id)
        +create(comision)
        +update(comision)
        +delete(id)
    }
    
    class RecetarioRepositoryImpl {
        -RecetarioLocalDataSource localDataSource
        -RecetarioRemoteDataSource remoteDataSource
        +getAll()
        +getById(id)
        +create(receta)
        +update(receta)
        +delete(id)
    }
    
    class HonorariosRepositoryImpl {
        -HonorariosLocalDataSource localDataSource
        -HonorariosRemoteDataSource remoteDataSource
        +getAll()
        +getById(id)
        +create(honorario)
        +update(honorario)
        +delete(id)
    }
    
    class MaquinariaRepositoryImpl {
        -MaquinariaLocalDataSource localDataSource
        -MaquinariaRemoteDataSource remoteDataSource
        +getAll()
        +getById(id)
        +create(maquinaria)
        +update(maquinaria)
        +delete(id)
    }
    
    %% DATA SOURCES
    class ComisionLocalDataSource {
        -SharedPreferences prefs
        -Database db
        +getCached()
        +cache(comision)
        +clear()
    }
    
    class ComisionRemoteDataSource {
        -ExcelGraphService excelService
        +syncToExcel(comisiones)
        +fetchFromExcel()
    }
    
    class RecetarioLocalDataSource {
        -SharedPreferences prefs
        -Database db
        +getCached()
        +cache(receta)
        +clear()
    }
    
    class RecetarioRemoteDataSource {
        -ExcelGraphService excelService
        +syncToExcel(recetas)
        +fetchFromExcel()
    }
    
    class HonorariosLocalDataSource {
        -SharedPreferences prefs
        -Database db
        +getCached()
        +cache(honorario)
        +clear()
    }
    
    class HonorariosRemoteDataSource {
        -ExcelGraphService excelService
        +syncToExcel(honorarios)
        +fetchFromExcel()
    }
    
    class MaquinariaLocalDataSource {
        -SharedPreferences prefs
        -Database db
        +getCached()
        +cache(maquinaria)
        +clear()
    }
    
    class MaquinariaRemoteDataSource {
        -ExcelGraphService excelService
        +syncToExcel(maquinarias)
        +fetchFromExcel()
    }
    
    %% ========================================
    %% SERVICIOS COMPARTIDOS (Core)
    %% ========================================
    
    class MicrosoftAuthService {
        -AadOAuth oauth
        +String clientId
        +String tenantId
        +bool isAuthenticated
        +login()
        +logout()
        +getAccessToken()
        +refreshToken()
    }
    
    class ExcelGraphService {
        -MicrosoftAuthService authService
        -http.Client client
        +createWorkbook(name)
        +addRow(workbookId, data)
        +readWorkbook(workbookId)
        +updateRow(workbookId, rowId, data)
        +deleteRow(workbookId, rowId)
        +uploadFile(bytes, name)
    }
    
    class PDFGeneratorService {
        +generateComisionPDF(comision)
        +generateRecetaPDF(receta)
        +generateHonorarioPDF(honorario)
        +generateMaquinariaPDF(maquinaria)
        +sharePDF(bytes, filename)
        +savePDF(bytes, filename)
    }
    
    class AppTheme {
        +ThemeData lightTheme
        +ThemeData darkTheme
        +Color primaryColor
        +Color accentColor
    }
    
    %% ========================================
    %% RELACIONES
    %% ========================================
    
    %% App relationships
    App --> AppRouter
    App --> AppTheme
    
    %% Auth relationships
    LoginScreen --> AuthProvider
    AuthProvider --> MicrosoftAuthService
    AuthProvider --> User
    
    %% Navigation
    HomeScreen --> AppRouter
    
    %% Comisiones relationships
    ComisionScreen --> ComisionFormProvider
    ComisionFormProvider --> ComisionRepository
    ComisionFormProvider --> PDFGeneratorService
    ComisionFormProvider --> ExcelGraphService
    ComisionRepository <|.. ComisionRepositoryImpl
    ComisionRepositoryImpl --> ComisionLocalDataSource
    ComisionRepositoryImpl --> ComisionRemoteDataSource
    ComisionRemoteDataSource --> ExcelGraphService
    ComisionFormProvider --> Comision
    Comision --> ComisionValidation
    
    %% Recetario relationships
    RecetarioScreen --> RecetarioFormProvider
    RecetarioFormProvider --> RecetarioRepository
    RecetarioFormProvider --> PDFGeneratorService
    RecetarioFormProvider --> ExcelGraphService
    RecetarioRepository <|.. RecetarioRepositoryImpl
    RecetarioRepositoryImpl --> RecetarioLocalDataSource
    RecetarioRepositoryImpl --> RecetarioRemoteDataSource
    RecetarioRemoteDataSource --> ExcelGraphService
    RecetarioFormProvider --> Receta
    Receta --> RecetaValidation
    Receta --> ProductoReceta
    
    %% Honorarios relationships
    HonorariosScreen --> HonorariosFormProvider
    HonorariosFormProvider --> HonorariosRepository
    HonorariosFormProvider --> PDFGeneratorService
    HonorariosFormProvider --> ExcelGraphService
    HonorariosRepository <|.. HonorariosRepositoryImpl
    HonorariosRepositoryImpl --> HonorariosLocalDataSource
    HonorariosRepositoryImpl --> HonorariosRemoteDataSource
    HonorariosRemoteDataSource --> ExcelGraphService
    HonorariosFormProvider --> Honorario
    Honorario --> HonorarioValidation
    
    %% Maquinaria relationships
    MaquinariaScreen --> MaquinariaFormProvider
    MaquinariaFormProvider --> MaquinariaRepository
    MaquinariaFormProvider --> PDFGeneratorService
    MaquinariaFormProvider --> ExcelGraphService
    MaquinariaRepository <|.. MaquinariaRepositoryImpl
    MaquinariaRepositoryImpl --> MaquinariaLocalDataSource
    MaquinariaRepositoryImpl --> MaquinariaRemoteDataSource
    MaquinariaRemoteDataSource --> ExcelGraphService
    MaquinariaFormProvider --> Maquinaria
    Maquinaria --> MaquinariaValidation
    
    %% Shared services
    ExcelGraphService --> MicrosoftAuthService
```

## 🔄 Diagrama de Flujo de Navegación

```mermaid
graph TD
    A[App Start] --> B{Auth Status?}
    B -->|Authenticated| C[Home Screen]
    B -->|Not Authenticated| D[Login Screen]
    
    D -->|Login Microsoft| E[Microsoft OAuth]
    D -->|Login Guest| F[Guest Mode]
    
    E --> C
    F --> C
    
    C -->|Button 1| G[Recetario]
    C -->|Button 2| H[Comisiones]
    C -->|Button 3| I[Honorarios]
    C -->|Button 4| J[Maquinaria]
    
    G --> G1[Lista Recetas]
    G1 --> G2[Nueva Receta]
    G2 --> G3{Save}
    G3 -->|Local| G4[SharedPreferences]
    G3 -->|Remote| G5[Excel OneDrive]
    G2 --> G6[Generar PDF]
    
    H --> H1[Lista Comisiones]
    H1 --> H2[Nueva Comisión]
    H2 --> H3{Save}
    H3 -->|Local| H4[SharedPreferences]
    H3 -->|Remote| H5[Excel OneDrive]
    H2 --> H6[Generar PDF]
    
    I --> I1[Lista Honorarios]
    I1 --> I2[Nuevo Honorario]
    I2 --> I3{Save}
    I3 -->|Local| I4[SharedPreferences]
    I3 -->|Remote| I5[Excel OneDrive]
    I2 --> I6[Generar PDF]
    
    J --> J1[Lista Maquinaria]
    J1 --> J2[Nueva Maquinaria]
    J2 --> J3{Save}
    J3 -->|Local| J4[SharedPreferences]
    J3 -->|Remote| J5[Excel OneDrive]
    J2 --> J6[Generar PDF]
    
    style C fill:#4CAF50
    style D fill:#2196F3
    style G fill:#FF9800
    style H fill:#FF9800
    style I fill:#FF9800
    style J fill:#FF9800
```

## 🏛️ Diagrama de Arquitectura por Capas

```mermaid
graph TB
    subgraph Presentation["🎨 PRESENTATION LAYER"]
        UI1[LoginScreen]
        UI2[HomeScreen]
        UI3[ComisionScreen]
        UI4[RecetarioScreen]
        UI5[HonorariosScreen]
        UI6[MaquinariaScreen]
        
        P1[AuthProvider]
        P2[ComisionFormProvider]
        P3[RecetarioFormProvider]
        P4[HonorariosFormProvider]
        P5[MaquinariaFormProvider]
    end
    
    subgraph Domain["💼 DOMAIN LAYER"]
        E1[User]
        E2[Comision]
        E3[Receta]
        E4[Honorario]
        E5[Maquinaria]
        
        R1[ComisionRepository Interface]
        R2[RecetarioRepository Interface]
        R3[HonorariosRepository Interface]
        R4[MaquinariaRepository Interface]
        
        V1[Validations]
    end
    
    subgraph Data["💾 DATA LAYER"]
        RI1[ComisionRepositoryImpl]
        RI2[RecetarioRepositoryImpl]
        RI3[HonorariosRepositoryImpl]
        RI4[MaquinariaRepositoryImpl]
        
        L1[LocalDataSources]
        L2[RemoteDataSources]
    end
    
    subgraph Core["⚙️ CORE LAYER"]
        S1[MicrosoftAuthService]
        S2[ExcelGraphService]
        S3[PDFGeneratorService]
        S4[AppRouter]
        S5[AppTheme]
    end
    
    UI3 --> P2
    UI4 --> P3
    UI5 --> P4
    UI6 --> P5
    
    P2 --> R1
    P3 --> R2
    P4 --> R3
    P5 --> R4
    
    R1 --> RI1
    R2 --> RI2
    R3 --> RI3
    R4 --> RI4
    
    RI1 --> L1
    RI1 --> L2
    RI2 --> L1
    RI2 --> L2
    RI3 --> L1
    RI3 --> L2
    RI4 --> L1
    RI4 --> L2
    
    P2 --> S2
    P2 --> S3
    P3 --> S2
    P3 --> S3
    P4 --> S2
    P4 --> S3
    P5 --> S2
    P5 --> S3
    
    L2 --> S2
    S2 --> S1
    P1 --> S1
    
    style Presentation fill:#E3F2FD
    style Domain fill:#FFF3E0
    style Data fill:#E8F5E9
    style Core fill:#F3E5F5
```

## 📝 Notas de Diseño

### Patrones de Diseño Utilizados

1. **Clean Architecture**: Separación en capas (Presentation, Domain, Data, Core)
2. **Repository Pattern**: Abstracción de la fuente de datos
3. **Provider Pattern**: Gestión de estado reactivo
4. **Dependency Injection**: Inyección de dependencias en constructores
5. **Strategy Pattern**: Diferentes estrategias de almacenamiento (Local/Remote)
6. **Factory Pattern**: Creación de objetos desde JSON
7. **Singleton Pattern**: Servicios compartidos (AuthService, PDFService, etc.)

### Principios SOLID

- **S**ingle Responsibility: Cada clase tiene una única responsabilidad
- **O**pen/Closed: Abierto a extensión, cerrado a modificación
- **L**iskov Substitution: Las implementaciones pueden sustituir interfaces
- **I**nterface Segregation: Interfaces específicas por feature
- **D**ependency Inversion: Dependencias apuntan a abstracciones

### Ventajas de esta Arquitectura

✅ **Escalable**: Fácil agregar nuevos módulos  
✅ **Testeable**: Cada capa puede testearse independientemente  
✅ **Mantenible**: Cambios localizados, bajo acoplamiento  
✅ **Reutilizable**: Código compartido en Core  
✅ **Desacoplado**: Las capas no se conocen entre sí  
