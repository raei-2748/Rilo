import React from 'react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { colors } from '../src/theme/colors';
import { PlaybookProvider } from '../src/storage/PlaybookStore';
import { StressPulseProvider } from '../src/storage/StressPulseStore';

export default function RootLayout() {
  return (
    <PlaybookProvider>
      <StressPulseProvider>
        <StatusBar style="dark" />
        <Stack
          screenOptions={{
            headerShown: false,
            contentStyle: { backgroundColor: colors.background },
          }}
        >
          <Stack.Screen name="(tabs)" />
          <Stack.Screen
            name="afford-it"
            options={{
              presentation: 'modal',
              animation: 'slide_from_bottom',
            }}
          />
        </Stack>
      </StressPulseProvider>
    </PlaybookProvider>
  );
}
