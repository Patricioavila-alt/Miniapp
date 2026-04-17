// ─── Modelos Dart — Mi Salud FdA ─────────────────────────────────────────────
// Mapean 1:1 con las respuestas del backend FastAPI

// ─── Doctor ──────────────────────────────────────────────────────────────────
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String avatarUrl;
  final double rating;
  final int experienceYears;
  final double consultationFee;
  final List<String> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.rating,
    required this.experienceYears,
    required this.consultationFee,
    required this.availableSlots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    specialty: json['specialty'] ?? '',
    avatarUrl: json['avatar_url'] ?? '',
    rating: (json['rating'] as num).toDouble(),
    experienceYears: json['experience_years'] ?? 0,
    consultationFee: (json['consultation_fee'] as num).toDouble(),
    availableSlots: List<String>.from(json['available_slots'] ?? []),
  );
}

// ─── Appointment ─────────────────────────────────────────────────────────────
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatar;
  final String date;
  final String time;
  final String status; // upcoming | completed | cancelled
  final String type;   // video | in-person
  final String notes;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorAvatar,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] ?? '',
    doctorId: json['doctor_id'] ?? '',
    doctorName: json['doctor_name'] ?? '',
    doctorSpecialty: json['doctor_specialty'] ?? '',
    doctorAvatar: json['doctor_avatar'] ?? '',
    date: json['date'] ?? '',
    time: json['time'] ?? '',
    status: json['status'] ?? '',
    type: json['type'] ?? 'video',
    notes: json['notes'] ?? '',
  );

  bool get isUpcoming => status == 'upcoming';
  bool get isVideo => type == 'video';
}

// ─── Medication ──────────────────────────────────────────────────────────────
class Medication {
  final String name;
  final String dosage;
  final String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    name: json['name'] ?? '',
    dosage: json['dosage'] ?? '',
    duration: json['duration'] ?? '',
  );
}

// ─── Prescription ─────────────────────────────────────────────────────────────
class Prescription {
  final String id;
  final String doctorName;
  final String doctorSpecialty;
  final String date;
  final List<Medication> medications;
  final String diagnosis;
  final String notes;
  final String qrCodeData;
  final String status; // active | completed

  Prescription({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.medications,
    required this.diagnosis,
    required this.notes,
    required this.qrCodeData,
    required this.status,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json['id'] ?? '',
    doctorName: json['doctor_name'] ?? '',
    doctorSpecialty: json['doctor_specialty'] ?? '',
    date: json['date'] ?? '',
    medications: (json['medications'] as List<dynamic>? ?? [])
        .map((m) => Medication.fromJson(m))
        .toList(),
    diagnosis: json['diagnosis'] ?? '',
    notes: json['notes'] ?? '',
    qrCodeData: json['qr_code_data'] ?? '',
    status: json['status'] ?? 'active',
  );
}

// ─── ClinicalDocument ─────────────────────────────────────────────────────────
class ClinicalDocument {
  final String id;
  final String title;
  final String type; // lab_result | consultation_summary
  final String date;
  final String doctorName;
  final String summary;
  final String status; // available

  ClinicalDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.doctorName,
    required this.summary,
    required this.status,
  });

  factory ClinicalDocument.fromJson(Map<String, dynamic> json) =>
      ClinicalDocument(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        date: json['date'] ?? '',
        doctorName: json['doctor_name'] ?? '',
        summary: json['summary'] ?? '',
        status: json['status'] ?? '',
      );
}

// ─── SignatureDocument ─────────────────────────────────────────────────────────
class SignatureDocument {
  final String id;
  final String title;
  final String type; // privacy_policy | consent_form | treatment_agreement
  final String date;
  final String status; // pending | signed
  final String contentPreview;

  SignatureDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.status,
    required this.contentPreview,
  });

  factory SignatureDocument.fromJson(Map<String, dynamic> json) =>
      SignatureDocument(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? 'pending',
        contentPreview: json['content_preview'] ?? '',
      );

  bool get isPending => status == 'pending';
}

// ─── Promotion ────────────────────────────────────────────────────────────────
class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String ctaText;
  final String ctaAction;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ctaText,
    required this.ctaAction,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    imageUrl: json['image_url'] ?? '',
    ctaText: json['cta_text'] ?? '',
    ctaAction: json['cta_action'] ?? '',
  );
}

// ─── VitalSign ────────────────────────────────────────────────────────────────
class VitalSign {
  final String label;
  final String value;
  final String date;
  final String iconKey;

  VitalSign({
    required this.label,
    required this.value,
    required this.date,
    required this.iconKey,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) => VitalSign(
    label: json['label'] ?? '',
    value: json['value'] ?? '',
    date: json['date'] ?? '',
    iconKey: json['icon_key'] ?? '',
  );
}

// ─── UserProfile ──────────────────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String bloodType;
  final String weight;
  final String height;
  final List<String> allergies;
  final String avatarUrl;
  final List<VitalSign> vitalSigns;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodType,
    required this.weight,
    required this.height,
    required this.allergies,
    required this.avatarUrl,
    required this.vitalSigns,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    fullName: json['full_name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dateOfBirth: json['date_of_birth'] ?? '',
    gender: json['gender'] ?? '',
    bloodType: json['blood_type'] ?? '',
    weight: json['weight'] ?? '',
    height: json['height'] ?? '',
    allergies: List<String>.from(json['allergies'] ?? []),
    avatarUrl: json['avatar_url'] ?? '',
    vitalSigns: (json['vital_signs'] as List<dynamic>? ?? [])
        .map((v) => VitalSign.fromJson(v))
        .toList(),
  );
}

// ─── RecentActivityItem ──────────────────────────────────────────────────────
class RecentActivityItem {
  final String id;
  final String title;
  final String? subtitle;  // null si no aplica
  final String date;
  final String status;     // 'pending_payment' | 'dispensed' | 'completed'
  final String type;       // 'vaccine' | 'prescription' | 'test'

  RecentActivityItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    required this.status,
    required this.type,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) =>
      RecentActivityItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'],
        date: json['date'] ?? '',
        status: json['status'] ?? '',
        type: json['type'] ?? 'prescription',
      );
}

// ─── HomeData ─────────────────────────────────────────────────────────────────
class HomeData {
  final String userName;
  final Map<String, dynamic> smartWidget;
  final List<Map<String, dynamic>> quickActions;
  final List<Promotion> promotions;

  HomeData({
    required this.userName,
    required this.smartWidget,
    required this.quickActions,
    required this.promotions,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    userName: json['user_name'] ?? 'Usuario',
    smartWidget: json['smart_widget'] ?? {},
    quickActions: List<Map<String, dynamic>>.from(json['quick_actions'] ?? []),
    promotions: (json['promotions'] as List<dynamic>? ?? [])
        .map((p) => Promotion.fromJson(p))
        .toList(),
  );
}
