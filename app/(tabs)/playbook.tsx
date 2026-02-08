import React from 'react';
import { View, StyleSheet } from 'react-native';
import Animated, { FadeInDown, FadeIn } from 'react-native-reanimated';
import { colors } from '../../src/theme/colors';
import { usePlaybookStore } from '../../src/storage/PlaybookStore';
import { formatCentsToDollars } from '../../src/core/Money';
import { calculatePlaybookMetrics } from '../../src/core/PlaybookMetrics';

// New playbook components
import { PulseStrip, MetricsPills } from '../../src/components/playbook/PulseStrip';
import { PlaybookCardGrid } from '../../src/components/playbook/PlaybookCardGrid';
import { EmptyPlaybook } from '../../src/components/playbook/EmptyPlaybook';

export default function PlaybookScreen() {
    const { cards, togglePin } = usePlaybookStore();
    const metrics = calculatePlaybookMetrics(cards);

    const sortedCards = [...cards].sort((a, b) => {
        if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
        return b.createdAt - a.createdAt;
    });

    return (
        <View style={styles.container}>
            {/* Header */}
            <Animated.View
                entering={FadeInDown.delay(100).springify().damping(18)}
                style={styles.header}
            >
                <Animated.Text
                    entering={FadeIn.delay(150)}
                    style={styles.title}
                >
                    Playbook
                </Animated.Text>
                <Animated.Text
                    entering={FadeIn.delay(200)}
                    style={styles.subtitle}
                >
                    YOUR PATTERNS
                </Animated.Text>
            </Animated.View>

            {/* Activity Visualization */}
            {cards.length > 0 && (
                <Animated.View entering={FadeIn.delay(250)}>
                    <PulseStrip cards={cards} />
                    <MetricsPills
                        decisionsCount={metrics.decisionsLast7Days}
                        delayedPercent={metrics.delay24hPercent}
                        avgAmount={formatCentsToDollars(metrics.averageRemainingCents)}
                    />
                </Animated.View>
            )}

            {/* Content */}
            {sortedCards.length === 0 ? (
                <EmptyPlaybook />
            ) : (
                <PlaybookCardGrid
                    cards={sortedCards}
                    onTogglePin={togglePin}
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
    header: {
        paddingHorizontal: 24,
        marginBottom: 20,
    },
    title: {
        fontSize: 40,
        fontWeight: '200',
        color: colors.text,
        letterSpacing: -2,
    },
    subtitle: {
        fontSize: 12,
        fontWeight: '500',
        color: colors.tertiary,
        textTransform: 'uppercase',
        letterSpacing: 4,
        marginTop: 4,
    },
});
