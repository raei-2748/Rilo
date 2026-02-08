import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, { FadeIn } from 'react-native-reanimated';
import { colors } from '../../theme/colors';
import type { PlaybookCard, AffordItAction } from '../../types/AffordIt';

interface PulseStripProps {
    cards: PlaybookCard[];
    daysToShow?: number;
}

interface DayData {
    date: string;
    intensity: number;
    primaryAction: AffordItAction | null;
    count: number;
}

function calculateDayActivity(cards: PlaybookCard[], days: number): DayData[] {
    const now = Date.now();
    const dayMs = 86400000;
    const result: DayData[] = [];

    for (let i = days - 1; i >= 0; i--) {
        const dayStart = now - (i + 1) * dayMs;
        const dayEnd = now - i * dayMs;

        const dayCards = cards.filter(
            (c) => c.createdAt >= dayStart && c.createdAt < dayEnd
        );

        const count = dayCards.length;
        const intensity = Math.min(count / 3, 1); // Max intensity at 3+ decisions

        // Find primary action (most common)
        let primaryAction: AffordItAction | null = null;
        if (dayCards.length > 0) {
            const actionCounts = dayCards.reduce((acc, c) => {
                acc[c.chosenAction] = (acc[c.chosenAction] || 0) + 1;
                return acc;
            }, {} as Record<string, number>);

            primaryAction = Object.entries(actionCounts).sort((a, b) => b[1] - a[1])[0][0] as AffordItAction;
        }

        result.push({
            date: new Date(dayEnd).toISOString().split('T')[0],
            intensity,
            primaryAction,
            count,
        });
    }

    return result;
}

function getActionColor(action: AffordItAction | null, intensity: number): string {
    if (!action || intensity === 0) {
        return colors.border;
    }

    const baseColor = action === 'proceed'
        ? colors.purchasedAccent
        : action === 'delay24h'
            ? colors.delayedAccent
            : colors.accent;

    // Return with opacity based on intensity
    return baseColor;
}

export function PulseStrip({ cards, daysToShow = 14 }: PulseStripProps) {
    const dayData = calculateDayActivity(cards, daysToShow);

    return (
        <View style={styles.container}>
            <View style={styles.strip}>
                {dayData.map((day, index) => (
                    <Animated.View
                        key={day.date}
                        entering={FadeIn.delay(index * 20).duration(150)}
                        style={[
                            styles.block,
                            {
                                backgroundColor: getActionColor(day.primaryAction, day.intensity),
                                opacity: day.intensity > 0 ? 0.3 + day.intensity * 0.7 : 0.15,
                            },
                        ]}
                    />
                ))}
            </View>
        </View>
    );
}

interface MetricsPillsProps {
    decisionsCount: number;
    delayedPercent: number;
    avgAmount: string;
}

export function MetricsPills({ decisionsCount, delayedPercent, avgAmount }: MetricsPillsProps) {
    return (
        <View style={styles.metricsContainer}>
            <View style={styles.pill}>
                <Text style={styles.pillValue}>{decisionsCount}</Text>
                <Text style={styles.pillLabel}>this week</Text>
            </View>
            <View style={styles.pillDivider} />
            <View style={styles.pill}>
                <Text style={styles.pillValue}>{delayedPercent}%</Text>
                <Text style={styles.pillLabel}>delayed</Text>
            </View>
            <View style={styles.pillDivider} />
            <View style={styles.pill}>
                <Text style={styles.pillValue}>{avgAmount}</Text>
                <Text style={styles.pillLabel}>avg.</Text>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        paddingHorizontal: 24,
        marginBottom: 8,
    },
    strip: {
        flexDirection: 'row',
        gap: 4,
        height: 24,
        alignItems: 'flex-end',
    },
    block: {
        flex: 1,
        height: '100%',
        borderRadius: 3,
    },
    metricsContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: 24,
        paddingVertical: 12,
        gap: 16,
    },
    pill: {
        alignItems: 'center',
    },
    pillValue: {
        fontSize: 16,
        fontWeight: '500',
        color: colors.text,
        letterSpacing: -0.3,
    },
    pillLabel: {
        fontSize: 10,
        fontWeight: '600',
        color: colors.tertiary,
        textTransform: 'uppercase',
        letterSpacing: 0.5,
        marginTop: 2,
    },
    pillDivider: {
        width: 1,
        height: 20,
        backgroundColor: colors.border,
    },
});
