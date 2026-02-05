import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

export type ReceiptMode = 'roast' | 'therapist';

type SettingsState = {
  receiptMode: ReceiptMode;
  reminderHour: number;
  reminderMinute: number;
  anonymizeDefault: boolean;
  setReceiptMode: (mode: ReceiptMode) => void;
  setReminderTime: (hour: number, minute: number) => void;
  setAnonymizeDefault: (value: boolean) => void;
};

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      receiptMode: 'roast',
      reminderHour: 19,
      reminderMinute: 30,
      anonymizeDefault: false,
      setReceiptMode: (mode) => set({ receiptMode: mode }),
      setReminderTime: (hour, minute) => set({ reminderHour: hour, reminderMinute: minute }),
      setAnonymizeDefault: (value) => set({ anonymizeDefault: value }),
    }),
    {
      name: 'rilo.settings',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
