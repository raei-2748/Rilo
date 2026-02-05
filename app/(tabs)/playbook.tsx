import React from 'react';
import { View, Text, FlatList, Pressable, StyleSheet } from 'react-native';
import { colors } from '../../src/theme/colors';
import { usePlaybookStore } from '../../src/storage/PlaybookStore';
import { formatCentsToDollars } from '../../src/core/Money';
import type { PlaybookCard } from '../../src/types/AffordIt';

function PlaybookCardItem({
  card,
  onTogglePin,
}: {
  card: PlaybookCard;
  onTogglePin: () => void;
}) {
  const actionLabel = formatActionLabel(card.chosenAction);

  return (
    <View style={[styles.card, card.isPinned && styles.cardPinned]}>
      <View style={styles.cardHeader}>
        <Text style={styles.cardLabel} numberOfLines={1}>
          {card.label}
        </Text>
        <Pressable onPress={onTogglePin} hitSlop={8}>
          <Text style={styles.pinIcon}>{card.isPinned ? '★' : '☆'}</Text>
        </Pressable>
      </View>

      <Text style={styles.cardAmount}>{formatCentsToDollars(card.amount)}</Text>
      <Text style={styles.cardAction}>Action: {actionLabel}</Text>

      {card.stressReduction > 0 && (
        <Text style={styles.stressReduction}>
          Stress reduced by {card.stressReduction} points
        </Text>
      )}

      {card.helpTags.length > 0 && (
        <View style={styles.tagsContainer}>
          {card.helpTags.map((tag) => (
            <View key={tag} style={styles.tag}>
              <Text style={styles.tagText}>{tag}</Text>
            </View>
          ))}
        </View>
      )}
    </View>
  );
}

function formatActionLabel(action: string): string {
  switch (action) {
    case 'proceed':
      return 'Proceed';
    case 'delay24h':
      return 'Delay 24 Hours';
    case 'bufferFirst':
      return 'Build Buffer First';
    case 'swap':
      return 'Swap for Less';
    default:
      return action;
  }
}

export default function PlaybookScreen() {
  const { cards, togglePin } = usePlaybookStore();

  // Sort: pinned first, then by createdAt descending
  const sortedCards = [...cards].sort((a, b) => {
    if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
    return b.createdAt - a.createdAt;
  });

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Playbook</Text>
      <Text style={styles.subheader}>Your decision patterns</Text>

      {sortedCards.length === 0 ? (
        <View style={styles.emptyState}>
          <Text style={styles.emptyText}>No cards yet</Text>
          <Text style={styles.emptySubtext}>
            Complete an "Afford It?" decision to save a card
          </Text>
        </View>
      ) : (
        <FlatList
          data={sortedCards}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <PlaybookCardItem
              card={item}
              onTogglePin={() => togglePin(item.id)}
            />
          )}
          contentContainerStyle={styles.list}
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
    fontSize: 28,
    fontWeight: '600',
    color: colors.text,
    paddingHorizontal: 24,
  },
  subheader: {
    fontSize: 14,
    color: colors.secondary,
    paddingHorizontal: 24,
    marginBottom: 20,
  },
  list: {
    paddingHorizontal: 24,
    paddingBottom: 24,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: colors.border,
  },
  cardPinned: {
    borderColor: colors.accent,
    borderWidth: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  cardLabel: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.text,
    flex: 1,
  },
  pinIcon: {
    fontSize: 20,
    color: colors.accent,
  },
  cardAmount: {
    fontSize: 24,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 4,
  },
  cardAction: {
    fontSize: 14,
    color: colors.secondary,
    marginBottom: 8,
  },
  stressReduction: {
    fontSize: 12,
    color: colors.success,
    marginBottom: 8,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
  },
  tag: {
    backgroundColor: colors.surfaceAlt,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  tagText: {
    fontSize: 11,
    color: colors.tertiary,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '500',
    color: colors.secondary,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: colors.tertiary,
    textAlign: 'center',
  },
});
