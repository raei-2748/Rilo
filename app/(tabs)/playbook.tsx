import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, { FadeInDown, Layout } from 'react-native-reanimated';
import { colors } from '../../src/theme/colors';
import { usePlaybookStore } from '../../src/storage/PlaybookStore';
import { formatCentsToDollars } from '../../src/core/Money';
import type { PlaybookCard } from '../../src/types/AffordIt';

function PlaybookCardItem({
    card,
    onTogglePin,
    index,
}: {
    card: PlaybookCard;
    onTogglePin: () => void;
    index: number;
}) {
    const actionLabel = formatActionLabel(card.chosenAction);
    const delay = index * 50;

    return (
        <Animated.View
            entering={FadeInDown.springify().damping(20).delay(delay)}
            layout={Layout.springify().damping(20)}
            style={[styles.card, card.isPinned && styles.cardPinned]}
        >
            <View style={styles.cardHeader}>
                <Text style={styles.cardLabel} numberOfLines={1}>
                    {card.label}
                </Text>
                <Text
                    style={[styles.pinIcon, card.isPinned && styles.pinIconActive]}
                    onPress={onTogglePin}
                >
                    {card.isPinned ? '★' : '☆'}
                </Text>
            </View>

            <View style={styles.amountRow}>
                <Text style={styles.cardAmount}>{formatCentsToDollars(card.amount)}</Text>
                <View style={[
                    styles.actionBadge,
                    card.chosenAction === 'proceed' ? styles.actionProceed : styles.actionCaution
                ]}>
                    <Text style={[
                        styles.actionText,
                        card.chosenAction === 'proceed' ? styles.actionTextProceed : styles.actionTextCaution
                    ]}>{actionLabel}</Text>
                </View>
            </View>

            {card.stressReduction > 0 && (
                <View style={styles.stressContainer}>
                    <Text style={styles.stressLabel}>Stress reduced by</Text>
                    <Text style={styles.stressValue}>{card.stressReduction}</Text>
                </View>
            )}
        </Animated.View>
    );
}

function formatActionLabel(action: string): string {
    switch (action) {
        case 'proceed': return 'Purchased';
        case 'delay24h': return 'Delayed';
        case 'bufferFirst': return 'Buffered';
        case 'swap': return 'Swapped';
        default: return action;
    }
}

export default function PlaybookScreen() {
    const { cards, togglePin } = usePlaybookStore();

    const sortedCards = [...cards].sort((a, b) => {
        if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
        return b.createdAt - a.createdAt;
    });

    return (
        <View style={styles.container}>
            <View style={styles.titleContainer}>
                <Text style={styles.header}>Playbook</Text>
                <Text style={styles.subheader}>Your patterns</Text>
            </View>

            {sortedCards.length === 0 ? (
                <View style={styles.emptyState}>
                    <Text style={styles.emptyText}>No entries yet</Text>
                    <Text style={styles.emptySubtext}>
                        Your decisions will appear here.
                    </Text>
                </View>
            ) : (
                <Animated.FlatList
                    data={sortedCards}
                    keyExtractor={(item) => item.id}
                    renderItem={({ item, index }) => (
                        <PlaybookCardItem
                            card={item}
                            index={index}
                            onTogglePin={() => togglePin(item.id)}
                        />
                    )}
                    contentContainerStyle={styles.list}
                    itemLayoutAnimation={Layout.springify()}
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
        paddingTop: 60,
    },
    titleContainer: {
        paddingHorizontal: 24,
        marginBottom: 24,
    },
    header: {
        fontSize: 32,
        fontWeight: '300',
        color: colors.text,
        letterSpacing: -1,
    },
    subheader: {
        fontSize: 14,
        color: colors.tertiary,
        textTransform: 'uppercase',
        letterSpacing: 2,
        marginTop: 4,
    },
    list: {
        paddingHorizontal: 24,
        paddingBottom: 24,
    },
    card: {
        backgroundColor: colors.surface,
        borderRadius: 24, // Soft UI
        padding: 24,
        marginBottom: 16,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.05,
        shadowRadius: 12,
        elevation: 3,
    },
    cardPinned: {
        borderWidth: 1,
        borderColor: colors.accent,
        backgroundColor: colors.surfaceAlt,
    },
    cardHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 16,
    },
    cardLabel: {
        fontSize: 16,
        fontWeight: '500',
        color: colors.secondary,
        flex: 1,
    },
    pinIcon: {
        fontSize: 20,
        color: colors.tertiary,
        opacity: 0.5,
    },
    pinIconActive: {
        color: colors.accent,
        opacity: 1,
    },
    amountRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'baseline',
        marginBottom: 16,
    },
    cardAmount: {
        fontSize: 32,
        fontWeight: '300',
        color: colors.text,
        letterSpacing: -1,
    },
    actionBadge: {
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 12,
        backgroundColor: colors.surfaceAlt,
    },
    actionProceed: {
        backgroundColor: 'rgba(74, 122, 104, 0.1)', // Success tint
    },
    actionCaution: {
        backgroundColor: 'rgba(179, 88, 72, 0.1)', // Warning tint
    },
    actionText: {
        fontSize: 13,
        fontWeight: '600',
        letterSpacing: 0.5,
    },
    actionTextProceed: { color: colors.success },
    actionTextCaution: { color: colors.warning },

    stressContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        borderTopWidth: 1,
        borderTopColor: colors.border,
        paddingTop: 16,
    },
    stressLabel: {
        fontSize: 12,
        color: colors.tertiary,
        textTransform: 'uppercase',
    },
    stressValue: {
        fontSize: 14,
        fontWeight: '600',
        color: colors.accent,
    },
    emptyState: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        opacity: 0.5,
    },
    emptyText: {
        fontSize: 18,
        color: colors.text,
        marginBottom: 8,
    },
    emptySubtext: {
        fontSize: 14,
        color: colors.tertiary,
    },
});
