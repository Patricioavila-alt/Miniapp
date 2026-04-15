import React, { useEffect, useState, useCallback } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  RefreshControl, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function AppointmentsScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [tab, setTab] = useState<'upcoming' | 'past'>('upcoming');
  const [appointments, setAppointments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchAppointments = async () => {
    try {
      const res = await fetch(`${API_URL}/api/appointments?status=${tab}`);
      const json = await res.json();
      setAppointments(json);
    } catch (e) {
      console.error('Failed to fetch appointments:', e);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    setLoading(true);
    fetchAppointments();
  }, [tab]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    fetchAppointments();
  }, [tab]);

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <Text style={styles.title}>My Appointments</Text>

      {/* Tab Buttons */}
      <View style={styles.tabs}>
        <TouchableOpacity
          testID="tab-upcoming"
          style={[styles.tabBtn, tab === 'upcoming' && styles.tabActive]}
          onPress={() => setTab('upcoming')}
        >
          <Text style={[styles.tabText, tab === 'upcoming' && styles.tabTextActive]}>
            Upcoming
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          testID="tab-past"
          style={[styles.tabBtn, tab === 'past' && styles.tabActive]}
          onPress={() => setTab('past')}
        >
          <Text style={[styles.tabText, tab === 'past' && styles.tabTextActive]}>Past</Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#001689" />
        }
        showsVerticalScrollIndicator={false}
      >
        {loading ? (
          <ActivityIndicator size="large" color="#001689" style={{ marginTop: 40 }} />
        ) : appointments.length === 0 ? (
          <View style={styles.emptyState}>
            <Ionicons name="calendar-outline" size={48} color="#E6E6E6" />
            <Text style={styles.emptyText}>No {tab} appointments</Text>
            {tab === 'upcoming' && (
              <TouchableOpacity
                testID="schedule-btn"
                style={styles.scheduleBtn}
                onPress={() => router.push('/appointment/schedule')}
              >
                <Text style={styles.scheduleBtnText}>Schedule Now</Text>
              </TouchableOpacity>
            )}
          </View>
        ) : (
          appointments.map((apt) => (
            <TouchableOpacity
              key={apt.id}
              testID={`appointment-card-${apt.id}`}
              style={styles.card}
              onPress={() => router.push(`/appointment/${apt.id}`)}
            >
              <View style={styles.cardRow}>
                <View style={styles.avatar}>
                  <Ionicons name="person" size={24} color="#CACACA" />
                </View>
                <View style={styles.cardInfo}>
                  <Text style={styles.doctorName}>{apt.doctor_name}</Text>
                  <Text style={styles.specialty}>{apt.doctor_specialty}</Text>
                  <View style={styles.dateRow}>
                    <Ionicons name="calendar-outline" size={13} color="#838383" />
                    <Text style={styles.dateText}>{apt.date}</Text>
                    <Ionicons
                      name="time-outline"
                      size={13}
                      color="#838383"
                      style={{ marginLeft: 8 }}
                    />
                    <Text style={styles.dateText}>{apt.time}</Text>
                  </View>
                </View>
                <View
                  style={[
                    styles.statusBadge,
                    apt.status === 'upcoming'
                      ? styles.badgeUpcoming
                      : apt.status === 'completed'
                      ? styles.badgeCompleted
                      : styles.badgeCancelled,
                  ]}
                >
                  <Text
                    style={[
                      styles.statusText,
                      apt.status === 'upcoming'
                        ? styles.statusUpcoming
                        : apt.status === 'completed'
                        ? styles.statusCompleted
                        : styles.statusCancelled,
                    ]}
                  >
                    {apt.status === 'upcoming'
                      ? 'Upcoming'
                      : apt.status === 'completed'
                      ? 'Completed'
                      : 'Cancelled'}
                  </Text>
                </View>
              </View>
              {apt.status === 'upcoming' && apt.type === 'video' && (
                <TouchableOpacity
                  testID={`join-video-${apt.id}`}
                  style={styles.joinBtn}
                  onPress={() => router.push(`/video-call?appointmentId=${apt.id}`)}
                >
                  <Ionicons name="videocam" size={16} color="#FFFFFF" />
                  <Text style={styles.joinBtnText}>Join Video Call</Text>
                </TouchableOpacity>
              )}
            </TouchableOpacity>
          ))
        )}
        <View style={{ height: 24 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  title: {
    fontSize: 28, fontWeight: '700', color: '#232323',
    paddingHorizontal: 24, marginTop: 16, marginBottom: 20,
  },
  tabs: {
    flexDirection: 'row', marginHorizontal: 24, backgroundColor: '#FFFFFF',
    borderRadius: 14, padding: 4, marginBottom: 20,
    borderWidth: 1, borderColor: '#E6E6E6',
  },
  tabBtn: { flex: 1, paddingVertical: 12, borderRadius: 10, alignItems: 'center' },
  tabActive: { backgroundColor: '#001689' },
  tabText: { fontSize: 14, fontWeight: '600', color: '#838383' },
  tabTextActive: { color: '#FFFFFF' },
  list: { flex: 1, paddingHorizontal: 24 },
  emptyState: { alignItems: 'center', paddingTop: 60 },
  emptyText: { fontSize: 16, color: '#838383', marginTop: 12 },
  scheduleBtn: {
    marginTop: 20, backgroundColor: '#001689', borderRadius: 12,
    paddingHorizontal: 24, paddingVertical: 12,
  },
  scheduleBtnText: { fontSize: 14, fontWeight: '700', color: '#FFFFFF' },
  card: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 12, borderWidth: 1, borderColor: '#E6E6E6',
  },
  cardRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: {
    width: 48, height: 48, borderRadius: 24, backgroundColor: '#FAFAFA',
    justifyContent: 'center', alignItems: 'center', marginRight: 12,
  },
  cardInfo: { flex: 1 },
  doctorName: { fontSize: 16, fontWeight: '700', color: '#232323' },
  specialty: { fontSize: 13, color: '#838383', marginTop: 2 },
  dateRow: { flexDirection: 'row', alignItems: 'center', marginTop: 6 },
  dateText: { fontSize: 12, color: '#838383', marginLeft: 4 },
  statusBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8 },
  badgeUpcoming: { backgroundColor: '#E8F5E9' },
  badgeCompleted: { backgroundColor: '#E3F2FD' },
  badgeCancelled: { backgroundColor: '#FFEBEE' },
  statusText: { fontSize: 11, fontWeight: '600' },
  statusUpcoming: { color: '#4CAF50' },
  statusCompleted: { color: '#1976D2' },
  statusCancelled: { color: '#CE0E2D' },
  joinBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#001689', borderRadius: 10,
    paddingVertical: 10, marginTop: 12, gap: 8,
  },
  joinBtnText: { fontSize: 14, fontWeight: '600', color: '#FFFFFF' },
});
