from fastapi import FastAPI, APIRouter, HTTPException, Header, UploadFile, File
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from supabase import create_client, Client
import os
import logging
from pathlib import Path
from pydantic import BaseModel
from typing import List, Optional
import uuid
from datetime import datetime, timezone, timedelta

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

supabase: Client = create_client(
    os.environ['SUPABASE_URL'],
    os.environ['SUPABASE_KEY']
)

app = FastAPI(title='Mi Salud FdA API')
api_router = APIRouter(prefix='/api')


# ========================
# Dependency — usuario activo
# ========================

def current_user(x_user_id: Optional[str] = Header(default='user-001')) -> str:
    return x_user_id or 'user-001'


# ========================
# Pydantic Models
# ========================

class AppointmentCreate(BaseModel):
    doctor_id: Optional[str] = None
    doctor_name: Optional[str] = None
    doctor_specialty: Optional[str] = None
    branch_id: Optional[str] = None
    branch_name: Optional[str] = None
    vaccine_type_id: Optional[str] = None
    test_type_id: Optional[str] = None
    date: str
    time: str
    type: str = 'video'
    payment_status: str = 'pending'
    notes: Optional[str] = None


class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    blood_type: Optional[str] = None
    weight: Optional[str] = None
    height: Optional[str] = None
    allergies: Optional[List[str]] = None


class PaymentRequest(BaseModel):
    card_number: str
    amount: float
    appointment_id: Optional[str] = None


class VitalSignCreate(BaseModel):
    label: str
    value: str
    date: str
    icon_key: str


class PromotionImageUpdate(BaseModel):
    image_url: str


# ========================
# Seed Data
# ========================

def seed_data():
    existing = supabase.table('users').select('id').limit(1).execute()
    if existing.data:
        logger.info('Data already seeded, skipping...')
        return

    logger.info('Seeding mock data...')
    now = datetime.now(timezone.utc)
    fmt = '%Y-%m-%d'

    d = lambda days: (now + timedelta(days=days)).strftime(fmt)

    # ── Doctors ───────────────────────────────────────────────────────────────
    supabase.table('doctors').insert([
        {'id': 'doc-001', 'name': 'Dr. Ana Rodríguez',   'specialty': 'Medicina General', 'rating': 4.8, 'experience_years': 12, 'consultation_fee': 450.0, 'available_slots': ['09:00','10:00','11:00','14:00','15:00']},
        {'id': 'doc-002', 'name': 'Dr. Carlos Méndez',   'specialty': 'Cardiología',      'rating': 4.9, 'experience_years': 15, 'consultation_fee': 750.0, 'available_slots': ['08:00','09:00','10:00','13:00','14:00']},
        {'id': 'doc-003', 'name': 'Dra. Laura Sánchez',  'specialty': 'Dermatología',     'rating': 4.7, 'experience_years': 8,  'consultation_fee': 600.0, 'available_slots': ['10:00','11:00','12:00','15:00','16:00']},
        {'id': 'doc-004', 'name': 'Dr. Roberto Torres',  'specialty': 'Pediatría',        'rating': 4.6, 'experience_years': 10, 'consultation_fee': 500.0, 'available_slots': ['09:00','10:00','11:00','14:00','15:00']},
        {'id': 'doc-005', 'name': 'Dra. Patricia Flores','specialty': 'Ginecología',      'rating': 4.8, 'experience_years': 14, 'consultation_fee': 650.0, 'available_slots': ['08:00','09:00','11:00','13:00','15:00']},
    ]).execute()

    # ── Branches ──────────────────────────────────────────────────────────────
    supabase.table('branches').insert([
        {'id': 'br-001', 'name': 'México Centro, Centro SCOP',    'address': 'Av. Universidad 216-218, Col. Narvarte',   'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03020', 'latitude': 19.4055, 'longitude': -99.1697, 'phone': '55 1234 0001', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
        {'id': 'br-002', 'name': 'México Centro, Eugenia',        'address': 'Av. Cuauhtémoc 919-B, Col. Narvarte',      'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03020', 'latitude': 19.4017, 'longitude': -99.1609, 'phone': '55 1234 0002', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
        {'id': 'br-003', 'name': 'México Centro, Xola',           'address': 'Xola 1001, Col. Narvarte Poniente',        'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03020', 'latitude': 19.4004, 'longitude': -99.1628, 'phone': '55 1234 0003', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
        {'id': 'br-004', 'name': 'México Centro, Viaducto',       'address': 'Calz. de Tlalpan 449-A, Col. Álamos',     'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03400', 'latitude': 19.3899, 'longitude': -99.1453, 'phone': '55 1234 0004', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
        {'id': 'br-005', 'name': 'México Centro, Del Valle',      'address': 'Av. Xola 701, Col. Del Valle Norte',       'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03100', 'latitude': 19.3983, 'longitude': -99.1617, 'phone': '55 1234 0005', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
        {'id': 'br-006', 'name': 'México Centro, Gabriel Mancera','address': 'Gabriel Mancera 123, Col. Del Valle',      'city': 'Ciudad de México', 'state': 'CDMX', 'zip_code': '03100', 'latitude': 19.3951, 'longitude': -99.1611, 'phone': '55 1234 0006', 'schedule': 'Lun-Dom 8:00-22:00', 'services': ['vaccine','test','pharmacy']},
    ]).execute()

    # ── Vaccine Types ──────────────────────────────────────────────────────────
    supabase.table('vaccine_types').insert([
        {'id': 'vac-001', 'name': 'VPH (Virus del Papiloma Humano)', 'description': 'Previene el cáncer cervicouterino. 2 dosis.', 'doses': 2, 'price': 450.0, 'age_range': '9 años en adelante'},
        {'id': 'vac-002', 'name': 'Influenza',                       'description': 'Protección estacional contra la gripe. 1 dosis anual.', 'doses': 1, 'price': 180.0, 'age_range': '6 meses en adelante'},
        {'id': 'vac-003', 'name': 'COVID-19 Refuerzo',               'description': 'Refuerzo de inmunidad contra SARS-CoV-2. 1 dosis.', 'doses': 1, 'price': 0.0, 'age_range': '12 años en adelante'},
        {'id': 'vac-004', 'name': 'Hepatitis B',                     'description': 'Previene la hepatitis viral tipo B. 3 dosis.', 'doses': 3, 'price': 350.0, 'age_range': 'Todas las edades'},
        {'id': 'vac-005', 'name': 'Neumococo',                       'description': 'Previene neumonía y meningitis bacteriana. 1 dosis.', 'doses': 1, 'price': 280.0, 'age_range': 'Adultos mayores y grupos de riesgo'},
        {'id': 'vac-006', 'name': 'Tétanos / dTpa',                  'description': 'Refuerzo contra tétanos, difteria y tosferina. 1 dosis.', 'doses': 1, 'price': 150.0, 'age_range': 'Adultos, embarazadas'},
    ]).execute()

    # ── Test Types ────────────────────────────────────────────────────────────
    supabase.table('test_types').insert([
        {'id': 'tst-001', 'name': 'Antígeno COVID-19',       'description': 'Detecta presencia activa del virus SARS-CoV-2.', 'preparation': 'Sin preparación previa.',        'result_time': '20 minutos', 'price': 250.0},
        {'id': 'tst-002', 'name': 'Influenza A/B',           'description': 'Detecta virus de influenza tipo A y B.',         'preparation': 'Sin preparación previa.',        'result_time': '20 minutos', 'price': 280.0},
        {'id': 'tst-003', 'name': 'Prueba de Embarazo',      'description': 'Detección de hormona hCG en orina.',             'preparation': 'Primera orina del día.',         'result_time': '10 minutos', 'price': 150.0},
        {'id': 'tst-004', 'name': 'Glucosa en Ayuno',        'description': 'Mide nivel de glucosa en sangre en ayuno.',      'preparation': 'Ayuno mínimo de 8 horas.',       'result_time': '24 horas',   'price': 120.0},
        {'id': 'tst-005', 'name': 'Biometría Hemática',      'description': 'Conteo completo de células sanguíneas.',         'preparation': 'Ayuno de 4 horas recomendado.', 'result_time': '24 horas',   'price': 200.0},
        {'id': 'tst-006', 'name': 'Perfil Lipídico',         'description': 'Colesterol total, HDL, LDL y triglicéridos.',   'preparation': 'Ayuno mínimo de 12 horas.',      'result_time': '24 horas',   'price': 350.0},
    ]).execute()

    # ── Promotions ────────────────────────────────────────────────────────────
    supabase.table('promotions').insert([
        {'id': 'promo-001', 'title': 'Fitmingo', 'description': 'Proteína Vegetal. Tu aliado para cuidarte por dentro y por fuera.', 'image_url': 'https://images.unsplash.com/photo-1607170208694-c8e3d66c4b51?w=400&q=80', 'cta_text': 'Ver más',  'cta_action': 'info',     'is_active': True},
        {'id': 'promo-002', 'title': 'Chequeo Preventivo', 'description': 'Agenda tu revisión anual sin costo adicional este mes.', 'image_url': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80', 'cta_text': 'Agendar', 'cta_action': 'schedule', 'is_active': True},
        {'id': 'promo-003', 'title': 'Vacuna Influenza',   'description': 'Protégete esta temporada. Sin cita necesaria.',          'image_url': 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400&q=80', 'cta_text': 'Agendar', 'cta_action': 'schedule', 'is_active': True},
    ]).execute()

    # ── User 001 — María García (perfil completo) ─────────────────────────────
    supabase.table('users').insert({
        'id': 'user-001', 'full_name': 'María García', 'email': 'maria.garcia@example.com',
        'phone': '+52 55 1234 5678', 'date_of_birth': '1990-03-15', 'gender': 'Femenino',
        'blood_type': 'O+', 'weight': '65', 'height': '162',
        'allergies': ['Penicilina', 'Polen'], 'description': 'Paciente activa · Historial médico completo',
    }).execute()
    supabase.table('vital_signs').insert([
        {'id': 'vs-001-1', 'user_id': 'user-001', 'label': 'Tipo de sangre', 'value': 'O+',           'date': d(-30), 'icon_key': 'blood_drop'},
        {'id': 'vs-001-2', 'user_id': 'user-001', 'label': 'Presión',        'value': '120/80 mmHg',  'date': d(-7),  'icon_key': 'vitals'},
        {'id': 'vs-001-3', 'user_id': 'user-001', 'label': 'Peso',           'value': '65 kg',        'date': d(-14), 'icon_key': 'monitor_weight'},
        {'id': 'vs-001-4', 'user_id': 'user-001', 'label': 'Estatura',       'value': '162 cm',       'date': d(-30), 'icon_key': 'height'},
        {'id': 'vs-001-5', 'user_id': 'user-001', 'label': 'Glucosa',        'value': '95 mg/dL',     'date': d(-7),  'icon_key': 'science'},
    ]).execute()
    supabase.table('appointments').insert([
        {'id': 'apt-001', 'user_id': 'user-001', 'doctor_id': 'doc-001', 'doctor_name': 'Dr. Ana Rodríguez',  'doctor_specialty': 'Medicina General', 'date': d(1),   'time': '10:00', 'status': 'upcoming',   'type': 'video',      'payment_status': 'paid',    'notes': 'Revisión de resultados de laboratorio.', 'created_at': now.isoformat()},
        {'id': 'apt-002', 'user_id': 'user-001', 'branch_id': 'br-002',  'branch_name': 'México Centro, Eugenia', 'vaccine_type_id': 'vac-001', 'doctor_name': 'Vacuna VPH',            'doctor_specialty': 'Farmacias del Ahorro',  'date': d(5),   'time': '11:00', 'status': 'upcoming',   'type': 'vaccine',    'payment_status': 'pending', 'notes': 'Segunda dosis. Llevar cartilla de vacunación.',   'created_at': now.isoformat()},
        {'id': 'apt-003', 'user_id': 'user-001', 'doctor_id': 'doc-003', 'doctor_name': 'Dra. Laura Sánchez', 'doctor_specialty': 'Dermatología',     'date': d(-7),  'time': '11:00', 'status': 'completed',  'type': 'video',      'payment_status': 'paid',    'notes': 'Revisión dermatológica.', 'created_at': (now - timedelta(days=14)).isoformat()},
        {'id': 'apt-004', 'user_id': 'user-001', 'branch_id': 'br-001',  'branch_name': 'México Centro, SCOP',   'test_type_id': 'tst-001',    'doctor_name': 'Antígeno COVID-19',    'doctor_specialty': 'Farmacias del Ahorro',  'date': d(-14), 'time': '09:00', 'status': 'completed',  'type': 'test',       'payment_status': 'paid',    'notes': 'Resultado negativo.',             'created_at': (now - timedelta(days=17)).isoformat()},
    ]).execute()
    supabase.table('prescriptions').insert([
        {'id': 'rx-001', 'user_id': 'user-001', 'doctor_name': 'Dr. Ana Rodríguez', 'doctor_specialty': 'Medicina General', 'date': d(-7), 'medications': [{'name': 'Amoxicilina 500mg', 'dosage': '1 cápsula cada 8h', 'duration': '7 días'}, {'name': 'Paracetamol 500mg', 'dosage': '1 tableta cada 6h si hay fiebre', 'duration': '3 días'}], 'diagnosis': 'Infección respiratoria aguda', 'notes': 'Reposo y abundantes líquidos. Evitar alcohol.', 'qr_code_data': 'RX-FDA-001-2026', 'status': 'active'},
        {'id': 'rx-002', 'user_id': 'user-001', 'doctor_name': 'Dra. Laura Sánchez', 'doctor_specialty': 'Dermatología',     'date': d(-14),'medications': [{'name': 'Hidrocortisona Crema 1%', 'dosage': 'Aplicar 2 veces al día', 'duration': '14 días'}, {'name': 'Cetirizina 10mg', 'dosage': '1 tableta diaria', 'duration': '30 días'}], 'diagnosis': 'Dermatitis de contacto', 'notes': 'Evitar exposición solar. SPF 50+.', 'qr_code_data': 'RX-FDA-002-2026', 'status': 'completed'},
    ]).execute()
    supabase.table('clinical_documents').insert([
        {'id': 'cdoc-001', 'user_id': 'user-001', 'title': 'Biometría Hemática',            'type': 'lab_result',           'date': d(-7),  'doctor_name': 'Dr. Ana Rodríguez',  'summary': 'Hemoglobina 13.5 g/dL, Leucocitos 7,500/μL, Plaquetas 250,000/μL. Todos los valores en rangos normales.',       'status': 'available'},
        {'id': 'cdoc-002', 'user_id': 'user-001', 'title': 'Resumen Consulta — Dermatología','type': 'consultation_summary', 'date': d(-14), 'doctor_name': 'Dra. Laura Sánchez', 'summary': 'Dermatitis de contacto leve en antebrazos. Sin signos de infección. Se prescribió corticosteroide tópico.', 'status': 'available'},
    ]).execute()
    supabase.table('signature_documents').insert([
        {'id': 'sig-001', 'user_id': 'user-001', 'title': 'Consentimiento de Videoconsulta', 'type': 'consent_form',        'date': d(0),  'status': 'pending', 'content_preview': 'Doy mi consentimiento para recibir consulta médica por videollamada y entiendo las limitaciones de la telemedicina.'},
        {'id': 'sig-002', 'user_id': 'user-001', 'title': 'Aviso de Privacidad',             'type': 'privacy_policy',      'date': d(-30),'status': 'signed',  'content_preview': 'Sus datos personales son tratados conforme a la legislación vigente en México (LFPDPPP).'},
    ]).execute()
    supabase.table('recent_activity').insert([
        {'id': 'act-001', 'user_id': 'user-001', 'title': 'Amoxicilina 500mg',  'subtitle': 'Infección respiratoria aguda', 'date': d(-7),  'status': 'dispensed',       'type': 'prescription'},
        {'id': 'act-002', 'user_id': 'user-001', 'title': 'Vacuna VPH',         'subtitle': 'Sucursal Eugenia',             'date': d(5),   'status': 'pending_payment', 'type': 'vaccine'},
    ]).execute()

    # ── User 002 — Carlos Mendoza (perfil básico, primer acceso) ──────────────
    supabase.table('users').insert({
        'id': 'user-002', 'full_name': 'Carlos Mendoza', 'email': 'carlos.mendoza@example.com',
        'phone': '+52 55 8765 4321', 'date_of_birth': '1998-07-22', 'gender': 'Masculino',
        'blood_type': 'A+', 'weight': '', 'height': '', 'allergies': [],
        'description': 'Primer acceso · Perfil en configuración',
    }).execute()
    supabase.table('vital_signs').insert([
        {'id': 'vs-002-1', 'user_id': 'user-002', 'label': 'Tipo de sangre', 'value': 'A+',    'date': d(0), 'icon_key': 'blood_drop'},
        {'id': 'vs-002-2', 'user_id': 'user-002', 'label': 'Frec. Cardíaca', 'value': '72 bpm','date': d(0), 'icon_key': 'vitals'},
    ]).execute()
    supabase.table('appointments').insert([
        {'id': 'apt-005', 'user_id': 'user-002', 'branch_id': 'br-001', 'branch_name': 'México Centro, SCOP', 'test_type_id': 'tst-001', 'doctor_name': 'Antígeno COVID-19', 'doctor_specialty': 'Farmacias del Ahorro', 'date': d(2), 'time': '09:00', 'status': 'upcoming', 'type': 'test', 'payment_status': 'pending', 'notes': '', 'created_at': now.isoformat()},
    ]).execute()
    supabase.table('signature_documents').insert([
        {'id': 'sig-003', 'user_id': 'user-002', 'title': 'Aviso de Privacidad', 'type': 'privacy_policy', 'date': d(0), 'status': 'pending', 'content_preview': 'Sus datos personales son tratados conforme a la legislación vigente en México (LFPDPPP).'},
    ]).execute()
    supabase.table('recent_activity').insert([
        {'id': 'act-003', 'user_id': 'user-002', 'title': 'Antígeno COVID-19', 'subtitle': 'Sucursal SCOP', 'date': d(2), 'status': 'pending_payment', 'type': 'test'},
    ]).execute()

    # ── User 003 — Ana López (paciente crónica, historial extenso) ────────────
    supabase.table('users').insert({
        'id': 'user-003', 'full_name': 'Ana López', 'email': 'ana.lopez@example.com',
        'phone': '+52 55 9988 7766', 'date_of_birth': '1963-11-08', 'gender': 'Femenino',
        'blood_type': 'B+', 'weight': '72', 'height': '158',
        'allergies': ['Aspirina', 'Mariscos', 'Látex'],
        'description': 'Paciente crónica · Tratamiento activo',
    }).execute()
    supabase.table('vital_signs').insert([
        {'id': 'vs-003-1', 'user_id': 'user-003', 'label': 'Tipo de sangre', 'value': 'B+',          'date': d(-60), 'icon_key': 'blood_drop'},
        {'id': 'vs-003-2', 'user_id': 'user-003', 'label': 'Presión',        'value': '135/88 mmHg', 'date': d(-3),  'icon_key': 'vitals'},
        {'id': 'vs-003-3', 'user_id': 'user-003', 'label': 'Peso',           'value': '72 kg',       'date': d(-7),  'icon_key': 'monitor_weight'},
        {'id': 'vs-003-4', 'user_id': 'user-003', 'label': 'Estatura',       'value': '158 cm',      'date': d(-60), 'icon_key': 'height'},
        {'id': 'vs-003-5', 'user_id': 'user-003', 'label': 'Glucosa',        'value': '108 mg/dL',   'date': d(-3),  'icon_key': 'science'},
    ]).execute()
    supabase.table('appointments').insert([
        {'id': 'apt-006', 'user_id': 'user-003', 'doctor_id': 'doc-002', 'doctor_name': 'Dr. Carlos Méndez',   'doctor_specialty': 'Cardiología',  'date': d(1),   'time': '08:00', 'status': 'upcoming',  'type': 'in-person', 'payment_status': 'paid',    'notes': 'Control mensual hipertensión.',           'created_at': now.isoformat()},
        {'id': 'apt-007', 'user_id': 'user-003', 'doctor_id': 'doc-005', 'doctor_name': 'Dra. Patricia Flores','doctor_specialty': 'Ginecología',  'date': d(8),   'time': '14:00', 'status': 'upcoming',  'type': 'video',     'payment_status': 'paid',    'notes': 'Seguimiento tratamiento hormonal.',       'created_at': now.isoformat()},
        {'id': 'apt-008', 'user_id': 'user-003', 'branch_id': 'br-003',  'branch_name': 'México Centro, Xola', 'vaccine_type_id': 'vac-002', 'doctor_name': 'Vacuna Influenza', 'doctor_specialty': 'Farmacias del Ahorro', 'date': d(14), 'time': '09:00', 'status': 'upcoming',  'type': 'vaccine',   'payment_status': 'pending', 'notes': 'Refuerzo anual.',                         'created_at': now.isoformat()},
        {'id': 'apt-009', 'user_id': 'user-003', 'doctor_id': 'doc-002', 'doctor_name': 'Dr. Carlos Méndez',   'doctor_specialty': 'Cardiología',  'date': d(-6),  'time': '08:00', 'status': 'completed', 'type': 'in-person', 'payment_status': 'paid',    'notes': 'Control rutinario.',                      'created_at': (now - timedelta(days=10)).isoformat()},
        {'id': 'apt-010', 'user_id': 'user-003', 'doctor_id': 'doc-001', 'doctor_name': 'Dr. Ana Rodríguez',   'doctor_specialty': 'Medicina General','date': d(-20), 'time': '10:00', 'status': 'completed', 'type': 'video',     'payment_status': 'paid',    'notes': 'Gripe estacional.',                       'created_at': (now - timedelta(days=24)).isoformat()},
        {'id': 'apt-011', 'user_id': 'user-003', 'branch_id': 'br-002',  'branch_name': 'México Centro, Eugenia', 'test_type_id': 'tst-004', 'doctor_name': 'Glucosa en Ayuno', 'doctor_specialty': 'Farmacias del Ahorro', 'date': d(-33), 'time': '07:30', 'status': 'completed', 'type': 'test', 'payment_status': 'paid', 'notes': 'Control glucémico.', 'created_at': (now - timedelta(days=37)).isoformat()},
        {'id': 'apt-012', 'user_id': 'user-003', 'doctor_id': 'doc-005', 'doctor_name': 'Dra. Patricia Flores','doctor_specialty': 'Ginecología',  'date': d(-49), 'time': '14:00', 'status': 'completed', 'type': 'in-person', 'payment_status': 'paid',    'notes': 'Inicio de tratamiento hormonal.',         'created_at': (now - timedelta(days=53)).isoformat()},
    ]).execute()
    supabase.table('prescriptions').insert([
        {'id': 'rx-003', 'user_id': 'user-003', 'doctor_name': 'Dr. Carlos Méndez',   'doctor_specialty': 'Cardiología', 'date': d(-6),  'medications': [{'name': 'Losartán 50mg', 'dosage': '1 tableta diaria', 'duration': '30 días'}, {'name': 'Amlodipino 5mg', 'dosage': '1 tableta diaria', 'duration': '30 días'}], 'diagnosis': 'Hipertensión arterial controlada', 'notes': 'Dieta baja en sodio. Ejercicio moderado. Control en 1 mes.', 'qr_code_data': 'RX-FDA-003-2026', 'status': 'active'},
        {'id': 'rx-004', 'user_id': 'user-003', 'doctor_name': 'Dra. Patricia Flores', 'doctor_specialty': 'Ginecología', 'date': d(-49), 'medications': [{'name': 'Estrógenos Conjugados 0.625mg', 'dosage': '1 tableta diaria', 'duration': '90 días'}, {'name': 'Progesterona 200mg', 'dosage': '1 cápsula cada noche', 'duration': '14 días del ciclo'}], 'diagnosis': 'Síndrome climatérico', 'notes': 'Control hormonal. Cita de seguimiento en 3 meses.', 'qr_code_data': 'RX-FDA-004-2026', 'status': 'active'},
    ]).execute()
    supabase.table('clinical_documents').insert([
        {'id': 'cdoc-003', 'user_id': 'user-003', 'title': 'ECG — Evaluación Cardiaca',   'type': 'consultation_summary', 'date': d(-6),  'doctor_name': 'Dr. Carlos Méndez',   'summary': 'Ritmo sinusal normal, FC 78 lpm. PA 135/88. Sin arritmias detectadas. Continúa tratamiento antihipertensivo.', 'status': 'available'},
        {'id': 'cdoc-004', 'user_id': 'user-003', 'title': 'Perfil Lipídico',             'type': 'lab_result',           'date': d(-33), 'doctor_name': 'Dr. Carlos Méndez',   'summary': 'Colesterol total 198 mg/dL, LDL 118, HDL 52, Triglicéridos 140. Perfil lipídico dentro de rangos aceptables.',  'status': 'available'},
        {'id': 'cdoc-005', 'user_id': 'user-003', 'title': 'Resumen Consulta Ginecológica','type': 'consultation_summary', 'date': d(-49), 'doctor_name': 'Dra. Patricia Flores', 'summary': 'Síndrome climatérico con sofocos moderados. Se inicia terapia hormonal sustitutiva. Próxima cita en 3 meses.',    'status': 'available'},
    ]).execute()
    supabase.table('signature_documents').insert([
        {'id': 'sig-004', 'user_id': 'user-003', 'title': 'Consentimiento de Tratamiento Hormonal', 'type': 'treatment_agreement', 'date': d(-49), 'status': 'signed',  'content_preview': 'Autorizo el inicio de terapia hormonal sustitutiva y confirmo haber recibido información sobre beneficios y riesgos.'},
        {'id': 'sig-005', 'user_id': 'user-003', 'title': 'Aviso de Privacidad',                    'type': 'privacy_policy',      'date': d(-60), 'status': 'signed',  'content_preview': 'Sus datos personales son tratados conforme a la legislación vigente en México (LFPDPPP).'},
    ]).execute()
    supabase.table('recent_activity').insert([
        {'id': 'act-004', 'user_id': 'user-003', 'title': 'Losartán 50mg',      'subtitle': 'Hipertensión arterial controlada', 'date': d(-6),  'status': 'dispensed',       'type': 'prescription'},
        {'id': 'act-005', 'user_id': 'user-003', 'title': 'Vacuna Influenza',   'subtitle': 'Sucursal Xola',                   'date': d(14),  'status': 'pending_payment', 'type': 'vaccine'},
        {'id': 'act-006', 'user_id': 'user-003', 'title': 'Glucosa en Ayuno',   'subtitle': 'Resultado: 108 mg/dL',            'date': d(-33), 'status': 'completed',       'type': 'test'},
    ]).execute()

    logger.info('Mock data seeded successfully — 3 users, full catalog.')


# ========================
# API Routes
# ========================

# ── Usuarios ─────────────────────────────────────────────────────────────────

@api_router.get('/users')
def get_users():
    return supabase.table('users').select('id,full_name,description,blood_type,gender,date_of_birth').execute().data


# ── Home ──────────────────────────────────────────────────────────────────────

@api_router.get('/home')
def get_home_screen(user_id: str = current_user):
    user = supabase.table('users').select('full_name').eq('id', user_id).execute()
    promotions = supabase.table('promotions').select('*').eq('is_active', True).execute()
    user_name = user.data[0]['full_name'] if user.data else 'Usuario'
    quick_actions = [
        {'id': 'expediente', 'icon': 'expediente', 'label': 'Mi expediente\nclínico'},
        {'id': 'video',      'icon': 'videocam',   'label': 'Videoconsulta\nen Medicina g.'},
        {'id': 'schedule',   'icon': 'calendar',   'label': 'Agendar\nCita'},
        {'id': 'prescription','icon': 'medical',   'label': 'Escanear\nrecetas'},
        {'id': 'pharmacy',   'icon': 'medkit',     'label': 'Buscar\nFarmacia'},
    ]
    return {'user_name': user_name, 'quick_actions': quick_actions, 'promotions': promotions.data}


# ── Doctors ───────────────────────────────────────────────────────────────────

@api_router.get('/doctors')
def get_doctors(search: Optional[str] = None):
    if search:
        return supabase.table('doctors').select('*').or_(f'name.ilike.%{search}%,specialty.ilike.%{search}%').execute().data
    return supabase.table('doctors').select('*').execute().data


@api_router.get('/doctors/{doctor_id}')
def get_doctor(doctor_id: str):
    result = supabase.table('doctors').select('*').eq('id', doctor_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Doctor not found')
    return result.data[0]


# ── Appointments ──────────────────────────────────────────────────────────────

@api_router.get('/appointments')
def get_appointments(status: Optional[str] = None, user_id: str = current_user):
    query = supabase.table('appointments').select('*').eq('user_id', user_id)
    if status == 'upcoming':
        query = query.eq('status', 'upcoming')
    elif status == 'past':
        query = query.in_('status', ['completed', 'cancelled'])
    return query.order('date', desc=True).execute().data


@api_router.get('/appointments/{appointment_id}')
def get_appointment(appointment_id: str, user_id: str = current_user):
    result = supabase.table('appointments').select('*').eq('id', appointment_id).eq('user_id', user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Appointment not found')
    return result.data[0]


@api_router.post('/appointments')
def create_appointment(data: AppointmentCreate, user_id: str = current_user):
    apt = {
        'id': str(uuid.uuid4()),
        'user_id': user_id,
        'doctor_id': data.doctor_id,
        'doctor_name': data.doctor_name or '',
        'doctor_specialty': data.doctor_specialty or '',
        'branch_id': data.branch_id,
        'branch_name': data.branch_name,
        'vaccine_type_id': data.vaccine_type_id,
        'test_type_id': data.test_type_id,
        'date': data.date,
        'time': data.time,
        'status': 'upcoming',
        'type': data.type,
        'payment_status': data.payment_status,
        'notes': data.notes or '',
        'created_at': datetime.now(timezone.utc).isoformat(),
    }
    if data.doctor_id and not data.doctor_name:
        doc = supabase.table('doctors').select('name,specialty').eq('id', data.doctor_id).execute()
        if doc.data:
            apt['doctor_name'] = doc.data[0]['name']
            apt['doctor_specialty'] = doc.data[0]['specialty']
    supabase.table('appointments').insert(apt).execute()
    return apt


@api_router.delete('/appointments/{appointment_id}')
def cancel_appointment(appointment_id: str, user_id: str = current_user):
    result = supabase.table('appointments').update({'status': 'cancelled'}).eq('id', appointment_id).eq('user_id', user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Appointment not found')
    return {'message': 'Appointment cancelled'}


# ── Profile ───────────────────────────────────────────────────────────────────

@api_router.get('/profile')
def get_profile(user_id: str = current_user):
    user = supabase.table('users').select('*').eq('id', user_id).execute()
    if not user.data:
        raise HTTPException(status_code=404, detail='User not found')
    vitals = supabase.table('vital_signs').select('*').eq('user_id', user_id).execute()
    profile = user.data[0]
    profile['vital_signs'] = vitals.data
    return profile


@api_router.put('/profile')
def update_profile(data: ProfileUpdate, user_id: str = current_user):
    update_data = {k: v for k, v in data.model_dump().items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail='No fields to update')
    supabase.table('users').update(update_data).eq('id', user_id).execute()
    user = supabase.table('users').select('*').eq('id', user_id).execute()
    vitals = supabase.table('vital_signs').select('*').eq('user_id', user_id).execute()
    profile = user.data[0]
    profile['vital_signs'] = vitals.data
    return profile


@api_router.post('/profile/vitals')
def add_vital_sign(data: VitalSignCreate, user_id: str = current_user):
    vital = {'id': str(uuid.uuid4()), 'user_id': user_id, 'label': data.label, 'value': data.value, 'date': data.date, 'icon_key': data.icon_key}
    supabase.table('vital_signs').insert(vital).execute()
    return vital


# ── Prescriptions ─────────────────────────────────────────────────────────────

@api_router.get('/prescriptions')
def get_prescriptions(user_id: str = current_user):
    return supabase.table('prescriptions').select('*').eq('user_id', user_id).order('date', desc=True).execute().data


@api_router.get('/prescriptions/{prescription_id}')
def get_prescription(prescription_id: str, user_id: str = current_user):
    result = supabase.table('prescriptions').select('*').eq('id', prescription_id).eq('user_id', user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Prescription not found')
    return result.data[0]


# ── Clinical Documents ────────────────────────────────────────────────────────

@api_router.get('/documents')
def get_documents(user_id: str = current_user):
    return supabase.table('clinical_documents').select('*').eq('user_id', user_id).order('date', desc=True).execute().data


@api_router.get('/documents/{document_id}')
def get_document(document_id: str, user_id: str = current_user):
    result = supabase.table('clinical_documents').select('*').eq('id', document_id).eq('user_id', user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Document not found')
    return result.data[0]


# ── Signature Documents ───────────────────────────────────────────────────────

@api_router.get('/signature-documents')
def get_signature_documents(user_id: str = current_user):
    return supabase.table('signature_documents').select('*').eq('user_id', user_id).order('date', desc=True).execute().data


@api_router.post('/signature-documents/{document_id}/sign')
def sign_document(document_id: str, user_id: str = current_user):
    result = supabase.table('signature_documents').update({'status': 'signed'}).eq('id', document_id).eq('user_id', user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Document not found')
    return {'message': 'Document signed successfully'}


# ── Recent Activity ───────────────────────────────────────────────────────────

@api_router.get('/recent-activity')
def get_recent_activity(user_id: str = current_user):
    return supabase.table('recent_activity').select('*').eq('user_id', user_id).order('date', desc=True).execute().data


# ── Branches ─────────────────────────────────────────────────────────────────

@api_router.get('/branches')
def get_branches(service: Optional[str] = None, state: Optional[str] = None, city: Optional[str] = None):
    query = supabase.table('branches').select('*')
    if state:
        query = query.eq('state', state)
    if city:
        query = query.ilike('city', f'%{city}%')
    results = query.execute().data
    if service:
        results = [b for b in results if service in (b.get('services') or [])]
    return results


# ── Vaccine Types ─────────────────────────────────────────────────────────────

@api_router.get('/vaccine-types')
def get_vaccine_types():
    return supabase.table('vaccine_types').select('*').execute().data


# ── Test Types ────────────────────────────────────────────────────────────────

@api_router.get('/test-types')
def get_test_types():
    return supabase.table('test_types').select('*').execute().data


# ── Promotions ────────────────────────────────────────────────────────────────

@api_router.get('/promotions')
def get_promotions():
    return supabase.table('promotions').select('*').eq('is_active', True).execute().data


@api_router.put('/promotions/{promo_id}/image')
def update_promotion_image(promo_id: str, data: PromotionImageUpdate):
    result = supabase.table('promotions').update({'image_url': data.image_url}).eq('id', promo_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail='Promotion not found')
    return result.data[0]


# ── Payment (Orquestador) ─────────────────────────────────────────────────────
# Lógica de validación SOLO aquí. Flutter nunca conoce las reglas.
# - Termina en 4242 → aprobada
# - Termina en 0000 → declinada
# - Termina en 9999 → error de banco (HTTP 503)
# - Cualquier otra  → aprobada (PoC)

@api_router.post('/payment/process')
def process_payment(data: PaymentRequest, user_id: str = current_user):
    digits = data.card_number.replace(' ', '').replace('-', '')
    last_four = digits[-4:] if len(digits) >= 4 else digits

    if last_four == '9999':
        raise HTTPException(status_code=503, detail='Error de conexión con el banco. Intente nuevamente.')

    if last_four == '0000':
        return {'status': 'declined', 'message': 'Tarjeta declinada. Verifique sus datos o use otra tarjeta.'}

    # Aprobada (4242 o cualquier otra)
    if data.appointment_id:
        supabase.table('appointments').update({'payment_status': 'paid'}).eq('id', data.appointment_id).eq('user_id', user_id).execute()

    return {'status': 'approved', 'message': 'Pago aprobado exitosamente.', 'amount': data.amount}


# ── Prescription AI Validation ────────────────────────────────────────────────
# Simula validación IA de receta médica.
# Regla demo: si el nombre del archivo contiene 'error' o 'invalid' → falla.
# Cualquier otro archivo → receta válida con medicamentos mock.

@api_router.post('/prescriptions/validate')
async def validate_prescription(
    file: UploadFile = File(...),
    x_user_id: Optional[str] = Header(default='user-001'),
):
    filename = (file.filename or '').lower()

    if any(kw in filename for kw in ('error', 'invalid', 'bad')):
        return {
            'valid': False,
            'message': 'No pudimos leer la receta. Asegúrate de que la imagen sea clara y legible.',
        }

    return {
        'valid': True,
        'prescription_id': f'rx-ai-{uuid.uuid4().hex[:8]}',
        'patient_name': 'Ana García López',
        'doctor_name': 'Dr. Roberto Martínez García',
        'doctor_cedula': '8754321',
        'issue_date': '2 de mayo de 2026',
        'medications': [
            {
                'name': 'Amoxicilina',
                'strength': '500mg',
                'dosage': '1 cápsula',
                'frequency': 'Cada 8 horas',
                'duration': '7 días',
                'quantity': 21,
                'is_antibiotic': True,
                'is_psychotropic': False,
                'available_strengths': ['250mg', '500mg', '875mg'],
                'alternatives': [
                    {'name': 'Amoxicilina Genérico', 'brand': 'Genérico', 'strength': '500mg', 'price': 89.00},
                    {'name': 'Amoxil', 'brand': 'Pfizer', 'strength': '500mg', 'price': 145.00},
                ],
            },
            {
                'name': 'Ibuprofeno',
                'strength': '400mg',
                'dosage': '1 tableta',
                'frequency': 'Cada 8 horas (con alimentos)',
                'duration': '5 días',
                'quantity': 15,
                'is_antibiotic': False,
                'is_psychotropic': False,
                'available_strengths': ['200mg', '400mg', '600mg'],
                'alternatives': [
                    {'name': 'Ibuprofen Genérico', 'brand': 'Genérico', 'strength': '400mg', 'price': 45.00},
                    {'name': 'Advil', 'brand': 'Pfizer', 'strength': '400mg', 'price': 78.00},
                    {'name': 'Brufen', 'brand': 'Abbott', 'strength': '400mg', 'price': 65.00},
                ],
            },
            {
                'name': 'Omeprazol',
                'strength': '20mg',
                'dosage': '1 cápsula',
                'frequency': 'En ayunas',
                'duration': '14 días',
                'quantity': 14,
                'is_antibiotic': False,
                'is_psychotropic': False,
                'available_strengths': ['10mg', '20mg', '40mg'],
                'alternatives': [
                    {'name': 'Omeprazol Genérico', 'brand': 'Genérico', 'strength': '20mg', 'price': 35.00},
                    {'name': 'Losec', 'brand': 'AstraZeneca', 'strength': '20mg', 'price': 125.00},
                ],
            },
            {
                'name': 'Clonazepam',
                'strength': '0.5mg',
                'dosage': '1 tableta',
                'frequency': 'Cada 12 horas',
                'duration': '30 días',
                'quantity': 60,
                'is_antibiotic': False,
                'is_psychotropic': True,
                'available_strengths': ['0.5mg', '1mg', '2mg'],
                'alternatives': [
                    {'name': 'Clonazepam Genérico', 'brand': 'Genérico', 'strength': '0.5mg', 'price': 95.00},
                    {'name': 'Rivotril', 'brand': 'Roche', 'strength': '0.5mg', 'price': 210.00},
                ],
            },
        ],
        'message': 'Receta validada exitosamente',
    }


# ========================
# App Config
# ========================

@app.on_event('startup')
def startup():
    seed_data()

app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)
