import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../../theme/colors';
import type { AffordItAction } from '../../types/AffordIt';

interface ActionBadgeProps {
    action: AffordItAction;
}

const ACTION_CONFIG: Record<AffordItAction, { label: string; icon: string; color: string }> = {
    proceed: { label: 'PURCHASED', icon: '●', color: colors.purchasedAccent },
    delay24h: { label: 'DELAYED', icon: '◐', color: colors.delayedAccent },
    bufferFirst: { label: 'BUFFERED', icon: '◈', color: colors.bufferedAccent },
    swap: { label: 'SWAPPED', icon: '⇄', color: colors.swappedAccent },
};

export function ActionBadge({ action }: ActionBadgeProps) {
    const config = ACTION_CONFIG[action];

    return (
        <View style={styles.container}>
            <Text style={[styles.icon, { color: config.color }]}>{config.icon}</Text>
            <Text style={[styles.label, { color: config.color }]}>{config.label}</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
    },
    icon: {
        fontSize: 10,
    },
    label: {
        fontSize: 11,
        fontWeight: '700',
        letterSpacing: 1,
    },
});
