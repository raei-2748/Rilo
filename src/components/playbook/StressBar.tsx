import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withDelay,
    withSpring,
} from 'react-native-reanimated';
import { colors } from '../../theme/colors';

interface StressBarProps {
    reduction: number; // 0-10
    delay?: number;
}

export function StressBar({ reduction, delay = 400 }: StressBarProps) {
    const width = useSharedValue(0);
    const targetWidth = Math.min(reduction / 10, 1) * 100;

    useEffect(() => {
        width.value = withDelay(
            delay,
            withSpring(targetWidth, { damping: 20, stiffness: 90 })
        );
    }, [reduction, delay, targetWidth]);

    const animatedBarStyle = useAnimatedStyle(() => ({
        width: `${width.value}%`,
    }));

    return (
        <View style={styles.container}>
            <View style={styles.track}>
                <Animated.View style={[styles.fill, animatedBarStyle]} />
            </View>
            <Text style={styles.label}>Stress reduced</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        marginTop: 12,
    },
    track: {
        height: 6,
        backgroundColor: colors.border,
        borderRadius: 3,
        overflow: 'hidden',
    },
    fill: {
        height: '100%',
        backgroundColor: colors.success,
        borderRadius: 3,
    },
    label: {
        fontSize: 11,
        color: colors.tertiary,
        marginTop: 6,
        fontWeight: '500',
        letterSpacing: 0.3,
    },
});
