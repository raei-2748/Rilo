import React, { useEffect } from 'react';
import { Text, TextProps, StyleSheet } from 'react-native';
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withTiming,
    withSequence,
    runOnJS,
} from 'react-native-reanimated';

interface AnimatedNumberProps extends TextProps {
    value: string; // The formatted string (e.g. "$1,200.00")
}

export function AnimatedNumber({ value, style, ...props }: AnimatedNumberProps) {
    const opacity = useSharedValue(1);
    const [displayValue, setDisplayValue] = React.useState(value);

    useEffect(() => {
        if (value !== displayValue) {
            // Crossfade: Fade out -> update text -> Fade in
            opacity.value = withSequence(
                withTiming(0.4, { duration: 100 }),
                withTiming(1, { duration: 150 }, (finished) => {
                    if (finished) {
                        runOnJS(setDisplayValue)(value);
                    }
                })
            );
        }
    }, [value, displayValue, opacity]);

    // If the value changed while animating, we might need to force update it visually 
    // to avoid lag, but for a calm UI, letting it catch up is okay.
    // Actually, to make it snappy enough but smooth:
    // We can just animate the opacity change on each new value.

    // Revised approach:
    // Since we want to update the text *during* the dip in opacity, 
    // we can use a key to force re-mounting or just let React handle the text update 
    // overlap. 

    // A simpler "Calm" approach is just to animate the opacity of the container
    // briefly when the value changes.

    const animatedStyle = useAnimatedStyle(() => ({
        opacity: opacity.value,
    }));

    // Trigger opacity dip on change
    useEffect(() => {
        opacity.value = 0.5;
        opacity.value = withTiming(1, { duration: 300 });
    }, [value, opacity]);

    return (
        <Animated.Text style={[style, animatedStyle]} {...props}>
            {value}
        </Animated.Text>
    );
}
