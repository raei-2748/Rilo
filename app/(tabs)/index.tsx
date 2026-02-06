import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { colors } from '../../src/theme/colors';
import { ScaleButton } from '../../src/components/ScaleButton';

export default function HomeScreen() {
  const router = useRouter();

  return (
    <View style={styles.container}>
      <StatusBar style="dark" />
      <View style={styles.headerSpacer} />

      <View style={styles.content}>
        <Animated.View entering={FadeInDown.delay(100).springify()}>
          <Text style={styles.brand}>Rilo</Text>
        </Animated.View>

        <Animated.View entering={FadeInDown.delay(200).springify()}>
          <Text style={styles.headline}>
            Financial clarity,{'\n'}
            <Text style={styles.headlineHighlight}>instant relief.</Text>
          </Text>
        </Animated.View>

        <Animated.View entering={FadeInDown.delay(300).springify()} style={styles.spacer} />

        <Animated.View entering={FadeInDown.delay(400).springify()}>
          <ScaleButton
            style={styles.ctaButton}
            onPress={() => router.push('/afford-it')}
          >
            <Text style={styles.ctaText}>Can I afford it?</Text>
            <View style={styles.ctaIconContainer}>
              <Text style={styles.ctaIcon}>→</Text>
            </View>
          </ScaleButton>
        </Animated.View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: 24,
  },
  headerSpacer: {
    height: 120, // Push content down for a modern "air" feel
  },
  content: {
    flex: 1,
    justifyContent: 'flex-start',
  },
  brand: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.secondary,
    textTransform: 'uppercase',
    letterSpacing: 2,
    marginBottom: 24,
  },
  headline: {
    fontSize: 48,
    lineHeight: 52,
    fontWeight: '300', // Light font for elegance
    color: colors.text,
    letterSpacing: -1,
  },
  headlineHighlight: {
    fontWeight: '500', // Slightly bolder for emphasis
    color: colors.accent,
  },
  spacer: {
    height: 60,
  },
  ctaButton: {
    backgroundColor: colors.accent,
    borderRadius: 32, // Pill shape
    paddingVertical: 20,
    paddingHorizontal: 32,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
  ctaText: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '500',
    letterSpacing: -0.5,
  },
  ctaIconContainer: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ctaIcon: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: -2,
  },
});
