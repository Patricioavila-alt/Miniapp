import React, { useEffect, useState } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  ActivityIndicator, TextInput, Alert,
  KeyboardAvoidingView, Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function AccountScreen() {
  const insets = useSafeAreaInsets();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [editData, setEditData] = useState<any>({});
  const [saving, setSaving] = useState(false);

  const fetchProfile = async () => {
    try {
      const res = await fetch(`${API_URL}/api/profile`);
      const json = await res.json();
      setProfile(json);
      setEditData(json);
    } catch (e) {
      console.error('Failed to fetch profile:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchProfile(); }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await fetch(`${API_URL}/api/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: editData.full_name,
          phone: editData.phone,
          date_of_birth: editData.date_of_birth,
          gender: editData.gender,
          blood_type: editData.blood_type,
        }),
      });
      const json = await res.json();
      setProfile(json);
      setEditing(false);
      Alert.alert('Éxito', 'Perfil actualizado exitosamente');
    } catch (e) {
      Alert.alert('Error', 'Error al actualizar perfil');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#CE0E2D" />
      </View>
    );
  }

  const initials =
    profile?.full_name
      ?.split(' ')
      .map((n: string) => n[0])
      .join('')
      .slice(0, 2)
      .toUpperCase() || 'U';

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        style={[styles.container, { paddingTop: insets.top }]}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <Text style={styles.title}>Mi Cuenta</Text>

        {/* Profile Card */}
        <View style={styles.profileCard}>
          <View style={styles.avatarCircle}>
            <Text style={styles.avatarText}>{initials}</Text>
          </View>
          <Text style={styles.profileName}>{profile?.full_name}</Text>
          <Text style={styles.profileEmail}>{profile?.email}</Text>
        </View>

        {/* Info Section */}
        <View style={styles.infoSection}>
          <View style={styles.infoHeader}>
            <Text style={styles.infoTitle}>Datos Personales</Text>
            <TouchableOpacity
              testID="edit-profile-btn"
              onPress={() => {
                if (editing) setEditData(profile);
                setEditing(!editing);
              }}
            >
              <Text style={styles.editBtn}>{editing ? 'Cancelar' : 'Editar'}</Text>
            </TouchableOpacity>
          </View>

          {editing ? (
            <>
              {[
                { key: 'full_name', label: 'Nombre Completo' },
                { key: 'phone', label: 'Teléfono' },
                { key: 'date_of_birth', label: 'Fecha de Nacimiento' },
                { key: 'gender', label: 'Género' },
                { key: 'blood_type', label: 'Tipo de Sangre' },
              ].map((field) => (
                <View key={field.key} style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>{field.label}</Text>
                  <TextInput
                    testID={`input-${field.key}`}
                    style={styles.input}
                    value={editData[field.key] || ''}
                    onChangeText={(v) => setEditData({ ...editData, [field.key]: v })}
                    placeholderTextColor="#CACACA"
                  />
                </View>
              ))}
              <TouchableOpacity
                testID="save-profile-btn"
                style={styles.saveBtn}
                onPress={handleSave}
                disabled={saving}
              >
                {saving ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <Text style={styles.saveBtnText}>Guardar Cambios</Text>
                )}
              </TouchableOpacity>
            </>
          ) : (
            <>
              {[
                { label: 'Teléfono', value: profile?.phone },
                { label: 'Fecha de Nacimiento', value: profile?.date_of_birth },
                { label: 'Género', value: profile?.gender },
                { label: 'Tipo de Sangre', value: profile?.blood_type },
                { label: 'Alergias', value: profile?.allergies?.join(', ') || 'Ninguna' },
              ].map((item, i) => (
                <View key={i} style={styles.detailRow}>
                  <Text style={styles.detailLabel}>{item.label}</Text>
                  <Text style={styles.detailValue}>{item.value}</Text>
                </View>
              ))}
            </>
          )}
        </View>

        {/* Menu Items */}
        <View style={styles.menuSection}>
          {[
            { icon: 'notifications-outline', label: 'Notificaciones', testId: 'menu-notifications' },
            { icon: 'shield-outline', label: 'Privacidad y Seguridad', testId: 'menu-privacy' },
            { icon: 'help-circle-outline', label: 'Ayuda y Soporte', testId: 'menu-help' },
            { icon: 'information-circle-outline', label: 'Acerca de Mi Salud FdA', testId: 'menu-about' },
          ].map((item, i) => (
            <TouchableOpacity key={i} testID={item.testId} style={styles.menuItem}>
              <Ionicons name={item.icon as any} size={22} color="#CE0E2D" />
              <Text style={styles.menuLabel}>{item.label}</Text>
              <Ionicons name="chevron-forward" size={18} color="#E6E6E6" />
            </TouchableOpacity>
          ))}
        </View>

        <View style={{ height: 32 }} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAFAFA' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  loadingContainer: {
    flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FAFAFA',
  },
  title: { fontSize: 28, fontWeight: '700', color: '#232323', marginTop: 16, marginBottom: 20 },
  profileCard: {
    alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 20,
    padding: 24, marginBottom: 20, borderWidth: 1, borderColor: '#E6E6E6',
  },
  avatarCircle: {
    width: 72, height: 72, borderRadius: 36, backgroundColor: '#CE0E2D',
    justifyContent: 'center', alignItems: 'center', marginBottom: 12,
  },
  avatarText: { fontSize: 24, fontWeight: '700', color: '#FFFFFF' },
  profileName: { fontSize: 20, fontWeight: '700', color: '#232323' },
  profileEmail: { fontSize: 14, color: '#838383', marginTop: 4 },
  infoSection: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 20, borderWidth: 1, borderColor: '#E6E6E6',
  },
  infoHeader: {
    flexDirection: 'row', justifyContent: 'space-between',
    alignItems: 'center', marginBottom: 12,
  },
  infoTitle: { fontSize: 16, fontWeight: '700', color: '#232323' },
  editBtn: { fontSize: 14, fontWeight: '600', color: '#CE0E2D' },
  inputGroup: { marginBottom: 12 },
  inputLabel: { fontSize: 12, color: '#838383', marginBottom: 4, fontWeight: '500' },
  input: {
    backgroundColor: '#FAFAFA', borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12,
    fontSize: 14, color: '#232323', borderWidth: 1, borderColor: '#E6E6E6',
  },
  saveBtn: {
    backgroundColor: '#CE0E2D', borderRadius: 12,
    paddingVertical: 14, alignItems: 'center', marginTop: 8,
  },
  saveBtnText: { fontSize: 15, fontWeight: '700', color: '#FFFFFF' },
  detailRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#F1F1F1',
  },
  detailLabel: { fontSize: 14, color: '#838383' },
  detailValue: { fontSize: 14, fontWeight: '600', color: '#232323' },
  menuSection: {
    backgroundColor: '#FFFFFF', borderRadius: 16, overflow: 'hidden',
    marginBottom: 20, borderWidth: 1, borderColor: '#E6E6E6',
  },
  menuItem: {
    flexDirection: 'row', alignItems: 'center',
    paddingHorizontal: 16, paddingVertical: 14,
    borderBottomWidth: 1, borderBottomColor: '#F1F1F1', gap: 12,
  },
  menuLabel: { flex: 1, fontSize: 15, color: '#232323' },
});
