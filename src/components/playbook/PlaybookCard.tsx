import React from 'react';
import { View, Text, StyleSheet, Pressable, Dimensions } from 'react-native';
import Animated, {
    useAnimatedStyle,
    useSharedValue,
    withSpring,
    FadeInUp,
} from 'react-native-reanimated';
import { colors } from '../../theme/colors';
import { formatCentsToDollars } from '../../core/Money';
import { ActionBadge } from './ActionBadge';
import { StressBar } from './StressBar';
import type { PlaybookCard as PlaybookCardType, AffordItAction } from '../../types/AffordIt';

export type CardSize = 'full' | 'half' | 'third';

interface PlaybookCardProps {
    card: PlaybookCardType;
    size: CardSize;
    onTogglePin: () => void;
    index: number;
}

const SCREEN_WIDTH = Dimensions.get('window').width;
const PADDING = 24;
const GAP = 12;

const ACTION_BACKGROUNDS: Record<AffordItAction, string> = {
    proceed: colors.actionPurchased,
    delay24h: colors.actionDelayed,
    bufferFirst: colors.actionBuffered,
    swap: colors.actionSwapped,
};

function formatRelativeTime(timestamp: number): string {
    const now = Date.now();
    const diffMs = now - timestamp;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    if (diffDays < 30) return `${Math.floor(diffDays / 7)}w ago`;
    return `${Math.floor(diffDays / 30)}mo ago`;
}

export function getCardWidth(size: CardSize): number {
    const availableWidth = SCREEN_WIDTH - PADDING * 2;
    switch (size) {
        case 'full':
            return availableWidth;
        case 'half':
            return (availableWidth - GAP) / 2;
        case 'third':
            return (availableWidth - GAP * 2) / 3;
    }
}

export function PlaybookCard({ card, size, onTogglePin, index }: PlaybookCardProps) {
    const scale = useSharedValue(1);
    const rotation = useSharedValue(0);

    const cardStyle = useAnimatedStyle(() => ({
        transform: [
            { scale: scale.value },
            { rotate: `${rotation.value}deg` },
        ],
    }));

    const handlePressIn = () => {
        scale.value = withSpring(0.97, { damping: 15 });
        if (card.isPinned) {
            rotation.value = withSpring(-0.5, { damping: 15 });
        }
    };

    const handlePressOut = () => {
        scale.value = withSpring(1, { damping: 15 });
        rotation.value = withSpring(0, { damping: 15 });
    };

    const relativeTime = formatRelativeTime(card.createdAt);
    const showStressBar = card.stressReduction > 0 && size !== 'third';
    const cardWidth = getCardWidth(size);

    return (
        <Animated.View
            entering={FadeInUp.delay(index * 40).springify().damping(18)}
            style={[
                styles.card,
                {
                    width: cardWidth,
                    backgroundColor: ACTION_BACKGROUNDS[card.chosenAction],
                },
                card.isPinned && styles.cardPinned,
                size === 'full' && styles.cardFull,
                size === 'third' && styles.cardCompact,
                cardStyle,
            ]}
        >
            <Pressable
                onPress={onTogglePin}
                onPressIn={handlePressIn}
                onPressOut={handlePressOut}
                style={styles.cardInner}
            >
                {/* Action Badge - Top */}
                <ActionBadge action={card.chosenAction} />

                {/* Label */}
                <Text
                    style={[styles.label, size === 'third' && styles.labelCompact]}
                    numberOfLines={size === 'third' ? 1 : 2}
                >
                    {card.label}
                </Text>

                {/* Amount - Centered, Large */}
                <Text style={[
                    styles.amount,
                    size === 'full' && styles.amountLarge,
                    size === 'third' && styles.amountCompact,
                ]}>
                    {formatCentsToDollars(card.amount)}
                </Text>

                {/* Stress Bar */}
                {showStressBar && (
                    <StressBar reduction={card.stressReduction} delay={300 + index * 50} />
                )}

                {/* Footer: Pin + Time */}
                <View style={styles.footer}>
                    <Text style={[styles.pin, card.isPinned && styles.pinActive]}>
                        {card.isPinned ? '★' : '☆'}
                    </Text>
                    <Text style={styles.time}>{relativeTime}</Text>
                </View>
            </Pressable>
        </Animated.View>
    );
}

const styles = StyleSheet.create({
    card: {
        borderRadius: 20,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.06,
        shadowRadius: 12,
        elevation: 3,
    },
    cardFull: {
        borderRadius: 24,
    },
    cardCompact: {
        borderRadius: 16,
    },
    cardPinned: {
        borderWidth: 1.5,
        borderColor: colors.accent,
        shadowOpacity: 0.1,
        shadowRadius: 16,
    },
    cardInner: {
        padding: 20,
    },
    label: {
        fontSize: 15,
        fontWeight: '400',
        color: colors.secondary,
        marginTop: 14,
        marginBottom: 8,
        lineHeight: 20,
    },
    labelCompact: {
        fontSize: 13,
        marginTop: 10,
        marginBottom: 6,
    },
    amount: {
        fontSize: 28,
        fontWeight: '300',
        color: colors.text,
        letterSpacing: -1,
        textAlign: 'center',
        marginVertical: 8,
    },
    amountLarge: {
        fontSize: 36,
        fontWeight: '200',
        marginVertical: 12,
    },
    amountCompact: {
        fontSize: 22,
        marginVertical: 4,
    },
    footer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 16,
        paddingTop: 12,
        borderTopWidth: 1,
        borderTopColor: colors.border,
    },
    pin: {
        fontSize: 18,
        color: colors.tertiary,
        opacity: 0.5,
    },
    pinActive: {
        color: colors.accent,
        opacity: 1,
    },
    time: {
        fontSize: 11,
        fontWeight: '500',
        color: colors.tertiary,
        letterSpacing: 0.3,
    },
});
