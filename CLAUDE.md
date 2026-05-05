# Mi Salud FdA — MiniApp · CLAUDE.md

Contexto técnico y funcional completo para asistencia con IA en este proyecto.

---

## Descripción general

**Mi Salud FdA** es una mini-app móvil de salud para **Farmacias del Ahorro (FdA)**. Es un mockup funcional de alta fidelidad (no producción) que demuestra flujos completos de gestión de salud personal: citas, expediente médico, recetas digitales y videoconsulta.

- **Estado**: UI mockup con backend funcional. Sin autenticación real ni pagos reales.
- **Plataforma objetivo**: Mobile (iOS / Android vía Flutter)
- **Idioma de la UI**: Español (México)

---

## Stack tecnológico

### Frontend — Flutter (Dart)
| Paquete | Versión | Uso |
|---|---|---|
| `flutter` | SDK | Framework base (Material 3) |
| `go_router` | ^14.0.0 | Navegación declarativa con URL-based routing |
| `provider` | ^6.1.2 | Estado global con ChangeNotifier |
| `http` | ^1.2.0 | Cliente HTTP para llamadas a la API |
| `google_fonts` | ^6.2.1 | Tipografías Outfit (headings) y Manrope (body) |
| `qr_flutter` | ^4.1.0 | Generación de códigos QR en recetas |
| `cached_network_image` | ^3.3.1 | Imágenes con caché |
| `flutter_signature_pad` | ^3.0.0 | Firma digital de documentos |
| `intl` | ^0.19.0 | Fechas en español y formato de moneda (`NumberFormat.currency`) |
| `cupertino_icons` | ^1.0.8 | Íconos iOS-style |

### Backend — Python / FastAPI
| Componente | Versión | Uso |
|---|---|---|
| `fastapi` | 0.110.1 | Framework REST API |
| `uvicorn` | 0.25.0 | ASGI server |
| `supabase-py` | 2.4.0 | Cliente de Supabase (PostgreSQL) |
| `pydantic` | ^2.6.4 | Validación de modelos y config |
| `python-dotenv` | — | Variables de entorno desde `.env` |

### Base de datos
- **Supabase** (PostgreSQL gestionado)
- Los datos se siembran automáticamente al arrancar el backend (`seed_data()`)
- Schema de referencia: `backend/supabase_schema.sql`

---

## Estructura del proyecto

```
Miniapp/
├── flutter_app/                    # App Flutter (frontend)
│   ├── lib/
│   │   ├── main.dart               # Punto de entrada, GoRouter, AppShell
│   │   ├── core/
│   │   │   ├── api/api_service.dart        # Capa HTTP centralizada
│   │   │   ├── config/supabase_config.dart # Credenciales Supabase (pendiente)
│   │   │   ├── models/models.dart          # 16 modelos de datos Dart
│   │   │   ├── routes/app_routes.dart      # Constantes de rutas
│   │   │   └── theme/app_theme.dart        # Tema Material 3 + colores
│   │   └── features/
│   │       ├── home/                       # Tab Inicio
│   │       ├── appointments/               # Tab Mis Citas (13 screens)
│   │       ├── health_record/              # Tab Expediente
│   │       ├── account/                    # Tab Mi Cuenta
│   │       ├── sign_document/              # Firma de documentos
│   │       └── video_call/                 # UI de videoconsulta
│   ├── pubspec.yaml
│   └── test/
├── backend/
│   ├── server.py                   # FastAPI: todos los endpoints + seed
│   ├── requirements.txt
│   ├── .env                        # SUPABASE_URL + SUPABASE_KEY
│   ├── .env.example
│   ├── supabase_schema.sql         # Schema de referencia de la BD
│   └── tests/
│       ├── conftest.py
│       └── test_api_endpoints.py
├── memory/
│   └── PRD.md                      # Product Requirements Document
├── design_guidelines.json          # Sistema de diseño completo (colores, tipografía, componentes)
└── README.md
```

---

## Cómo correr el proyecto

### Backend
```bash
cd backend
pip install -r requirements.txt
# Crear .env con SUPABASE_URL y SUPABASE_KEY
uvicorn server:app --reload
# Disponible en http://localhost:8000
```

### Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

> La app funciona sin backend: cada Provider tiene datos mock de respaldo y cae silenciosamente ante errores de API.

---

## Arquitectura

### Patrón general
```
UI Screen → Provider (ChangeNotifier) → ApiService → FastAPI Backend → Supabase
                ↑ fallback mock data si la API falla
```

### Navegación (GoRouter)
- **ShellRoute**: Envuelve las 4 tabs del bottom nav. Las tabs usan `FadeTransition` (220ms).
- **Rutas secundarias**: Stacks sobre el ShellRoute, usan `SlideTransition` horizontal (300ms, `easeOutCubic`).
- **`AppShell`**: Lee la URL actual para activar el ícono correcto del bottom nav sin estado adicional.
- **No se usa `Navigator.push`** en ningún punto; todo es `context.go()` / `context.push()`.

### Estado (Provider)
Cada feature tiene su propio provider:
- `HomeProvider` — datos del dashboard principal
- `AppointmentsProvider` — citas (upcoming/past), creación, cancelación
- `HealthRecordProvider` — expediente, recetas, documentos
- `AccountProvider` — perfil de usuario, signos vitales

### ApiService (`lib/core/api/api_service.dart`)
- URL base configurable: `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000')` — cambiar con `--dart-define=API_BASE_URL=https://...` en build
- Timeout global: 15 segundos en todos los verbos HTTP (`_timeout = Duration(seconds: 15)`)
- User ID privado (`_currentUserId`); cambiar con `ApiService.setCurrentUser(id)` — valida que no sea vacío
- Header custom `X-User-Id` inyecta contexto de usuario (sin auth real)
- Punto único de contacto HTTP; los providers nunca llaman a `http` directamente

---

## API Endpoints (Backend)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/home` | Orquestador: retorna smart widget + quick actions + banners |
| GET | `/api/users` | Listar usuarios del sistema (selección de perfil) |
| GET | `/api/doctors` | Listar/buscar médicos (`?search=`) |
| GET | `/api/appointments` | Citas del usuario (`?status=upcoming\|past`) |
| POST | `/api/appointments` | Crear cita |
| DELETE | `/api/appointments/{id}` | Cancelar cita |
| GET | `/api/profile` | Perfil del usuario |
| PUT | `/api/profile` | Actualizar perfil |
| POST | `/api/profile/vitals` | Registrar signos vitales |
| GET | `/api/prescriptions` | Historial de recetas |
| GET | `/api/prescriptions/{id}` | Detalle de receta |
| GET | `/api/documents` | Documentos clínicos |
| GET | `/api/documents/{id}` | Detalle de documento clínico |
| GET | `/api/signature-documents` | Documentos pendientes de firma |
| POST | `/api/signature-documents/{id}/sign` | Firmar un documento |
| GET | `/api/recent-activity` | Timeline de actividad reciente |
| GET | `/api/branches` | Sucursales (`?service=&state=&city=`) |
| GET | `/api/vaccine-types` | Catálogo de vacunas |
| GET | `/api/test-types` | Catálogo de estudios |
| GET | `/api/promotions` | Banners promocionales |
| PUT | `/api/promotions/{id}/image` | Actualizar imagen de promoción |
| POST | `/api/payment/process` | Procesar pago (mock) |

---

## Modelos de datos (`lib/core/models/models.dart`)

16 modelos Dart que mapean 1:1 con las respuestas JSON del backend:
`User`, `Doctor`, `Branch`, `VaccineType`, `TestType`, `Appointment`, `Prescription`, `Medication`, `ClinicalDocument`, `SignatureDocument`, `Promotion`, `VitalSigns`, `RecentActivityItem`, `HomeData`, `SmartWidget`, `QuickAction`

**Notas de implementación:**
- `Appointment.price` es `double?` opcional — permite mostrar el precio real de la cita si el backend lo retorna; si es null, la pantalla de detalle usa valores de fallback por tipo de servicio.
- `_parseStringList(dynamic)` — helper top-level defensivo que reemplaza `List<String>.from()` para parsear listas JSON sin lanzar excepciones en datos malformados.
- `UserListItem.initials` filtra partes vacías antes de extraer iniciales para evitar excepciones con nombres con espacios extra.

---

## Rutas de navegación

### Tabs principales (ShellRoute, fade 220ms)
| Ruta | Screen |
|---|---|
| `/` | HomeScreen |
| `/appointments` | AppointmentsScreen |
| `/health-record` | HealthRecordScreen |
| `/account` | AccountScreen |

### Flujo: Videoconsulta (slide 300ms)
```
/appointments/schedule-type
  → /appointments/consult/symptoms
  → /appointments/consult/branch
  → /appointments/consult/datetime
  → /appointments/consult/patient-info
  → /appointments/consult/confirmation
  → /appointments/consult/success
  → /video-call
```

### Flujo: Vacunación (slide 300ms)
```
/appointments/schedule-type
  → /appointments/vaccine/type
  → /appointments/vaccine/questionnaire
  → /appointments/vaccine/branch
  → /appointments/vaccine/datetime
  → /appointments/vaccine/patient-info
  → /appointments/vaccine/confirmation
  → /appointments/vaccine/success  (o /pay-in-branch)
```

### Flujo: Estudios de laboratorio (slide 300ms)
```
/appointments/schedule-type
  → /appointments/test/type
  → /appointments/test/branch
  → /appointments/test/datetime
  → /appointments/test/patient-info
  → /appointments/test/confirmation
  → /appointments/test/success
  → /appointments/test/validating
```

### Health Record (slide 300ms)
```
/health-record
  → /health-record/prescriptions
  → /health-record/prescription/:id
  → /health-record/documents-list
  → /health-record/document/:id
  → /sign-document/:id
```

### Citas
```
/appointments/:id   → AppointmentDetailScreen
```

---

## Sistema de diseño

Tema: **Organic & Earthy**. Definido completamente en `design_guidelines.json` e implementado en `lib/core/theme/app_theme.dart`.

### Paleta de colores
| Token | Valor | Uso |
|---|---|---|
| Background | `#F9F8F6` | Fondo principal (Warm Sand) |
| Primary | `#E07A5F` | CTAs, estados activos (Terracotta) |
| Secondary | `#2A433A` | Textos principales, headers (Deep Forest) |
| Accent | `#819E8E` | Textos secundarios, íconos inactivos (Sage) |
| Surface | `#FFFFFF` | Cards, modales |
| Border | `#E5E1DA` | Bordes de cards |
| Blue | `#3B82F6` | Acento FdA |
| Success | `#4CAF50` | Estados positivos |
| Error | `#E53935` | Errores, alertas |
| BrandBlue | `#13299D` | Azul corporativo FdA (CTAs de confirmación, headers de videoconsulta) |
| Warning | `#D97706` | Ámbar (pagos pendientes, estados de advertencia) |
| VideoCallBg | `#1A2B25` | Fondo oscuro de la pantalla de videollamada |

### Tipografía
| Rol | Fuente | Tamaño |
|---|---|---|
| H1 | Outfit Bold | 32px |
| H2 | Outfit Bold | 24px |
| H3 | Outfit SemiBold | 18px |
| Body | Manrope Regular | 15px |
| Label | Manrope Medium | 12px |

### Espaciado y radios
- Screen padding: 24px horizontal, 40px vertical
- Card padding: 24px
- Radius: sm=12px, md=16px, lg=20px, xl=32px
- Sombra soft: `0 4px 20px` (6% opacidad)
- Sombra floating: `0 8px 32px` (10% opacidad)

---

## Funcionalidades principales

### 1. Home Dashboard
- Saludo dinámico según hora del día
- **Smart Widget**: muestra "Próxima Cita" si existe, o card de bienvenida
- **Quick Actions**: carrusel de 5 acciones (Expediente, Videoconsulta, Agendar, Recetas, Farmacia)
- **Banners promocionales**: PageView horizontal con indicadores de posición
- **Card "Surte tu Receta"**: acceso rápido a escaneo de recetas

### 2. Gestión de Citas
- Tabs Próximas / Pasadas con cards de cita
- Crear cita con 3 tipos: Videoconsulta, Vacuna, Estudio
- Flujo multi-pantalla con estado persistido en el Provider
- Pago mock (tarjeta terminación 4242)
- Cancelar citas próximas

### 3. Expediente de Salud
- Cabecera con avatar y datos del perfil
- Timeline de actividad reciente (cargado desde `/api/recent-activity`)
- **Mi Información**: tipo de sangre, signos vitales, peso, talla
- **Recetas**: lista con medicamentos y código QR de verificación
- **Documentos Clínicos**: resultados de laboratorio, notas de consulta
- **Documentos por Firmar**: formularios de consentimiento con pad de firma

### 4. Mi Cuenta
- Vista y edición de perfil
- Gestión de signos vitales
- Registro de alergias
- Datos demográficos

### 5. Funcionalidades de apoyo
- **Video Call**: UI completa (mute, cámara, chat, archivos) — sin WebRTC real
- **Sign Document**: integración con `flutter_signature_pad`
- **QR en recetas**: generado con `qr_flutter`
- **Skeleton Loaders**: placeholders durante carga (`shared/widgets/skeleton_loader.dart`)

---

## Datos mock

El backend siembra automáticamente al arrancar:
- **3 perfiles de usuario** con datos completos
- **5 médicos** con especialidades variadas
- **4 citas** (próximas y pasadas)
- **2 recetas** con medicamentos
- **3 documentos clínicos** (resultados, notas)
- **3 documentos de firma** (consentimientos, aviso de privacidad)
- **3 promociones** con imágenes

Adicionalmente, cada Provider Flutter tiene datos mock embebidos que se usan si la API no responde.

---

## Decisiones de diseño clave

1. **Orquestador en `/api/home`**: Un solo endpoint retorna la estructura completa del home para evitar múltiples llamadas en el arranque.

2. **Sin autenticación**: El usuario se selecciona por un dropdown al inicio; el ID viaja en el header `X-User-Id`. Diseño intencionalmente simple para un mockup.

3. **Graceful degradation**: La app funciona offline. Si la API falla, se cargan datos mock sin mostrar error al usuario.

4. **Pantallas separadas por paso**: Los flujos multi-paso usan pantallas individuales (no modals o steppers), lo que permite animaciones de slide nativas y gestión limpia del estado.

5. **ApiService como única capa HTTP**: Ninguna pantalla o provider llama a `http` directamente; todo pasa por `ApiService`. Facilita mock, debug e intercepción.

6. **Material 3**: La app usa ThemeData de Material 3 con el sistema de colores personalizado sobreescrito.

7. **`_disposed` / `_notify()` en providers**: Todos los `ChangeNotifier` implementan `dispose()` con un flag `_disposed` y reemplazan `notifyListeners()` por `_notify()`, que lo omite si el provider ya fue destruido. Previene excepciones `setState after dispose` en navegación rápida.

8. **`AppTheme` cacheado con `static final`**: Los `TextStyle`, `BoxShadow` y el `ThemeData` raíz se instancian una sola vez como campos `static final`, no en cada llamada. Evita allocations en cada rebuild.

9. **`kDebugMode` para UI de debug**: Botones y elementos solo visibles en desarrollo (e.g. selector de usuario) se envuelven en `if (kDebugMode)` para que no aparezcan en release builds.

10. **`String.fromEnvironment` para la URL base**: `ApiService._baseUrl` se configura en tiempo de compilación vía `--dart-define=API_BASE_URL=...`. Sin ese flag, cae al default `http://localhost:8000`. Permite builds para distintos entornos sin cambiar código.

---

## Lo que está fuera del alcance (Fase 2)

- Widget de resultados de laboratorio recientes en Home
- Widget de medicamentos activos en Home
- Subida de documentos por el usuario
- Recordatorios inteligentes de medicamentos
- Notificaciones de bienestar
- Gestión de contactos de emergencia
- Autenticación real
- WebRTC para videoconsulta real
- Pagos reales
