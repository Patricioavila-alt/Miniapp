import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  ActivityIndicator, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function SignDocumentScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const [doc, setDoc] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [signing, setSigning] = useState(false);

  useEffect(() => {
    const fetchDoc = async () => {
      try {
        const res = await fetch(`${API_URL}/api/signature-documents`);
        const docs = await res.json();
        const found = docs.find((d: any) => d.id === id);
        setDoc(found || null);
      } catch (e) {
        console.error('Failed to fetch document:', e);
      } finally {
        setLoading(false);
      }
    };
    if (id) fetchDoc();
  }, [id]);

  const handleSign = () => {
    Alert.alert('Firmar Documento', '¿Estás seguro de que quieres firmar este documento?', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Firmar',
        onPress: async () => {
          setSigning(true);
          try {
            await fetch(`${API_URL}/api/signature-documents/${id}/sign`, { method: 'POST' });
            setDoc({ ...doc, status: 'signed' });
            Alert.alert('Éxito', 'Documento firmado exitosamente');
          } catch (e) {
            Alert.alert('Error', 'Error al firmar el documento');
          } finally {
            setSigning(false);
          }
        },
      },
    ]);
  };

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

  return (
    <ScrollView
      style={[styles.container, { paddingTop: insets.top }]}
      contentContainerStyle={styles.content}
    >
      <View style={styles.header}>
        <TouchableOpacity testID="back-btn" onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#232323" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Documento</Text>
        <View style={{ width: 40 }} />
      </View>

      <View
        style={[
          styles.statusBadge,
          doc.status === 'signed' ? styles.badgeSigned : styles.badgePending,
        ]}
      >
        <Ionicons
          name={doc.status === 'signed' ? 'checkmark-circle' : 'time'}
          size={18}
          color={doc.status === 'signed' ? '#4CAF50' : '#001689'}
        />
        <Text
          style={[
            styles.statusText,
            { color: doc.status === 'signed' ? '#4CAF50' : '#001689' },
          ]}
        >
          {doc.status === 'signed' ? 'Firmado' : 'Pendiente de Firma'}
        </Text>
      </View>

      <Text style={styles.docTitle}>{doc.title}</Text>
      <Text style={styles.docDate}>{doc.date}</Text>

      <View style={styles.contentCard}>
        <Text style={styles.contentBody}>{doc.content_preview}</Text>
      </View>

      {doc.status === 'pending' && (
        <TouchableOpacity
          testID="sign-document-btn"
          style={styles.signBtn}
          onPress={handleSign}
          disabled={signing}
        >
          {signing ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <>
              <Ionicons name="create" size={20} color="#FFFFFF" />
              <Text style={styles.signBtnText}>Firmar Documento</Text>
            </>
          )}
        </TouchableOpacity>
      )}

      {doc.status === 'signed' && (
        <View style={styles.signedBox}>
          <Ionicons name="checkmark-circle" size={48} color="#4CAF50" />
          <Text style={styles.signedText}>Este documento ha sido firmado</Text>
        </View>
      )}

      <View style={{ height: 32 }} />
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
  headerTitle: { fontSize: 18, fontWeight: '700', color: '#232323' },
  statusBadge: {
    flexDirection: 'row', alignItems: 'center', alignSelf: 'flex-start',
    gap: 6, paddingHorizontal: 14, paddingVertical: 8, borderRadius: 20, marginBottom: 16,
  },
  badgeSigned: { backgroundColor: '#E8F5E9' },
  badgePending: { backgroundColor: '#E4F3FF' },
  statusText: { fontSize: 13, fontWeight: '600' },
  docTitle: { fontSize: 22, fontWeight: '700', color: '#232323', marginBottom: 4 },
  docDate: { fontSize: 14, color: '#838383', marginBottom: 24 },
  contentCard: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 20,
    marginBottom: 24, borderWidth: 1, borderColor: '#E6E6E6',
  },
  contentBody: { fontSize: 15, color: '#838383', lineHeight: 22 },
  signBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    backgroundColor: '#001689', borderRadius: 14, paddingVertical: 16, gap: 8,
  },
  signBtnText: { fontSize: 16, fontWeight: '700', color: '#FFFFFF' },
  signedBox: { alignItems: 'center', paddingVertical: 32 },
  signedText: { fontSize: 16, color: '#4CAF50', fontWeight: '600', marginTop: 12 },
});
