import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

export default function VideoCallScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { appointmentId } = useLocalSearchParams<{ appointmentId: string }>();
  const [apt, setApt] = useState<any>(null);
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoOff, setIsVideoOff] = useState(false);
  const [isChatOpen, setIsChatOpen] = useState(false);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    if (appointmentId) {
      fetch(`${API_URL}/api/appointments/${appointmentId}`)
        .then((r) => r.json())
        .then(setApt)
        .catch(() => {});
    }
  }, [appointmentId]);

  useEffect(() => {
    const timer = setInterval(() => setDuration((d) => d + 1), 1000);
    return () => clearInterval(timer);
  }, []);

  const fmt = (secs: number) => {
    const m = Math.floor(secs / 60).toString().padStart(2, '0');
    const s = (secs % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const handleEnd = () => {
    Alert.alert('End Call', 'Are you sure you want to end this call?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'End Call', style: 'destructive', onPress: () => router.back() },
    ]);
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Video Area */}
      <View style={styles.videoArea}>
        <View style={styles.remotePlaceholder}>
          <Ionicons name="person" size={64} color="rgba(255,255,255,0.3)" />
          <Text style={styles.doctorLabel}>{apt?.doctor_name || 'Doctor'}</Text>
          <Text style={styles.connText}>Connected</Text>
        </View>

        {/* Self view */}
        <View style={styles.selfView}>
          {isVideoOff ? (
            <Ionicons name="videocam-off" size={24} color="#FFFFFF" />
          ) : (
            <Ionicons name="person" size={28} color="rgba(255,255,255,0.5)" />
          )}
        </View>

        {/* Top bar */}
        <View style={[styles.topBar, { top: insets.top + 8 }]}>
          <View style={styles.callInfo}>
            <View style={styles.liveIndicator} />
            <Text style={styles.callDuration}>{fmt(duration)}</Text>
          </View>
        </View>

        {/* Chat panel */}
        {isChatOpen && (
          <View style={styles.chatPanel}>
            <Text style={styles.chatTitle}>Chat</Text>
            <View style={styles.chatMsg}>
              <Text style={styles.chatSender}>{apt?.doctor_name || 'Doctor'}</Text>
              <Text style={styles.chatText}>Hello! How can I help you today?</Text>
            </View>
            <View style={styles.chatInputRow}>
              <Text style={styles.chatPlaceholder}>Type a message...</Text>
            </View>
          </View>
        )}
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          testID="toggle-mute"
          style={styles.ctrlBtn}
          onPress={() => setIsMuted(!isMuted)}
        >
          <Ionicons
            name={isMuted ? 'mic-off' : 'mic'}
            size={24}
            color={isMuted ? '#CE0E2D' : '#FFFFFF'}
          />
          <Text style={styles.ctrlLabel}>{isMuted ? 'Unmute' : 'Mute'}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          testID="toggle-video"
          style={styles.ctrlBtn}
          onPress={() => setIsVideoOff(!isVideoOff)}
        >
          <Ionicons
            name={isVideoOff ? 'videocam-off' : 'videocam'}
            size={24}
            color={isVideoOff ? '#CE0E2D' : '#FFFFFF'}
          />
          <Text style={styles.ctrlLabel}>{isVideoOff ? 'Turn On' : 'Camera'}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          testID="toggle-chat"
          style={styles.ctrlBtn}
          onPress={() => setIsChatOpen(!isChatOpen)}
        >
          <Ionicons name="chatbubble" size={24} color={isChatOpen ? '#001689' : '#FFFFFF'} />
          <Text style={styles.ctrlLabel}>Chat</Text>
        </TouchableOpacity>

        <TouchableOpacity testID="share-file" style={styles.ctrlBtn}>
          <Ionicons name="attach" size={24} color="#FFFFFF" />
          <Text style={styles.ctrlLabel}>Files</Text>
        </TouchableOpacity>

        <TouchableOpacity testID="end-call-btn" style={styles.endCallBtn} onPress={handleEnd}>
          <Ionicons
            name="call"
            size={28}
            color="#FFFFFF"
            style={{ transform: [{ rotate: '135deg' }] }}
          />
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#1A1A2E' },
  videoArea: { flex: 1, position: 'relative', justifyContent: 'center', alignItems: 'center' },
  remotePlaceholder: { alignItems: 'center' },
  doctorLabel: { fontSize: 20, fontWeight: '700', color: '#FFFFFF', marginTop: 12 },
  connText: { fontSize: 14, color: '#4CAF50', marginTop: 4 },
  selfView: {
    position: 'absolute', bottom: 16, right: 16,
    width: 100, height: 140, borderRadius: 16, backgroundColor: '#2A2A4A',
    justifyContent: 'center', alignItems: 'center',
    borderWidth: 2, borderColor: 'rgba(255,255,255,0.2)',
  },
  topBar: {
    position: 'absolute', left: 16, right: 16,
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
  },
  callInfo: {
    flexDirection: 'row', alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.4)', borderRadius: 20,
    paddingHorizontal: 12, paddingVertical: 6, gap: 8,
  },
  liveIndicator: { width: 8, height: 8, borderRadius: 4, backgroundColor: '#4CAF50' },
  callDuration: { fontSize: 14, fontWeight: '600', color: '#FFFFFF' },
  chatPanel: {
    position: 'absolute', bottom: 0, left: 0, right: 0, height: '40%',
    backgroundColor: 'rgba(0,0,0,0.85)',
    borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 16,
  },
  chatTitle: { fontSize: 16, fontWeight: '700', color: '#FFFFFF', marginBottom: 12 },
  chatMsg: {
    backgroundColor: 'rgba(255,255,255,0.1)', borderRadius: 12,
    padding: 12, marginBottom: 12,
  },
  chatSender: { fontSize: 12, color: '#001689', fontWeight: '600', marginBottom: 4 },
  chatText: { fontSize: 14, color: '#FFFFFF' },
  chatInputRow: {
    backgroundColor: 'rgba(255,255,255,0.1)', borderRadius: 12,
    paddingHorizontal: 16, paddingVertical: 12,
  },
  chatPlaceholder: { fontSize: 14, color: 'rgba(255,255,255,0.4)' },
  controls: {
    flexDirection: 'row', justifyContent: 'space-evenly', alignItems: 'center',
    paddingVertical: 16, paddingHorizontal: 8, backgroundColor: '#0F0F23',
  },
  ctrlBtn: { alignItems: 'center', gap: 4, padding: 8 },
  ctrlLabel: { fontSize: 10, color: 'rgba(255,255,255,0.6)', fontWeight: '500' },
  endCallBtn: {
    width: 56, height: 56, borderRadius: 28, backgroundColor: '#CE0E2D',
    justifyContent: 'center', alignItems: 'center',
  },
});
