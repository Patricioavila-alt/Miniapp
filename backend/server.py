from fastapi import FastAPI, APIRouter, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timezone, timedelta

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

app = FastAPI()
api_router = APIRouter(prefix="/api")


# ========================
# Pydantic Models
# ========================

class AppointmentCreate(BaseModel):
    doctor_id: str
    date: str
    time: str
    type: str = "video"
    notes: Optional[str] = None


class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = None


# ========================
# Seed Data
# ========================

async def seed_data():
    existing = await db.users.find_one({}, {"_id": 0})
    if existing:
        logger.info("Data already seeded, skipping...")
        return

    logger.info("Seeding mock data...")
    now = datetime.now(timezone.utc)
    tomorrow = now + timedelta(days=1)
    next_week = now + timedelta(days=7)
    last_week = now - timedelta(days=7)
    two_weeks_ago = now - timedelta(days=14)

    # User
    await db.users.insert_one({
        "id": "user-001",
        "full_name": "María García",
        "email": "maria.garcia@email.com",
        "phone": "+52 555 123 4567",
        "date_of_birth": "1990-03-15",
        "gender": "Femenino",
        "blood_type": "O+",
        "allergies": ["Penicilina", "Polen"],
        "avatar_url": ""
    })

    # Doctors
    await db.doctors.insert_many([
        {"id": "doc-001", "name": "Dr. Ana Rodríguez", "specialty": "Medicina General", "avatar_url": "", "rating": 4.8, "experience_years": 12, "consultation_fee": 45.0, "available_slots": ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00"]},
        {"id": "doc-002", "name": "Dr. Carlos Méndez", "specialty": "Cardiología", "avatar_url": "", "rating": 4.9, "experience_years": 15, "consultation_fee": 75.0, "available_slots": ["08:00", "09:00", "10:00", "13:00", "14:00"]},
        {"id": "doc-003", "name": "Dr. Laura Sánchez", "specialty": "Dermatología", "avatar_url": "", "rating": 4.7, "experience_years": 8, "consultation_fee": 60.0, "available_slots": ["10:00", "11:00", "12:00", "15:00", "16:00", "17:00"]},
        {"id": "doc-004", "name": "Dr. Roberto Torres", "specialty": "Pediatría", "avatar_url": "", "rating": 4.6, "experience_years": 10, "consultation_fee": 50.0, "available_slots": ["09:00", "10:00", "11:00", "14:00", "15:00"]},
        {"id": "doc-005", "name": "Dr. Patricia Flores", "specialty": "Ginecología", "avatar_url": "", "rating": 4.8, "experience_years": 14, "consultation_fee": 65.0, "available_slots": ["08:00", "09:00", "11:00", "13:00", "15:00", "16:00"]}
    ])

    # Appointments
    await db.appointments.insert_many([
        {"id": "apt-001", "doctor_id": "doc-001", "doctor_name": "Dr. Ana Rodríguez", "doctor_specialty": "Medicina General", "doctor_avatar": "", "date": tomorrow.strftime("%Y-%m-%d"), "time": "10:00", "status": "upcoming", "type": "video", "notes": "Consulta de seguimiento", "created_at": now.isoformat()},
        {"id": "apt-002", "doctor_id": "doc-002", "doctor_name": "Dr. Carlos Méndez", "doctor_specialty": "Cardiología", "doctor_avatar": "", "date": next_week.strftime("%Y-%m-%d"), "time": "14:00", "status": "upcoming", "type": "in-person", "notes": "Chequeo anual", "created_at": now.isoformat()},
        {"id": "apt-003", "doctor_id": "doc-003", "doctor_name": "Dr. Laura Sánchez", "doctor_specialty": "Dermatología", "doctor_avatar": "", "date": last_week.strftime("%Y-%m-%d"), "time": "11:00", "status": "completed", "type": "video", "notes": "Revisión dermatológica", "created_at": two_weeks_ago.isoformat()},
        {"id": "apt-004", "doctor_id": "doc-004", "doctor_name": "Dr. Roberto Torres", "doctor_specialty": "Pediatría", "doctor_avatar": "", "date": two_weeks_ago.strftime("%Y-%m-%d"), "time": "09:00", "status": "completed", "type": "in-person", "notes": "Vacunación infantil", "created_at": (two_weeks_ago - timedelta(days=3)).isoformat()}
    ])

    # Prescriptions
    await db.prescriptions.insert_many([
        {"id": "rx-001", "doctor_name": "Dr. Ana Rodríguez", "doctor_specialty": "Medicina General", "date": last_week.strftime("%Y-%m-%d"), "medications": [{"name": "Amoxicillin 500mg", "dosage": "1 tableta cada 8 horas", "duration": "7 días"}, {"name": "Ibuprofen 400mg", "dosage": "1 tableta cada 12 horas si es necesario", "duration": "5 días"}], "diagnosis": "Infección respiratoria alta", "notes": "Tomar con alimentos. Evitar alcohol durante el tratamiento.", "qr_code_data": "RX-001-MARIA-GARCIA-2025", "status": "active"},
        {"id": "rx-002", "doctor_name": "Dr. Laura Sánchez", "doctor_specialty": "Dermatología", "date": two_weeks_ago.strftime("%Y-%m-%d"), "medications": [{"name": "Hydrocortisone Cream 1%", "dosage": "Aplicar dos veces al día", "duration": "14 días"}, {"name": "Cetirizine 10mg", "dosage": "1 tableta diaria", "duration": "30 días"}], "diagnosis": "Dermatitis de contacto", "notes": "Evitar exposición solar prolongada. Usar protector solar SPF 50+.", "qr_code_data": "RX-002-MARIA-GARCIA-2025", "status": "completed"}
    ])

    # Clinical Documents
    await db.clinical_documents.insert_many([
        {"id": "cdoc-001", "title": "Resultados de Biometría Hemática", "type": "lab_result", "date": last_week.strftime("%Y-%m-%d"), "doctor_name": "Dr. Ana Rodríguez", "summary": "Todos los valores dentro del rango normal. Hemoglobina 13.5 g/dL, Leucocitos 7,500/μL. Plaquetas 250,000/μL. Sin anomalías detectadas.", "status": "available"},
        {"id": "cdoc-002", "title": "Resumen de Consulta - Evaluación Cardiaca", "type": "consultation_summary", "date": two_weeks_ago.strftime("%Y-%m-%d"), "doctor_name": "Dr. Carlos Méndez", "summary": "Paciente sin hallazgos cardiacos significativos. Presión arterial 120/80 mmHg. Frecuencia cardiaca 72 lpm, ritmo regular. ECG ritmo sinusal normal. Sin soplos ni arritmias detectadas.", "status": "available"},
        {"id": "cdoc-003", "title": "Informe de Evaluación Dermatológica", "type": "consultation_summary", "date": two_weeks_ago.strftime("%Y-%m-%d"), "doctor_name": "Dr. Laura Sánchez", "summary": "Dermatitis de contacto leve en antebrazos. Sin signos de infección. Se prescribió corticosteroide tópico y antihistamínico oral. Seguimiento en 2 semanas para evaluar eficacia del tratamiento.", "status": "available"}
    ])

    # Signature Documents
    await db.signature_documents.insert_many([
        {"id": "sig-001", "title": "Acuerdo de Política de Privacidad", "type": "privacy_policy", "date": now.strftime("%Y-%m-%d"), "status": "pending", "content_preview": "Al firmar este documento, usted acepta nuestras prácticas de manejo y privacidad de datos según lo descrito en nuestra política de privacidad integral. Su información personal de salud será manejada de acuerdo con las regulaciones locales de protección de datos. Estamos comprometidos a proteger sus datos médicos sensibles y solo compartiremos información con proveedores de salud autorizados involucrados en su atención."},
        {"id": "sig-002", "title": "Consentimiento de Videoconsulta", "type": "consent_form", "date": now.strftime("%Y-%m-%d"), "status": "pending", "content_preview": "Doy mi consentimiento para recibir consulta médica por videollamada y entiendo las limitaciones de la telemedicina. Reconozco que las videoconsultas pueden no ser adecuadas para todas las condiciones médicas y que mi proveedor de salud puede recomendar una visita presencial si es necesario. Entiendo que problemas técnicos pueden afectar la calidad de la consulta."},
        {"id": "sig-003", "title": "Formulario de Consentimiento de Tratamiento", "type": "treatment_agreement", "date": last_week.strftime("%Y-%m-%d"), "status": "signed", "content_preview": "Reconozco y doy mi consentimiento al plan de tratamiento prescrito según lo discutido durante mi consulta. Entiendo los posibles efectos secundarios y acepto seguir el régimen prescrito. Reportaré cualquier reacción adversa a mi proveedor de salud de inmediato."}
    ])

    # Promotions
    await db.promotions.insert_many([
        {"id": "promo-001", "title": "Chequeo Anual de Salud", "description": "Obtén un chequeo de salud completo con 30% de descuento este mes", "image_url": "promo_health", "cta_text": "Reservar Ahora", "cta_action": "schedule"},
        {"id": "promo-002", "title": "Vacuna contra la Gripe", "description": "Protégete esta temporada. Sin cita o agenda en línea.", "image_url": "promo_vaccine", "cta_text": "Saber Más", "cta_action": "info"},
        {"id": "promo-003", "title": "Teleconsulta Gratuita", "description": "Tu primera videoconsulta es por nuestra cuenta. Usa el código: PRIMERA100", "image_url": "promo_tele", "cta_text": "Comenzar", "cta_action": "schedule"}
    ])

    logger.info("Mock data seeded successfully!")


# ========================
# API Routes
# ========================

# Orchestrator - Home Screen
@api_router.get("/home")
async def get_home_screen():
    user = await db.users.find_one({}, {"_id": 0})
    if not user:
        return {
            "user_name": "User",
            "smart_widget": {"type": "welcome", "data": {"title": "Bienvenido a Mi Salud FdA", "search_placeholder": "Buscar doctores y servicios...", "cta_text": "Agendar una Consulta"}},
            "quick_actions": [],
            "promotions": []
        }

    upcoming = await db.appointments.find(
        {"status": "upcoming"}, {"_id": 0}
    ).sort("date", 1).to_list(10)

    if upcoming:
        smart_widget = {"type": "next_appointment", "data": upcoming[0]}
    else:
        smart_widget = {
            "type": "welcome",
            "data": {
                "title": "Bienvenido a Mi Salud FdA",
                "search_placeholder": "Buscar doctores y servicios...",
                "cta_text": "Agendar una Consulta"
            }
        }

    quick_actions = [
        {"id": "video", "icon": "videocam", "label": "Video\nConsulta"},
        {"id": "schedule", "icon": "calendar", "label": "Agendar\nCita"},
        {"id": "prescription", "icon": "medical", "label": "Mis\nRecetas"},
        {"id": "pharmacy", "icon": "medkit", "label": "Buscar\nFarmacia"}
    ]

    promotions = await db.promotions.find({}, {"_id": 0}).to_list(10)

    return {
        "user_name": user.get("full_name", "User"),
        "smart_widget": smart_widget,
        "quick_actions": quick_actions,
        "promotions": promotions
    }


# Doctors
@api_router.get("/doctors")
async def get_doctors(search: Optional[str] = None):
    query = {}
    if search:
        query = {"$or": [
            {"name": {"$regex": search, "$options": "i"}},
            {"specialty": {"$regex": search, "$options": "i"}}
        ]}
    doctors = await db.doctors.find(query, {"_id": 0}).to_list(100)
    return doctors


@api_router.get("/doctors/{doctor_id}")
async def get_doctor(doctor_id: str):
    doctor = await db.doctors.find_one({"id": doctor_id}, {"_id": 0})
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doctor


# Appointments
@api_router.get("/appointments")
async def get_appointments(status: Optional[str] = None):
    query = {}
    if status == "upcoming":
        query["status"] = "upcoming"
    elif status == "past":
        query["status"] = {"$in": ["completed", "cancelled"]}
    appointments = await db.appointments.find(query, {"_id": 0}).sort("date", -1).to_list(100)
    return appointments


@api_router.get("/appointments/{appointment_id}")
async def get_appointment(appointment_id: str):
    apt = await db.appointments.find_one({"id": appointment_id}, {"_id": 0})
    if not apt:
        raise HTTPException(status_code=404, detail="Appointment not found")
    return apt


@api_router.post("/appointments")
async def create_appointment(data: AppointmentCreate):
    doctor = await db.doctors.find_one({"id": data.doctor_id}, {"_id": 0})
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    apt = {
        "id": str(uuid.uuid4()),
        "doctor_id": data.doctor_id,
        "doctor_name": doctor["name"],
        "doctor_specialty": doctor["specialty"],
        "doctor_avatar": doctor.get("avatar_url", ""),
        "date": data.date,
        "time": data.time,
        "status": "upcoming",
        "type": data.type,
        "notes": data.notes or "",
        "created_at": datetime.now(timezone.utc).isoformat()
    }
    await db.appointments.insert_one(apt)
    apt.pop("_id", None)
    return apt


@api_router.delete("/appointments/{appointment_id}")
async def cancel_appointment(appointment_id: str):
    result = await db.appointments.update_one(
        {"id": appointment_id}, {"$set": {"status": "cancelled"}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Appointment not found")
    return {"message": "Appointment cancelled"}


# Profile
@api_router.get("/profile")
async def get_profile():
    user = await db.users.find_one({}, {"_id": 0})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@api_router.put("/profile")
async def update_profile(data: ProfileUpdate):
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    await db.users.update_one({}, {"$set": update_data})
    user = await db.users.find_one({}, {"_id": 0})
    return user


# Prescriptions
@api_router.get("/prescriptions")
async def get_prescriptions():
    return await db.prescriptions.find({}, {"_id": 0}).sort("date", -1).to_list(100)


@api_router.get("/prescriptions/{prescription_id}")
async def get_prescription(prescription_id: str):
    rx = await db.prescriptions.find_one({"id": prescription_id}, {"_id": 0})
    if not rx:
        raise HTTPException(status_code=404, detail="Prescription not found")
    return rx


# Clinical Documents
@api_router.get("/documents")
async def get_documents():
    return await db.clinical_documents.find({}, {"_id": 0}).sort("date", -1).to_list(100)


@api_router.get("/documents/{document_id}")
async def get_document(document_id: str):
    doc = await db.clinical_documents.find_one({"id": document_id}, {"_id": 0})
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc


# Signature Documents
@api_router.get("/signature-documents")
async def get_signature_documents():
    return await db.signature_documents.find({}, {"_id": 0}).sort("date", -1).to_list(100)


@api_router.post("/signature-documents/{document_id}/sign")
async def sign_document(document_id: str):
    result = await db.signature_documents.update_one(
        {"id": document_id}, {"$set": {"status": "signed"}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Document not found")
    return {"message": "Document signed successfully"}


# Promotions
@api_router.get("/promotions")
async def get_promotions():
    return await db.promotions.find({}, {"_id": 0}).to_list(100)


# ========================
# App Events & Config
# ========================

@app.on_event("startup")
async def startup():
    await seed_data()


app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
