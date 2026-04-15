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
        <ActivityIndicator size="large" color="#001689" />
      </View>
    );
  }
  if (!doc) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <Text style={{ color: '#838383' }}>Document not found</Text>
      </View>
    );
  }

  const typeLabel =
    doc.type === 'lab_result'
      ? 'Resultado de Laboratorio'
      : doc.type === 'consultation_summary'
      ? 'Resumen de Consulta'
      : 'Documento';
  const typeIcon = doc.type === 'lab_result' ? 'flask' : 'clipboard';

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <TouchableOpacity testID="back-btn" onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#232323" />
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
        <Text style={styles.contentLabel}>Resumen</Text>
        <Text style={styles.contentBody}>{doc.summary}</Text>
      </View>

      <TouchableOpacity testID="download-btn" style={styles.downloadBtn}>
        <Ionicons name="download-outline" size={20} color="#FFFFFF" />
        <Text style={styles.downloadBtnText}>Descargar Documento</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FAFAFA' },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    marginTop: 8, marginBottom: 24,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: '#FFFFFF',
    justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: '#E6E6E6',
  },
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#232323', flex: 1, textAlign: 'center' },
  docHeader: { alignItems: 'center', marginBottom: 24 },
  docIconBig: {
    width: 64, height: 64, borderRadius: 20, backgroundColor: '#E3F2FD',
    justifyContent: 'center', alignItems: 'center', marginBottom: 16,
  },
  docTitle: { fontSize: 20, fontWeight: '700', color: '#232323', textAlign: 'center' },
  docMeta: { fontSize: 14, color: '#838383', marginTop: 4 },
  contentCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 20,
    marginBottom: 24, borderWidth: 1, borderColor: '#E6E6E6',
  },
  contentLabel: { fontSize: 16, fontWeight: '700', color: '#232323', marginBottom: 12 },
  contentBody: { fontSize: 15, color: '#838383', lineHeight: 22 },
  downloadBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#001689', borderRadius: 14, paddingVertical: 16, gap: 8,
  },
  downloadBtnText: { fontSize: 15, fontWeight: '700', color: '#FFFFFF' },
});
