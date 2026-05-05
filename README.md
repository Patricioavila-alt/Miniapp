# Mi Salud FdA — MiniApp

Mini-app móvil de salud para **Farmacias del Ahorro**. Mockup funcional de alta fidelidad con Flutter y FastAPI que cubre los flujos completos de gestión de salud: citas, expediente médico, recetas digitales y videoconsulta.

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3 / Dart (Material 3) |
| Navegación | go_router 14 |
| Estado | Provider 6 (ChangeNotifier) |
| Backend | FastAPI + Uvicorn |
| Base de datos | Supabase (PostgreSQL) |
| Tipografía | Outfit (headings) + Manrope (body) vía google_fonts |

---

## Estructura

```
Miniapp/
├── flutter_app/          # App Flutter
│   └── lib/
│       ├── main.dart           # Punto de entrada, GoRouter, AppShell
│       ├── core/               # API, modelos, rutas, tema
│       └── features/           # home / appointments / health_record / account
├── backend/              # FastAPI + Supabase
│   ├── server.py               # Todos los endpoints REST + seed de datos
│   └── supabase_schema.sql     # Schema de referencia de la BD
├── memory/PRD.md         # Product Requirements Document
└── design_guidelines.json  # Sistema de diseño (colores, tipografía, espaciado)
```

---

## Correr el proyecto

### Backend

```bash
cd backend
pip install -r requirements.txt

# Crear .env con credenciales de Supabase:
# SUPABASE_URL=https://xxxx.supabase.co
# SUPABASE_KEY=sb_publishable_...

uvicorn server:app --reload
# API disponible en http://localhost:8000
```

Al arrancar, el backend siembra automáticamente datos mock en Supabase.

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

> La app funciona sin backend: los providers tienen datos mock de respaldo.

---

## Funcionalidades

- **Home Dashboard**: saludo contextual, próxima cita, 5 quick actions, banners promocionales
- **Agendar Citas**: flujos multi-paso para videoconsulta, vacunas y estudios de laboratorio
- **Expediente de Salud**: perfil, recetas con QR, documentos clínicos, firma digital
- **Mi Cuenta**: edición de perfil, signos vitales, alergias
- **Videoconsulta**: UI completa con controles de mute / cámara / chat (sin WebRTC real)

---

## API — Endpoints principales

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/home` | Orquestador del dashboard |
| GET/POST | `/api/appointments` | Listar y crear citas |
| DELETE | `/api/appointments/{id}` | Cancelar cita |
| GET/PUT | `/api/profile` | Perfil del usuario |
| GET | `/api/prescriptions` | Recetas |
| GET | `/api/documents` | Documentos clínicos |
| POST | `/api/signature-documents/{id}/sign` | Firmar documento |
| GET | `/api/branches` | Sucursales |
| POST | `/api/payment/process` | Pago mock |

Ver `CLAUDE.md` para el listado completo de endpoints y toda la documentación técnica.

---

## Diseño

Tema **Organic & Earthy** — ver `design_guidelines.json` para specs completos.

| Token | Color |
|---|---|
| Background | `#F9F8F6` Warm Sand |
| Primary (CTAs) | `#E07A5F` Terracotta |
| Secondary | `#2A433A` Deep Forest Green |
| Accent | `#819E8E` Sage |
| BrandBlue | `#13299D` Azul corporativo FdA |
| Warning | `#D97706` Ámbar (pagos pendientes) |
| VideoCallBg | `#1A2B25` Fondo videollamada |

---

## Estado del proyecto

Mockup funcional — sin autenticación real, sin pagos reales, sin WebRTC.
Ver `CLAUDE.md` y `memory/PRD.md` para el detalle de lo que está en scope y fuera de scope.
