import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import type { StressPulse } from '../types/AffordIt';

export const HELP_TAGS = [
  'Felt less anxious',
  'Avoided impulse buy',
  'Stuck to budget',
  'Delayed gratification',
  'Made informed choice',
  'Protected savings',
] as const;

type StressPulseState = {
  currentPulse: StressPulse | null;
  setStressBefore: (value: number) => void;
  setStressAfter: (value: number) => void;
  toggleHelpTag: (tag: string) => void;
  reset: () => void;
};

const defaultPulse: StressPulse = {
  before: 5,
  after: 5,
  helpTags: [],
};

const StressPulseContext = createContext<StressPulseState | null>(null);

export function StressPulseProvider({ children }: { children: ReactNode }) {
  const [currentPulse, setCurrentPulse] = useState<StressPulse | null>(null);

  const setStressBefore = useCallback((value: number) => {
    setCurrentPulse((prev) => ({
      ...(prev ?? defaultPulse),
      before: value,
    }));
  }, []);

  const setStressAfter = useCallback((value: number) => {
    setCurrentPulse((prev) => ({
      ...(prev ?? defaultPulse),
      after: value,
    }));
  }, []);

  const toggleHelpTag = useCallback((tag: string) => {
    setCurrentPulse((prev) => {
      const current = prev ?? defaultPulse;
      const hasTag = current.helpTags.includes(tag);
      return {
        ...current,
        helpTags: hasTag
          ? current.helpTags.filter((t) => t !== tag)
          : [...current.helpTags, tag],
      };
    });
  }, []);

  const reset = useCallback(() => {
    setCurrentPulse(null);
  }, []);

  return React.createElement(
    StressPulseContext.Provider,
    { value: { currentPulse, setStressBefore, setStressAfter, toggleHelpTag, reset } },
    children
  );
}

export function useStressPulseStore(): StressPulseState {
  const context = useContext(StressPulseContext);
  if (!context) {
    return {
      currentPulse: null,
      setStressBefore: () => { },
      setStressAfter: () => { },
      toggleHelpTag: () => { },
      reset: () => { },
    };
  }
  return context;
}
