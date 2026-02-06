export type AffordItCategory = 'essential' | 'nonEssential';

export type AffordItAction = 'proceed' | 'delay24h' | 'bufferFirst' | 'swap';

export interface PlaybookCard {
    id: string;
    createdAt: number;
    label: string;
    category: AffordItCategory;
    amount: number; // cents
    chosenAction: AffordItAction;
    stressReduction: number;
    helpTags: string[];
    isPinned: boolean;
}

export interface StressPulse {
    before: number; // 0-10
    after: number; // 0-10
    helpTags: string[];
}

export interface AffordItInput {
    amount: number; // cents
    balance: number; // cents
    buffer: number; // cents
}

export interface AffordItResult {
    safeToSpend: number;
    remainingAfterPurchase: number;
    recommendedAction: AffordItAction;
    alternateActions: AffordItAction[];
    swapSuggestion: number;
}
