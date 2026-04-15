import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

// Mock QR Code visual
const MockQR = ({ data }: { data: string }) => {
  const grid: boolean[][] = [];
  for (let i = 0; i < 9; i++) {
    const row: boolean[] = [];
    for (let j = 0; j < 9; j++) {
      const c = data.charCodeAt((i * 9 + j) % data.length);
      row.push(c % 3 !== 0);
    }
    grid.push(row);
  }
  // Corner markers
  for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 3; j++) {
      grid[i][j] = true;
      grid[i][8 - j] = true;
      grid[8 - i][j] = true;
    }
  }
  return (
    <View style={qrS.box}>
      {grid.map((row, i) => (
        <View key={i} style={qrS.row}>
          {row.map((f, j) => (
            <View key={j} style={[qrS.cell, f && qrS.filled]} />
          ))}
        </View>
      ))}
    </View>
  );
};

const qrS = StyleSheet.create({
  box: { padding: 8, backgroundColor: '#FFFFFF', borderRadius: 12 },
  row: { flexDirection: 'row' },
  cell: { width: 12, height: 12, margin: 1, backgroundColor: '#F9F8F6', borderRadius: 1 },
  filled: { backgroundColor: '#1F2321' },
});

export default function PrescriptionDetail() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const [rx, setRx] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchRx = async () => {
      try {
        const res = await fetch(`${API_URL}/api/prescriptions/${id}`);
        setRx(await res.json());
      } catch (e) {
        console.error('Fetch prescription failed:', e);
      } finally {
        setLoading(false);
      }
    };
    if (id) fetchRx();
  }, [id]);

  if (loading) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#E07A5F" />
      </View>
    );
  }
  if (!rx) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <Text style={{ color: '#5C6B64', fontSize: 16 }}>Prescription not found</Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <TouchableOpacity testID="back-btn" onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#2A433A" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Prescription</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* Status */}
      <View
        style={[
          styles.statusBanner,
          rx.status === 'active' ? styles.bannerActive : styles.bannerDone,
        ]}
      >
        <Ionicons
          name={rx.status === 'active' ? 'medical' : 'checkmark-circle'}
          size={20}
          color={rx.status === 'active' ? '#4CAF50' : '#1976D2'}
        />
        <Text
          style={[
            styles.statusText,
            { color: rx.status === 'active' ? '#4CAF50' : '#1976D2' },
          ]}
        >
          {rx.status === 'active' ? 'Active Prescription' : 'Completed'}
        </Text>
      </View>

      {/* Info */}
      <View style={styles.infoCard}>
        {[
          { label: 'Doctor', value: rx.doctor_name },
          { label: 'Specialty', value: rx.doctor_specialty },
          { label: 'Date', value: rx.date },
          { label: 'Diagnosis', value: rx.diagnosis },
        ].map((r, i) => (
          <View
            key={i}
            style={[styles.infoRow, i === 3 && { borderBottomWidth: 0 }]}
          >
            <Text style={styles.infoLabel}>{r.label}</Text>
            <Text style={styles.infoValue}>{r.value}</Text>
          </View>
        ))}
      </View>

      {/* Medications */}
      <Text style={styles.sectionTitle}>Medications</Text>
      {rx.medications?.map((med: any, i: number) => (
        <View key={i} style={styles.medCard}>
          <View style={styles.medIcon}>
            <Ionicons name="medical" size={20} color="#E07A5F" />
          </View>
          <View style={styles.medInfo}>
            <Text style={styles.medName}>{med.name}</Text>
            <Text style={styles.medDosage}>{med.dosage}</Text>
            <Text style={styles.medDuration}>Duration: {med.duration}</Text>
          </View>
        </View>
      ))}

      {/* Notes */}
      {rx.notes ? (
        <>
          <Text style={styles.sectionTitle}>Notes</Text>
          <View style={styles.notesCard}>
            <Text style={styles.notesText}>{rx.notes}</Text>
          </View>
        </>
      ) : null}

      {/* QR Code */}
      <Text style={styles.sectionTitle}>Digital Prescription QR</Text>
      <View style={styles.qrContainer}>
        <MockQR data={rx.qr_code_data || rx.id} />
        <Text style={styles.qrLabel}>Scan to verify prescription</Text>
        <Text style={styles.qrData}>{rx.qr_code_data}</Text>
      </View>

      <View style={{ height: 32 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9F8F6' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F9F8F6' },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    marginTop: 8, marginBottom: 24,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#E5E1DA',
  },
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#2A433A' },
  statusBanner: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    padding: 14, borderRadius: 12, marginBottom: 16,
  },
  bannerActive: { backgroundColor: '#E8F5E9' },
  bannerDone: { backgroundColor: '#E3F2FD' },
  statusText: { fontSize: 14, fontWeight: '600' },
  infoCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 20, borderWidth: 1, borderColor: '#E5E1DA',
  },
  infoRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: '#F5F3F0',
  },
  infoLabel: { fontSize: 13, color: '#5C6B64' },
  infoValue: {
    fontSize: 13, fontWeight: '600', color: '#1F2321',
    maxWidth: '60%', textAlign: 'right',
  },
  sectionTitle: { fontSize: 16, fontWeight: '700', color: '#1F2321', marginBottom: 12, marginTop: 4 },
  medCard: {
    flexDirection: 'row', backgroundColor: '#FFFFFF', borderRadius: 14,
    padding: 16, marginBottom: 10, borderWidth: 1, borderColor: '#E5E1DA', gap: 12,
  },
  medIcon: {
    width: 40, height: 40, borderRadius: 12, backgroundColor: '#FFF3E0',
    justifyContent: 'center', alignItems: 'center',
  },
  medInfo: { flex: 1 },
  medName: { fontSize: 15, fontWeight: '700', color: '#1F2321' },
  medDosage: { fontSize: 13, color: '#5C6B64', marginTop: 2 },
  medDuration: { fontSize: 12, color: '#819E8E', marginTop: 2, fontWeight: '500' },
  notesCard: {
    backgroundColor: '#FFFFFF', borderRadius: 14, padding: 16,
    marginBottom: 20, borderWidth: 1, borderColor: '#E5E1DA',
  },
  notesText: { fontSize: 14, color: '#5C6B64', lineHeight: 20 },
  qrContainer: {
    alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 20,
    padding: 24, borderWidth: 1, borderColor: '#E5E1DA',
  },
  qrLabel: { fontSize: 14, color: '#5C6B64', marginTop: 12 },
  qrData: { fontSize: 12, color: '#819E8E', marginTop: 4, fontWeight: '500' },
});
