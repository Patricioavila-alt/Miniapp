---
name: misalud-flutter
description: Conocimiento completo del proyecto "Mi Salud FdA" — MiniApp médica migrada a Flutter. Usar este skill cuando se trabaje con cualquier archivo de este proyecto, ya sea frontend Flutter, backend FastAPI o configuración de entorno.
---

# Proyecto: Mi Salud FdA — MiniApp Flutter

## Descripción General

Mini app de salud digital para **Farmacias del Ahorro (FdA)** que permite a pacientes gestionar citas, ver recetas, revisar documentos clínicos, firmar documentos y hacer videoconsultas. El frontend fue migrado de **React Native + Expo** a **Flutter**. El backend es Python (FastAPI) + MongoDB y **no debe modificarse**.

---

## Stack Tecnológico

| Capa | Tecnología | Ubicación |
|---|---|---|
| Frontend | Flutter (Dart) | `flutter_app/` |
| Backend | FastAPI (Python) | `backend/server.py` |
| Base de datos | MongoDB (Motor async) | Configurado en `backend/.env` |
| Navegación | `go_router` | `flutter_app/lib/main.dart` |
| Estado | `provider` | Por feature en `lib/features/` |
| HTTP | `http` package | `lib/core/api/api_service.dart` |

---

## Estructura del Proyecto

```
Miniapp/
├── backend/
│   ├── server.py          # API FastAPI — NO modificar salvo nuevos endpoints
│   ├── .env               # MONGO_URL y DB_NAME — NO commitear
│   └── requirements.txt   # Dependencias Python
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart                    # Entry point + GoRouter
│   │   ├── core/
│   │   │   ├── theme/app_theme.dart     # Paleta, tipografías, tokens
│   │   │   ├── api/api_service.dart     # Todos los métodos HTTP
│   │   │   └── models/                  # Modelos Dart (entidades)
│   │   ├── features/
│   │   │   ├── home/
│   │   │   ├── appointments/
│   │   │   ├── health_record/
│   │   │   ├── sign_document/
│   │   │   ├── video_call/
│   │   │   └── account/
│   │   └── shared/
│   │       └── widgets/                 # Widgets reutilizables
│   ├── assets/fonts/                    # Outfit + Manrope .ttf
│   └── pubspec.yaml
├── design_guidelines.json               # Referencia de diseño — SIEMPRE consultar
├── .agents/
│   └── skills/misalud-flutter/
│       └── SKILL.md                     # Este archivo
└── frontend/                            # Legacy React Native — NO modificar
```

---

## Paleta de Colores (del `design_guidelines.json`)

```dart
// Siempre usar constantes de AppTheme, NUNCA valores hex directos en widgets
static const Color background    = Color(0xFFF9F8F6); // Fondo general
static const Color surface       = Color(0xFFFFFFFF); // Tarjetas
static const Color primary       = Color(0xFFE07A5F); // Terracota (CTAs)
static const Color primaryLight  = Color(0xFFF2B8A7); // Terracota suave
static const Color secondary     = Color(0xFF2A433A); // Verde oscuro (header widget)
static const Color accent        = Color(0xFF819E8E); // Verde gris (íconos inactivos)
static const Color textPrimary   = Color(0xFF1F2321); // Texto principal
static const Color textSecondary = Color(0xFF5C6B64); // Texto secundario
static const Color border        = Color(0xFFE5E1DA); // Bordes y divisores
static const Color success       = Color(0xFF4CAF50); // Estados exitosos
static const Color error         = Color(0xFFE53935); // Errores
```

---

## Tipografías

- **Headings:** `Outfit` (pesos 600, 700)
- **Body:** `Manrope` (pesos 400, 500, 600)
- Cargadas con el paquete `google_fonts`. Si no hay conexión, usar fallback del sistema.

```dart
// Correcto
TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 24, fontWeight: FontWeight.w700)

// Incorrecto — no usar strings directos sin google_fonts
TextStyle(fontFamily: 'Outfit', fontSize: 24)
```

---

## Convenciones de Código Flutter

### Estructura de widgets
- Un archivo por pantalla. Nombre en `snake_case.dart`.
- Cada pantalla exporta un único `StatefulWidget` o `StatelessWidget`.
- Widgets reutilizables van en `shared/widgets/`, nombrados con sufijo `Widget` (ej. `AppointmentCardWidget`).

### Estado
- Usar `provider` con `ChangeNotifier` por cada feature.
- NO usar `setState` para lógica de negocio, solo para micro-estados locales de UI.
- Cada provider vive en `features/<feature>/providers/<feature>_provider.dart`.

### API calls
- **Todas** las llamadas HTTP van en `ApiService` (`core/api/api_service.dart`).
- Las pantallas nunca usan `http.get()` directamente; siempre llaman a `ApiService`.
- Manejar siempre los tres estados: `loading`, `data`, `error`.

```dart
// Patrón correcto en providers
Future<void> fetchAppointments() async {
  _isLoading = true;
  notifyListeners();
  try {
    _appointments = await ApiService.getAppointments();
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Navegación
- Usar `GoRouter`. Las rutas se definen **únicamente** en `main.dart`.
- Nombres de rutas en constantes: `AppRoutes.home`, `AppRoutes.appointments`, etc.
- Para pasar parámetros entre pantallas, usar `pathParameters` o `extra` de GoRouter.

```dart
// Correcto
context.push(AppRoutes.appointmentDetail, extra: appointment);

// Incorrecto
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen()));
```

---

## API y Backend

### URL Base
```dart
const String baseUrl = 'http://localhost:8000'; // Desarrollo local
```

> ⚠️ **Importante:** El backend corre en `localhost:8000`. Asegurarse de que FastAPI esté corriendo antes de probar la app. Comando para iniciar: `uvicorn server:app --reload` desde la carpeta `backend/`.

### Endpoints principales
| Ruta | Descripción |
|---|---|
| `GET /api/home` | Dashboard completo (usuario + widget + acciones + promos) |
| `GET /api/doctors` | Lista de doctores (acepta `?search=`) |
| `GET /api/appointments?status=upcoming` | Citas próximas |
| `GET /api/appointments?status=past` | Citas pasadas |
| `POST /api/appointments` | Crear cita |
| `DELETE /api/appointments/{id}` | Cancelar cita |
| `GET /api/prescriptions` | Recetas |
| `GET /api/documents` | Documentos clínicos |
| `GET /api/signature-documents` | Documentos para firmar |
| `POST /api/signature-documents/{id}/sign` | Firmar documento |
| `GET /api/profile` | Perfil del usuario |
| `PUT /api/profile` | Actualizar perfil |

---

## Dependencias Clave (`pubspec.yaml`)

```yaml
dependencies:
  go_router: ^14.0.0         # Navegación declarativa
  http: ^1.2.0               # Cliente HTTP
  google_fonts: ^6.2.1       # Outfit + Manrope
  provider: ^6.1.2           # Manejo de estado
  qr_flutter: ^4.1.0         # QR codes en recetas
  cached_network_image: ^3.3.1  # Imágenes con caché
  intl: ^0.19.0              # Fechas en español (es_MX)
  flutter_signature_pad: ^3.0.0 # Firma digital
```

---

## Componentes de UI Clave

### ContextualWidget (Header del Home)
- Fondo `secondary` (`#2A433A`) cuando hay cita próxima.
- Muestra nombre del doctor, especialidad, fecha/hora y botón "Unirse" en `primary` (`#E07A5F`).
- Si no hay cita, muestra mensaje de bienvenida en fondo `secondary`.
- `borderRadius`: 32px (muy redondeado).

### QuickActionButton
- Grid de 4 botones: Video Consulta | Agendar Cita | Mis Recetas | Buscar Farmacia.
- Fondo `background` con sombra suave.
- Ícono arriba, texto pequeño centrado abajo.
- Forma cuadrada con `borderRadius` 16px.

### AppointmentCard
- Layout horizontal: avatar redondeado | nombre + especialidad | badge de fecha/hora.
- Borde `1px solid border` (`#E5E1DA`).
- Botón de acción `primary` al fondo derecho.

### BottomNavigationBar
- 4 tabs: Home | Mis Citas | Expediente | Mi Cuenta.
- Color activo: `primary` (`#E07A5F`).
- Color inactivo: `accent` (`#819E8E`).
- Fondo blanco con sombra en la parte superior.

---

## Flujo de Desarrollo

```
1. Asegurarse que backend esté corriendo (uvicorn)
2. Editar código en flutter_app/
3. Probar en Chrome: flutter run -d chrome
4. Probar en Android: flutter run -d android (o emulador)
5. Verificar que todas las llamadas API respondan correctamente
6. git add . → git commit -m "feat: descripción" → git push
```

---

## Qué NO hacer

- ❌ **No modificar `backend/server.py`** a menos que sea para agregar un endpoint nuevo aprobado.
- ❌ **No modificar la carpeta `frontend/`** (React Native legacy). Está ahí solo como referencia.
- ❌ **No usar `Navigator.push()`** directamente. Siempre `context.push()` de GoRouter.
- ❌ **No hardcodear colores hex** en los widgets. Siempre `AppTheme.primary`, etc.
- ❌ **No hacer llamadas HTTP fuera de `ApiService`**.
- ❌ **No commitear el archivo `backend/.env`** (contiene credenciales de MongoDB).

---

## Notas de Diseño

- El estilo general es **"Organic & Earthy"**: cálido, limpio y de confianza.
- Usar sombras suaves (`BoxShadow` con opacidad baja, máximo 0.10).
- Padding estándar de pantallas: `EdgeInsets.symmetric(horizontal: 24, vertical: 40)`.
- Padding estándar de tarjetas: `EdgeInsets.all(24)`.
- Gap estándar entre elementos: `24px`.
- Las imágenes de doctores vienen desde URLs de Unsplash (ver `design_guidelines.json`).
- La videollamada es UI simulada — no implementar WebRTC en el MVP.
