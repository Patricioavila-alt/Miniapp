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
        "gender": "Female",
        "blood_type": "O+",
        "allergies": ["Penicillin", "Pollen"],
        "avatar_url": ""
    })

    # Doctors
    await db.doctors.insert_many([
        {"id": "doc-001", "name": "Dr. Ana Rodríguez", "specialty": "General Medicine", "avatar_url": "", "rating": 4.8, "experience_years": 12, "consultation_fee": 45.0, "available_slots": ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00"]},
        {"id": "doc-002", "name": "Dr. Carlos Méndez", "specialty": "Cardiology", "avatar_url": "", "rating": 4.9, "experience_years": 15, "consultation_fee": 75.0, "available_slots": ["08:00", "09:00", "10:00", "13:00", "14:00"]},
        {"id": "doc-003", "name": "Dr. Laura Sánchez", "specialty": "Dermatology", "avatar_url": "", "rating": 4.7, "experience_years": 8, "consultation_fee": 60.0, "available_slots": ["10:00", "11:00", "12:00", "15:00", "16:00", "17:00"]},
        {"id": "doc-004", "name": "Dr. Roberto Torres", "specialty": "Pediatrics", "avatar_url": "", "rating": 4.6, "experience_years": 10, "consultation_fee": 50.0, "available_slots": ["09:00", "10:00", "11:00", "14:00", "15:00"]},
        {"id": "doc-005", "name": "Dr. Patricia Flores", "specialty": "Gynecology", "avatar_url": "", "rating": 4.8, "experience_years": 14, "consultation_fee": 65.0, "available_slots": ["08:00", "09:00", "11:00", "13:00", "15:00", "16:00"]}
    ])

    # Appointments
    await db.appointments.insert_many([
        {"id": "apt-001", "doctor_id": "doc-001", "doctor_name": "Dr. Ana Rodríguez", "doctor_specialty": "General Medicine", "doctor_avatar": "", "date": tomorrow.strftime("%Y-%m-%d"), "time": "10:00", "status": "upcoming", "type": "video", "notes": "Follow-up consultation", "created_at": now.isoformat()},
        {"id": "apt-002", "doctor_id": "doc-002", "doctor_name": "Dr. Carlos Méndez", "doctor_specialty": "Cardiology", "doctor_avatar": "", "date": next_week.strftime("%Y-%m-%d"), "time": "14:00", "status": "upcoming", "type": "in-person", "notes": "Annual check-up", "created_at": now.isoformat()},
        {"id": "apt-003", "doctor_id": "doc-003", "doctor_name": "Dr. Laura Sánchez", "doctor_specialty": "Dermatology", "doctor_avatar": "", "date": last_week.strftime("%Y-%m-%d"), "time": "11:00", "status": "completed", "type": "video", "notes": "Skin check", "created_at": two_weeks_ago.isoformat()},
        {"id": "apt-004", "doctor_id": "doc-004", "doctor_name": "Dr. Roberto Torres", "doctor_specialty": "Pediatrics", "doctor_avatar": "", "date": two_weeks_ago.strftime("%Y-%m-%d"), "time": "09:00", "status": "completed", "type": "in-person", "notes": "Child vaccination", "created_at": (two_weeks_ago - timedelta(days=3)).isoformat()}
    ])

    # Prescriptions
    await db.prescriptions.insert_many([
        {"id": "rx-001", "doctor_name": "Dr. Ana Rodríguez", "doctor_specialty": "General Medicine", "date": last_week.strftime("%Y-%m-%d"), "medications": [{"name": "Amoxicillin 500mg", "dosage": "1 tablet every 8 hours", "duration": "7 days"}, {"name": "Ibuprofen 400mg", "dosage": "1 tablet every 12 hours if needed", "duration": "5 days"}], "diagnosis": "Upper respiratory infection", "notes": "Take with food. Avoid alcohol during treatment.", "qr_code_data": "RX-001-MARIA-GARCIA-2025", "status": "active"},
        {"id": "rx-002", "doctor_name": "Dr. Laura Sánchez", "doctor_specialty": "Dermatology", "date": two_weeks_ago.strftime("%Y-%m-%d"), "medications": [{"name": "Hydrocortisone Cream 1%", "dosage": "Apply twice daily", "duration": "14 days"}, {"name": "Cetirizine 10mg", "dosage": "1 tablet daily", "duration": "30 days"}], "diagnosis": "Contact dermatitis", "notes": "Avoid prolonged sun exposure. Use sunscreen SPF 50+.", "qr_code_data": "RX-002-MARIA-GARCIA-2025", "status": "completed"}
    ])

    # Clinical Documents
    await db.clinical_documents.insert_many([
        {"id": "cdoc-001", "title": "Complete Blood Count Results", "type": "lab_result", "date": last_week.strftime("%Y-%m-%d"), "doctor_name": "Dr. Ana Rodríguez", "summary": "All values within normal range. Hemoglobin 13.5 g/dL, WBC 7,500/μL. Platelet count 250,000/μL. No abnormalities detected.", "status": "available"},
        {"id": "cdoc-002", "title": "Consultation Summary - Cardiac Evaluation", "type": "consultation_summary", "date": two_weeks_ago.strftime("%Y-%m-%d"), "doctor_name": "Dr. Carlos Méndez", "summary": "Patient presents with no significant cardiac findings. Blood pressure 120/80 mmHg. Heart rate 72 bpm, regular rhythm. ECG normal sinus rhythm. No murmurs or arrhythmias detected.", "status": "available"},
        {"id": "cdoc-003", "title": "Dermatology Assessment Report", "type": "consultation_summary", "date": two_weeks_ago.strftime("%Y-%m-%d"), "doctor_name": "Dr. Laura Sánchez", "summary": "Mild contact dermatitis on forearms. No signs of infection. Prescribed topical corticosteroid and oral antihistamine. Follow-up in 2 weeks to assess treatment efficacy.", "status": "available"}
    ])

    # Signature Documents
    await db.signature_documents.insert_many([
        {"id": "sig-001", "title": "Privacy Policy Agreement", "type": "privacy_policy", "date": now.strftime("%Y-%m-%d"), "status": "pending", "content_preview": "By signing this document, you agree to our data handling and privacy practices as outlined in our comprehensive privacy policy. Your personal health information will be handled in accordance with HIPAA regulations and local data protection laws. We are committed to protecting your sensitive medical data and will only share information with authorized healthcare providers involved in your care."},
        {"id": "sig-002", "title": "Video Consultation Consent", "type": "consent_form", "date": now.strftime("%Y-%m-%d"), "status": "pending", "content_preview": "I consent to receive medical consultation via video call and understand the limitations of telemedicine. I acknowledge that video consultations may not be suitable for all medical conditions and that my healthcare provider may recommend an in-person visit if necessary. I understand that technical issues may affect the quality of the consultation."},
        {"id": "sig-003", "title": "Treatment Consent Form", "type": "treatment_agreement", "date": last_week.strftime("%Y-%m-%d"), "status": "signed", "content_preview": "I acknowledge and consent to the prescribed treatment plan as discussed during my consultation. I understand the potential side effects and agree to follow the prescribed regimen. I will report any adverse reactions to my healthcare provider immediately."}
    ])

    # Promotions
    await db.promotions.insert_many([
        {"id": "promo-001", "title": "Annual Health Check-Up", "description": "Get a comprehensive health screening at 30% off this month", "image_url": "promo_health", "cta_text": "Book Now", "cta_action": "schedule"},
        {"id": "promo-002", "title": "Flu Vaccine Available", "description": "Protect yourself this season. Walk-in or schedule online.", "image_url": "promo_vaccine", "cta_text": "Learn More", "cta_action": "info"},
        {"id": "promo-003", "title": "Free Teleconsultation", "description": "Your first video consultation is on us. Use code: FIRST100", "image_url": "promo_tele", "cta_text": "Get Started", "cta_action": "schedule"}
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
            "smart_widget": {"type": "welcome", "data": {"title": "Welcome to Mi Salud FdA", "search_placeholder": "Search doctors and services...", "cta_text": "Schedule a Consultation"}},
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
                "title": "Welcome to Mi Salud FdA",
                "search_placeholder": "Search doctors and services...",
                "cta_text": "Schedule a Consultation"
            }
        }

    quick_actions = [
        {"id": "video", "icon": "videocam", "label": "Video\nConsultation"},
        {"id": "schedule", "icon": "calendar", "label": "Schedule\nAppointment"},
        {"id": "prescription", "icon": "medical", "label": "My\nPrescriptions"},
        {"id": "pharmacy", "icon": "medkit", "label": "Find a\nPharmacy"}
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
