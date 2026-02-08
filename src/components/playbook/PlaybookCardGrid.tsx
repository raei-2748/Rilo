import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import Animated, { Layout } from 'react-native-reanimated';
import { PlaybookCard, CardSize } from './PlaybookCard';
import type { PlaybookCard as PlaybookCardType } from '../../types/AffordIt';

interface PlaybookCardGridProps {
    cards: PlaybookCardType[];
    onTogglePin: (id: string) => void;
}

interface RowItem {
    card: PlaybookCardType;
    size: CardSize;
}

type Row = RowItem[];

function determineCardSize(card: PlaybookCardType): CardSize {
    // Pinned cards always get full width
    if (card.isPinned) return 'full';
    // High-value decisions ($200+) get full width
    if (card.amount >= 20000) return 'full';
    // Medium decisions ($50-199) can be half width
    if (card.amount >= 5000) return 'half';
    // Small decisions (<$50) can be third width
    return 'third';
}

function organizeIntoRows(cards: PlaybookCardType[]): Row[] {
    const rows: Row[] = [];
    let currentRow: Row = [];
    let currentRowWeight = 0; // full=6, half=3, third=2

    const sizeWeight = { full: 6, half: 3, third: 2 };

    for (const card of cards) {
        const size = determineCardSize(card);
        const weight = sizeWeight[size];

        // Full-width cards always get their own row
        if (size === 'full') {
            // Flush current row first
            if (currentRow.length > 0) {
                rows.push(currentRow);
                currentRow = [];
                currentRowWeight = 0;
            }
            rows.push([{ card, size }]);
            continue;
        }

        // Can this card fit in the current row?
        if (currentRowWeight + weight <= 6) {
            currentRow.push({ card, size });
            currentRowWeight += weight;
        } else {
            // Start a new row
            if (currentRow.length > 0) {
                rows.push(currentRow);
            }
            currentRow = [{ card, size }];
            currentRowWeight = weight;
        }
    }

    // Don't forget the last row
    if (currentRow.length > 0) {
        rows.push(currentRow);
    }

    return rows;
}

export function PlaybookCardGrid({ cards, onTogglePin }: PlaybookCardGridProps) {
    const rows = organizeIntoRows(cards);
    let globalIndex = 0;

    return (
        <ScrollView
            contentContainerStyle={styles.container}
            showsVerticalScrollIndicator={false}
        >
            {rows.map((row, rowIndex) => (
                <Animated.View
                    key={`row-${rowIndex}`}
                    layout={Layout.springify().damping(20)}
                    style={styles.row}
                >
                    {row.map((item) => {
                        const index = globalIndex++;
                        return (
                            <PlaybookCard
                                key={item.card.id}
                                card={item.card}
                                size={item.size}
                                onTogglePin={() => onTogglePin(item.card.id)}
                                index={index}
                            />
                        );
                    })}
                </Animated.View>
            ))}
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        paddingHorizontal: 24,
        paddingBottom: 100,
    },
    row: {
        flexDirection: 'row',
        gap: 12,
        marginBottom: 12,
    },
});
