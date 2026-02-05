import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '../src/theme/colors';
import { parseDollarsToCents, formatCentsToDollars } from '../src/core/Money';
import { recommendAction } from '../src/core/AffordItCalculator';
import { usePlaybookStore } from '../src/storage/PlaybookStore';
import {
  useStressPulseStore,
  HELP_TAGS,
} from '../src/storage/StressPulseStore';
import type {
  AffordItCategory,
  AffordItAction,
  AffordItResult,
  PlaybookCard,
} from '../src/types/AffordIt';

type Step = 'input' | 'result' | 'relief';

export default function AffordItScreen() {
  const router = useRouter();
  const addCard = usePlaybookStore((s) => s.addCard);
  const {
    currentPulse,
    setStressBefore,
    setStressAfter,
    toggleHelpTag,
    reset,
  } = useStressPulseStore();

  // Form state
  const [step, setStep] = useState<Step>('input');
  const [amount, setAmount] = useState('');
  const [label, setLabel] = useState('');
  const [category, setCategory] = useState<AffordItCategory>('nonEssential');
  const [balance, setBalance] = useState('');
  const [buffer, setBuffer] = useState('200');

  // Result state
  const [result, setResult] = useState<AffordItResult | null>(null);
  const [chosenAction, setChosenAction] = useState<AffordItAction | null>(null);

  // Validation
  const amountCents = parseDollarsToCents(amount);
  const balanceCents = parseDollarsToCents(balance);
  const canCalculate = amountCents > 0 && balanceCents > 0;

  const handleCalculate = () => {
    if (!canCalculate) return;

    const bufferCents = parseDollarsToCents(buffer);
    const calcResult = recommendAction({
      amount: amountCents,
      balance: balanceCents,
      buffer: bufferCents,
    });

    setResult(calcResult);
    setStep('result');
  };

  const handleSelectAction = (action: AffordItAction) => {
    setChosenAction(action);
    setStep('relief');
  };

  const handleComplete = () => {
    if (!result || !chosenAction) return;

    const card: PlaybookCard = {
      id: Date.now().toString(),
      createdAt: Date.now(),
      label: label || 'Unnamed purchase',
      category,
      amount: amountCents,
      chosenAction,
      stressReduction: (currentPulse?.before ?? 5) - (currentPulse?.after ?? 5),
      helpTags: currentPulse?.helpTags ?? [],
      isPinned: false,
    };

    addCard(card);
    reset();
    router.back();
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        <Pressable style={styles.closeButton} onPress={() => router.back()}>
          <Text style={styles.closeText}>✕</Text>
        </Pressable>

        <Text style={styles.title}>Afford It?</Text>

        {step === 'input' && (
          <View style={styles.section}>
            <Text style={styles.label}>Amount</Text>
            <TextInput
              style={styles.input}
              value={amount}
              onChangeText={setAmount}
              placeholder="0.00"
              keyboardType="decimal-pad"
              placeholderTextColor={colors.tertiary}
            />

            <Text style={styles.label}>What is it?</Text>
            <TextInput
              style={styles.input}
              value={label}
              onChangeText={setLabel}
              placeholder="Coffee, shoes, etc."
              placeholderTextColor={colors.tertiary}
            />

            <Text style={styles.label}>Category</Text>
            <View style={styles.categoryRow}>
              {(['essential', 'nonEssential'] as const).map((cat) => (
                <Pressable
                  key={cat}
                  style={[
                    styles.categoryButton,
                    category === cat && styles.categorySelected,
                  ]}
                  onPress={() => setCategory(cat)}
                >
                  <Text
                    style={[
                      styles.categoryText,
                      category === cat && styles.categoryTextSelected,
                    ]}
                  >
                    {cat === 'essential' ? 'Essential' : 'Non-Essential'}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Text style={styles.label}>Current Balance</Text>
            <TextInput
              style={styles.input}
              value={balance}
              onChangeText={setBalance}
              placeholder="0.00"
              keyboardType="decimal-pad"
              placeholderTextColor={colors.tertiary}
            />

            <Text style={styles.label}>Buffer (safety cushion)</Text>
            <TextInput
              style={styles.input}
              value={buffer}
              onChangeText={setBuffer}
              placeholder="200"
              keyboardType="decimal-pad"
              placeholderTextColor={colors.tertiary}
            />

            <Pressable
              style={[
                styles.primaryButton,
                !canCalculate && styles.primaryButtonDisabled,
              ]}
              onPress={handleCalculate}
              disabled={!canCalculate}
            >
              <Text style={styles.primaryButtonText}>Calculate</Text>
            </Pressable>

            {!canCalculate && (amount !== '' || balance !== '') && (
              <Text style={styles.errorText}>
                Please enter a valid amount and balance
              </Text>
            )}
          </View>
        )}

        {step === 'result' && result && (
          <View style={styles.section}>
            <View style={styles.resultCard}>
              <Text style={styles.resultLabel}>Safe to Spend</Text>
              <Text style={styles.resultValue}>
                {formatCentsToDollars(result.safeToSpend)}
              </Text>

              <Text style={styles.resultLabel}>After Purchase</Text>
              <Text
                style={[
                  styles.resultValue,
                  result.remainingAfterPurchase < 0 && styles.resultNegative,
                ]}
              >
                {formatCentsToDollars(result.remainingAfterPurchase)}
              </Text>
            </View>

            <Text style={styles.sectionTitle}>Recommended</Text>
            <Pressable
              style={[styles.actionButton, styles.actionPrimary]}
              onPress={() => handleSelectAction(result.recommendedAction)}
            >
              <Text style={styles.actionPrimaryText}>
                {formatActionLabel(result.recommendedAction)}
              </Text>
            </Pressable>

            <Text style={styles.sectionTitle}>Alternatives</Text>
            {result.alternateActions.map((action) => (
              <Pressable
                key={action}
                style={styles.actionButton}
                onPress={() => handleSelectAction(action)}
              >
                <Text style={styles.actionText}>
                  {formatActionLabel(action)}
                </Text>
              </Pressable>
            ))}

            {result.recommendedAction !== 'proceed' && (
              <Text style={styles.swapHint}>
                Swap suggestion: {formatCentsToDollars(result.swapSuggestion)}
              </Text>
            )}
          </View>
        )}

        {step === 'relief' && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>How stressed were you before?</Text>
            <View style={styles.stressRow}>
              {[0, 2, 4, 6, 8, 10].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.stressButton,
                    currentPulse?.before === val && styles.stressSelected,
                  ]}
                  onPress={() => setStressBefore(val)}
                >
                  <Text
                    style={[
                      styles.stressText,
                      currentPulse?.before === val && styles.stressTextSelected,
                    ]}
                  >
                    {val}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Text style={styles.sectionTitle}>How stressed are you now?</Text>
            <View style={styles.stressRow}>
              {[0, 2, 4, 6, 8, 10].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.stressButton,
                    currentPulse?.after === val && styles.stressSelected,
                  ]}
                  onPress={() => setStressAfter(val)}
                >
                  <Text
                    style={[
                      styles.stressText,
                      currentPulse?.after === val && styles.stressTextSelected,
                    ]}
                  >
                    {val}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Text style={styles.sectionTitle}>What helped?</Text>
            <View style={styles.tagsContainer}>
              {HELP_TAGS.map((tag) => (
                <Pressable
                  key={tag}
                  style={[
                    styles.helpTag,
                    currentPulse?.helpTags.includes(tag) &&
                    styles.helpTagSelected,
                  ]}
                  onPress={() => toggleHelpTag(tag)}
                >
                  <Text
                    style={[
                      styles.helpTagText,
                      currentPulse?.helpTags.includes(tag) &&
                      styles.helpTagTextSelected,
                    ]}
                  >
                    {tag}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Pressable style={styles.primaryButton} onPress={handleComplete}>
              <Text style={styles.primaryButtonText}>Save to Playbook</Text>
            </Pressable>
          </View>
        )}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

function formatActionLabel(action: AffordItAction): string {
  switch (action) {
    case 'proceed':
      return 'Proceed';
    case 'delay24h':
      return 'Delay 24 Hours';
    case 'bufferFirst':
      return 'Build Buffer First';
    case 'swap':
      return 'Swap for Less';
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollContent: {
    padding: 24,
    paddingTop: 60,
  },
  closeButton: {
    position: 'absolute',
    top: 16,
    right: 24,
    zIndex: 10,
    padding: 8,
  },
  closeText: {
    fontSize: 24,
    color: colors.secondary,
  },
  title: {
    fontSize: 28,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 24,
  },
  section: {
    marginBottom: 24,
  },
  label: {
    fontSize: 14,
    color: colors.secondary,
    marginBottom: 6,
    marginTop: 16,
  },
  input: {
    backgroundColor: colors.surface,
    borderRadius: 8,
    padding: 14,
    fontSize: 16,
    color: colors.text,
    borderWidth: 1,
    borderColor: colors.border,
  },
  categoryRow: {
    flexDirection: 'row',
    gap: 12,
  },
  categoryButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
  },
  categorySelected: {
    borderColor: colors.accent,
    backgroundColor: `${colors.accent}15`,
  },
  categoryText: {
    color: colors.secondary,
    fontSize: 14,
  },
  categoryTextSelected: {
    color: colors.accent,
    fontWeight: '500',
  },
  primaryButton: {
    backgroundColor: colors.accent,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 24,
  },
  primaryButtonDisabled: {
    opacity: 0.5,
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  errorText: {
    color: colors.warning,
    fontSize: 13,
    textAlign: 'center',
    marginTop: 8,
  },
  resultCard: {
    backgroundColor: colors.surface,
    padding: 20,
    borderRadius: 12,
    marginBottom: 24,
  },
  resultLabel: {
    fontSize: 14,
    color: colors.secondary,
    marginBottom: 4,
  },
  resultValue: {
    fontSize: 28,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 16,
  },
  resultNegative: {
    color: colors.warning,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.text,
    marginBottom: 12,
    marginTop: 16,
  },
  actionButton: {
    padding: 14,
    borderRadius: 10,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 10,
    alignItems: 'center',
  },
  actionPrimary: {
    backgroundColor: colors.accent,
    borderColor: colors.accent,
  },
  actionPrimaryText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
  },
  actionText: {
    color: colors.text,
    fontSize: 16,
  },
  swapHint: {
    fontSize: 13,
    color: colors.tertiary,
    textAlign: 'center',
    marginTop: 8,
  },
  stressRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 8,
  },
  stressButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: colors.border,
  },
  stressSelected: {
    backgroundColor: colors.accent,
    borderColor: colors.accent,
  },
  stressText: {
    fontSize: 14,
    color: colors.text,
  },
  stressTextSelected: {
    color: '#FFFFFF',
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  helpTag: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  helpTagSelected: {
    backgroundColor: `${colors.accent}20`,
    borderColor: colors.accent,
  },
  helpTagText: {
    fontSize: 13,
    color: colors.secondary,
  },
  helpTagTextSelected: {
    color: colors.accent,
  },
});
