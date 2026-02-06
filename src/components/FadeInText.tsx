import React, { useEffect } from 'react';
import { Text, TextProps } from 'react-native';
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withTiming,
    WithTimingConfig,
} from 'react-native-reanimated';

interface FadeInTextProps extends TextProps {
    children: React.ReactNode;
    visible?: boolean;
}

const FADE_CONFIG: WithTimingConfig = {
    duration: 250,
};

export function FadeInText({ children, visible = true, style, ...props }: FadeInTextProps) {
    const opacity = useSharedValue(visible ? 1 : 0);

    useEffect(() => {
        opacity.value = withTiming(visible ? 1 : 0, FADE_CONFIG);
    }, [visible, opacity]);

    const animatedStyle = useAnimatedStyle(() => ({
        opacity: opacity.value,
    }));

    return (
        <Animated.Text style={[style, animatedStyle]} {...props}>
            {children}
        </Animated.Text>
    );
}
