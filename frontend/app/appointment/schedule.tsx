import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  TextInput, ActivityIndicator, Alert, Dimensions,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;
const SCREEN_W = Dimensions.get('window').width;

export default function ScheduleAppointment() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [step, setStep] = useState(1);
  const [doctors, setDoctors] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [selectedDoctor, setSelectedDoctor] = useState<any>(null);
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedTime, setSelectedTime] = useState('');
  const [aptType, setAptType] = useState<'video' | 'in-person'>('video');
  const [booking, setBooking] = useState(false);
  const [createdApt, setCreatedApt] = useState<any>(null);

  useEffect(() => { fetchDoctors(); }, []);

  const fetchDoctors = async (q?: string) => {
    try {
      const url = q ? `${API_URL}/api/doctors?search=${q}` : `${API_URL}/api/doctors`;
      const res = await fetch(url);
      setDoctors(await res.json());
    } catch (e) {
      console.error('Failed to fetch doctors:', e);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (text: string) => {
    setSearch(text);
    fetchDoctors(text);
  };

  const getNextDays = () => {
    const days = [];
    const today = new Date();
    for (let i = 1; i <= 7; i++) {
      const d = new Date(today);
      d.setDate(today.getDate() + i);
      days.push({
        date: d.toISOString().split('T')[0],
        day: d.toLocaleDateString('en', { weekday: 'short' }),
        num: d.getDate(),
        month: d.toLocaleDateString('en', { month: 'short' }),
      });
    }
    return days;
  };

  const handleBook = async () => {
    setBooking(true);
    try {
      const res = await fetch(`${API_URL}/api/appointments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          doctor_id: selectedDoctor.id,
          date: selectedDate,
          time: selectedTime,
          type: aptType,
        }),
      });
      const json = await res.json();
      setCreatedApt(json);
      setStep(4);
    } catch (e) {
      Alert.alert('Error', 'Error al agendar la cita');
    } finally {
      setBooking(false);
    }
  };

  const days = getNextDays();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          testID="back-btn"
          onPress={() => (step > 1 && step < 4 ? setStep(step - 1) : router.back())}
          style={styles.backBtn}
        >
          <Ionicons name="arrow-back" size={24} color="#232323" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>
          {step === 1
            ? 'Seleccionar Doctor'
            : step === 2
            ? 'Seleccionar Horario'
            : step === 3
            ? 'Confirmar Cita'
            : '¡Agendada!'}
        </Text>
        <View style={{ width: 40 }} />
      </View>

      {/* Progress */}
      {step < 4 && (
        <View style={styles.progress}>
          {[1, 2, 3].map((s) => (
            <View key={s} style={[styles.dot, s <= step && styles.dotActive]} />
          ))}
        </View>
      )}

      <ScrollView style={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Step 1: Doctor */}
        {step === 1 && (
          <>
            <View style={styles.searchBox}>
              <Ionicons name="search" size={18} color="#CACACA" />
              <TextInput
                testID="doctor-search-input"
                style={styles.searchInput}
                placeholder="Buscar por nombre o especialidad..."
                placeholderTextColor="#CACACA"
                value={search}
                onChangeText={handleSearch}
              />
            </View>
            {loading ? (
              <ActivityIndicator size="large" color="#001689" style={{ marginTop: 40 }} />
            ) : (
              doctors.map((doc) => (
                <TouchableOpacity
                  key={doc.id}
                  testID={`doctor-${doc.id}`}
                  style={[
                    styles.docCard,
                    selectedDoctor?.id === doc.id && styles.docCardSelected,
                  ]}
                  onPress={() => setSelectedDoctor(doc)}
                >
                  <View style={styles.docAvatar}>
                    <Ionicons name="person" size={24} color="#CACACA" />
                  </View>
                  <View style={styles.docInfo}>
                    <Text style={styles.docName}>{doc.name}</Text>
                    <Text style={styles.docSpec}>{doc.specialty}</Text>
                    <View style={styles.docMeta}>
                      <Ionicons name="star" size={12} color="#FFB300" />
                      <Text style={styles.docRating}>{doc.rating}</Text>
                      <Text style={styles.docExp}>{doc.experience_years} años exp</Text>
                    </View>
                  </View>
                  <Text style={styles.docPrice}>${doc.consultation_fee}</Text>
                </TouchableOpacity>
              ))
            )}
          </>
        )}

        {/* Step 2: Date & Time */}
        {step === 2 && selectedDoctor && (
          <>
            <Text style={styles.stepLabel}>Selecciona una Fecha</Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.daysRow}
            >
              {days.map((d) => (
                <TouchableOpacity
                  key={d.date}
                  testID={`date-${d.date}`}
                  style={[styles.dayCard, selectedDate === d.date && styles.dayActive]}
                  onPress={() => setSelectedDate(d.date)}
                >
                  <Text style={[styles.dayName, selectedDate === d.date && styles.dayTextW]}>
                    {d.day}
                  </Text>
                  <Text style={[styles.dayNum, selectedDate === d.date && styles.dayTextW]}>
                    {d.num}
                  </Text>
                  <Text style={[styles.dayMonth, selectedDate === d.date && styles.dayTextW]}>
                    {d.month}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            <Text style={[styles.stepLabel, { marginTop: 24 }]}>Horarios Disponibles</Text>
            <View style={styles.timesGrid}>
              {selectedDoctor.available_slots?.map((slot: string) => (
                <TouchableOpacity
                  key={slot}
                  testID={`time-${slot}`}
                  style={[styles.timeSlot, selectedTime === slot && styles.timeActive]}
                  onPress={() => setSelectedTime(slot)}
                >
                  <Text style={[styles.timeText, selectedTime === slot && styles.timeTextW]}>
                    {slot}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            <Text style={[styles.stepLabel, { marginTop: 24 }]}>Tipo de Consulta</Text>
            <View style={styles.typeRow}>
              {(['video', 'in-person'] as const).map((t) => (
                <TouchableOpacity
                  key={t}
                  testID={`type-${t}`}
                  style={[styles.typeBtn, aptType === t && styles.typeBtnActive]}
                  onPress={() => setAptType(t)}
                >
                  <Ionicons
                    name={t === 'video' ? 'videocam' : 'location'}
                    size={20}
                    color={aptType === t ? '#FFFFFF' : '#838383'}
                  />
                  <Text style={[styles.typeText, aptType === t && styles.typeTextW]}>
                    {t === 'video' ? 'Video Call' : 'In-Person'}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </>
        )}

        {/* Step 3: Confirm */}
        {step === 3 && selectedDoctor && (
          <View style={styles.confirmSection}>
            <View style={styles.confirmCard}>
              <View style={styles.confirmAvatar}>
                <Ionicons name="person" size={32} color="#CACACA" />
              </View>
              <Text style={styles.confirmDocName}>{selectedDoctor.name}</Text>
              <Text style={styles.confirmSpec}>{selectedDoctor.specialty}</Text>
            </View>

            <View style={styles.confirmDetails}>
              {[
                { icon: 'calendar-outline', text: selectedDate },
                { icon: 'time-outline', text: selectedTime },
                {
                  icon: aptType === 'video' ? 'videocam-outline' : 'location-outline',
                  text: aptType === 'video' ? 'Videoconsulta' : 'Consulta Presencial',
                },
              ].map((r, i) => (
                <View key={i} style={styles.confirmRow}>
                  <Ionicons name={r.icon as any} size={18} color="#001689" />
                  <Text style={styles.confirmText}>{r.text}</Text>
                </View>
              ))}
            </View>

            <View style={styles.priceRow}>
              <Text style={styles.priceLabel}>Costo de Consulta</Text>
              <Text style={styles.priceValue}>${selectedDoctor.consultation_fee}</Text>
            </View>

            <View style={styles.mockPayment}>
              <Ionicons name="card-outline" size={20} color="#838383" />
              <Text style={styles.mockPayText}>**** **** **** 4242</Text>
              <Text style={styles.mockPayLabel}>Pago Simulado</Text>
            </View>
          </View>
        )}

        {/* Step 4: Success */}
        {step === 4 && (
          <View style={styles.successSection}>
            <Ionicons name="checkmark-circle" size={80} color="#4CAF50" />
            <Text style={styles.successTitle}>¡Cita Agendada!</Text>
            <Text style={styles.successSub}>
              Tu cita ha sido agendada exitosamente.
            </Text>
            {createdApt && (
              <View style={styles.successCard}>
                <Text style={styles.successDoc}>{createdApt.doctor_name}</Text>
                <Text style={styles.successDetail}>
                  {createdApt.date} at {createdApt.time}
                </Text>
                <Text style={styles.successDetail}>
                  {createdApt.type === 'video' ? 'Videoconsulta' : 'Consulta Presencial'}
                </Text>
              </View>
            )}
            <TouchableOpacity
              testID="view-appointment-btn"
              style={styles.successBtn}
              onPress={() =>
                createdApt
                  ? router.replace(`/appointment/${createdApt.id}`)
                  : router.replace('/(tabs)/appointments')
              }
            >
              <Text style={styles.successBtnText}>Ver Cita</Text>
            </TouchableOpacity>
            <TouchableOpacity
              testID="go-home-btn"
              style={styles.successBtnSec}
              onPress={() => router.replace('/(tabs)')}
            >
              <Text style={styles.successBtnSecText}>Ir al Inicio</Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={{ height: 120 }} />
      </ScrollView>

      {/* Bottom CTA */}
      {step >= 1 && step <= 3 && (
        <View style={[styles.bottomCta, { paddingBottom: insets.bottom + 16 }]}>
          {step === 1 && (
            <TouchableOpacity
              testID="next-step-btn"
              style={[styles.ctaBtn, !selectedDoctor && styles.ctaDisabled]}
              disabled={!selectedDoctor}
              onPress={() => setStep(2)}
            >
              <Text style={styles.ctaText}>Continuar</Text>
            </TouchableOpacity>
          )}
          {step === 2 && (
            <TouchableOpacity
              testID="next-step-btn"
              style={[
                styles.ctaBtn,
                (!selectedDate || !selectedTime) && styles.ctaDisabled,
              ]}
              disabled={!selectedDate || !selectedTime}
              onPress={() => setStep(3)}
            >
              <Text style={styles.ctaText}>Continuar</Text>
            </TouchableOpacity>
          )}
          {step === 3 && (
            <TouchableOpacity
              testID="confirm-booking-btn"
              style={styles.ctaBtn}
              onPress={handleBook}
              disabled={booking}
            >
              {booking ? (
                <ActivityIndicator color="#FFFFFF" />
              ) : (
                <Text style={styles.ctaText}>
                  Confirmar y Pagar ${selectedDoctor?.consultation_fee}
                </Text>
              )}
            </TouchableOpacity>
          )}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: 24, marginTop: 8, marginBottom: 16,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#E6E6E6',
  },
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#232323' },
  progress: { flexDirection: 'row', justifyContent: 'center', gap: 8, marginBottom: 20 },
  dot: { width: 32, height: 4, borderRadius: 2, backgroundColor: '#E6E6E6' },
  dotActive: { backgroundColor: '#001689' },
  scroll: { flex: 1, paddingHorizontal: 24 },
  // Step 1
  searchBox: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFFFFF',
    borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12,
    marginBottom: 16, borderWidth: 1, borderColor: '#E6E6E6',
  },
  searchInput: { flex: 1, fontSize: 14, color: '#232323', marginLeft: 10 },
  docCard: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: '#FFFFFF',
    borderRadius: 16, padding: 16, marginBottom: 10, borderWidth: 2, borderColor: '#E6E6E6',
  },
  docCardSelected: { borderColor: '#001689', backgroundColor: '#E4F3FF' },
  docAvatar: {
    width: 48, height: 48, borderRadius: 24, backgroundColor: '#FAFAFA',
    justifyContent: 'center', alignItems: 'center', marginRight: 12,
  },
  docInfo: { flex: 1 },
  docName: { fontSize: 15, fontWeight: '700', color: '#232323' },
  docSpec: { fontSize: 13, color: '#838383', marginTop: 2 },
  docMeta: { flexDirection: 'row', alignItems: 'center', marginTop: 4, gap: 4 },
  docRating: { fontSize: 12, color: '#FFB300', fontWeight: '600' },
  docExp: { fontSize: 12, color: '#838383', marginLeft: 8 },
  docPrice: { fontSize: 16, fontWeight: '700', color: '#001689' },
  // Step 2
  stepLabel: { fontSize: 16, fontWeight: '700', color: '#232323', marginBottom: 12 },
  daysRow: { gap: 10 },
  dayCard: {
    width: 64, paddingVertical: 12, borderRadius: 16, backgroundColor: '#FFFFFF',
    alignItems: 'center', borderWidth: 1, borderColor: '#E6E6E6',
  },
  dayActive: { backgroundColor: '#001689', borderColor: '#001689' },
  dayName: { fontSize: 12, color: '#838383', fontWeight: '500' },
  dayNum: { fontSize: 20, fontWeight: '700', color: '#232323', marginVertical: 4 },
  dayMonth: { fontSize: 11, color: '#838383' },
  dayTextW: { color: '#FFFFFF' },
  timesGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  timeSlot: {
    paddingHorizontal: 20, paddingVertical: 12, borderRadius: 12,
    backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: '#E6E6E6',
  },
  timeActive: { backgroundColor: '#001689', borderColor: '#001689' },
  timeText: { fontSize: 14, fontWeight: '600', color: '#232323' },
  timeTextW: { color: '#FFFFFF' },
  typeRow: { flexDirection: 'row', gap: 12 },
  typeBtn: {
    flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    gap: 8, paddingVertical: 14, borderRadius: 12, backgroundColor: '#FFFFFF',
    borderWidth: 1, borderColor: '#E6E6E6',
  },
  typeBtnActive: { backgroundColor: '#001689', borderColor: '#001689' },
  typeText: { fontSize: 14, fontWeight: '600', color: '#838383' },
  typeTextW: { color: '#FFFFFF' },
  // Step 3
  confirmSection: { alignItems: 'center' },
  confirmCard: {
    alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 20,
    padding: 24, width: '100%', marginBottom: 16, borderWidth: 1, borderColor: '#E6E6E6',
  },
  confirmAvatar: {
    width: 64, height: 64, borderRadius: 32, backgroundColor: '#FAFAFA',
    justifyContent: 'center', alignItems: 'center', marginBottom: 12,
  },
  confirmDocName: { fontSize: 18, fontWeight: '700', color: '#232323' },
  confirmSpec: { fontSize: 14, color: '#838383', marginTop: 4 },
  confirmDetails: {
    width: '100%', backgroundColor: '#FFFFFF', borderRadius: 16,
    padding: 16, marginBottom: 16, borderWidth: 1, borderColor: '#E6E6E6', gap: 12,
  },
  confirmRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  confirmText: { fontSize: 15, fontWeight: '600', color: '#232323' },
  priceRow: {
    flexDirection: 'row', justifyContent: 'space-between', width: '100%',
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 16, borderWidth: 1, borderColor: '#E6E6E6',
  },
  priceLabel: { fontSize: 15, color: '#838383' },
  priceValue: { fontSize: 20, fontWeight: '700', color: '#001689' },
  mockPayment: {
    flexDirection: 'row', alignItems: 'center', width: '100%',
    backgroundColor: '#FAFAFA', borderRadius: 12, padding: 16, gap: 10,
  },
  mockPayText: { flex: 1, fontSize: 14, color: '#232323', fontWeight: '500' },
  mockPayLabel: { fontSize: 11, color: '#838383', fontWeight: '600' },
  // Step 4
  successSection: { alignItems: 'center', paddingTop: 40 },
  successTitle: { fontSize: 24, fontWeight: '700', color: '#232323', marginTop: 20, marginBottom: 8 },
  successSub: { fontSize: 15, color: '#838383', textAlign: 'center', marginBottom: 32 },
  successCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 20,
    width: '100%', alignItems: 'center', marginBottom: 32,
    borderWidth: 1, borderColor: '#E6E6E6',
  },
  successDoc: { fontSize: 16, fontWeight: '700', color: '#232323' },
  successDetail: { fontSize: 14, color: '#838383', marginTop: 4 },
  successBtn: {
    backgroundColor: '#001689', borderRadius: 14, paddingVertical: 16,
    width: '100%', alignItems: 'center', marginBottom: 12,
  },
  successBtnText: { fontSize: 16, fontWeight: '700', color: '#FFFFFF' },
  successBtnSec: { paddingVertical: 14, width: '100%', alignItems: 'center' },
  successBtnSecText: { fontSize: 15, fontWeight: '600', color: '#232323' },
  // Bottom CTA
  bottomCta: {
    position: 'absolute', bottom: 0, left: 0, right: 0,
    paddingHorizontal: 24, paddingTop: 12, backgroundColor: '#FAFAFA',
    borderTopWidth: 1, borderTopColor: '#E6E6E6',
  },
  ctaBtn: {
    backgroundColor: '#001689', borderRadius: 14, paddingVertical: 16, alignItems: 'center',
  },
  ctaDisabled: { backgroundColor: '#E6E6E6' },
  ctaText: { fontSize: 16, fontWeight: '700', color: '#FFFFFF' },
});
