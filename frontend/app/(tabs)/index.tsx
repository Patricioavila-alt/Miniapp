import React, { useEffect, useState, useCallback } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  RefreshControl, TextInput, Dimensions, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;
const SCREEN_WIDTH = Dimensions.get('window').width;
const CARD_PAD = 24;

const PROMO_COLORS = ['#2A433A', '#5C3D2E', '#1A365D'];

export default function HomeScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchHome = async () => {
    try {
      const res = await fetch(`${API_URL}/api/home`);
      const json = await res.json();
      setData(json);
    } catch (e) {
      console.error('Failed to fetch home:', e);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => { fetchHome(); }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    fetchHome();
  }, []);

  const iconMap: Record<string, any> = {
    videocam: 'videocam',
    calendar: 'calendar',
    medical: 'medical',
    medkit: 'medkit',
  };

  const handleQuickAction = (id: string) => {
    switch (id) {
      case 'video':
      case 'schedule':
        router.push('/appointment/schedule');
        break;
      case 'prescription':
        router.push('/(tabs)/health-record');
        break;
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#E07A5F" />
      </View>
    );
  }

  const widget = data?.smart_widget;
  const isAppointment = widget?.type === 'next_appointment';

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#E07A5F" />
      }
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.greeting}>Hello,</Text>
          <Text style={styles.userName}>{data?.user_name || 'User'}</Text>
        </View>
        <TouchableOpacity testID="notification-bell" style={styles.notifButton}>
          <Ionicons name="notifications-outline" size={24} color="#2A433A" />
          <View style={styles.notifBadge} />
        </TouchableOpacity>
      </View>

      {/* Smart Widget */}
      {isAppointment ? (
        <View testID="appointment-widget" style={styles.appointmentWidget}>
          <Text style={styles.widgetLabel}>NEXT APPOINTMENT</Text>
          <View style={styles.aptRow}>
            <View style={styles.avatarContainer}>
              <Ionicons name="person" size={28} color="#819E8E" />
            </View>
            <View style={styles.aptInfo}>
              <Text style={styles.aptDoctorName}>{widget.data.doctor_name}</Text>
              <Text style={styles.aptSpecialty}>{widget.data.doctor_specialty}</Text>
              <View style={styles.aptDateRow}>
                <Ionicons name="calendar-outline" size={14} color="#F2B8A7" />
                <Text style={styles.aptDateText}>{widget.data.date}</Text>
                <Ionicons name="time-outline" size={14} color="#F2B8A7" style={{ marginLeft: 12 }} />
                <Text style={styles.aptDateText}>{widget.data.time}</Text>
              </View>
            </View>
          </View>
          <TouchableOpacity
            testID="widget-cta-btn"
            style={styles.widgetCta}
            onPress={() => router.push(`/appointment/${widget.data.id}`)}
          >
            <Ionicons
              name={widget.data.type === 'video' ? 'videocam' : 'eye'}
              size={18}
              color="#2A433A"
            />
            <Text style={styles.widgetCtaText}>
              {widget.data.type === 'video' ? 'Join Video Call' : 'View Details'}
            </Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View testID="welcome-widget" style={styles.welcomeWidget}>
          <Text style={styles.welcomeTitle}>
            {widget?.data?.title || 'Welcome to Mi Salud FdA'}
          </Text>
          <View style={styles.searchContainer}>
            <Ionicons name="search" size={18} color="#819E8E" />
            <TextInput
              testID="home-search-input"
              style={styles.searchInput}
              placeholder={widget?.data?.search_placeholder || 'Search doctors and services...'}
              placeholderTextColor="#819E8E"
            />
          </View>
          <TouchableOpacity
            testID="schedule-consultation-btn"
            style={styles.widgetCta}
            onPress={() => router.push('/appointment/schedule')}
          >
            <Text style={styles.widgetCtaText}>
              {widget?.data?.cta_text || 'Schedule a Consultation'}
            </Text>
            <Ionicons name="arrow-forward" size={18} color="#2A433A" />
          </TouchableOpacity>
        </View>
      )}

      {/* Quick Actions */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Quick Actions</Text>
      </View>
      <View style={styles.quickActionsRow}>
        {data?.quick_actions?.map((action: any) => (
          <TouchableOpacity
            key={action.id}
            testID={`quick-action-${action.id}`}
            style={styles.quickActionItem}
            onPress={() => handleQuickAction(action.id)}
          >
            <View style={styles.quickActionIcon}>
              <Ionicons name={iconMap[action.icon] || 'ellipse'} size={24} color="#E07A5F" />
            </View>
            <Text style={styles.quickActionLabel}>{action.label}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Promotions Carousel */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>For You</Text>
        <TouchableOpacity testID="see-all-promos">
          <Text style={styles.seeAll}>See All</Text>
        </TouchableOpacity>
      </View>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.promoScroll}
      >
        {data?.promotions?.map((promo: any, index: number) => (
          <TouchableOpacity
            key={promo.id}
            testID={`promo-${promo.id}`}
            style={[
              styles.promoCard,
              { backgroundColor: PROMO_COLORS[index % PROMO_COLORS.length] },
            ]}
            activeOpacity={0.9}
          >
            <View style={styles.promoContent}>
              <View style={styles.promoIconCircle}>
                <Ionicons
                  name={index === 0 ? 'fitness' : index === 1 ? 'shield-checkmark' : 'videocam'}
                  size={24}
                  color="#FFFFFF"
                />
              </View>
              <Text style={styles.promoTitle}>{promo.title}</Text>
              <Text style={styles.promoDesc} numberOfLines={2}>{promo.description}</Text>
              <View style={styles.promoCta}>
                <Text style={styles.promoCtaText}>{promo.cta_text}</Text>
                <Ionicons name="arrow-forward" size={14} color="#FFFFFF" />
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>

      <View style={{ height: 24 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9F8F6' },
  content: { paddingHorizontal: CARD_PAD, paddingBottom: 32 },
  loadingContainer: {
    flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F9F8F6',
  },
  header: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    marginTop: 16, marginBottom: 24,
  },
  greeting: { fontSize: 16, color: '#5C6B64' },
  userName: { fontSize: 28, fontWeight: '700', color: '#2A433A', marginTop: 2 },
  notifButton: {
    width: 44, height: 44, borderRadius: 22, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center',
    elevation: 2, shadowColor: '#2A433A',
    shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8,
  },
  notifBadge: {
    position: 'absolute', top: 10, right: 12,
    width: 8, height: 8, borderRadius: 4, backgroundColor: '#E07A5F',
  },
  // Appointment Widget
  appointmentWidget: {
    backgroundColor: '#2A433A', borderRadius: 24, padding: 24, marginBottom: 28,
  },
  widgetLabel: {
    fontSize: 11, fontWeight: '700', letterSpacing: 1.5,
    color: '#819E8E', marginBottom: 16,
  },
  aptRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 20 },
  avatarContainer: {
    width: 56, height: 56, borderRadius: 28,
    backgroundColor: 'rgba(255,255,255,0.1)',
    justifyContent: 'center', alignItems: 'center', marginRight: 16,
  },
  aptInfo: { flex: 1 },
  aptDoctorName: { fontSize: 18, fontWeight: '700', color: '#FFFFFF' },
  aptSpecialty: { fontSize: 14, color: '#F2B8A7', marginTop: 2 },
  aptDateRow: { flexDirection: 'row', alignItems: 'center', marginTop: 8 },
  aptDateText: { fontSize: 13, color: '#F2B8A7', marginLeft: 4 },
  // Welcome Widget
  welcomeWidget: {
    backgroundColor: '#2A433A', borderRadius: 24, padding: 24, marginBottom: 28,
  },
  welcomeTitle: { fontSize: 22, fontWeight: '700', color: '#FFFFFF', marginBottom: 16 },
  searchContainer: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.12)',
    borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12, marginBottom: 16,
  },
  searchInput: { flex: 1, fontSize: 14, color: '#FFFFFF', marginLeft: 10 },
  // CTA
  widgetCta: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#F2B8A7', borderRadius: 14, paddingVertical: 14, gap: 8,
  },
  widgetCtaText: { fontSize: 15, fontWeight: '700', color: '#2A433A' },
  // Quick Actions
  sectionHeader: {
    flexDirection: 'row', justifyContent: 'space-between',
    alignItems: 'center', marginBottom: 16,
  },
  sectionTitle: { fontSize: 18, fontWeight: '700', color: '#1F2321' },
  seeAll: { fontSize: 14, color: '#E07A5F', fontWeight: '600' },
  quickActionsRow: {
    flexDirection: 'row', justifyContent: 'space-between', marginBottom: 32,
  },
  quickActionItem: {
    width: (SCREEN_WIDTH - CARD_PAD * 2 - 36) / 4, alignItems: 'center',
  },
  quickActionIcon: {
    width: 60, height: 60, borderRadius: 20, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center', marginBottom: 8,
    elevation: 2, shadowColor: '#2A433A',
    shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, shadowRadius: 8,
  },
  quickActionLabel: {
    fontSize: 11, color: '#5C6B64', textAlign: 'center',
    fontWeight: '500', lineHeight: 15,
  },
  // Promotions
  promoScroll: { paddingRight: 24, gap: 16 },
  promoCard: {
    width: SCREEN_WIDTH * 0.72, height: 170, borderRadius: 20,
    overflow: 'hidden',
  },
  promoContent: {
    flex: 1, padding: 20, justifyContent: 'space-between',
  },
  promoIconCircle: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.15)',
    justifyContent: 'center', alignItems: 'center',
  },
  promoTitle: { fontSize: 18, fontWeight: '700', color: '#FFFFFF' },
  promoDesc: { fontSize: 13, color: 'rgba(255,255,255,0.8)', lineHeight: 18 },
  promoCta: {
    flexDirection: 'row', alignItems: 'center', alignSelf: 'flex-start',
    backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: 8,
    paddingHorizontal: 14, paddingVertical: 8, gap: 6,
  },
  promoCtaText: { fontSize: 13, fontWeight: '700', color: '#FFFFFF' },
});
