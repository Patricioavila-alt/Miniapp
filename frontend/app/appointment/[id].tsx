import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  ActivityIndicator, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function AppointmentDetail() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const [apt, setApt] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchApt = async () => {
      try {
        const res = await fetch(`${API_URL}/api/appointments/${id}`);
        const json = await res.json();
        setApt(json);
      } catch (e) {
        console.error('Failed to fetch appointment:', e);
      } finally {
        setLoading(false);
      }
    };
    if (id) fetchApt();
  }, [id]);

  const handleCancel = () => {
    Alert.alert('Cancelar Cita', '¿Estás seguro de que quieres cancelar?', [
      { text: 'No', style: 'cancel' },
      {
        text: 'Sí, Cancelar',
        style: 'destructive',
        onPress: async () => {
          try {
            await fetch(`${API_URL}/api/appointments/${id}`, { method: 'DELETE' });
            Alert.alert('Cancelada', 'Tu cita ha sido cancelada.');
            router.back();
          } catch (e) {
            Alert.alert('Error', 'Error al cancelar la cita');
          }
        },
      },
    ]);
  };

  if (loading) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#CE0E2D" />
      </View>
    );
  }

  if (!apt) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <Text style={styles.errorText}>Cita no encontrada</Text>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.linkText}>Regresar</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const statusLabel = apt.status.charAt(0).toUpperCase() + apt.status.slice(1);

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
    >
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity testID="back-btn" onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#232323" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Detalles de la Cita</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* Doctor Card */}
      <View style={styles.doctorCard}>
        <View style={styles.avatarCircle}>
          <Ionicons name="person" size={32} color="#CACACA" />
        </View>
        <Text style={styles.doctorName}>{apt.doctor_name}</Text>
        <Text style={styles.specialty}>{apt.doctor_specialty}</Text>
        <View
          style={[
            styles.pill,
            apt.status === 'upcoming'
              ? styles.pillUpcoming
              : apt.status === 'completed'
              ? styles.pillCompleted
              : styles.pillCancelled,
          ]}
        >
          <Text
            style={[
              styles.pillText,
              {
                color:
                  apt.status === 'upcoming'
                    ? '#4CAF50'
                    : apt.status === 'completed'
                    ? '#1976D2'
                    : '#CE0E2D',
              },
            ]}
          >
            {statusLabel}
          </Text>
        </View>
      </View>

      {/* Details */}
      <View style={styles.detailsCard}>
        {[
          { icon: 'calendar-outline', label: 'Fecha', value: apt.date },
          { icon: 'time-outline', label: 'Hora', value: apt.time },
          {
            icon: apt.type === 'video' ? 'videocam-outline' : 'location-outline',
            label: 'Tipo',
            value: apt.type === 'video' ? 'Video Consultation' : 'In-Person Visit',
          },
        ].map((item, i) => (
          <View key={i} style={styles.detailItem}>
            <View style={styles.detailIcon}>
              <Ionicons name={item.icon as any} size={20} color="#CE0E2D" />
            </View>
            <View>
              <Text style={styles.detailLabel}>{item.label}</Text>
              <Text style={styles.detailValue}>{item.value}</Text>
            </View>
          </View>
        ))}
        {apt.notes ? (
          <View style={styles.detailItem}>
            <View style={styles.detailIcon}>
              <Ionicons name="document-text-outline" size={20} color="#CE0E2D" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.detailLabel}>Notes</Text>
              <Text style={styles.detailValue}>{apt.notes}</Text>
            </View>
          </View>
        ) : null}
      </View>

      {/* Actions */}
      {apt.status === 'upcoming' && (
        <View style={styles.actions}>
          {apt.type === 'video' && (
            <TouchableOpacity
              testID="join-video-btn"
              style={styles.primaryBtn}
              onPress={() => router.push(`/video-call?appointmentId=${apt.id}`)}
            >
              <Ionicons name="videocam" size={20} color="#FFFFFF" />
              <Text style={styles.primaryBtnText}>Unirse a Videollamada</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity testID="cancel-apt-btn" style={styles.cancelBtn} onPress={handleCancel}>
            <Text style={styles.cancelBtnText}>Cancelar Cita</Text>
          </TouchableOpacity>
        </View>
      )}

      <View style={{ height: 32 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  center: {
    flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FAFAFA',
  },
  errorText: { fontSize: 16, color: '#838383' },
  linkText: { fontSize: 14, color: '#CE0E2D', fontWeight: '600', marginTop: 16 },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    marginTop: 8, marginBottom: 24,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#E6E6E6',
  },
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#232323' },
  doctorCard: {
    alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 20,
    padding: 24, marginBottom: 16, borderWidth: 1, borderColor: '#E6E6E6',
  },
  avatarCircle: {
    width: 72, height: 72, borderRadius: 36, backgroundColor: '#FAFAFA',
    justifyContent: 'center', alignItems: 'center', marginBottom: 12,
  },
  doctorName: { fontSize: 20, fontWeight: '700', color: '#232323' },
  specialty: { fontSize: 14, color: '#838383', marginTop: 4 },
  pill: { marginTop: 12, paddingHorizontal: 16, paddingVertical: 6, borderRadius: 20 },
  pillUpcoming: { backgroundColor: '#E8F5E9' },
  pillCompleted: { backgroundColor: '#E3F2FD' },
  pillCancelled: { backgroundColor: '#FFEBEE' },
  pillText: { fontSize: 13, fontWeight: '600' },
  detailsCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 20, borderWidth: 1, borderColor: '#E6E6E6',
  },
  detailItem: {
    flexDirection: 'row', alignItems: 'center',
    paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#F1F1F1', gap: 12,
  },
  detailIcon: {
    width: 40, height: 40, borderRadius: 12, backgroundColor: '#FFF1F3',
    justifyContent: 'center', alignItems: 'center',
  },
  detailLabel: { fontSize: 12, color: '#838383' },
  detailValue: { fontSize: 15, fontWeight: '600', color: '#232323', marginTop: 2 },
  actions: { gap: 12 },
  primaryBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#CE0E2D', borderRadius: 14, paddingVertical: 16, gap: 8,
  },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: '#FFFFFF' },
  cancelBtn: { alignItems: 'center', paddingVertical: 14 },
  cancelBtnText: { fontSize: 15, fontWeight: '600', color: '#CE0E2D' },
});
