import React from 'react';
import { Pressable, StyleProp, ViewStyle } from 'react-native';
import Animated, {
    useAnimatedStyle,
    useSharedValue,
    withTiming,
    WithTimingConfig,
} from 'react-native-reanimated';

// Calm motion config
export const CALM_TIMING: WithTimingConfig = {
    duration: 100,
};

interface ScaleButtonProps {
    onPress: () => void;
    style?: StyleProp<ViewStyle>;
    children: React.ReactNode;
    disabled?: boolean;
}

export function ScaleButton({ onPress, style, children, disabled }: ScaleButtonProps) {
    const scale = useSharedValue(1);

    const animatedStyle = useAnimatedStyle(() => ({
        transform: [{ scale: scale.value }],
    }));

    const handlePressIn = () => {
        scale.value = withTiming(0.97, CALM_TIMING);
    };

    const handlePressOut = () => {
        scale.value = withTiming(1, CALM_TIMING);
    };

    return (
        <Pressable
            onPress={onPress}
            onPressIn={handlePressIn}
            onPressOut={handlePressOut}
            disabled={disabled}
        >
            <Animated.View style={[style, animatedStyle]}>{children}</Animated.View>
        </Pressable>
    );
}
