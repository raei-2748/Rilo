import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withRepeat,
    withTiming,
    withDelay,
    withSequence,
    Easing,
    FadeIn,
} from 'react-native-reanimated';
import { useRouter } from 'expo-router';
import { colors } from '../../theme/colors';

interface NodeProps {
    x: number;
    y: number;
    delay: number;
}

function AnimatedNode({ x, y, delay }: NodeProps) {
    const opacity = useSharedValue(0.2);
    const scale = useSharedValue(0.8);

    useEffect(() => {
        opacity.value = withDelay(
            delay,
            withRepeat(
                withSequence(
                    withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
                    withTiming(0.2, { duration: 1500, easing: Easing.inOut(Easing.ease) })
                ),
                -1,
                true
            )
        );
        scale.value = withDelay(
            delay,
            withRepeat(
                withSequence(
                    withTiming(1.2, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
                    withTiming(0.8, { duration: 1500, easing: Easing.inOut(Easing.ease) })
                ),
                -1,
                true
            )
        );
    }, []);

    const animatedStyle = useAnimatedStyle(() => ({
        opacity: opacity.value,
        transform: [{ scale: scale.value }],
    }));

    return (
        <Animated.View
            style={[
                styles.node,
                { left: x, top: y },
                animatedStyle,
            ]}
        />
    );
}

function ConnectionLine({ x1, y1, x2, y2, delay }: { x1: number; y1: number; x2: number; y2: number; delay: number }) {
    const opacity = useSharedValue(0);

    useEffect(() => {
        opacity.value = withDelay(
            delay + 500,
            withRepeat(
                withSequence(
                    withTiming(0.4, { duration: 2000, easing: Easing.inOut(Easing.ease) }),
                    withTiming(0.1, { duration: 2000, easing: Easing.inOut(Easing.ease) })
                ),
                -1,
                true
            )
        );
    }, []);

    const animatedStyle = useAnimatedStyle(() => ({
        opacity: opacity.value,
    }));

    const length = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
    const angle = Math.atan2(y2 - y1, x2 - x1) * (180 / Math.PI);

    return (
        <Animated.View
            style={[
                styles.line,
                {
                    left: x1 + 6,
                    top: y1 + 6,
                    width: length,
                    transform: [{ rotate: `${angle}deg` }],
                },
                animatedStyle,
            ]}
        />
    );
}

export function EmptyPlaybook() {
    const router = useRouter();

    // Constellation nodes
    const nodes = [
        { x: 60, y: 20, delay: 0 },
        { x: 140, y: 50, delay: 200 },
        { x: 100, y: 100, delay: 400 },
        { x: 180, y: 90, delay: 600 },
        { x: 40, y: 80, delay: 800 },
    ];

    // Connections between nodes
    const connections = [
        { from: 0, to: 1, delay: 100 },
        { from: 1, to: 3, delay: 300 },
        { from: 1, to: 2, delay: 500 },
        { from: 2, to: 4, delay: 700 },
        { from: 0, to: 4, delay: 900 },
    ];

    return (
        <View style={styles.container}>
            {/* Constellation */}
            <View style={styles.constellation}>
                {connections.map((conn, i) => (
                    <ConnectionLine
                        key={`line-${i}`}
                        x1={nodes[conn.from].x}
                        y1={nodes[conn.from].y}
                        x2={nodes[conn.to].x}
                        y2={nodes[conn.to].y}
                        delay={conn.delay}
                    />
                ))}
                {nodes.map((node, i) => (
                    <AnimatedNode key={`node-${i}`} {...node} />
                ))}
            </View>

            {/* Text */}
            <Animated.Text
                entering={FadeIn.delay(300).duration(400)}
                style={styles.title}
            >
                Your Playbook starts here
            </Animated.Text>

            <Animated.Text
                entering={FadeIn.delay(500).duration(400)}
                style={styles.subtitle}
            >
                Each decision you make{'\n'}becomes a pattern you own
            </Animated.Text>

            {/* CTA */}
            <Animated.View entering={FadeIn.delay(700).duration(400)}>
                <Pressable
                    style={({ pressed }) => [
                        styles.cta,
                        pressed && styles.ctaPressed,
                    ]}
                    onPress={() => router.push('/afford-it')}
                >
                    <Text style={styles.ctaText}>Make first decision</Text>
                    <Text style={styles.ctaArrow}>→</Text>
                </Pressable>
            </Animated.View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: 40,
    },
    constellation: {
        width: 220,
        height: 140,
        marginBottom: 40,
        position: 'relative',
    },
    node: {
        position: 'absolute',
        width: 12,
        height: 12,
        borderRadius: 6,
        backgroundColor: colors.accent,
    },
    line: {
        position: 'absolute',
        height: 1,
        backgroundColor: colors.accent,
        transformOrigin: 'left center',
    },
    title: {
        fontSize: 22,
        fontWeight: '300',
        color: colors.text,
        textAlign: 'center',
        marginBottom: 12,
        letterSpacing: -0.5,
    },
    subtitle: {
        fontSize: 15,
        fontWeight: '400',
        color: colors.secondary,
        textAlign: 'center',
        lineHeight: 22,
        marginBottom: 32,
    },
    cta: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.accent,
        paddingHorizontal: 28,
        paddingVertical: 16,
        borderRadius: 32,
        gap: 8,
    },
    ctaPressed: {
        opacity: 0.9,
        transform: [{ scale: 0.98 }],
    },
    ctaText: {
        fontSize: 16,
        fontWeight: '600',
        color: '#FFFFFF',
    },
    ctaArrow: {
        fontSize: 18,
        color: '#FFFFFF',
    },
});
