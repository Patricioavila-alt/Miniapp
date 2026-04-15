import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function DocumentDetail() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const [doc, setDoc] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDoc = async () => {
      try {
        const res = await fetch(`${API_URL}/api/documents/${id}`);
        setDoc(await res.json());
      } catch (e) {
        console.error('Failed to fetch document:', e);
      } finally {
        setLoading(false);
      }
    };
    if (id) fetchDoc();
  }, [id]);

  if (loading) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#E07A5F" />
      </View>
    );
  }
  if (!doc) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <Text style={{ color: '#5C6B64' }}>Document not found</Text>
      </View>
    );
  }

  const typeLabel =
    doc.type === 'lab_result'
      ? 'Lab Result'
      : doc.type === 'consultation_summary'
      ? 'Consultation Summary'
      : 'Document';
  const typeIcon = doc.type === 'lab_result' ? 'flask' : 'clipboard';

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <TouchableOpacity testID="back-btn" onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#2A433A" />
        </TouchableOpacity>
        <Text style={styles.headerTitle} numberOfLines={1}>
          {typeLabel}
        </Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={styles.docHeader}>
        <View style={styles.docIconBig}>
          <Ionicons name={typeIcon as any} size={28} color="#1976D2" />
        </View>
        <Text style={styles.docTitle}>{doc.title}</Text>
        <Text style={styles.docMeta}>
          {doc.doctor_name} • {doc.date}
        </Text>
      </View>

      <View style={styles.contentCard}>
        <Text style={styles.contentLabel}>Summary</Text>
        <Text style={styles.contentBody}>{doc.summary}</Text>
      </View>

      <TouchableOpacity testID="download-btn" style={styles.downloadBtn}>
        <Ionicons name="download-outline" size={20} color="#FFFFFF" />
        <Text style={styles.downloadBtnText}>Download Document</Text>
      </TouchableOpacity>
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
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#2A433A', flex: 1, textAlign: 'center' },
  docHeader: { alignItems: 'center', marginBottom: 24 },
  docIconBig: {
    width: 64, height: 64, borderRadius: 20, backgroundColor: '#E3F2FD',
    justifyContent: 'center', alignItems: 'center', marginBottom: 16,
  },
  docTitle: { fontSize: 20, fontWeight: '700', color: '#1F2321', textAlign: 'center' },
  docMeta: { fontSize: 14, color: '#5C6B64', marginTop: 4 },
  contentCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 20,
    marginBottom: 24, borderWidth: 1, borderColor: '#E5E1DA',
  },
  contentLabel: { fontSize: 16, fontWeight: '700', color: '#1F2321', marginBottom: 12 },
  contentBody: { fontSize: 15, color: '#5C6B64', lineHeight: 22 },
  downloadBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#2A433A', borderRadius: 14, paddingVertical: 16, gap: 8,
  },
  downloadBtnText: { fontSize: 15, fontWeight: '700', color: '#FFFFFF' },
});
