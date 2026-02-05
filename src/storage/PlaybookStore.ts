import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import type { PlaybookCard } from '../types/AffordIt';

type PlaybookState = {
  cards: PlaybookCard[];
  addCard: (card: PlaybookCard) => void;
  togglePin: (cardId: string) => void;
  deleteCard: (cardId: string) => void;
};

const PlaybookContext = createContext<PlaybookState | null>(null);

export function PlaybookProvider({ children }: { children: ReactNode }) {
  const [cards, setCards] = useState<PlaybookCard[]>([]);

  const addCard = useCallback((card: PlaybookCard) => {
    setCards((prev) => [card, ...prev]);
  }, []);

  const togglePin = useCallback((cardId: string) => {
    setCards((prev) => {
      const pinnedCount = prev.filter((c) => c.isPinned).length;
      return prev.map((card) => {
        if (card.id !== cardId) return card;
        if (card.isPinned || pinnedCount < 3) {
          return { ...card, isPinned: !card.isPinned };
        }
        return card;
      });
    });
  }, []);

  const deleteCard = useCallback((cardId: string) => {
    setCards((prev) => prev.filter((card) => card.id !== cardId));
  }, []);

  return React.createElement(
    PlaybookContext.Provider,
    { value: { cards, addCard, togglePin, deleteCard } },
    children
  );
}

export function usePlaybookStore(): PlaybookState {
  const context = useContext(PlaybookContext);
  if (!context) {
    return {
      cards: [],
      addCard: () => { },
      togglePin: () => { },
      deleteCard: () => { },
    };
  }
  return context;
}
