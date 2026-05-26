# 🍵 Plan de Implementación: Aplicación **Caffenio**

> **Stack:** Flutter 3.x · Dart 3.x · Firebase (Auth + Firestore + Storage + Analytics) · Provider · VS Code  
> **Plataformas objetivo:** Android · iOS · Web  
> **Versión del documento:** 1.0.0  
> **Propósito:** Documento maestro de planificación. Sin código. Arquitectura, decisiones técnicas, flujos y estándares definidos al máximo detalle para ejecución por cualquier desarrollador, sin ambigüedad.

---

## 📐 Índice General

1. [Fase 0 — Definición de Alcance y Requisitos](#fase-0)
2. [Fase 1 — Configuración del Entorno](#fase-1)
3. [Fase 2 — Arquitectura y Estructura del Proyecto](#fase-2)
4. [Fase 3 — Sistema de Diseño UI/UX](#fase-3)
5. [Fase 4 — Dependencias (`pubspec.yaml`)](#fase-4)
6. [Fase 5 — Configuración de Firebase](#fase-5)
7. [Fase 6 — Autenticación (Email/Password + Google)](#fase-6)
8. [Fase 7 — Esquema Firestore y Capa de Datos](#fase-7)
9. [Fase 8 — Providers y Gestión de Estado](#fase-8)
10. [Fase 9 — Pantallas y Navegación](#fase-9)
11. [Fase 10 — Módulos Funcionales de Caffenio](#fase-10)
12. [Fase 11 — Pruebas y Calidad](#fase-11)
13. [Fase 12 — Construcción y Despliegue](#fase-12)
14. [Apéndice A — pubspec.yaml completo](#apendice-a)
15. [Apéndice B — Reglas de Seguridad Firestore](#apendice-b)
16. [Apéndice C — Checklist de Validación](#apendice-c)
17. [Apéndice D — Convenciones del Equipo](#apendice-d)

---

## Fase 0 — Definición de Alcance y Requisitos {#fase-0}

### 0.1 Propósito de la Aplicación

Caffenio es una aplicación móvil y web para la gestión integral de una cadena de cafeterías. Cubre dos mundos simultáneos:

- **App de cliente:** Catálogo de productos, pedidos con personalización (tamaño, leche, shots), programa de lealtad con puntos, historial de compras, promociones y cupones.
- **App de administrador/barista:** Panel de gestión de pedidos en tiempo real, control de inventario por sucursal, alta/baja de productos, reportes de ventas.

### 0.2 Roles de Usuario

| Rol | Acceso | Descripción |
|---|---|---|
| `guest` | Solo lectura del catálogo | Sin sesión activa |
| `customer` | Toda la app cliente | Usuario registrado con email/Google |
| `barista` | Panel de pedidos de su sucursal | Staff asignado a una sucursal |
| `admin` | Panel completo de gestión | Dueño/gerente con acceso total |

### 0.3 Funcionalidades MVP (v1.0)

**Cliente:**
- [ ] Registro con email/contraseña y con Google
- [ ] Inicio de sesión, cierre de sesión, recuperación de contraseña
- [ ] Perfil de usuario (foto, nombre, dirección de entrega)
- [ ] Catálogo de productos con filtro por categoría
- [ ] Detalle de producto con personalización (tamaño, tipo de leche, extras)
- [ ] Carrito de compras y generación de pedido
- [ ] Historial de pedidos con estado en tiempo real
- [ ] Programa de lealtad (puntos, nivel, canje)
- [ ] Notificaciones push cuando el pedido está listo

**Administrador:**
- [ ] Dashboard con métricas del día (pedidos, ventas, productos más pedidos)
- [ ] Lista de pedidos activos con cambio de estado
- [ ] CRUD completo de productos y categorías
- [ ] Vista de inventario por sucursal
- [ ] Gestión básica de promociones y descuentos

### 0.4 Funcionalidades Futuras (v2.0+)

- Pagos en línea integrados (Stripe o MercadoPago)
- Mapa de sucursales con geolocalización
- Chat de soporte en tiempo real
- Escaneo de QR para check-in en sucursal
- Pedidos programados
- Módulo de reportes avanzados con exportación a PDF/Excel

### 0.5 Control de Versiones y Ramas Git

```
main            → Producción estable
develop         → Integración de features
feature/*       → Una rama por funcionalidad (ej. feature/auth, feature/catalog)
bugfix/*        → Correcciones de errores
release/*       → Preparación de versión (release/v1.0.0)
hotfix/*        → Parches urgentes sobre main
```

- **Mensajes de commit:** Seguir Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- **Code review:** Todo merge a `develop` requiere Pull Request aprobado por al menos 1 revisor
- **Tags de versión:** Semver estricto `vMAJOR.MINOR.PATCH`

---

## Fase 1 — Configuración del Entorno {#fase-1}

### 1.1 Requisitos de Sistema

| Herramienta | Versión mínima | Notas |
|---|---|---|
| Flutter SDK | 3.19.x (stable) | `flutter channel stable && flutter upgrade` |
| Dart SDK | 3.3.x | Incluido con Flutter |
| Android Studio | Hedgehog 2023.1+ | Para Android SDK y emuladores |
| Xcode | 15.x | Solo en macOS, para iOS |
| VS Code | 1.87+ | Editor principal |
| Node.js | 18.x LTS | Para Firebase CLI |
| Firebase CLI | 13.x | `npm install -g firebase-tools` |
| Git | 2.40+ | Control de versiones |

### 1.2 Extensiones de VS Code (Obligatorias)

| Extensión | ID | Propósito |
|---|---|---|
| Flutter | `dart-code.flutter` | Soporte completo Flutter |
| Dart | `dart-code.dart-code` | Lenguaje Dart |
| Firebase Explorer | `googlecloudtools.cloudcode` | Explorar Firebase desde el editor |
| GitLens | `eamodio.gitlens` | Historial y blame de Git |
| Error Lens | `usernamehakki.error-lens` | Errores inline en el editor |
| Pubspec Assist | `jeroen-meijer.pubspec-assist` | Agregar paquetes fácilmente |
| Material Icon Theme | `pkief.material-icon-theme` | Iconos de archivos |
| Bracket Pair Colorizer | `coenraads.bracket-pair-colorizer-2` | Legibilidad de código |
| REST Client | `humao.rest-client` | Probar endpoints (si se agrega backend) |
| Conventional Commits | `vivaxy.vscode-conventional-commits` | Mensajes de commit guiados |

### 1.3 Configuración del Linter (`analysis_options.yaml`)

Crear este archivo en la raíz del proyecto con las siguientes configuraciones:
- Heredar de `package:flutter_lints/flutter.yaml`
- Activar reglas adicionales: `prefer_single_quotes`, `always_use_package_imports`, `avoid_print`, `unawaited_futures`, `cancel_subscriptions`, `close_sinks`
- Desactivar reglas que generen ruido innecesario según el equipo

### 1.4 Configuración de `settings.json` de VS Code

Configurar para el workspace (`.vscode/settings.json`):
- Formateo automático al guardar (`editor.formatOnSave: true`)
- Longitud de línea: 80 caracteres
- Editor de Dart como formateador por defecto
- Tab size: 2 espacios para Dart/YAML
- Excluir carpetas de búsqueda: `build/`, `.dart_tool/`, `.pub-cache/`

### 1.5 Inicialización del Proyecto Flutter

```bash
# 1. Crear el proyecto con soporte para todas las plataformas objetivo
flutter create --org com.caffenio --project-name caffenio_app \
  --platforms android,ios,web caffenio_app

# 2. Verificar que todo esté correcto
cd caffenio_app
flutter doctor -v
flutter run

# 3. Vincular con repositorio Git
git init
git add .
git commit -m "chore: initial project setup"
git remote add origin 
git push -u origin main
```

### 1.6 Configuración de Firebase CLI

```bash
# Autenticar con cuenta Google
firebase login

# Inicializar (solo para Firestore rules, Hosting si aplica)
firebase init

# Instalar FlutterFire CLI (para configuración multiplataforma automática)
dart pub global activate flutterfire_cli

# Configurar Firebase en el proyecto Flutter
flutterfire configure --project=caffenio-prod
```

> ⚠️ **Importante:** El comando `flutterfire configure` genera automáticamente el archivo `firebase_options.dart` con las configuraciones de todas las plataformas. Este archivo **no se versiona** en Git si contiene claves sensibles. Agregar al `.gitignore`.

---

## Fase 2 — Arquitectura y Estructura del Proyecto {#fase-2}

### 2.1 Patrón Arquitectónico

Se adopta **Feature-First Clean Architecture** con las siguientes capas dentro de cada feature:

```
presentation/   → Widgets, Screens, Providers (UI-facing)
domain/         → Modelos de negocio, interfaces de repositorio
data/           → Repositorios concretos, servicios Firebase, DTOs
```

Ventajas para Caffenio:
- Cada módulo (auth, catalog, orders, loyalty) es completamente independiente
- Fácil de probar: la capa `domain` no depende de Flutter ni Firebase
- Escalable: agregar features no afecta otras
- Separación estricta entre UI y lógica de negocio

### 2.2 Gestión de Estado: `provider`

- `ChangeNotifier` para estados simples (auth, UI local)
- `ChangeNotifierProxyProvider` cuando un provider depende de otro
- `StreamProvider` para datos en tiempo real de Firestore
- `MultiProvider` en la raíz de la app para inyección global
- **Regla:** Nunca acceder a Firebase directamente desde un Widget. Siempre a través de un Provider → Repository → Service.

### 2.3 Estructura de Carpetas Completa

```
caffenio_app/
├── android/                          # Configuración nativa Android
│   └── app/
│       ├── google-services.json      # Config Firebase Android
│       └── build.gradle              # Dependencias Android
├── ios/                              # Configuración nativa iOS
│   └── Runner/
│       └── GoogleService-Info.plist  # Config Firebase iOS
├── web/                              # Configuración web
│   └── index.html
├── assets/
│   ├── images/                       # PNG, JPG, WebP
│   │   ├── logo/
│   │   ├── onboarding/
│   │   └── placeholders/
│   ├── icons/                        # SVG iconos propios
│   ├── fonts/                        # Tipografías .ttf/.otf
│   │   ├── Montserrat-*.ttf
│   │   └── Lato-*.ttf
│   ├── animations/                   # Archivos .json de Lottie
│   └── translations/                 # Archivos .arb para i18n
│       ├── app_es.arb
│       └── app_en.arb
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart       # Strings, números mágicos
│   │   │   ├── firebase_constants.dart  # Nombres de colecciones
│   │   │   ├── route_constants.dart     # Nombres de rutas
│   │   │   └── asset_constants.dart     # Paths de assets
│   │   ├── errors/
│   │   │   ├── app_exception.dart       # Excepción base custom
│   │   │   ├── auth_exception.dart      # Errores de autenticación
│   │   │   └── firestore_exception.dart # Errores de Firestore
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart   # Validaciones, formateo
│   │   │   ├── context_extensions.dart  # Theme, media query
│   │   │   └── datetime_extensions.dart # Formateo de fechas
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # ThemeData light/dark
│   │   │   ├── app_colors.dart          # Paleta de colores Caffenio
│   │   │   ├── app_typography.dart      # TextTheme, estilos
│   │   │   ├── app_spacing.dart         # Constantes de espaciado
│   │   │   ├── app_shadows.dart         # BoxShadow reutilizables
│   │   │   └── app_border_radius.dart   # BorderRadius estándar
│   │   ├── utils/
│   │   │   ├── validators.dart          # Validaciones de formularios
│   │   │   ├── formatters.dart          # Moneda, fecha, número
│   │   │   ├── logger.dart              # Logging controlado
│   │   │   └── debouncer.dart           # Anti-rebote para búsquedas
│   │   ├── services/
│   │   │   ├── analytics_service.dart   # Firebase Analytics wrapper
│   │   │   ├── notification_service.dart# FCM wrapper
│   │   │   └── storage_service.dart     # Firebase Storage wrapper
│   │   └── network/
│   │       └── connectivity_service.dart # Detectar conexión
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   ├── secondary_button.dart
│   │   │   │   ├── icon_button_custom.dart
│   │   │   │   └── loading_button.dart
│   │   │   ├── inputs/
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── password_field.dart
│   │   │   │   └── search_field.dart
│   │   │   ├── cards/
│   │   │   │   ├── product_card.dart
│   │   │   │   ├── order_card.dart
│   │   │   │   └── promotion_card.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirm_dialog.dart
│   │   │   │   ├── error_dialog.dart
│   │   │   │   └── loading_dialog.dart
│   │   │   ├── feedback/
│   │   │   │   ├── empty_state.dart
│   │   │   │   ├── error_state.dart
│   │   │   │   ├── loading_skeleton.dart
│   │   │   │   └── shimmer_widget.dart
│   │   │   ├── navigation/
│   │   │   │   ├── custom_bottom_nav.dart
│   │   │   │   └── custom_app_bar.dart
│   │   │   └── misc/
│   │   │       ├── badge_widget.dart
│   │   │       ├── tag_chip.dart
│   │   │       └── rating_stars.dart
│   │   └── models/
│   │       └── paginated_result.dart    # Wrapper para listas paginadas
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository_impl.dart
│   │   │   │   └── user_dto.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_repository.dart  # Interfaz (contrato)
│   │   │   │   └── user_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       └── screens/
│   │   │           ├── splash_screen.dart
│   │   │           ├── onboarding_screen.dart
│   │   │           ├── login_screen.dart
│   │   │           ├── register_screen.dart
│   │   │           └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── featured_banner.dart
│   │   │           └── quick_actions_row.dart
│   │   ├── catalog/
│   │   │   ├── data/
│   │   │   │   ├── catalog_repository_impl.dart
│   │   │   │   └── product_dto.dart
│   │   │   ├── domain/
│   │   │   │   ├── catalog_repository.dart
│   │   │   │   ├── product_model.dart
│   │   │   │   └── category_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── catalog_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── catalog_screen.dart
│   │   │       │   └── product_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── category_filter.dart
│   │   │           ├── product_grid.dart
│   │   │           └── customization_sheet.dart
│   │   ├── cart/
│   │   │   ├── domain/
│   │   │   │   └── cart_item_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── cart_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── cart_screen.dart
│   │   │       └── widgets/
│   │   │           └── cart_item_tile.dart
│   │   ├── orders/
│   │   │   ├── data/
│   │   │   │   ├── order_repository_impl.dart
│   │   │   │   └── order_dto.dart
│   │   │   ├── domain/
│   │   │   │   ├── order_repository.dart
│   │   │   │   └── order_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── order_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── orders_screen.dart
│   │   │       │   └── order_detail_screen.dart
│   │   │       └── widgets/
│   │   │           └── order_status_tracker.dart
│   │   ├── loyalty/
│   │   │   ├── data/
│   │   │   │   └── loyalty_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── loyalty_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── loyalty_provider.dart
│   │   │       └── screens/
│   │   │           └── loyalty_screen.dart
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   │   └── profile_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── profile_model.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── profile_provider.dart
│   │   │       └── screens/
│   │   │           ├── profile_screen.dart
│   │   │           └── edit_profile_screen.dart
│   │   ├── admin/
│   │   │   ├── data/
│   │   │   │   └── admin_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── admin_provider.dart
│   │   │       └── screens/
│   │   │           ├── admin_dashboard_screen.dart
│   │   │           ├── manage_orders_screen.dart
│   │   │           ├── manage_products_screen.dart
│   │   │           └── inventory_screen.dart
│   │   └── settings/
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── settings_provider.dart
│   │           └── screens/
│   │               └── settings_screen.dart
│   ├── navigation/
│   │   ├── app_router.dart            # GoRouter configuración central
│   │   ├── route_guards.dart          # Redirecciones por autenticación/rol
│   │   └── nav_observer.dart          # Observer para analytics de navegación
│   ├── firebase_options.dart          # Generado por FlutterFire CLI
│   └── main.dart                      # Punto de entrada
├── test/
│   ├── unit/
│   │   ├── auth/
│   │   ├── catalog/
│   │   └── orders/
│   ├── widget/
│   │   ├── shared/
│   │   └── features/
│   └── integration/
│       └── flows/
├── .env                               # Variables de entorno locales (NO versionar)
├── .env.example                       # Template de variables (SÍ versionar)
├── .gitignore
├── analysis_options.yaml
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
└── README.md
```

---

## Fase 3 — Sistema de Diseño UI/UX {#fase-3}

### 3.1 Identidad Visual de Caffenio

**Concepto:** Sofisticación cálida. Una app que se siente como entrar a una cafetería premium: cálida, acogedora, pero ordenada y eficiente.

### 3.2 Paleta de Colores

```
PRIMARIO (Rojo Caffenio):
  Primary          → #D32F2F  (rojo intenso, acciones principales)
  Primary Light    → #EF5350  (hover, estados activos)
  Primary Dark     → #B71C1C  (pressed, sombras)
  Primary Container→ #FFCDD2  (fondos de chips, tags)

SECUNDARIO (Café/Ámbar):
  Secondary        → #5D4037  (café oscuro, textos sobre fondo claro)
  Secondary Light  → #8D6E63
  Secondary Dark   → #3E2723

NEUTROS:
  Background       → #FAFAFA  (fondo principal)
  Surface          → #FFFFFF  (tarjetas, modales)
  Surface Variant  → #F5F5F5  (secciones secundarias)
  On Background    → #1C1B1F  (texto principal)
  On Surface       → #49454F  (texto secundario)
  Outline          → #CAC4D0  (bordes, separadores)

SEMÁNTICOS:
  Success          → #2E7D32  (#E8F5E9 container)
  Warning          → #F57F17  (#FFF9C4 container)
  Error            → #C62828  (#FFEBEE container)
  Info             → #1565C0  (#E3F2FD container)

MODO OSCURO:
  Background Dark  → #1C1B1F
  Surface Dark     → #2B2930
  Primary Dark Mode→ #EF9A9A  (más suave para contraste)
```

### 3.3 Tipografía

```
DISPLAY / HEADINGS:
  Familia: Playfair Display (Google Fonts)
  Uso: Logo, títulos de pantalla, nombres de productos destacados
  Pesos: 700 (Bold)

BODY / INTERFACE:
  Familia: Nunito (Google Fonts)
  Uso: Texto de interfaz, botones, inputs, listas
  Pesos: 400 (Regular), 500 (Medium), 700 (Bold)

MONOESPACIADO (código/IDs):
  Familia: JetBrains Mono
  Uso: Códigos de pedido, referencias de pago

ESCALA TIPOGRÁFICA (Material You):
  Display Large:   57sp / Playfair 700
  Display Medium:  45sp / Playfair 700
  Headline Large:  32sp / Nunito 700
  Headline Medium: 28sp / Nunito 700
  Headline Small:  24sp / Nunito 600
  Title Large:     22sp / Nunito 600
  Title Medium:    16sp / Nunito 600
  Title Small:     14sp / Nunito 600
  Body Large:      16sp / Nunito 400
  Body Medium:     14sp / Nunito 400
  Body Small:      12sp / Nunito 400
  Label Large:     14sp / Nunito 500
  Label Medium:    12sp / Nunito 500
  Label Small:     11sp / Nunito 500
```

### 3.4 Sistema de Espaciado (8px Grid)

```
xs:   4px
sm:   8px
md:   16px
lg:   24px
xl:   32px
xxl:  48px
xxxl: 64px
```

### 3.5 Border Radius

```
xs:     4px  (chips pequeños)
sm:     8px  (inputs, botones pequeños)
md:     12px (tarjetas compactas)
lg:     16px (tarjetas normales)
xl:     24px (tarjetas destacadas)
full:   100px (botones pill, avatares)
```

### 3.6 Sombras

```
sm:   0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04)
md:   0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.05)
lg:   0 10px 15px rgba(0,0,0,0.10), 0 4px 6px rgba(0,0,0,0.05)
xl:   0 20px 25px rgba(0,0,0,0.10), 0 10px 10px rgba(0,0,0,0.04)
```

### 3.7 Pantallas y Flujos UX

```
FLUJO DE ONBOARDING:
SplashScreen (2s) → OnboardingScreen (3 slides) → LoginScreen

FLUJO DE AUTENTICACIÓN:
LoginScreen → [éxito] → RoleRouter → HomeScreen / AdminDashboard
           → [sin cuenta] → RegisterScreen → [éxito] → HomeScreen
           → [olvidé pass] → ForgotPasswordScreen → [email enviado] → LoginScreen

FLUJO DE COMPRA (Cliente):
HomeScreen → CatalogScreen → ProductDetailScreen → [agregar al carrito]
          → CartScreen → ConfirmOrderScreen → OrderTrackingScreen

FLUJO ADMINISTRATIVO:
AdminDashboard → ManageOrdersScreen → [cambiar estado] → (actualiza cliente en tiempo real)
               → ManageProductsScreen → ProductFormScreen
               → InventoryScreen

FLUJO DE LEALTAD:
ProfileScreen → LoyaltyScreen → [canjear puntos] → CartScreen (descuento aplicado)
```

### 3.8 Estados de UI Mandatorios

Cada pantalla con datos remotos DEBE implementar los siguientes estados:

- **`loading`** → Shimmer/Skeleton (nunca un spinner circular genérico)
- **`loaded`** → Contenido normal
- **`empty`** → Ilustración + mensaje descriptivo + CTA (ej. "Explorar el menú")
- **`error`** → Mensaje de error legible + botón "Reintentar"
- **`offline`** → Banner de aviso + mostrar datos en caché si existen

### 3.9 Accesibilidad

- Contraste mínimo AA: 4.5:1 para texto normal, 3:1 para texto grande
- `Semantics` widgets en elementos interactivos sin texto
- Fuentes escalables: no usar `textScaleFactor` fijo
- Soporte completo para lectores de pantalla (TalkBack / VoiceOver)
- Área mínima de toque: 48×48dp

---

## Fase 4 — Dependencias (`pubspec.yaml`) {#fase-4}

### 4.1 Versiones y Principios

- Usar restricciones `^x.y.z` para actualizaciones patch/minor automáticas
- Ejecutar `flutter pub outdated` antes de cada release para revisar versiones
- Documentar el propósito de cada dependencia
- No agregar paquetes sin justificación: cada uno agrega peso al build

### 4.2 Dependencias por Categoría

#### Firebase (Core)
| Paquete | Versión | Propósito |
|---|---|---|
| `firebase_core` | `^2.27.0` | Inicialización de Firebase |
| `firebase_auth` | `^4.17.0` | Autenticación |
| `cloud_firestore` | `^4.15.0` | Base de datos en tiempo real |
| `firebase_storage` | `^11.6.0` | Almacenamiento de archivos |
| `firebase_analytics` | `^10.8.0` | Analíticas de uso |
| `firebase_messaging` | `^14.7.0` | Notificaciones push (FCM) |
| `firebase_crashlytics` | `^3.4.0` | Reportes de errores en producción |
| `firebase_remote_config` | `^4.3.0` | Configuración remota sin deploy |

#### Autenticación Social
| Paquete | Versión | Propósito |
|---|---|---|
| `google_sign_in` | `^6.2.1` | Inicio de sesión con Google |

#### Estado y Arquitectura
| Paquete | Versión | Propósito |
|---|---|---|
| `provider` | `^6.1.2` | Gestión de estado con ChangeNotifier |
| `get_it` | `^7.7.0` | Inyección de dependencias (service locator) |
| `equatable` | `^2.0.5` | Comparación de objetos por valor |
| `dartz` | `^0.10.1` | Tipos Either para manejo funcional de errores |

#### Navegación
| Paquete | Versión | Propósito |
|---|---|---|
| `go_router` | `^13.2.0` | Enrutamiento declarativo con guards |

#### UI y Componentes
| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_svg` | `^2.0.10+1` | Renderizar SVG |
| `cached_network_image` | `^3.3.1` | Cache de imágenes de red |
| `shimmer` | `^3.0.0` | Efecto skeleton de carga |
| `lottie` | `^3.1.0` | Animaciones Lottie JSON |
| `carousel_slider` | `^4.2.1` | Banners y carruseles |
| `smooth_page_indicator` | `^1.1.0` | Indicadores de onboarding |
| `flutter_rating_bar` | `^4.0.1` | Estrellas de calificación |
| `badges` | `^3.1.2` | Badge numérico (carrito, notificaciones) |
| `skeletonizer` | `^1.1.1` | Skeleton automático de widgets |
| `gap` | `^3.0.1` | Espaciado semántico en layouts |
| `animate_do` | `^3.3.4` | Animaciones de entrada/salida |

#### Formularios y Validación
| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_form_builder` | `^9.3.0` | Formularios reactivos avanzados |
| `form_builder_validators` | `^10.0.1` | Validadores para form_builder |
| `mask_text_input_formatter` | `^2.9.0` | Máscaras de input (teléfono, tarjeta) |

#### Multimedia y Archivos
| Paquete | Versión | Propósito |
|---|---|---|
| `image_picker` | `^1.0.7` | Seleccionar imagen de galería/cámara |
| `image_cropper` | `^5.0.1` | Recortar foto de perfil |
| `file_picker` | `^8.0.3` | Seleccionar archivos genéricos |

#### Localización e Internacionalización
| Paquete | Versión | Propósito |
|---|---|---|
| `intl` | `^0.19.0` | Formateo de fechas, moneda, plurales |
| `flutter_localizations` | SDK | Soporte de idiomas de Flutter |
| `intl_utils` | `^2.8.7` | Generación de código ARB |

#### Persistencia Local
| Paquete | Versión | Propósito |
|---|---|---|
| `shared_preferences` | `^2.2.3` | Preferencias simples (tema, idioma) |
| `hive_flutter` | `^1.1.0` | Base de datos local rápida |
| `hive` | `^2.2.3` | Core de Hive |
| `flutter_secure_storage` | `^9.0.0` | Almacenamiento seguro de tokens |

#### Conectividad y Red
| Paquete | Versión | Propósito |
|---|---|---|
| `connectivity_plus` | `^5.0.2` | Detectar estado de red |
| `internet_connection_checker_plus` | `^2.1.0` | Verificar conexión a internet real |

#### Utilidades
| Paquete | Versión | Propósito |
|---|---|---|
| `uuid` | `^4.3.3` | Generar UUIDs únicos |
| `timeago` | `^3.6.1` | Fechas relativas ("hace 5 min") |
| `url_launcher` | `^6.2.6` | Abrir URLs, teléfono, email |
| `share_plus` | `^9.0.0` | Compartir contenido nativo |
| `package_info_plus` | `^8.0.0` | Info del paquete (versión) |
| `device_info_plus` | `^10.1.0` | Info del dispositivo |
| `permission_handler` | `^11.3.0` | Manejo de permisos del sistema |
| `local_auth` | `^2.2.0` | Biometría (huella/Face ID) |
| `flutter_dotenv` | `^5.1.0` | Variables de entorno desde .env |

#### Notificaciones
| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_local_notifications` | `^17.1.2` | Notificaciones locales |

#### Branding y Assets
| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_native_splash` | `^2.3.11` | Splash screen nativo (no blanco) |
| `flutter_launcher_icons` | `^0.13.1` | Iconos de app para todas las plataformas |

#### Google Fonts
| Paquete | Versión | Propósito |
|---|---|---|
| `google_fonts` | `^6.2.1` | Fuentes Nunito, Playfair Display |

#### Dev Dependencies (No entran al build de producción)
| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_lints` | `^4.0.0` | Reglas de linting recomendadas |
| `build_runner` | `^2.4.9` | Generación de código (Hive adapters, JSON) |
| `hive_generator` | `^2.0.1` | Generador de adapters para Hive |
| `json_serializable` | `^6.7.1` | Generación de fromJson/toJson |
| `mockito` | `^5.4.4` | Mocks para pruebas unitarias |
| `fake_cloud_firestore` | `^2.5.1` | Firestore simulado para tests |
| `firebase_auth_mocks` | `^0.13.0` | Auth simulada para tests |
| `bloc_test` | `^9.1.6` | Tests de estado (compatible con provider) |

---

## Fase 5 — Configuración de Firebase {#fase-5}

### 5.1 Crear Proyecto en Firebase Console

1. Ir a https://console.firebase.google.com
2. **Nombre del proyecto:** `caffenio-prod`
3. Crear también `caffenio-dev` para ambiente de desarrollo separado
4. Habilitar Google Analytics durante la creación

### 5.2 Configurar Servicios

#### Authentication
- Método: **Email/Password** → Habilitar
- Método: **Google** → Habilitar (requiere SHA-1 de Android)
- Configurar: Plantilla de correo de verificación con branding Caffenio
- Configurar: Plantilla de restablecimiento de contraseña
- Política de contraseña: Mínimo 8 caracteres, al menos 1 número

#### Cloud Firestore
- Modo inicial: **Modo de prueba** (30 días) → Migrar a producción con reglas antes del launch
- Región: `nam5` (us-central) o la más cercana a la mayoría de usuarios
- Habilitar caché offline

#### Firebase Storage
- Reglas iniciales: Solo usuarios autenticados pueden leer/escribir su propia carpeta
- Estructura de carpetas:
  ```
  /users/{uid}/avatar.jpg
  /products/{productId}/main.jpg
  /products/{productId}/gallery/{index}.jpg
  /promotions/{promotionId}/banner.jpg
  ```

#### Cloud Messaging (FCM)
- Generar clave de servidor (para envío desde backend o Cloud Functions)
- Configurar APNs para iOS (requiere certificado Apple)
- Crear topics: `all-users`, `customers`, `admins`, `sucursal-{id}`

#### Analytics
- Configurar eventos personalizados: `product_viewed`, `order_placed`, `loyalty_points_redeemed`, `product_added_to_cart`

#### Crashlytics
- Habilitar en ambas plataformas
- Configurar en CI/CD para dSYM upload (iOS)

#### Remote Config
- Parámetros iniciales:
  - `maintenance_mode` → `false`
  - `min_app_version_android` → `1.0.0`
  - `min_app_version_ios` → `1.0.0`
  - `promo_banner_url` → `""`
  - `points_per_peso` → `1`

### 5.3 Configuración por Plataforma

#### Android
```
Archivo: android/app/google-services.json
Pasos:
1. En Firebase Console → Project Settings → Agregar app Android
2. Package name: com.caffenio.caffenio_app
3. Registrar SHA-1 del keystore de debug y producción
4. Descargar google-services.json
5. Colocar en android/app/
6. Agregar google-services plugin en android/build.gradle y android/app/build.gradle
```

#### iOS
```
Archivo: ios/Runner/GoogleService-Info.plist
Pasos:
1. En Firebase Console → Project Settings → Agregar app iOS
2. Bundle ID: com.caffenio.caffenioApp
3. Descargar GoogleService-Info.plist
4. Agregar al proyecto Xcode (arrastrar a Runner/Runner en Xcode)
5. Configurar APNs en Apple Developer → Certificates
```

#### Web
```
Pasos:
1. En Firebase Console → Project Settings → Agregar app Web
2. Copiar firebaseConfig object
3. Pegar en web/index.html (dentro del script de inicialización)
4. O usar firebase_options.dart generado por flutterfire configure
```

### 5.4 Índices de Firestore

Crear los siguientes índices compuestos en `firestore.indexes.json`:

```
orders: (userId ASC, createdAt DESC)
orders: (sucursalId ASC, status ASC, createdAt DESC)
orders: (status ASC, createdAt DESC)
products: (categoryId ASC, available ASC, name ASC)
products: (available ASC, featured ASC)
loyaltyTransactions: (userId ASC, createdAt DESC)
```

---

## Fase 6 — Sistema de Autenticación {#fase-6}

### 6.1 Modelo de Usuario en Firestore

```
Collection: users
Document ID: {uid} (mismo que Firebase Auth UID)

Campos:
  uid:             String  (PK, mismo que Auth)
  email:           String
  displayName:     String
  photoURL:        String? (URL en Firebase Storage)
  phone:           String?
  role:            String  ('customer' | 'barista' | 'admin')
  sucursalId:      String? (solo para baristas)
  createdAt:       Timestamp
  updatedAt:       Timestamp
  lastLoginAt:     Timestamp
  isActive:        Boolean
  emailVerified:   Boolean
  preferencias:
    notificaciones: Boolean
    tema:           String ('light' | 'dark' | 'system')
    idioma:         String ('es' | 'en')
```

### 6.2 AuthState (Estados de Autenticación)

```
enum AuthStatus {
  initial,       // App recién iniciada, verificando sesión
  authenticated, // Usuario autenticado y perfil cargado
  unauthenticated, // Sin sesión
  loading,       // Operación en proceso
  error,         // Error de autenticación
}
```

### 6.3 Flujos de Autenticación Detallados

#### Registro
1. Usuario llena: nombre, email, contraseña (x2), aceptar términos
2. Validar campos en cliente (sin llamada Firebase)
3. Llamar `createUserWithEmailAndPassword`
4. Si éxito: crear documento en `users/{uid}` con datos básicos y role `customer`
5. Enviar email de verificación (`sendEmailVerification`)
6. Inicializar tarjeta de lealtad en `loyaltyCards/{uid}` con 0 puntos
7. Redirigir a HomeScreen con banner "Verifica tu correo"

#### Login con Email
1. Validar formato de email y que contraseña no esté vacía
2. Llamar `signInWithEmailAndPassword`
3. Si éxito: cargar documento del usuario desde Firestore
4. Determinar rol → redirigir a HomeScreen o AdminDashboard
5. Actualizar `lastLoginAt` en Firestore

#### Login con Google
1. Llamar `GoogleSignIn().signIn()`
2. Obtener `GoogleSignInAuthentication` → crear `GoogleAuthCredential`
3. Llamar `signInWithCredential`
4. Verificar si es usuario nuevo: si `additionalUserInfo.isNewUser == true`, crear documento en Firestore
5. Redirigir según rol

#### Recuperación de Contraseña
1. Usuario ingresa email
2. Llamar `sendPasswordResetEmail`
3. Mostrar pantalla de confirmación ("Revisa tu correo")
4. No revelar si el email existe o no (seguridad)

#### Cierre de Sesión
1. Confirmar con diálogo
2. Limpiar estado local (carrito, preferencias en memoria)
3. Llamar `signOut`
4. Si Google Sign-In: también llamar `GoogleSignIn().signOut()`
5. Redirigir a LoginScreen

### 6.4 Mapeo de Errores de Firebase Auth

| Código Firebase | Mensaje en español para el usuario |
|---|---|
| `email-already-in-use` | Este correo ya está registrado. ¿Quieres iniciar sesión? |
| `invalid-email` | El formato del correo no es válido |
| `weak-password` | La contraseña debe tener al menos 8 caracteres |
| `user-not-found` | No encontramos una cuenta con ese correo |
| `wrong-password` | Contraseña incorrecta. Intenta de nuevo |
| `user-disabled` | Esta cuenta ha sido desactivada |
| `too-many-requests` | Demasiados intentos. Espera unos minutos |
| `network-request-failed` | Sin conexión a internet |
| `requires-recent-login` | Por seguridad, vuelve a iniciar sesión |

### 6.5 Persistencia de Sesión

Firebase Auth mantiene la sesión automáticamente. Al iniciar la app:
1. SplashScreen espera `FirebaseAuth.instance.authStateChanges()` primer evento
2. Si hay usuario activo → cargar perfil desde Firestore → redirigir según rol
3. Si no hay usuario → OnboardingScreen (primera vez) o LoginScreen

---

## Fase 7 — Esquema Firestore y Capa de Datos {#fase-7}

### 7.1 Colecciones Principales

#### `users/{uid}`
Ver estructura completa en Fase 6.1

#### `categories/{categoryId}`
```
id:          String
name:        String
description: String?
iconUrl:     String?
order:       Number  (para ordenar en UI)
isActive:    Boolean
createdAt:   Timestamp
```

#### `products/{productId}`
```
id:            String
categoryId:    String (ref a categories)
name:          String
description:   String
price:         Number
imageUrl:      String
galleryUrls:   String[]
isAvailable:   Boolean
isFeatured:    Boolean
preparationTime: Number (minutos)
tags:          String[]  (['vegano', 'sin gluten', 'nuevo'])
customizationOptions: Map
  sizes:       [{id, name, priceExtra}]  (['chico', 'mediano', 'grande'])
  milkTypes:   [{id, name, priceExtra}]  (['entera', 'descremada', 'vegetal'])
  extras:      [{id, name, priceExtra}]  (['shot extra', 'caramelo', 'canela'])
createdAt:     Timestamp
updatedAt:     Timestamp
```

#### `orders/{orderId}`
```
id:            String (UUID)
userId:        String (ref a users)
sucursalId:    String (ref a sucursales)
employeeId:    String? (barista asignado)
status:        String ('pending'|'confirmed'|'preparing'|'ready'|'delivered'|'cancelled')
items:         Array
  productId:   String
  productName: String (denormalizado para historial)
  quantity:    Number
  unitPrice:   Number
  customizations: Map
    size:      String
    milkType:  String
    extras:    String[]
  subtotal:    Number
subtotal:      Number
discount:      Number
total:         Number
discountCode:  String?
pointsEarned:  Number
pointsRedeemed:Number
paymentMethod: String ('cash'|'card'|'app')
notes:         String?
estimatedReady:Timestamp?
createdAt:     Timestamp
updatedAt:     Timestamp
statusHistory: Array
  status:      String
  timestamp:   Timestamp
  note:        String?
```

#### `sucursales/{sucursalId}`
```
id:          String
name:        String
address:     String
city:        String
phone:       String
schedule:    String
lat:         Number
lng:         Number
isActive:    Boolean
employees:   String[] (UIDs de empleados)
```

#### `loyaltyCards/{uid}`
```
userId:        String
points:        Number
totalEarned:   Number
totalRedeemed: Number
level:         String ('bronze'|'silver'|'gold'|'platinum')
createdAt:     Timestamp
updatedAt:     Timestamp
```

#### `loyaltyTransactions/{transactionId}`
```
id:        String
userId:    String
orderId:   String
type:      String ('earn'|'redeem')
points:    Number
balance:   Number (puntos totales después de la transacción)
note:      String
createdAt: Timestamp
```

#### `promotions/{promotionId}`
```
id:           String
title:        String
description:  String
bannerUrl:    String?
type:         String ('percentage'|'fixed'|'2x1'|'free_item')
value:        Number
minPurchase:  Number?
applicableProducts: String[]? (vacío = todos)
code:         String?  (si requiere cupón)
startDate:    Timestamp
endDate:      Timestamp
isActive:     Boolean
usageLimit:   Number?
usageCount:   Number
createdAt:    Timestamp
```

#### `inventory/{inventoryId}`
```
sucursalId:    String
ingredientId:  String
currentStock:  Number
minStock:      Number
unit:          String
lastUpdated:   Timestamp
```

### 7.2 Capa Repository (Contratos)

Cada feature tiene una interfaz abstract que define el contrato:

```
AuthRepository:
  Future<UserModel> login(String email, String password)
  Future<UserModel> register(String name, String email, String password)
  Future<UserModel> loginWithGoogle()
  Future<void> logout()
  Future<void> sendPasswordReset(String email)
  Future<void> updateProfile(UserModel user)
  Stream<UserModel?> get authStateChanges

CatalogRepository:
  Stream<List<CategoryModel>> getCategories()
  Stream<List<ProductModel>> getProducts({String? categoryId})
  Future<ProductModel> getProductById(String id)
  Future<void> createProduct(ProductModel product)
  Future<void> updateProduct(ProductModel product)
  Future<void> deleteProduct(String id)

OrderRepository:
  Future<String> createOrder(OrderModel order)
  Stream<List<OrderModel>> getUserOrders(String userId)
  Stream<List<OrderModel>> getSucursalOrders(String sucursalId)
  Stream<OrderModel> getOrderById(String orderId)
  Future<void> updateOrderStatus(String orderId, String status)

LoyaltyRepository:
  Stream<LoyaltyModel> getLoyaltyCard(String userId)
  Future<void> addPoints(String userId, int points, String orderId)
  Future<void> redeemPoints(String userId, int points, String orderId)
  Stream<List<LoyaltyTransactionModel>> getTransactions(String userId)
```

### 7.3 Implementación con GetIt (Inyección de Dependencias)

Configurar GetIt en `lib/core/di/injection_container.dart`:

1. Registrar servicios Firebase como singletons (FirebaseAuth, FirebaseFirestore, FirebaseStorage)
2. Registrar repositorios con sus implementaciones concretas
3. Registrar providers con `factory` (nueva instancia por pantalla) o `singleton`
4. Inicializar GetIt antes de `runApp()` en `main.dart`

### 7.4 Paginación de Listas

Para listas grandes (historial de pedidos, catálogo extenso):
- Usar `startAfterDocument` de Firestore para cursor-based pagination
- Implementar `ScrollController` en la UI para detectar scroll al final
- Mantener el último documento como cursor en el Provider
- Cargar 20 items por página

### 7.5 Offline Support

- Llamar `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)` al inicio
- Manejar `FirebaseException` con código `unavailable` para mostrar datos de caché
- Indicar visualmente cuando los datos son de caché (banner sutil)
- Cola de escrituras: Firestore maneja automáticamente las escrituras offline

---

## Fase 8 — Providers y Gestión de Estado {#fase-8}

### 8.1 Árbol de Providers (MultiProvider en main.dart)

```
MultiProvider
├── ChangeNotifierProvider → AuthProvider
├── ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>
├── ChangeNotifierProvider → SettingsProvider
├── ChangeNotifierProvider → CatalogProvider
├── ChangeNotifierProvider → CartProvider
├── ChangeNotifierProxyProvider<AuthProvider, OrderProvider>
├── ChangeNotifierProxyProvider<AuthProvider, LoyaltyProvider>
├── ChangeNotifierProvider → AdminProvider (solo si role == admin)
└── ChangeNotifierProvider → ConnectivityProvider
```

### 8.2 Estructura Interna de Cada Provider

Cada Provider debe tener:

```
Estado:
  _status: ProviderStatus (idle | loading | loaded | error)
  _errorMessage: String?
  _data: T (los datos específicos)

Getters públicos (sin setters públicos):
  ProviderStatus get status
  String? get errorMessage
  T get data
  bool get isLoading → status == loading
  bool get hasError → status == error

Métodos:
  Future<void> load*()     → cargar datos
  Future<void> create*()   → crear registro
  Future<void> update*()   → actualizar
  Future<void> delete*()   → eliminar
  void _setLoading()       → privado
  void _setError(String)   → privado
  void _setLoaded(T data)  → privado
```

### 8.3 CartProvider (Estado Local, Sin Firebase)

El carrito vive únicamente en memoria (CartProvider) y solo se persiste en Firestore cuando se confirma el pedido:

```
Estado:
  List<CartItemModel> _items
  String? _appliedDiscountCode
  double _discount

Lógica:
  addItem(ProductModel, customizations) → agregar o incrementar cantidad
  removeItem(String itemId)
  updateQuantity(String itemId, int quantity)
  applyDiscountCode(String code) → verificar en Firestore → aplicar
  clearCart()
  double get subtotal
  double get total
  int get itemCount
```

### 8.4 ConnectivityProvider

- Escuchar `ConnectivityPlus` y `InternetConnectionCheckerPlus`
- Exponer `bool isConnected`
- Mostrar banner global cuando `isConnected == false`
- Usar `Consumer<ConnectivityProvider>` en el widget raíz

---

## Fase 9 — Pantallas y Navegación {#fase-9}

### 9.1 Configuración de GoRouter

```
Router con las siguientes rutas:
  /splash                          → SplashScreen
  /onboarding                      → OnboardingScreen
  /auth/login                      → LoginScreen
  /auth/register                   → RegisterScreen
  /auth/forgot-password            → ForgotPasswordScreen

  /home                            → HomeScreen (shell con BottomNav)
    /home/catalog                  → CatalogScreen
      /home/catalog/:productId     → ProductDetailScreen
    /home/cart                     → CartScreen
      /home/cart/confirm           → ConfirmOrderScreen
    /home/orders                   → OrdersScreen
      /home/orders/:orderId        → OrderDetailScreen
    /home/loyalty                  → LoyaltyScreen
    /home/profile                  → ProfileScreen
      /home/profile/edit           → EditProfileScreen
    /home/settings                 → SettingsScreen

  /admin                           → AdminDashboard (shell separado)
    /admin/orders                  → ManageOrdersScreen
    /admin/products                → ManageProductsScreen
      /admin/products/new          → ProductFormScreen
      /admin/products/:id/edit     → ProductFormScreen
    /admin/inventory               → InventoryScreen
    /admin/promotions              → PromotionsScreen
```

### 9.2 Guards de Navegación

```
authGuard:
  Si no hay usuario autenticado → redirigir a /auth/login
  Si hay usuario → continuar

roleGuard:
  Si usuario.role != 'admin' → redirigir a /home
  Si usuario.role == 'admin' → continuar a /admin

emailVerificationGuard:
  Si !user.emailVerified → mostrar banner pero no bloquear (UX preferencia)
```

### 9.3 BottomNavigationBar (Cliente)

```
Tab 0: Home        (ti-home)
Tab 1: Catálogo    (ti-coffee)
Tab 2: Mis Pedidos (ti-clipboard-list)
Tab 3: Lealtad     (ti-star)
Tab 4: Perfil      (ti-user)
```

Configuración:
- Mantener estado de cada tab entre cambios de pestaña (`StatefulShellRoute`)
- Badge numérico en el ícono del carrito (flotante sobre Tab 1)
- Animación de selección suave

### 9.4 AppBar Personalizado

- **HomeScreen:** Logo Caffenio centrado + ícono de notificaciones (derecha) + ícono de carrito con badge (derecha)
- **CatalogScreen:** Buscador integrado en AppBar + filtros
- **OrderDetailScreen:** Título + estado del pedido como chip
- **AdminScreens:** Título de sección + acciones contextuales

---

## Fase 10 — Módulos Funcionales de Caffenio {#fase-10}

### 10.1 Catálogo y Productos

**CatalogScreen:**
- Buscador en tiempo real con debounce de 300ms
- Filtros horizontales por categoría (chips scrollables)
- Grid de 2 columnas de productos (ProductCard)
- Ordenamiento: relevancia, precio asc/desc, nuevo
- Pull-to-refresh

**ProductCard:**
- Imagen con `cached_network_image` + placeholder
- Badge "NUEVO" o "POPULAR"
- Nombre, precio, tiempo de preparación
- Botón "+" para agregar rápido al carrito
- Tap → ProductDetailScreen

**ProductDetailScreen:**
- Imagen hero (hero animation desde CatalogScreen)
- Nombre, descripción, precio
- Selección de personalización:
  - Tamaño: chips seleccionables (chico / mediano / grande)
  - Tipo de leche: radio buttons (entera / descremada / avena / almendra)
  - Extras: checkboxes (shot extra / caramelo / canela / crema)
- Contador de cantidad
- Total dinámico (actualiza en tiempo real al seleccionar opciones)
- Botón "Agregar al carrito" → muestra SnackBar de confirmación

### 10.2 Carrito y Pedidos

**CartScreen:**
- Lista de items con `CartItemTile`
  - Foto, nombre, personalización, precio, controles de cantidad, eliminar
- Sección de resumen: subtotal, descuento, total
- Campo de código de descuento / cupón
- Canje de puntos de lealtad (slider o input)
- Notas adicionales (textarea)
- Botón "Confirmar pedido"

**ConfirmOrderScreen:**
- Resumen final (solo lectura)
- Selección de método de pago
- Selección de sucursal
- Botón "Pagar / Confirmar"
- Al confirmar: crear documento en `orders` → navegar a OrderDetailScreen

**OrderDetailScreen:**
- Número de orden (QR code del orderId)
- Estado con timeline visual (pending → confirmed → preparing → ready → delivered)
- Escucha en tiempo real con `StreamBuilder`
- Estimado de tiempo listo
- Detalle de items
- Puntos ganados

### 10.3 Programa de Lealtad

**LoyaltyScreen:**
- Tarjeta visual con puntos actuales y nivel (bronce/plata/oro/platino)
- Barra de progreso al siguiente nivel
- Historial de transacciones (lista paginada)
- Beneficios por nivel
- Botón "Canjear puntos" → bottom sheet con opciones de canje

**Reglas de puntos:**
- 1 punto por cada $10 MXN de compra
- Niveles: Bronce (0-499), Plata (500-1499), Oro (1500-2999), Platino (3000+)
- Beneficios por nivel: descuentos, prioridad, bebida de cumpleaños

### 10.4 Panel de Administración

**AdminDashboard:**
- Métricas en tiempo real del día: pedidos totales, ingresos, pedidos pendientes, producto más pedido
- Gráfico de pedidos por hora (últimas 12 horas)
- Accesos rápidos a sub-módulos

**ManageOrdersScreen (Barista):**
- Lista de pedidos activos de la sucursal en tiempo real
- Filtro por estado
- Tap en pedido → ver detalle + cambiar estado
- Notificación de nuevo pedido (sonido + vibración)

**ManageProductsScreen:**
- CRUD completo de productos
- Toggle de disponibilidad
- Reordenar categorías
- Búsqueda y filtros

**InventoryScreen:**
- Stock actual por ingrediente
- Indicadores de alerta (rojo si < stock mínimo)
- Actualizar stock manualmente
- Historial de movimientos

### 10.5 Notificaciones Push

**Tópicos FCM:**
- Al registrarse: suscribirse a `all-users` y `customers`
- Al hacer pedido: escuchar canal del pedido específico
- Baristas: suscribirse a `sucursal-{id}`

**Tipos de notificaciones:**
- Pedido confirmado
- Pedido listo para recoger
- Nuevo pedido (para baristas)
- Promoción especial
- Puntos ganados

---

## Fase 11 — Pruebas y Calidad {#fase-11}

### 11.1 Pruebas Unitarias

Cubrir al 100% con tests:
- Todos los validators (email, password, nombre, teléfono)
- Todos los formatters (moneda, fecha, puntos)
- Lógica de CartProvider (agregar, remover, calcular total, aplicar descuento)
- Mapeo de errores de Firebase Auth
- Cálculo de puntos de lealtad y niveles
- Métodos de repositorios (con mocks de Firestore y Auth)

### 11.2 Pruebas de Widget

Cubrir widgets críticos:
- LoginScreen: validación de formulario, botones, estados de carga y error
- RegisterScreen: validación completa
- ProductCard: renderizado, interacciones
- CartItemTile: actualización de cantidad, eliminación
- OrderStatusTracker: todos los estados posibles

### 11.3 Pruebas de Integración

Flujos completos a probar:
- Registro → Login → Catálogo → Agregar al carrito → Confirmar pedido
- Login → Ver historial → Ver detalle de pedido
- Login → Ver puntos → Canjear puntos

### 11.4 CI/CD con GitHub Actions

Workflows a configurar:
```
on_pull_request.yml:
  - flutter analyze (sin warnings)
  - dart format --set-exit-if-changed (código formateado)
  - flutter test (todos los tests pasan)
  - flutter build apk --debug (compila sin errores)

on_merge_to_main.yml:
  - Todo lo anterior
  - flutter build apk --release
  - flutter build ipa
  - Upload a Firebase App Distribution (para testers)
```

### 11.5 Estándares de Calidad

- Cobertura de tests: mínimo 70% en lógica de negocio
- `flutter analyze` → 0 errores, 0 warnings en PR
- `dart format` → código correctamente formateado
- Ninguna dependencia deprecated en `pubspec.yaml`
- Sin uso de `print()` → usar logger personalizado
- Sin `// ignore:` sin justificación documentada

---

## Fase 12 — Construcción y Despliegue {#fase-12}

### 12.1 Configuración de Flavors (Ambientes)

Crear dos flavors para separar `dev` y `prod`:

```
Flavor development:
  App ID Android: com.caffenio.caffenio_app.dev
  Bundle ID iOS: com.caffenio.caffenioApp.dev
  Nombre de app: "Caffenio DEV"
  Firebase project: caffenio-dev

Flavor production:
  App ID Android: com.caffenio.caffenio_app
  Bundle ID iOS: com.caffenio.caffenioApp
  Nombre de app: "Caffenio"
  Firebase project: caffenio-prod
```

### 12.2 Configuración de Firma (Android)

1. Generar keystore:
   ```
   keytool -genkey -v -keystore caffenio-release.jks \
     -alias caffenio -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Guardar keystore en lugar seguro (NO en Git)
3. Configurar `key.properties` con paths y contraseñas (NO en Git)
4. Referenciar `key.properties` desde `android/app/build.gradle`

### 12.3 Configuración de Firma (iOS)

1. Crear App ID en Apple Developer Portal
2. Crear provisioning profile de distribución
3. Instalar certificado de distribución en macOS Keychain
4. Configurar en Xcode: Team, Bundle ID, Provisioning Profile

### 12.4 Comandos de Build

```bash
# Android APK (pruebas)
flutter build apk --flavor production --release

# Android App Bundle (Play Store)
flutter build appbundle --flavor production --release

# iOS (App Store)
flutter build ipa --flavor production --release

# Web
flutter build web --release --base-href /
```

### 12.5 Configuración de Splash Screen (`flutter_native_splash`)

Definir en `pubspec.yaml` bajo `flutter_native_splash`:
- Color de fondo: `#D32F2F` (rojo Caffenio)
- Logo: `assets/images/logo/logo_white.png`
- Soporte para dark mode: color `#1C1B1F`, logo `logo_white.png`
- Ejecutar: `dart run flutter_native_splash:create`

### 12.6 Configuración de Iconos (`flutter_launcher_icons`)

Definir en `pubspec.yaml` bajo `flutter_launcher_icons`:
- Imagen fuente: `assets/icons/app_icon.png` (1024×1024 sin transparencia)
- Android: ícono adaptativo con foreground y background
- iOS: ícono sin transparencia (requerimiento Apple)
- Web: íconos de múltiples tamaños
- Ejecutar: `dart run flutter_launcher_icons`

### 12.7 Checklist Pre-Release

- [ ] `flutter analyze` → sin errores
- [ ] Todos los tests pasan
- [ ] Versión incrementada en `pubspec.yaml` (version: 1.0.0+1)
- [ ] `CHANGELOG.md` actualizado
- [ ] Reglas de Firestore en modo producción (no test)
- [ ] Remote Config `maintenance_mode = false`
- [ ] Crashlytics habilitado y funcionando
- [ ] Analytics verificado con DebugView
- [ ] Imágenes comprimidas y assets optimizados
- [ ] Metadatos de tienda preparados (capturas, descripción, política de privacidad)
- [ ] App probada en dispositivo físico Android e iOS

---

## Apéndice A — pubspec.yaml Completo {#apendice-a}

```yaml
name: caffenio_app
description: Aplicación móvil y web para la gestión integral de Caffenio.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.19.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  firebase_storage: ^11.6.0
  firebase_analytics: ^10.8.0
  firebase_messaging: ^14.7.0
  firebase_crashlytics: ^3.4.0
  firebase_remote_config: ^4.3.0

  # Auth Social
  google_sign_in: ^6.2.1

  # Estado y Arquitectura
  provider: ^6.1.2
  get_it: ^7.7.0
  equatable: ^2.0.5
  dartz: ^0.10.1

  # Navegación
  go_router: ^13.2.0

  # UI y Componentes
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.0
  carousel_slider: ^4.2.1
  smooth_page_indicator: ^1.1.0
  flutter_rating_bar: ^4.0.1
  badges: ^3.1.2
  skeletonizer: ^1.1.1
  gap: ^3.0.1
  animate_do: ^3.3.4

  # Formularios
  flutter_form_builder: ^9.3.0
  form_builder_validators: ^10.0.1
  mask_text_input_formatter: ^2.9.0

  # Multimedia
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
  file_picker: ^8.0.3

  # Internacionalización
  intl: ^0.19.0
  intl_utils: ^2.8.7

  # Persistencia Local
  shared_preferences: ^2.2.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # Conectividad
  connectivity_plus: ^5.0.2
  internet_connection_checker_plus: ^2.1.0

  # Utilidades
  uuid: ^4.3.3
  timeago: ^3.6.1
  url_launcher: ^6.2.6
  share_plus: ^9.0.0
  package_info_plus: ^8.0.0
  device_info_plus: ^10.1.0
  permission_handler: ^11.3.0
  local_auth: ^2.2.0
  flutter_dotenv: ^5.1.0

  # Notificaciones
  flutter_local_notifications: ^17.1.2

  # Fuentes
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Calidad
  flutter_lints: ^4.0.0

  # Generación de código
  build_runner: ^2.4.9
  hive_generator: ^2.0.1
  json_serializable: ^6.7.1

  # Pruebas
  mockito: ^5.4.4
  fake_cloud_firestore: ^2.5.1
  firebase_auth_mocks: ^0.13.0

  # Branding
  flutter_native_splash: ^2.3.11
  flutter_launcher_icons: ^0.13.1

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
    - assets/images/logo/
    - assets/images/onboarding/
    - assets/images/placeholders/
    - assets/icons/
    - assets/animations/
    - .env

  fonts:
    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
          weight: 400
        - asset: assets/fonts/Montserrat-Medium.ttf
          weight: 500
        - asset: assets/fonts/Montserrat-Bold.ttf
          weight: 700

flutter_native_splash:
  color: "#D32F2F"
  image: assets/images/logo/logo_white.png
  android_12:
    image: assets/images/logo/logo_white.png
    color: "#D32F2F"
  dark:
    color: "#1C1B1F"
    image: assets/images/logo/logo_white.png

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
    background_color: "#D32F2F"
    theme_color: "#D32F2F"
  windows:
    generate: true
    image_path: "assets/icons/app_icon.png"
    icon_size: 48
```

---

## Apéndice B — Reglas de Seguridad Firestore {#apendice-b}

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Funciones auxiliares
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    function isAdmin() {
      return isAuthenticated() && getUserData().role == 'admin';
    }
    function isBarista() {
      return isAuthenticated() && getUserData().role in ['admin', 'barista'];
    }

    // Usuarios
    match /users/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow delete: if isAdmin();
    }

    // Categorías (solo admins escriben, todos los auth leen)
    match /categories/{categoryId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // Productos (solo admins escriben, todos los auth leen)
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // Pedidos
    match /orders/{orderId} {
      allow read: if isAuthenticated() && (
        resource.data.userId == request.auth.uid || isBarista()
      );
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && (
        resource.data.userId == request.auth.uid || isBarista()
      );
      allow delete: if isAdmin();
    }

    // Sucursales
    match /sucursales/{sucursalId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // Tarjetas de lealtad
    match /loyaltyCards/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow write: if isAuthenticated() && (isOwner(userId) || isBarista());
    }

    // Transacciones de lealtad
    match /loyaltyTransactions/{transactionId} {
      allow read: if isAuthenticated() && (
        resource.data.userId == request.auth.uid || isAdmin()
      );
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin();
    }

    // Promociones
    match /promotions/{promotionId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // Inventario
    match /inventory/{inventoryId} {
      allow read: if isBarista();
      allow write: if isBarista();
    }
  }
}
```

---

## Apéndice C — Checklist de Validación Pre-Código {#apendice-c}

### Entorno
- [ ] `flutter doctor -v` sin errores críticos
- [ ] Android emulator o dispositivo físico funcionando
- [ ] iOS Simulator o dispositivo físico funcionando (macOS)
- [ ] VS Code con todas las extensiones instaladas
- [ ] Firebase CLI autenticado (`firebase login`)
- [ ] FlutterFire CLI instalado (`flutterfire configure` ejecutado)
- [ ] Repositorio Git configurado con ramas correctas

### Firebase
- [ ] Proyectos `caffenio-dev` y `caffenio-prod` creados
- [ ] Authentication habilitado (Email/Password + Google)
- [ ] Firestore habilitado en región correcta
- [ ] Storage habilitado con reglas básicas
- [ ] FCM configurado (APNs para iOS)
- [ ] Crashlytics habilitado
- [ ] Remote Config configurado con valores iniciales
- [ ] `google-services.json` en `android/app/`
- [ ] `GoogleService-Info.plist` en `ios/Runner/`
- [ ] `firebase_options.dart` generado y en `lib/`

### Arquitectura y Código
- [ ] Estructura de carpetas creada completa
- [ ] `pubspec.yaml` con todas las dependencias definidas
- [ ] `flutter pub get` ejecutado sin errores
- [ ] `analysis_options.yaml` configurado
- [ ] `flutter analyze` sin errores en proyecto vacío
- [ ] Variables de entorno en `.env` (no versionadas)
- [ ] `.gitignore` actualizado (excluir keys, .env, build/, google-services.json)

### Diseño
- [ ] Paleta de colores definida en `app_colors.dart`
- [ ] Tipografías descargadas o configuradas con Google Fonts
- [ ] `ThemeData` light y dark configurados en `app_theme.dart`
- [ ] Constantes de espaciado y radios definidas
- [ ] Assets organizados en carpetas correctas
- [ ] Splash screen generado (`dart run flutter_native_splash:create`)
- [ ] Iconos generados (`dart run flutter_launcher_icons`)

### Seguridad
- [ ] Reglas de Firestore escritas y desplegadas
- [ ] Reglas de Storage escritas y desplegadas
- [ ] `firebase_options.dart` en `.gitignore` si contiene claves
- [ ] Keystore de Android en lugar seguro (no en Git)
- [ ] `key.properties` en `.gitignore`

---

## Apéndice D — Convenciones del Equipo {#apendice-d}

### Nomenclatura de Archivos
```
Widgets/Screens:  snake_case.dart         → login_screen.dart
Providers:        snake_case_provider.dart → auth_provider.dart
Modelos:          snake_case_model.dart    → user_model.dart
DTOs:             snake_case_dto.dart      → user_dto.dart
Repos (interface):snake_case_repository.dart
Repos (impl):     snake_case_repository_impl.dart
Servicios:        snake_case_service.dart
Constantes:       snake_case_constants.dart
Utilidades:       snake_case.dart         → validators.dart
```

### Nomenclatura de Clases
```
Screens:    PascalCaseScreen         → LoginScreen
Widgets:    PascalCase               → ProductCard
Providers:  PascalCaseProvider       → AuthProvider
Modelos:    PascalCaseModel          → UserModel
DTOs:       PascalCaseDTO            → UserDTO
Repos:      PascalCaseRepository     → AuthRepository
Impl:       PascalCaseRepositoryImpl → AuthRepositoryImpl
Servicios:  PascalCaseService        → AnalyticsService
Enums:      PascalCase con valores camelCase
```

### Reglas de Código
- **Importaciones:** Siempre `package:` imports (nunca relativos para `lib/`)
- **Widgets:** Preferir `const` constructors donde sea posible
- **BuildContext:** Nunca usar `context` en un `async` gap sin verificar `mounted`
- **Strings:** Preferir comillas simples `'texto'`
- **Nulos:** Usar null-safety estricto, evitar `!` sin justificación
- **Comentarios:** Documentar métodos públicos de providers y repositorios con `///`
- **TODO:** Formato `// TODO(nombre): descripción` para tareas pendientes
- **print:** Prohibido en código. Usar `logger.dart` con niveles (debug, info, warning, error)

### Estructura de un Widget de Pantalla
```
1. Imports (package primero, luego relativos)
2. Clase StatelessWidget o ConsumerWidget
3. build() → Scaffold con:
   a. AppBar personalizado
   b. Body con Consumer<Provider> para estado
   c. Manejo explícito de estados: loading, error, empty, loaded
4. Widgets privados al final del archivo (si son pequeños)
5. Widgets complejos en archivos separados en /widgets/
```

---

> 📌 **Instrucción final para el desarrollador:** Seguir este documento fase por fase, en orden. No saltar fases. Cada fase debe estar completamente implementada y funcionando antes de pasar a la siguiente. En caso de duda sobre una decisión técnica, referirse primero a este documento; si no está cubierto, documentar la decisión tomada en el `README.md` del proyecto.

---
*Documento generado para el proyecto Caffenio. Versión 1.0.0*
Prompt:
Eres un asistente técnico que debe generar un paquete completo listo para desarrollo del proyecto "Caffenio" (Sistema de Gestión de Cafetería). Entrega todo lo siguiente, respetando los requisitos técnicos y formatos solicitados.

1) Resumen del proyecto
- Nombre: Caffenio
- Propósito: Sistema para gestionar productos, pedidos, inventario, sucursales, empleados, lealtad y compras a proveedores.
- Tech stack objetivo: Flutter 3.x + Dart 3.x (cliente móvil y web), Firebase (Auth, Firestore, Storage, Analytics) para la app; MySQL/MariaDB para el DDL relacional y backups; GitHub Actions para CI/CD.

2) Requisitos de entrega (archivos y artefactos)
Genera los siguientes archivos/artefactos, cada uno como un archivo descargable separado cuando sea posible:
- `bdcaffenio.sql`: DDL completo (CREATE DATABASE + CREATE TABLE) para **18 tablas** con PK, FK, índices, constraints y tipos según el modelo abajo.
- `er_diagram.png` y `er_diagram.svg`: Diagrama ER visual con las 18 entidades, atributos clave (PK/FK), y relaciones (cardinalidades mínimas: 1..*, 0..* donde aplique).
- `seed_data/` carpeta con CSVs para cada tabla (nombres: Categoria.csv, Producto.csv, Ingrediente.csv, Receta.csv, Cliente.csv, TarjetaLealtad.csv, Pedido.csv, DetallePedido.csv, Personalizacion.csv, Pago.csv, Descuento.csv, Sucursal.csv, Empleado.csv, Turno.csv, Inventario.csv, Proveedor.csv, OrdenCompra.csv, DetalleOrdenCompra.csv) con 10–20 filas de ejemplo realistas.
- `postman_collection.json`: colección Postman con endpoints REST CRUD para Producto, Pedido, Inventario, Sucursal, Empleado, Proveedor, OrdenCompra, Cliente, y autenticación (simulada).
- `api_schema.graphql` y `api_schema_openapi.yaml`: esquema GraphQL y especificación OpenAPI (REST) que cubran las operaciones principales (consultas, mutaciones, endpoints de autenticación, endpoints para aplicar descuentos y procesar pagos).
- `flutter_scaffold/` estructura de proyecto (lista de archivos y carpetas) con convenciones Feature‑First Clean Architecture (por feature: presentation, domain, data). Incluye ejemplos de archivos: `main.dart`, `pubspec.yaml` (dependencias), ejemplo de provider/state management, y un ejemplo de pantalla para catálogo y pantalla para gestión de pedidos en tiempo real.
- `firestore_mapping.md`: mapeo recomendado de colecciones Firestore (users, products, orders, sucursales, loyaltyCards, inventory, promotions), con índices compuestos sugeridos y recomendaciones de denormalización para rendimiento.
- `github_actions/` carpeta con 2 workflows: `ci.yml` (análisis Flutter, tests, build) y `deploy.yml` (deploy a Firebase Hosting/Functions o instrucciones para despliegue).
- `README.md`: guía de instalación paso a paso (instalar Flutter, configurar Firebase, importar `bdcaffenio.sql`, ejecutar seed CSVs, ejecutar app localmente, ejecutar workflows).
- `tests/` carpeta con ejemplos de pruebas unitarias y de integración (Dart/Flutter) y ejemplos de queries SQL para validación de integridad referencial.
- `acceptance_criteria.md`: lista de criterios de aceptación y ejemplos de consultas SQL y GraphQL para validar funcionalidades clave (crear pedido, descontar inventario, acumular puntos, generar orden de compra cuando stock < mínimo).

3) Modelo de datos (resumen de las 18 entidades)
Incluye exactamente estas entidades con los atributos sugeridos (marca PK y FK). Asegúrate de que el DDL use estos nombres y tipos:

- Categoria: categoria_id (PK INT AI), nombre VARCHAR(100)
- Producto: producto_id (PK INT AI), nombre VARCHAR(100), descripcion TEXT, precio DECIMAL(10,2), disponible BOOLEAN, categoria_id (FK)
- Ingrediente: ingrediente_id (PK INT AI), nombre VARCHAR(100), unidad_medida VARCHAR(50), stock DECIMAL(10,2)
- Receta: receta_id (PK INT AI), producto_id (FK), ingrediente_id (FK), cantidad DECIMAL(10,2)
- Cliente: cliente_id (PK INT AI), nombre VARCHAR(150), contacto VARCHAR(150), fecha_registro DATETIME
- TarjetaLealtad: tarjeta_id (PK INT AI), cliente_id (FK), puntos INT, fecha_ultima_actualizacion DATETIME
- Pedido: pedido_id (PK INT AI), cliente_id (FK), sucursal_id (FK), fecha DATETIME, total DECIMAL(10,2), estado ENUM('pendiente','listo','entregado','cancelado')
- DetallePedido: detalle_id (PK INT AI), pedido_id (FK), producto_id (FK), cantidad INT, precio_unitario DECIMAL(10,2), subtotal (computed)
- Personalizacion: personalizacion_id (PK INT AI), detalle_id (FK), tipo VARCHAR(50), valor VARCHAR(100)
- Pago: pago_id (PK INT AI), pedido_id (FK), metodo ENUM('efectivo','tarjeta','app'), monto DECIMAL(10,2), referencia VARCHAR(100), fecha DATETIME
- Descuento: descuento_id (PK INT AI), codigo VARCHAR(50) UNIQUE, descripcion VARCHAR(200), tipo ENUM('porcentaje','monto','combo'), valor DECIMAL(10,2), fecha_inicio DATE, fecha_fin DATE
- Sucursal: sucursal_id (PK INT AI), nombre VARCHAR(100), ubicacion VARCHAR(200), horario VARCHAR(100), telefono VARCHAR(20), capacidad INT
- Empleado: empleado_id (PK INT AI), nombre VARCHAR(150), rol ENUM('barista','cajero','gerente','otro'), sucursal_id (FK), fecha_contratacion DATE
- Turno: turno_id (PK INT AI), empleado_id (FK), sucursal_id (FK), fecha DATE, hora_inicio TIME, hora_fin TIME
- Inventario: inventario_id (PK INT AI), sucursal_id (FK), ingrediente_id (FK), stock_actual DECIMAL(10,2), stock_minimo DECIMAL(10,2)
- Proveedor: proveedor_id (PK INT AI), nombre VARCHAR(150), contacto VARCHAR(150), telefono VARCHAR(20)
- OrdenCompra: orden_id (PK INT AI), proveedor_id (FK), sucursal_id (FK), fecha DATE, estado ENUM('pendiente','recibida','cancelada')
- DetalleOrdenCompra: detalle_id (PK INT AI), orden_id (FK), ingrediente_id (FK), cantidad DECIMAL(10,2), precio_unitario DECIMAL(10,2)

4) Reglas, constraints y comportamiento esperado
- Incluye FK con ON DELETE/ON UPDATE apropiados (usar RESTRICT o CASCADE con justificación).
- Añade índices recomendados para consultas frecuentes (buscar productos por categoría, pedidos por sucursal/cliente, inventario por ingrediente).
- Implementa triggers o stored procedures opcionales (documentados) para: actualizar stock al recibir OrdenCompra; decrementar stock al confirmar Pedido; acumular puntos en TarjetaLealtad al pagar.
- Define ejemplos de políticas de seguridad Firestore (reglas) y recomendaciones de roles/claims para Firebase Auth (cliente vs admin/barista).

5) Criterios de aceptación y ejemplos
- Proporciona 8–12 pruebas/queries concretas (SQL y GraphQL) que validen: creación de pedido con detalle y personalizaciones; pago asociado; inventario decrecido; generación de orden de compra cuando stock < mínimo; canje de puntos; aplicación de descuento; consulta de historial de cliente.
- Incluye ejemplos de payloads JSON para endpoints y respuestas esperadas.

6) Formato de entrega y prioridades
- Prioriza: 1) `bdcaffenio.sql`, 2) ER diagram PNG/SVG, 3) seed CSVs, 4) README + instrucciones de import, 5) Flutter scaffold y Firestore mapping, 6) Postman/OpenAPI/GraphQL, 7) CI workflows, 8) tests y acceptance criteria.
- Para cada archivo generado, incluye un encabezado con una breve explicación (1–2 líneas) y el propósito del archivo.

Genera todo lo anterior en español. Cuando entregues el SQL y los CSVs, indícame exactamente cómo descargar cada archivo (nombres de archivo y contenido). Si no puedes crear archivos descargables directamente, devuelve el contenido completo de cada archivo en bloques separados y claramente etiquetados para que pueda copiarlos y guardarlos localmente. Termina con un checklist de verificación que pueda marcar al importar y probar el sistema.
