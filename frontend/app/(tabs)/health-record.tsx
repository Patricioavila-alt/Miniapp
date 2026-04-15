import React, { useEffect, useState, useCallback } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  RefreshControl, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function HealthRecordScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [profile, setProfile] = useState<any>(null);
  const [documents, setDocuments] = useState<any[]>([]);
  const [prescriptions, setPrescriptions] = useState<any[]>([]);
  const [signDocs, setSignDocs] = useState<any[]>([]);
  const [expanded, setExpanded] = useState<string | null>(null);

  const fetchAll = async () => {
    try {
      const [pRes, dRes, rRes, sRes] = await Promise.all([
        fetch(`${API_URL}/api/profile`),
        fetch(`${API_URL}/api/documents`),
        fetch(`${API_URL}/api/prescriptions`),
        fetch(`${API_URL}/api/signature-documents`),
      ]);
      setProfile(await pRes.json());
      setDocuments(await dRes.json());
      setPrescriptions(await rRes.json());
      setSignDocs(await sRes.json());
    } catch (e) {
      console.error('Failed to fetch health records:', e);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => { fetchAll(); }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    fetchAll();
  }, []);

  const toggle = (section: string) => {
    setExpanded(expanded === section ? null : section);
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#001689" />
      </View>
    );
  }

  const pendingCount = signDocs.filter((d) => d.status === 'pending').length;

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#001689" />
      }
      showsVerticalScrollIndicator={false}
    >
      <Text style={styles.title}>Health Record</Text>

      {/* Personal Information */}
      <TouchableOpacity
        testID="section-personal-info"
        style={styles.sectionCard}
        onPress={() => toggle('personal')}
      >
        <View style={styles.sectionRow}>
          <View style={[styles.sectionIcon, { backgroundColor: '#E8F5E9' }]}>
            <Ionicons name="person-outline" size={20} color="#4CAF50" />
          </View>
          <Text style={styles.sectionTitle}>My Personal Information</Text>
          <Ionicons
            name={expanded === 'personal' ? 'chevron-up' : 'chevron-down'}
            size={20}
            color="#838383"
          />
        </View>
      </TouchableOpacity>
      {expanded === 'personal' && profile && (
        <View style={styles.expandedContent}>
          {[
            { label: 'Full Name', value: profile.full_name },
            { label: 'Email', value: profile.email },
            { label: 'Phone', value: profile.phone },
            { label: 'Date of Birth', value: profile.date_of_birth },
            { label: 'Gender', value: profile.gender },
            { label: 'Blood Type', value: profile.blood_type },
            { label: 'Allergies', value: profile.allergies?.join(', ') || 'None' },
          ].map((item, i) => (
            <View key={i} style={styles.infoRow}>
              <Text style={styles.infoLabel}>{item.label}</Text>
              <Text style={styles.infoValue}>{item.value}</Text>
            </View>
          ))}
        </View>
      )}

      {/* Clinical Documents */}
      <TouchableOpacity
        testID="section-clinical-docs"
        style={styles.sectionCard}
        onPress={() => toggle('documents')}
      >
        <View style={styles.sectionRow}>
          <View style={[styles.sectionIcon, { backgroundColor: '#E3F2FD' }]}>
            <Ionicons name="document-text-outline" size={20} color="#1976D2" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.sectionTitle}>Clinical Documents</Text>
            <Text style={styles.sectionSub}>
              {documents.length} document{documents.length !== 1 ? 's' : ''}
            </Text>
          </View>
          <Ionicons
            name={expanded === 'documents' ? 'chevron-up' : 'chevron-down'}
            size={20}
            color="#838383"
          />
        </View>
      </TouchableOpacity>
      {expanded === 'documents' && (
        <View style={styles.expandedContent}>
          {documents.map((doc) => (
            <TouchableOpacity
              key={doc.id}
              testID={`doc-${doc.id}`}
              style={styles.listItem}
              onPress={() => router.push(`/document/${doc.id}`)}
            >
              <Ionicons
                name={doc.type === 'lab_result' ? 'flask' : 'clipboard'}
                size={20}
                color="#1976D2"
              />
              <View style={styles.listItemInfo}>
                <Text style={styles.listItemTitle}>{doc.title}</Text>
                <Text style={styles.listItemSub}>
                  {doc.doctor_name} • {doc.date}
                </Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#E6E6E6" />
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Prescription History */}
      <TouchableOpacity
        testID="section-prescriptions"
        style={styles.sectionCard}
        onPress={() => toggle('prescriptions')}
      >
        <View style={styles.sectionRow}>
          <View style={[styles.sectionIcon, { backgroundColor: '#E4F3FF' }]}>
            <Ionicons name="medical-outline" size={20} color="#001689" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.sectionTitle}>Prescription History</Text>
            <Text style={styles.sectionSub}>
              {prescriptions.length} prescription{prescriptions.length !== 1 ? 's' : ''}
            </Text>
          </View>
          <Ionicons
            name={expanded === 'prescriptions' ? 'chevron-up' : 'chevron-down'}
            size={20}
            color="#838383"
          />
        </View>
      </TouchableOpacity>
      {expanded === 'prescriptions' && (
        <View style={styles.expandedContent}>
          {prescriptions.map((rx) => (
            <TouchableOpacity
              key={rx.id}
              testID={`rx-${rx.id}`}
              style={styles.listItem}
              onPress={() => router.push(`/prescription/${rx.id}`)}
            >
              <View
                style={[
                  styles.statusDot,
                  { backgroundColor: rx.status === 'active' ? '#4CAF50' : '#E6E6E6' },
                ]}
              />
              <View style={styles.listItemInfo}>
                <Text style={styles.listItemTitle}>{rx.diagnosis}</Text>
                <Text style={styles.listItemSub}>
                  {rx.doctor_name} • {rx.date}
                </Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#E6E6E6" />
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Documents for Signature */}
      <TouchableOpacity
        testID="section-signature-docs"
        style={styles.sectionCard}
        onPress={() => toggle('signature')}
      >
        <View style={styles.sectionRow}>
          <View style={[styles.sectionIcon, { backgroundColor: '#FCE4EC' }]}>
            <Ionicons name="create-outline" size={20} color="#CE0E2D" />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.sectionTitle}>Documents for Signature</Text>
            {pendingCount > 0 && (
              <Text style={styles.pendingText}>{pendingCount} pending</Text>
            )}
          </View>
          <Ionicons
            name={expanded === 'signature' ? 'chevron-up' : 'chevron-down'}
            size={20}
            color="#838383"
          />
        </View>
      </TouchableOpacity>
      {expanded === 'signature' && (
        <View style={styles.expandedContent}>
          {signDocs.map((doc) => (
            <TouchableOpacity
              key={doc.id}
              testID={`sig-${doc.id}`}
              style={styles.listItem}
              onPress={() => router.push(`/sign-document/${doc.id}`)}
            >
              <Ionicons
                name={doc.status === 'signed' ? 'checkmark-circle' : 'alert-circle'}
                size={20}
                color={doc.status === 'signed' ? '#4CAF50' : '#001689'}
              />
              <View style={styles.listItemInfo}>
                <Text style={styles.listItemTitle}>{doc.title}</Text>
                <Text style={styles.listItemSub}>
                  {doc.status === 'signed' ? 'Signed' : 'Pending signature'} • {doc.date}
                </Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#E6E6E6" />
            </TouchableOpacity>
          ))}
        </View>
      )}

      <View style={{ height: 32 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  loadingContainer: {
    flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FAFAFA',
  },
  title: { fontSize: 28, fontWeight: '700', color: '#232323', marginTop: 16, marginBottom: 20 },
  sectionCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 8, borderWidth: 1, borderColor: '#E6E6E6',
  },
  sectionRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  sectionIcon: {
    width: 40, height: 40, borderRadius: 12,
    justifyContent: 'center', alignItems: 'center',
  },
  sectionTitle: { fontSize: 15, fontWeight: '600', color: '#232323', flex: 1 },
  sectionSub: { fontSize: 12, color: '#838383', marginTop: 2 },
  pendingText: { fontSize: 12, color: '#001689', fontWeight: '600', marginTop: 2 },
  expandedContent: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 8, marginTop: -4, borderWidth: 1, borderColor: '#E6E6E6',
    borderTopWidth: 0, borderTopLeftRadius: 0, borderTopRightRadius: 0,
  },
  infoRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: '#F1F1F1',
  },
  infoLabel: { fontSize: 13, color: '#838383' },
  infoValue: {
    fontSize: 13, fontWeight: '600', color: '#232323',
    maxWidth: '60%', textAlign: 'right',
  },
  listItem: {
    flexDirection: 'row', alignItems: 'center',
    paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#F1F1F1', gap: 12,
  },
  listItemInfo: { flex: 1 },
  listItemTitle: { fontSize: 14, fontWeight: '600', color: '#232323' },
  listItemSub: { fontSize: 12, color: '#838383', marginTop: 2 },
  statusDot: { width: 10, height: 10, borderRadius: 5 },
});
