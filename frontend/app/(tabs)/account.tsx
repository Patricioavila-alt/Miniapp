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
      Alert.alert('Success', 'Profile updated successfully');
    } catch (e) {
      Alert.alert('Error', 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View style={[styles.loadingContainer, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#E07A5F" />
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
        <Text style={styles.title}>My Account</Text>

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
            <Text style={styles.infoTitle}>Personal Details</Text>
            <TouchableOpacity
              testID="edit-profile-btn"
              onPress={() => {
                if (editing) setEditData(profile);
                setEditing(!editing);
              }}
            >
              <Text style={styles.editBtn}>{editing ? 'Cancel' : 'Edit'}</Text>
            </TouchableOpacity>
          </View>

          {editing ? (
            <>
              {[
                { key: 'full_name', label: 'Full Name' },
                { key: 'phone', label: 'Phone' },
                { key: 'date_of_birth', label: 'Date of Birth' },
                { key: 'gender', label: 'Gender' },
                { key: 'blood_type', label: 'Blood Type' },
              ].map((field) => (
                <View key={field.key} style={styles.inputGroup}>
                  <Text style={styles.inputLabel}>{field.label}</Text>
                  <TextInput
                    testID={`input-${field.key}`}
                    style={styles.input}
                    value={editData[field.key] || ''}
                    onChangeText={(v) => setEditData({ ...editData, [field.key]: v })}
                    placeholderTextColor="#819E8E"
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
                  <Text style={styles.saveBtnText}>Save Changes</Text>
                )}
              </TouchableOpacity>
            </>
          ) : (
            <>
              {[
                { label: 'Phone', value: profile?.phone },
                { label: 'Date of Birth', value: profile?.date_of_birth },
                { label: 'Gender', value: profile?.gender },
                { label: 'Blood Type', value: profile?.blood_type },
                { label: 'Allergies', value: profile?.allergies?.join(', ') || 'None' },
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
            { icon: 'notifications-outline', label: 'Notifications', testId: 'menu-notifications' },
            { icon: 'shield-outline', label: 'Privacy & Security', testId: 'menu-privacy' },
            { icon: 'help-circle-outline', label: 'Help & Support', testId: 'menu-help' },
            { icon: 'information-circle-outline', label: 'About Mi Salud FdA', testId: 'menu-about' },
          ].map((item, i) => (
            <TouchableOpacity key={i} testID={item.testId} style={styles.menuItem}>
              <Ionicons name={item.icon as any} size={22} color="#2A433A" />
              <Text style={styles.menuLabel}>{item.label}</Text>
              <Ionicons name="chevron-forward" size={18} color="#E5E1DA" />
            </TouchableOpacity>
          ))}
        </View>

        <View style={{ height: 32 }} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9F8F6' },
  content: { paddingHorizontal: 24, paddingBottom: 32 },
  loadingContainer: {
    flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F9F8F6',
  },
  title: { fontSize: 28, fontWeight: '700', color: '#2A433A', marginTop: 16, marginBottom: 20 },
  profileCard: {
    alignItems: 'center', backgroundColor: '#FFFFFF', borderRadius: 20,
    padding: 24, marginBottom: 20, borderWidth: 1, borderColor: '#E5E1DA',
  },
  avatarCircle: {
    width: 72, height: 72, borderRadius: 36, backgroundColor: '#2A433A',
    justifyContent: 'center', alignItems: 'center', marginBottom: 12,
  },
  avatarText: { fontSize: 24, fontWeight: '700', color: '#FFFFFF' },
  profileName: { fontSize: 20, fontWeight: '700', color: '#1F2321' },
  profileEmail: { fontSize: 14, color: '#5C6B64', marginTop: 4 },
  infoSection: {
    backgroundColor: '#FFFFFF', borderRadius: 16, padding: 16,
    marginBottom: 20, borderWidth: 1, borderColor: '#E5E1DA',
  },
  infoHeader: {
    flexDirection: 'row', justifyContent: 'space-between',
    alignItems: 'center', marginBottom: 12,
  },
  infoTitle: { fontSize: 16, fontWeight: '700', color: '#1F2321' },
  editBtn: { fontSize: 14, fontWeight: '600', color: '#E07A5F' },
  inputGroup: { marginBottom: 12 },
  inputLabel: { fontSize: 12, color: '#5C6B64', marginBottom: 4, fontWeight: '500' },
  input: {
    backgroundColor: '#F9F8F6', borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12,
    fontSize: 14, color: '#1F2321', borderWidth: 1, borderColor: '#E5E1DA',
  },
  saveBtn: {
    backgroundColor: '#E07A5F', borderRadius: 12,
    paddingVertical: 14, alignItems: 'center', marginTop: 8,
  },
  saveBtnText: { fontSize: 15, fontWeight: '700', color: '#FFFFFF' },
  detailRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#F5F3F0',
  },
  detailLabel: { fontSize: 14, color: '#5C6B64' },
  detailValue: { fontSize: 14, fontWeight: '600', color: '#1F2321' },
  menuSection: {
    backgroundColor: '#FFFFFF', borderRadius: 16, overflow: 'hidden',
    marginBottom: 20, borderWidth: 1, borderColor: '#E5E1DA',
  },
  menuItem: {
    flexDirection: 'row', alignItems: 'center',
    paddingHorizontal: 16, paddingVertical: 14,
    borderBottomWidth: 1, borderBottomColor: '#F5F3F0', gap: 12,
  },
  menuLabel: { flex: 1, fontSize: 15, color: '#1F2321' },
});
