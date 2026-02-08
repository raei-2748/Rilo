import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    TextInput,
    ScrollView,
    StyleSheet,
    KeyboardAvoidingView,
    Platform,
    Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import Animated, {
    FadeIn,
    FadeInDown,
    useSharedValue,
    useAnimatedStyle,
    withTiming,
    runOnJS
} from 'react-native-reanimated';

import { colors } from '../src/theme/colors';
import { parseDollarsToCents, formatCentsToDollars, formatCentsToInput } from '../src/core/Money';
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

// polished components
import { ScaleButton } from '../src/components/ScaleButton';
import { AnimatedNumber } from '../src/components/AnimatedNumber';
import { FadeInText } from '../src/components/FadeInText';

type Step = 'input' | 'result' | 'relief' | 'saving';

export default function AffordItScreen() {
    const router = useRouter();
    const { addCard } = usePlaybookStore();
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

    // Animation state for exit
    const containerOpacity = useSharedValue(1);

    // Validation
    const amountCents = parseDollarsToCents(amount);
    const balanceCents = parseDollarsToCents(balance);
    const canCalculate = amountCents > 0 && balanceCents > 0;

    const [liveResult, setLiveResult] = useState<AffordItResult | null>(null);

    useEffect(() => {
        if (canCalculate) {
            const bufferCents = parseDollarsToCents(buffer);
            const res = recommendAction({
                amount: amountCents,
                balance: balanceCents,
                buffer: bufferCents,
            });
            setLiveResult(res);
        } else {
            setLiveResult(null);
        }
    }, [amountCents, balanceCents, buffer]);


    const handleCalculate = () => {
        if (!canCalculate) return;
        setResult(liveResult);
        setStep('result');
    };

    const handleSelectAction = (action: AffordItAction) => {
        setChosenAction(action);
        setStep('relief');
    };

    const performSave = () => {
        const card: PlaybookCard = {
            id: Date.now().toString(),
            createdAt: Date.now(),
            label: label || 'Unnamed purchase',
            category,
            amount: amountCents,
            chosenAction: chosenAction!,
            stressReduction: (currentPulse?.before ?? 5) - (currentPulse?.after ?? 5),
            helpTags: currentPulse?.helpTags ?? [],
            isPinned: false,
        };

        addCard(card);
        reset();
        router.back();
    };

    const handleComplete = () => {
        if (!result || !chosenAction) return;

        // 1. Show Success State first
        setStep('saving');
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

        // 2. Wait, then animate out
        setTimeout(() => {
            containerOpacity.value = withTiming(0, { duration: 300 }, (finished) => {
                if (finished) {
                    runOnJS(performSave)();
                }
            });
        }, 800);
    };

    const animatedContainerStyle = useAnimatedStyle(() => ({
        opacity: containerOpacity.value,
    }));

    return (
        <KeyboardAvoidingView
            style={styles.container}
            behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
            <Animated.View
                style={[styles.container, animatedContainerStyle]}
            >
                <ScrollView
                    contentContainerStyle={styles.scrollContent}
                    keyboardShouldPersistTaps="handled"
                >
                    <Pressable style={styles.closeButton} onPress={() => router.back()}>
                        <Text style={styles.closeText}>✕</Text>
                    </Pressable>

                    <Text style={styles.headerTitle}>Afford It?</Text>

                    {step === 'input' && (
                        <Animated.View entering={FadeIn.duration(300)}>
                            <View style={styles.section}>
                                {/* Oversized Amount Input */}
                                <View style={styles.amountContainer}>
                                    <Text style={styles.amountPrefix}>$</Text>
                                    <TextInput
                                        style={styles.amountInput}
                                        value={amount}
                                        onChangeText={setAmount}
                                        placeholder="0"
                                        keyboardType="decimal-pad"
                                        placeholderTextColor={colors.borderStrong}
                                        autoFocus={true}
                                    />
                                </View>
                                <Text style={styles.inputHelper}>Enter amount</Text>

                                {/* Live Preview - Premium Style */}
                                <View style={styles.livePreviewContainer}>
                                    <View style={styles.livePreviewItem}>
                                        <Text style={styles.liveLabel}>SAFE TO SPEND</Text>
                                        <AnimatedNumber
                                            style={styles.liveValue}
                                            value={liveResult ? formatCentsToDollars(liveResult.safeToSpend) : '---'}
                                        />
                                    </View>
                                    <View style={styles.livePreviewDivider} />
                                    <View style={styles.livePreviewItem}>
                                        <Text style={styles.liveLabel}>REMAINING</Text>
                                        <AnimatedNumber
                                            style={styles.liveValue}
                                            value={liveResult ? formatCentsToDollars(liveResult.remainingAfterPurchase) : '---'}
                                        />
                                    </View>
                                </View>

                                <FadeInText visible={!!liveResult} style={[
                                    styles.statusText,
                                    liveResult?.remainingAfterPurchase && liveResult.remainingAfterPurchase < 0 ? styles.statusWarning : styles.statusSuccess
                                ]}>
                                    {liveResult?.remainingAfterPurchase && liveResult.remainingAfterPurchase < 0
                                        ? "Exceeds balance"
                                        : "Fits in balance"
                                    }
                                </FadeInText>

                                <View style={styles.divider} />

                                {/* Modern Inputs */}
                                <Text style={styles.fieldLabel}>CATEGORY</Text>
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
                                                {cat === 'essential' ? 'Essential' : 'Nice to have'}
                                            </Text>
                                        </Pressable>
                                    ))}
                                </View>

                                <Text style={styles.fieldLabel}>DETAILS</Text>
                                <TextInput
                                    style={styles.textInput}
                                    value={label}
                                    onChangeText={setLabel}
                                    placeholder="What is it?"
                                    placeholderTextColor={colors.tertiary}
                                />

                                <View style={styles.rowInputs}>
                                    <View style={styles.halfInput}>
                                        <Text style={styles.fieldLabel}>BALANCE</Text>
                                        <TextInput
                                            style={styles.textInput}
                                            value={balance}
                                            onChangeText={setBalance}
                                            placeholder="$0"
                                            keyboardType="decimal-pad"
                                            placeholderTextColor={colors.tertiary}
                                        />
                                    </View>
                                    <View style={styles.halfInput}>
                                        <Text style={styles.fieldLabel}>BUFFER</Text>
                                        <TextInput
                                            style={styles.textInput}
                                            value={buffer}
                                            onChangeText={setBuffer}
                                            placeholder="$200"
                                            keyboardType="decimal-pad"
                                            placeholderTextColor={colors.tertiary}
                                        />
                                    </View>
                                </View>

                                <ScaleButton
                                    style={[
                                        styles.primaryButton,
                                        !canCalculate && styles.primaryButtonDisabled,
                                    ]}
                                    onPress={handleCalculate}
                                    disabled={!canCalculate}
                                >
                                    <Text style={styles.primaryButtonText}>Analyze</Text>
                                </ScaleButton>
                            </View>
                        </Animated.View>
                    )}

                    {step === 'result' && result && (
                        <Animated.View entering={FadeInDown.duration(400).springify()} style={styles.section}>
                            <View style={styles.resultContainer}>
                                <Text style={styles.resultLabel}>SAFE TO SPEND</Text>
                                <Text style={styles.resultHero}>
                                    {formatCentsToDollars(result.safeToSpend)}
                                </Text>

                                <View style={styles.resultRow}>
                                    <Text style={styles.resultSubLabel}>After purchase:</Text>
                                    <Text
                                        style={[
                                            styles.resultSubValue,
                                            result.remainingAfterPurchase < 0 && styles.resultNegative,
                                        ]}
                                    >
                                        {formatCentsToDollars(result.remainingAfterPurchase)}
                                    </Text>
                                </View>
                            </View>

                            <Text style={styles.sectionHeader}>Recommendation</Text>
                            <ScaleButton
                                style={[styles.actionButton, styles.actionPrimary]}
                                onPress={() => handleSelectAction(result.recommendedAction)}
                            >
                                <Text style={styles.actionPrimaryText}>
                                    {formatActionLabel(result.recommendedAction)}
                                </Text>
                                <Text style={styles.actionArrow}>→</Text>
                            </ScaleButton>

                            <Text style={styles.sectionHeader}>Other Options</Text>
                            {result.alternateActions.map((action) => (
                                <ScaleButton
                                    key={action}
                                    style={styles.actionButton}
                                    onPress={() => handleSelectAction(action)}
                                >
                                    <Text style={styles.actionText}>
                                        {formatActionLabel(action)}
                                    </Text>
                                </ScaleButton>
                            ))}

                            {result.recommendedAction !== 'proceed' && (
                                <Text style={styles.swapHint}>
                                    Suggestion: Swap for {formatCentsToDollars(result.swapSuggestion)} item
                                </Text>
                            )}
                        </Animated.View>
                    )}

                    {step === 'relief' && (
                        <Animated.View entering={FadeInDown.duration(400).springify()} style={styles.section}>
                            {/* Updated 5-step Mood Selectors */}
                            <Text style={styles.reliefQuestion}>Stress level before?</Text>
                            <MoodSelector value={currentPulse?.before} onChange={setStressBefore} />

                            <Text style={styles.reliefQuestion}>Stress level now?</Text>
                            <MoodSelector value={currentPulse?.after} onChange={setStressAfter} />

                            <Text style={styles.reliefQuestion}>What helped?</Text>
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

                            <ScaleButton style={styles.primaryButton} onPress={handleComplete}>
                                <Text style={styles.primaryButtonText}>Save & Close</Text>
                            </ScaleButton>
                        </Animated.View>
                    )}

                    {step === 'saving' && (
                        <Animated.View entering={FadeIn.duration(300)} style={styles.centerContainer}>
                            <View style={styles.successIcon}>
                                <Text style={styles.successCheck}>✓</Text>
                            </View>
                            <Text style={styles.successText}>Saved to Playbook</Text>
                        </Animated.View>
                    )}
                </ScrollView>
            </Animated.View>
        </KeyboardAvoidingView>
    );
}

// 5-level mood scale
const MOOD_LEVELS = [
    { value: 0, label: 'Calm', emoji: '😌' },
    { value: 3, label: 'Okay', emoji: '🙂' },
    { value: 5, label: 'Uneasy', emoji: '😐' },
    { value: 8, label: 'Stressed', emoji: '😰' },
    { value: 10, label: 'Panic', emoji: '🤯' },
];

function MoodSelector({ value, onChange }: { value: number | undefined, onChange: (v: number) => void }) {
    return (
        <View style={styles.moodContainer}>
            {MOOD_LEVELS.map((level) => {
                const isSelected = value === level.value;
                return (
                    <Pressable
                        key={level.value}
                        style={[styles.moodButton, isSelected && styles.moodSelected]}
                        onPress={() => onChange(level.value)}
                    >
                        <Text style={styles.moodEmoji}>{level.emoji}</Text>
                        <Text style={[styles.moodLabel, isSelected && styles.moodLabelSelected]}>
                            {level.label}
                        </Text>
                    </Pressable>
                );
            })}
        </View>
    );
}

function formatActionLabel(action: AffordItAction): string {
    switch (action) {
        case 'proceed': return 'Proceed with purchase';
        case 'delay24h': return 'Wait 24 hours';
        case 'bufferFirst': return 'Build buffer first';
        case 'swap': return 'Swap for cheaper option';
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
        paddingBottom: 40,
    },
    closeButton: {
        position: 'absolute',
        top: 20,
        right: 20,
        zIndex: 10,
        padding: 8,
        backgroundColor: 'rgba(0,0,0,0.05)',
        borderRadius: 20,
    },
    closeText: {
        fontSize: 16,
        color: colors.secondary,
        fontWeight: '500',
    },
    headerTitle: {
        fontSize: 14,
        fontWeight: '600',
        color: colors.tertiary,
        textTransform: 'uppercase',
        letterSpacing: 1,
        marginBottom: 40,
        textAlign: 'center',
    },
    section: {
        marginBottom: 24,
    },
    amountContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 8,
    },
    amountPrefix: {
        fontSize: 56,
        fontWeight: '300',
        color: colors.text,
        marginRight: 4,
    },
    amountInput: {
        fontSize: 56, // Massive input
        fontWeight: '300',
        color: colors.text,
        minWidth: 60,
        textAlign: 'left',
        paddingVertical: 10,
    },
    inputHelper: {
        fontSize: 14,
        color: colors.tertiary,
        textAlign: 'center',
        marginBottom: 32,
    },
    livePreviewContainer: {
        flexDirection: 'row',
        backgroundColor: colors.surface,
        borderRadius: 20,
        padding: 24,
        marginBottom: 16,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.05,
        shadowRadius: 10,
        elevation: 2,
        alignItems: 'center',
    },
    livePreviewItem: {
        flex: 1,
        alignItems: 'center',
    },
    livePreviewDivider: {
        width: 1,
        height: 30,
        backgroundColor: colors.border,
        marginHorizontal: 16,
    },
    liveLabel: {
        fontSize: 10,
        color: colors.tertiary,
        fontWeight: '600',
        letterSpacing: 0.5,
        marginBottom: 4,
        textTransform: 'uppercase',
    },
    liveValue: {
        fontSize: 20,
        fontWeight: '500',
        color: colors.text,
    },
    statusText: {
        textAlign: 'center',
        fontSize: 14,
        fontWeight: '500',
        marginBottom: 32,
        height: 20,
    },
    statusSuccess: { color: colors.success },
    statusWarning: { color: colors.warning },

    divider: {
        height: 1,
        backgroundColor: colors.border,
        marginBottom: 32,
    },
    fieldLabel: {
        fontSize: 12,
        fontWeight: '600',
        color: colors.tertiary,
        letterSpacing: 0.5,
        marginBottom: 12,
        textTransform: 'uppercase',
    },
    textInput: {
        fontSize: 18,
        color: colors.text,
        borderBottomWidth: 1, // Line style
        borderBottomColor: colors.borderStrong,
        paddingVertical: 8,
        marginBottom: 24,
    },
    rowInputs: {
        flexDirection: 'row',
        gap: 24,
    },
    halfInput: {
        flex: 1,
    },
    categoryRow: {
        flexDirection: 'row',
        gap: 12,
        marginBottom: 24,
    },
    categoryButton: {
        flex: 1,
        padding: 16,
        borderRadius: 16,
        backgroundColor: colors.surfaceAlt,
        borderWidth: 1,
        borderColor: 'transparent',
    },
    categorySelected: {
        backgroundColor: colors.surface,
        borderColor: colors.accent,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
    },
    categoryText: {
        color: colors.tertiary,
        fontSize: 15,
        textAlign: 'center',
        fontWeight: '500',
    },
    categoryTextSelected: {
        color: colors.accent,
        fontWeight: '600',
    },
    primaryButton: {
        backgroundColor: colors.accent,
        paddingVertical: 20,
        borderRadius: 30,
        alignItems: 'center',
        marginTop: 16,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.2,
        shadowRadius: 16,
        elevation: 6,
    },
    primaryButtonDisabled: {
        opacity: 0.5,
        shadowOpacity: 0.1,
    },
    primaryButtonText: {
        color: '#FFFFFF',
        fontSize: 18,
        fontWeight: '600',
        letterSpacing: 0.5,
    },

    // Result Styles
    resultContainer: {
        alignItems: 'center',
        marginBottom: 40,
    },
    resultLabel: {
        fontSize: 12,
        fontWeight: '600',
        color: colors.tertiary,
        letterSpacing: 1,
        marginBottom: 8,
        textTransform: 'uppercase',
    },
    resultHero: {
        fontSize: 64, // Massive hero number
        fontWeight: '200',
        color: colors.text,
        letterSpacing: -2,
        marginBottom: 16,
    },
    resultRow: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.surface,
        paddingVertical: 8,
        paddingHorizontal: 16,
        borderRadius: 20,
    },
    resultSubLabel: {
        fontSize: 14,
        color: colors.secondary,
        marginRight: 8,
    },
    resultSubValue: {
        fontSize: 16,
        fontWeight: '600',
        color: colors.text,
    },
    resultNegative: {
        color: colors.warning,
    },
    sectionHeader: {
        fontSize: 18,
        fontWeight: '600',
        color: colors.text,
        marginBottom: 16,
        marginTop: 8,
    },
    actionButton: {
        padding: 20,
        borderRadius: 24,
        backgroundColor: colors.surface,
        marginBottom: 12,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
    actionPrimary: {
        backgroundColor: colors.accent,
        paddingVertical: 24,
    },
    actionPrimaryText: {
        color: '#FFFFFF',
        fontSize: 18,
        fontWeight: '600',
    },
    actionArrow: {
        color: '#FFFFFF',
        fontSize: 20,
        marginLeft: 12,
        fontWeight: '300',
    },
    actionText: {
        color: colors.text,
        fontSize: 16,
        fontWeight: '500',
    },
    swapHint: {
        fontSize: 14,
        color: colors.secondary,
        textAlign: 'center',
        marginTop: 16,
        fontStyle: 'italic',
    },

    // Relief Styles
    reliefQuestion: {
        fontSize: 18,
        fontWeight: '500',
        color: colors.text,
        marginBottom: 20,
        marginTop: 10,
    },
    stressRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 32,
    },
    stressButton: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: colors.surface,
        alignItems: 'center',
        justifyContent: 'center',
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
    },
    stressSelected: {
        backgroundColor: colors.accent,
        transform: [{ scale: 1.1 }],
    },
    stressText: {
        fontSize: 16,
        color: colors.secondary,
        fontWeight: '500',
    },
    stressTextSelected: {
        color: '#FFFFFF',
    },
    tagsContainer: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 10,
        marginBottom: 20,
    },
    helpTag: {
        paddingHorizontal: 16,
        paddingVertical: 12,
        borderRadius: 20,
        backgroundColor: colors.surface,
        borderWidth: 1,
        borderColor: 'transparent',
    },
    helpTagSelected: {
        backgroundColor: colors.surfaceAlt,
        borderColor: colors.accent,
    },
    helpTagText: {
        fontSize: 14,
        color: colors.secondary,
    },
    helpTagTextSelected: {
        color: colors.accent,
        fontWeight: '600',
    },

    // Mood Selector Details
    moodContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 32,
    },
    moodButton: {
        alignItems: 'center',
        opacity: 0.5,
        padding: 8,
    },
    moodSelected: {
        opacity: 1,
        transform: [{ scale: 1.1 }],
    },
    moodEmoji: {
        fontSize: 32,
        marginBottom: 8,
    },
    moodLabel: {
        fontSize: 12,
        color: colors.secondary,
        fontWeight: '500',
    },
    moodLabelSelected: {
        color: colors.accent,
        fontWeight: '700',
    },

    // Success State
    centerContainer: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 100,
    },
    successIcon: {
        width: 80,
        height: 80,
        borderRadius: 40,
        backgroundColor: colors.success,
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 24,
    },
    successCheck: {
        color: '#FFFFFF',
        fontSize: 40,
        fontWeight: 'bold',
    },
    successText: {
        fontSize: 24,
        color: colors.text,
        fontWeight: '600',
    },
});
