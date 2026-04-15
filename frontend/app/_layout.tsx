import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="appointment/[id]" />
        <Stack.Screen name="appointment/schedule" />
        <Stack.Screen name="video-call" options={{ presentation: 'fullScreenModal' }} />
        <Stack.Screen name="prescription/[id]" />
        <Stack.Screen name="document/[id]" />
        <Stack.Screen name="sign-document/[id]" />
      </Stack>
    </>
  );
}
