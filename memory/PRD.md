# MiniApp - Mi Salud FdA - Product Requirements Document

## Overview
A smart, personal health assistant mobile app built with Flutter and a FastAPI backend. The app provides contextual health management with appointment scheduling, health records, digital prescriptions, and mock video consultations.

## Tech Stack
- **Frontend**: Flutter (Dart), go_router (navigation), Provider (state management), google_fonts (Outfit + Manrope)
- **Backend**: FastAPI (Python), Motor (async MongoDB driver)
- **Database**: MongoDB
- **Styling**: Organic & Earthy theme — Warm Sand (#F9F8F6), Terracotta (#E07A5F), Deep Forest Green (#2A433A)

## Architecture
- **Orchestrator Pattern**: Single `/api/home` endpoint returns entire home screen layout based on user context
- **Mock Data**: Seeded on startup with user profile, 5 doctors, 4 appointments, 2 prescriptions, 3 clinical documents, 3 signature documents, 3 promotions
- **No Authentication**: Mockup project — all endpoints are open
- **Status**: Flutter app currently works as a UI mockup; API integration is pending

## Key Features (MVP)
1. **Contextual Home Dashboard**: Smart widget shows next appointment or welcome card based on user state
2. **4-Tab Navigation**: Home | My Appointments | Health Record | My Account
3. **Appointment Management**: View upcoming/past, create new appointments, cancel
4. **Appointment Scheduling Flow**: Multi-step (select doctor → select date/time → confirm & mock pay → success)
5. **Mock Video Consultation**: UI with mute, camera toggle, chat, file sharing controls
6. **Health Records**: Personal info, clinical documents, prescription history, documents for signature
7. **Digital Prescriptions**: Medication list with QR code (qr_flutter) for verification
8. **Document Signing**: View and electronically sign consent forms (flutter_signature_pad)
9. **Profile Management**: View and edit user profile details
10. **Promotional Banners**: Horizontal carousel with health promotions

## API Endpoints (Backend — pending integration in Flutter)
- `GET /api/home` - Orchestrator home screen data
- `GET /api/doctors` - List/search doctors
- `GET/POST /api/appointments` - CRUD appointments
- `DELETE /api/appointments/{id}` - Cancel appointment
- `GET/PUT /api/profile` - User profile
- `GET /api/prescriptions` - Prescription history
- `GET /api/documents` - Clinical documents
- `GET /api/signature-documents` - Signature documents
- `POST /api/signature-documents/{id}/sign` - Sign a document
- `GET /api/promotions` - Promotional content

## Mock/Simulated Features
- **Video Consultation**: Mock UI only (no real WebRTC)
- **Payment**: Mock card ending in 4242
- **QR Codes**: Generated via qr_flutter with static data
- **Authentication**: None (mockup project)

## Phase 2 Exclusions
- Recent Lab Results widget on Home
- Active Medications widget on Home
- User document upload in Health Records
- Smart medication reminders
- Wellness/engagement notifications
- Emergency contacts management
