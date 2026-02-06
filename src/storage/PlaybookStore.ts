import React, { createContext, useContext, useState, useCallback, ReactNode, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { PlaybookCard } from '../types/AffordIt';

const STORAGE_KEY = '@rilo_playbook_cards';

type PlaybookState = {
    cards: PlaybookCard[];
    addCard: (card: PlaybookCard) => void;
    togglePin: (cardId: string) => void;
    deleteCard: (cardId: string) => void;
    isHydrated: boolean;
};

const PlaybookContext = createContext<PlaybookState | null>(null);

export function PlaybookProvider({ children }: { children: ReactNode }) {
    const [cards, setCards] = useState<PlaybookCard[]>([]);
    const [isHydrated, setIsHydrated] = useState(false);

    // Load cards from storage on mount
    useEffect(() => {
        async function loadCards() {
            try {
                const storedCards = await AsyncStorage.getItem(STORAGE_KEY);
                if (storedCards) {
                    setCards(JSON.parse(storedCards));
                }
            } catch (e) {
                console.error('Failed to load playbook cards', e);
            } finally {
                setIsHydrated(true);
            }
        }
        loadCards();
    }, []);

    // Save cards to storage whenever they change
    useEffect(() => {
        if (isHydrated) {
            AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(cards)).catch((e) => {
                console.error('Failed to save playbook cards', e);
            });
        }
    }, [cards, isHydrated]);

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
        { value: { cards, addCard, togglePin, deleteCard, isHydrated } },
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
            isHydrated: false,
        };
    }
    return context;
}
