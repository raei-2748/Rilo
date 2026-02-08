# Rilo Product Requirements Document
**Version:** 1.0  
**Last Updated:** February 7, 2026  
**Status:** Pre-Development  

---

## Executive Summary

### Product Vision
Rilo is a conversational payday coach that helps Australians avoid financial regret by providing clear, conservative guidance at the moments that matter. Unlike traditional budgeting apps that show dashboards and hope users interpret them correctly, Rilo actively coaches users through two complementary interaction patterns: proactive payday coaching and reactive purchase decisions.

### Core Value Proposition
"A conversational financial assistant that talks to you like a mate, knows your actual numbers, and shows up at the moments that matter."

### Market Position
Rilo differentiates from the Australian market (Frollo, WeMoney, Up Bank, CommBank) by combining:
- Conversational UI with personality instead of dashboards
- Proactive coaching instead of passive information display
- Context-aware guidance at decision moments instead of post-hoc analysis

### Success Criteria
- Primary: Users report avoiding financial regret and feeling more confident about spending decisions
- Secondary: Habitual daily engagement with both proactive and reactive features
- Tertiary: Viral sharing of the Spending Roast onboarding experience

---

## Problem Statement

### The Core Problem
Most people fail at money not because they cannot understand dashboards or budgets, but because:
1. **Decisions happen fast** in the moment of purchase
2. **Emotions win** over rational analysis
3. **Guilt arrives later** after the damage is done
4. **Existing tools are passive** showing information without judgment or guidance

### User Pain Points
- "I thought I had enough, but then overdraft fees hit"
- "I don't want to budget, I just want to know if I can afford this right now"
- "By the time I check my balance, I've already spent too much"
- "The app tells me my balance, but not whether I should actually spend it"

### Why Current Solutions Fail
**Frollo & WeMoney:** Dashboard-first, require interpretation, no personality  
**Up Bank:** Shows "Spendable Balance" but it's embedded in a full banking app, no proactive coaching  
**CommBank Bill Sense:** Timeline predictions but no conversational guidance  
**None:** Combine proactive coaching with reactive decision support in a conversational interface

---

## Target Users

### Primary User Profile
**Demographics:**
- Age: 25-40
- Income: $50K-$90K AUD
- Employment: Regular paycheck (fortnightly or monthly)
- Location: Australian urban centers

**Psychographics:**
- Self-aware about spending struggles
- Not interested in complex budgeting
- Responsive to playful, direct communication
- Mobile-first behavior
- Values convenience over comprehensive tracking

**Behavioral Patterns:**
- Paycheck-to-paycheck lifestyle (not necessarily low income)
- Impulse purchase tendencies
- Money anxiety, especially near payday
- Avoids traditional banking apps due to guilt/stress
- Willing to connect financial accounts for convenience

### User Personas

**Persona 1: "Careful Casey"**
- 28, marketing coordinator, $70K
- Gets paid fortnightly
- Knows they overspend on weekends
- Wants guidance without judgment
- Will check app before larger purchases

**Persona 2: "Optimistic Omar"**
- 34, trades worker, $85K
- Weekly pay
- Tends to think "I'll have more money soon"
- Needs reality checks on spending
- More likely to ignore warnings than Casey

---

## Product Strategy

### Strategic Insight
A finance assistant must support both interaction patterns that humans naturally use:

**Proactive Mode:** The app reaches out before the pay-cycle spiral happens  
**Reactive Mode:** The user asks at the moment of purchase and gets an instant answer

These are NOT separate products. They are two modes of the same assistant that create a habit loop:
1. Proactive messages build trust and top-of-mind awareness
2. Reactive queries convert that trust into saved money and reduced regret
3. Positive outcomes reinforce trust and increase engagement

### Competitive Differentiation

| Feature | Rilo | Up Bank | Frollo/WeMoney | CommBank |
|---------|------|---------|----------------|----------|
| Conversational UI | ✅ | ❌ | ❌ | ❌ |
| Proactive Coaching | ✅ | ❌ | ❌ | Limited |
| Reactive Decisions | ✅ | Manual | Manual | ❌ |
| Personality | ✅ | Minimal | None | Corporate |
| Multi-Bank CDR | ✅ | N/A | ✅ | N/A |
| Decision Guidance | ✅ | ❌ | ❌ | ❌ |

### Development Philosophy
- **Validation-first:** Test demand before building scale
- **Learning over polish:** Prioritize learning what resonates over perfect execution
- **Solo-founder constraints:** Build what one person can ship and maintain
- **Mobile-first:** Native mobile experience is the product

---

## Core Features

### Feature 1: Bank Connection (Foundation)
**Purpose:** Enable all other features through access to real financial data

**Technical Approach:**
- CDR Open Banking via Basiq or similar provider
- Multi-bank aggregation capability
- Real-time transaction and balance sync

**User Flow:**
1. Download app
2. Grant CDR consent
3. Select bank(s)
4. Authenticate via bank's official process
5. Confirm connection success

**Business Constraints:**
- Basiq costs: ~$0.50/user/month
- CDR compliance requirements
- Bank sync reliability impacts entire experience

**Open Questions:**
- Which CDR provider? (Basiq, Frollo, Illion)
- Single-bank vs multi-bank at launch?
- Fallback experience if sync fails?
- Re-authentication frequency?

---

### Feature 2: Spending Roast (Onboarding)
**Purpose:** Make onboarding fun, build trust, prove Rilo "gets" the user, create shareable viral content

**User Experience:**
- After bank connection, Rilo analyzes recent spending (last 30 days)
- Delivers a playful, personalized "roast" of spending patterns
- Uses humor to surface real insights
- Shareable to social media

**Example Roast Insights:**
- "You spent $47 at 7-Eleven at 2am on a Tuesday. Buddy, that's a cry for help."
- "14 Uber Eats orders in a week? Your kitchen called, it misses you."
- "You're averaging $180/week on coffee. That's not a habit, that's a relationship."

**Tone Guidelines:**
- Playful, not mean
- Self-aware, not preachy
- Specific, not generic
- Australian vernacular ("mate," "reckon," "yeah nah")

**Technical Requirements:**
- Transaction categorization
- Pattern recognition (frequency, timing, unusual amounts)
- Template system for roast generation
- Social share functionality

**Open Questions:**
- How much transaction history needed? (30 days minimum?)
- Opt-out mechanism if user finds it offensive?
- Generate once or allow re-generation?
- Should this be mandatory or skippable?
- Pre-written templates vs LLM-generated?
- How to handle users with boring spending (all groceries and rent)?

---

### Feature 3: Payday Coach (Core Proactive Experience)
**Purpose:** Prevent pay-cycle spiral by providing timely, contextual, conservative guidance

**Conceptual Model:**
The Payday Coach is the heart of Rilo. It reaches out to users at critical moments in their pay cycle with clear, conservative advice based on their actual cash flow patterns.

**When Coach Appears:**

**Moment 1: Post-Payday (Day 0-1)**
- **Trigger:** Paycheck detected
- **Message:** "Your $2,450 just hit. Based on your bills, you've got $780 safe to spend this fortnight. Don't blow it on weekend one, yeah?"
- **Goal:** Set expectations early

**Moment 2: Mid-Cycle Risk (Day 5-7)**
- **Trigger:** Spending velocity above pattern + still week+ to payday
- **Message:** "Mate, you're 60% through your safe-to-spend and only halfway to payday. Ease up or you'll be eating Mi Goreng again."
- **Goal:** Course correction before crisis

**Moment 3: Pre-Payday Danger (Day 10-13)**
- **Trigger:** Safe-to-spend running low with days remaining
- **Message:** "You've got $42 left and 3 days to payday. Lock it in. No Uber Eats. No 'just one drink.'"
- **Goal:** Lock in discipline for final stretch

**Moment 4: Near Miss (Previous Cycle Review)**
- **Trigger:** Previous cycle ended with <$20 remaining
- **Message:** "Last pay you had $8 left on payday eve. That's too close. Let's aim for $100 buffer this time."
- **Goal:** Reinforce learning from near-failures

**Moment 5: Success Celebration**
- **Trigger:** Reached payday with $100+ buffer
- **Message:** "You legend. $156 buffer going into payday. That's how it's done."
- **Goal:** Positive reinforcement

**Message Characteristics:**
- Direct, not vague ("$780 safe to spend" not "you should be careful")
- Conservative by default (better to under-promise)
- Contextual (references specific patterns)
- Actionable (clear next steps)
- Australian tone (conversational, mate-like)

**Technical Requirements:**
- Payday detection algorithm
- Bill prediction engine
- Safe-to-spend calculation
- Spending velocity tracking
- Push notification system
- In-app message history

**Open Questions:**
- What defines "payday"? (largest regular deposit? user sets it?)
- How to calculate "safe-to-spend"? (income minus predicted bills minus safety buffer?)
- What's the right safety buffer %? (10%? 15%? User configurable?)
- How aggressive should velocity warnings be?
- Notification frequency limits? (max per day/week?)
- What if user has irregular income (gig workers, contractors)?
- How to handle multiple income sources?
- Notification timing optimization? (when are users most receptive?)

---

### Feature 4: Ask Anytime (Reactive Decision Support)
**Purpose:** Provide instant, contextual answers at point-of-purchase

**User Experience:**
User opens app and asks: "Can I afford this $80 jacket?"

Rilo responds with:
- **Clear answer:** "Yeah, you're good" or "Nah, not today"
- **Context:** "You've got $340 safe until payday on Friday"
- **Reasoning:** "That jacket leaves you $260, still comfortable"

Alternative phrasing:
- "Should I buy this?"
- "Can I spend $50?"
- "Am I okay to go out tonight?"

**Response Framework:**

**Green Light (>30% safe-to-spend remaining after purchase):**
"Yeah, go for it. You've got $[amount] safe to spend and this leaves you $[amount], you're fine."

**Yellow Light (15-30% remaining):**
"You can, but it's tight. You've got $[amount] left for [X] days. If something unexpected comes up, you might be stuck."

**Red Light (<15% remaining):**
"Nah mate, not today. You've only got $[amount] for [X] days. Wait till Friday."

**Extreme Red (would go negative):**
"Hard no. This would put you negative. You're $[amount] short even before other expenses."

**Additional Context When Relevant:**
- "You've got two Uber Eats orders this week already. Maybe cook tonight?"
- "Last month you spent $200 on clothes and regretted it. Sure about this?"
- "There's a $150 bill hitting tomorrow. Keep that in mind."

**Technical Requirements:**
- Natural language understanding
- Quick calculation engine
- Purchase amount extraction
- Context injection from spending patterns
- Fast response time (<2 seconds)
- Conversation history

**Open Questions:**
- Input method: text? voice? number pad?
- Should it remember context within a conversation? ("What about $50 instead?")
- How to handle vague questions? ("Can I go shopping?")
- Should it proactively suggest alternatives? ("Rent that jacket instead?")
- Integration with specific merchants/stores?
- Photo of price tag recognition?
- What if user ignores red light repeatedly?

---

### Feature 5: Safe-to-Spend Engine (Technical Foundation)
**Purpose:** Power both Payday Coach and Ask Anytime with accurate, conservative calculations

**Core Algorithm:**

```
SAFE_TO_SPEND = 
  (Current Balance 
  + Predicted Income Until Next Payday
  - Predicted Bills Until Next Payday
  - Safety Buffer
  - Already Committed Spending)
```

**Component Breakdown:**

**Current Balance:**
- Sum across all connected accounts
- Exclude pending transactions
- Real-time sync critical

**Predicted Income:**
- Based on historical payday detection
- Regular salary/wages
- Known recurring deposits
- Does NOT include irregular income (bonuses, gifts)

**Predicted Bills:**
- Regular subscriptions (Netflix, Spotify, gym)
- Utilities (power, internet)
- Rent/mortgage
- Insurance
- Loan payments
- Based on historical patterns + upcoming scheduled dates

**Safety Buffer:**
- Configurable percentage (default 10-15%)
- Accounts for unpredictable expenses
- User can adjust in settings

**Already Committed:**
- Pending transactions
- Known upcoming expenses user logged

**Conservatism Principles:**
- When uncertain about bill timing, assume it's sooner
- When uncertain about bill amount, assume it's higher
- Better to have money left over than run short
- Under-promise, over-deliver

**Technical Requirements:**
- Transaction categorization engine
- Recurring pattern detection
- Date prediction algorithms
- Real-time recalculation
- Confidence scoring on predictions

**Open Questions:**
- How to handle first-time users with no history?
- Manual bill entry option?
- Merchant-specific categorization?
- What confidence threshold for bill predictions?
- How to learn from user corrections?
- Variable income handling?
- Should irregular income (tax refunds, bonuses) be included or excluded?

---

## User Flows

### Flow 1: First-Time User Onboarding
```
1. Download app from App Store
2. Welcome screen: "Stop screwing yourself before payday"
3. Connect bank via CDR (Basiq flow)
4. Wait for data sync (30-60 seconds)
5. Receive Spending Roast
   - Option to share to social
   - Option to skip
6. Payday setup
   - Auto-detected: "Looks like you get paid fortnightly on Thursdays?"
   - Or manual: "When do you get paid?"
7. Brief tutorial on two modes:
   - "I'll check in when you need it" (Payday Coach)
   - "Ask me anytime" (Ask Anytime)
8. Permission requests:
   - Push notifications (critical)
   - Optional: Contact access for bill detection
9. First Payday Coach message
   - "Your next payday is in 6 days. You've got $420 safe to spend until then."
10. Prompt to try Ask Anytime
    - "Try asking: Can I spend $50 tonight?"
```

**Open Questions:**
- What if CDR connection fails?
- Skip roast option placement?
- How much tutorial is too much?
- Notification permission rejection handling?

---

### Flow 2: Daily Active User
```
Morning:
- User wakes up
- Sees Payday Coach notification (if triggered)
- "3 days to payday, $180 left. You're on track, keep it tight."

Lunchtime:
- Considering buying lunch vs packing
- Opens app
- Asks: "Can I get lunch out?"
- Rilo: "Yeah, but this is your 4th time this week. You've got $160 left for 3 days. Pack it today?"

Evening:
- Friends invite to dinner
- Opens app
- Asks: "Dinner tonight, maybe $60?"
- Rilo: "Cutting it close. That leaves you $100 for the next 2.5 days. If you go, skip drinks."

Night:
- User makes it home without spending
- No notification needed (only proactive when necessary)
```

**Open Questions:**
- Max notifications per day?
- When to be silent vs speak up?
- Context carryover between sessions?

---

### Flow 3: Pay Cycle Journey (Fortnightly Example)

**Day 0 (Payday Thursday):**
- 8am: Paycheck lands ($2,450)
- 8:05am: Payday Coach notification
  - "Your $2,450 just hit. Bills take $1,550, safety buffer $120. You've got $780 safe to spend this fortnight."

**Day 2 (Saturday):**
- User spends $200 on weekend (drinks, Uber, breakfast)
- No notification (within normal patterns)

**Day 5 (Tuesday):**
- User has spent $480 (61% of safe-to-spend)
- Mid-cycle check triggers
- 7pm notification: "Mate, you're 61% through your $780 and only a third through the fortnight. Pace yourself."

**Day 8 (Friday):**
- User asks: "Drinks tonight?"
- Rilo: "You've got $160 left for 6 days. If you go out, make it a cheap one. You're trending tight."

**Day 11 (Monday):**
- User down to $85 remaining
- 6pm notification: "3 days to payday, $85 left. Lock it in. Groceries at home, no takeaway."

**Day 13 (Wednesday):**
- Payday eve, $42 remaining
- 8pm: "One more sleep. $42 buffer. You made it, nice work."

**Day 14 (Thursday - Payday):**
- Cycle completes
- 8am: New payday lands
- Rilo: "Back to $780 safe. Last cycle you finished with $42, bit too close. Let's aim for $100+ this time."

**Open Questions:**
- Should weekly cycles have different triggers?
- Monthly pay = more/fewer interventions?
- How to handle bonus/irregular pay events?

---

## Technical Architecture

### Tech Stack

**Mobile App:**
- Framework: React Native (Expo)
- Language: TypeScript
- State Management: TBD (Zustand? Redux?)
- Navigation: React Navigation
- UI Components: TBD (custom? React Native Paper?)

**Backend:**
- API: Node.js + Express OR Python + FastAPI
- Database: PostgreSQL (structured financial data) + Redis (caching)
- Hosting: TBD (Railway? Render? AWS?)

**Integrations:**
- CDR Provider: Basiq OR Illion OR Frollo API
- Push Notifications: Expo Push Notifications OR Firebase Cloud Messaging
- Analytics: TBD (Mixpanel? PostHog?)

**Development Tools:**
- Version Control: Git + GitHub
- CI/CD: GitHub Actions
- Testing: Jest + React Native Testing Library
- Monitoring: TBD

**Open Questions:**
- Expo managed vs bare workflow?
- Monorepo or separate repos (app + backend)?
- Which CDR provider best balances cost/reliability/features?
- Where to host backend for Australian latency?
- Authentication approach? (email? phone? Apple/Google?)

---

### Data Architecture

**User Profile:**
```
{
  userId: string
  email: string
  phone?: string
  createdAt: timestamp
  onboardingComplete: boolean
  paydaySchedule: {
    frequency: 'weekly' | 'fortnightly' | 'monthly'
    dayOfWeek?: number // for weekly/fortnightly
    dayOfMonth?: number // for monthly
    nextPayday: date
    lastPayday: date
  }
  preferences: {
    safetyBufferPercent: number // default 10-15
    notificationSettings: {
      paydayCoach: boolean
      dailyDigest: boolean
      quietHours: { start: time, end: time }
    }
  }
}
```

**Connected Accounts:**
```
{
  accountId: string
  userId: string
  bankId: string
  accountNumber: string (encrypted)
  accountType: 'checking' | 'savings' | 'credit'
  currentBalance: number
  availableBalance: number
  lastSyncedAt: timestamp
  connectionStatus: 'active' | 'requires_reauth' | 'error'
}
```

**Transactions:**
```
{
  transactionId: string
  accountId: string
  userId: string
  amount: number
  date: date
  description: string
  merchantName?: string
  category: string
  isRecurring: boolean
  recurringGroupId?: string
  isPredictedBill: boolean
}
```

**Predicted Bills:**
```
{
  billId: string
  userId: string
  name: string
  amount: number
  nextDueDate: date
  frequency: 'weekly' | 'fortnightly' | 'monthly' | 'quarterly' | 'annual'
  confidence: number // 0-1
  basedOnTransactionId: string
  userConfirmed: boolean
}
```

**Safe-to-Spend Snapshot:**
```
{
  snapshotId: string
  userId: string
  calculatedAt: timestamp
  safeToSpend: number
  breakdown: {
    currentBalance: number
    predictedIncome: number
    predictedBills: number
    safetyBuffer: number
    committedSpending: number
  }
  confidence: number
}
```

**Payday Coach Messages:**
```
{
  messageId: string
  userId: string
  sentAt: timestamp
  messageType: 'post_payday' | 'mid_cycle_risk' | 'pre_payday_danger' | 'celebration' | 'near_miss'
  messageText: string
  userOpened: boolean
  userEngaged: boolean
}
```

**Ask Anytime Conversations:**
```
{
  conversationId: string
  userId: string
  messages: [
    {
      role: 'user' | 'assistant'
      text: string
      timestamp: timestamp
    }
  ]
  purchaseAmount?: number
  recommendation: 'green' | 'yellow' | 'red' | 'extreme_red'
  safeToSpendAtTime: number
}
```

**Open Questions:**
- Should we store raw transactions or just aggregated insights?
- How long to retain transaction history?
- Where does LLM context/prompts get stored?
- How to handle data deletion requests (CDR compliance)?

---

### External Dependencies

**CDR Open Banking Provider:**
- **Options:** Basiq, Illion, Frollo
- **Cost:** ~$0.50-$1.00 per user per month
- **Critical for:** All bank data access
- **Risk:** Sync failures, bank compatibility, cost scaling

**Push Notification Service:**
- **Options:** Expo Push, Firebase Cloud Messaging
- **Cost:** Free tier likely sufficient initially
- **Critical for:** Payday Coach proactive messages
- **Risk:** Delivery reliability, iOS/Android differences

**LLM Provider (for Ask Anytime):**
- **Options:** OpenAI, Anthropic, local model
- **Cost:** Varies by usage (~$0.01-0.05 per conversation)
- **Critical for:** Natural language understanding and response generation
- **Risk:** Cost at scale, response quality, latency

**Transaction Categorization:**
- **Options:** Build custom, use CDR provider's categories, third-party (Plaid Enrichment)
- **Cost:** Varies
- **Critical for:** Bill detection, pattern recognition
- **Risk:** Accuracy impacts all features

**Open Questions:**
- Build vs buy for categorization?
- Which LLM provider for Ask Anytime?
- Fallback plans if dependencies fail?
- How to negotiate better rates as we scale?

---

### Security & Privacy

**CDR Compliance Requirements:**
- Must meet Australian CDR standards
- Data handling rules
- User consent management
- Audit trail requirements
- Data deletion on request

**Data Protection:**
- End-to-end encryption for financial data at rest
- TLS for data in transit
- Minimal data retention
- No selling user data (ever)

**Authentication:**
- Multi-factor authentication
- Biometric unlock (Face ID, fingerprint)
- Session management
- Secure token handling

**Open Questions:**
- Do we need SOC 2 compliance?
- How to handle password reset securely?
- What PII do we absolutely need vs nice-to-have?
- Third-party security audit budget/timeline?

---

## User Interface & Experience

### Design Principles
1. **Conversational over Transactional:** Every interaction should feel like talking to a friend, not using software
2. **Clear over Clever:** Direct language beats fancy visualizations
3. **Fast over Comprehensive:** Quick answers matter more than detailed breakdowns
4. **Mobile-native:** Designed for thumb-scrolling and quick glances
5. **Personality over Corporate:** Australian, direct, playful tone throughout

### Key Screens

**Home Screen:**
- Big number: Current safe-to-spend amount
- Days until payday
- Quick access to "Ask Anytime" input
- Recent Payday Coach messages
- NOT a dashboard, NOT charts

**Ask Anytime Screen:**
- Input field: "Can I spend $50?"
- Conversation history
- Quick suggestion chips ("Can I afford lunch?" "Should I buy this?")
- Response card with clear yes/no and reasoning

**Payday Coach History:**
- Timeline of past messages
- Visual indicators of cycle milestones
- Optional: Past cycle review stats

**Settings:**
- Connected banks management
- Notification preferences
- Safety buffer adjustment
- Payday schedule
- About/Help

**Onboarding Flows:**
- Bank connection
- Spending Roast display
- Payday setup
- Tutorial

### Tone & Voice Guidelines

**Personality Traits:**
- **Mate-like:** Talks like a supportive friend, not a financial advisor
- **Direct:** No beating around the bush, says it straight
- **Australian:** Uses Aussie vernacular naturally
- **Playful:** Humor without being annoying
- **Conservative:** Financially cautious, not YOLO

**Voice Examples:**

*Too Corporate:* "Based on your spending patterns and upcoming financial obligations, we recommend exercising caution with discretionary purchases at this time."

*Too Casual:* "lol ur broke mate 😂"

*Just Right:* "Nah mate, not today. You've got $65 left for 3 days and bills hitting tomorrow. Wait till payday."

**Vocabulary:**
- Use: mate, reckon, yeah nah, fair dinkum, too easy, no worries
- Avoid: definitely, absolutely, leverage, optimize, curated

**Open Questions:**
- How much personality is too much?
- Should tone adapt based on user preferences?
- Regional dialect variations (Melbourne vs Sydney)?
- Formal fallback option for users who don't want personality?

---

## Monetization Strategy

### Pricing Model (To Be Validated)

**Potential Approach: Freemium**
- **Free Tier:** Single-bank connection, basic Payday Coach, limited Ask Anytime queries
- **Paid Tier:** $4.99-$7.99/month for multi-bank, unlimited queries, advanced features

**Alternative: Paid-First**
- **$7.99/month:** All features from day one
- **Rationale:** CDR costs + LLM costs make free unsustainable at scale
- **Inspired by:** PocketSmith's paid model

**Open Questions:**
- Can freemium work given $0.50/user CDR costs?
- What's the willingness-to-pay for this category?
- Should we do a free trial period?
- Annual plan discount?

### Unit Economics (Preliminary)

**Costs per User per Month:**
- CDR provider (Basiq): $0.50-$1.00
- LLM API calls: ~$0.20-$1.00 (depends on usage)
- Infrastructure: ~$0.10-$0.30
- Total: ~$0.80-$2.30 per user per month

**Revenue per User:**
- If $7.99/month: $5.69-$7.19 net margin per user
- If $4.99/month: $2.69-$4.19 net margin per user (tighter)

**Break-even:**
- Need minimum ~$2.30/user/month to cover costs
- Freemium challenging unless conversion rates high (>10%)

**Open Questions:**
- What's realistic conversion rate for this category?
- Can we negotiate better CDR rates at volume?
- Should we optimize for lower LLM costs (self-hosted model)?
- What revenue target validates this business?

---

## Success Metrics

### North Star Metric
**"Users who avoid financial regret because of Rilo"**

Measured by:
- Survey question after each pay cycle: "Did Rilo help you avoid a spending decision you would have regretted?"
- Proxy metrics: Users who finish pay cycles with planned buffer intact

### Product Metrics

**Engagement:**
- DAU/MAU ratio
- Ask Anytime queries per user per week
- Payday Coach message open rate
- Average session duration
- Retention (D7, D30, D90)

**Feature Adoption:**
- % users who use Ask Anytime at least once per week
- % users who read Payday Coach messages
- % users who share Spending Roast

**Financial Impact:**
- Average safe-to-spend buffer at payday
- Trend: Are users improving over time?
- Reported financial stress reduction (survey)

**Business Metrics:**
- MRR (Monthly Recurring Revenue)
- Churn rate
- CAC (Customer Acquisition Cost)
- LTV (Lifetime Value)
- LTV:CAC ratio

**Open Questions:**
- What retention rate is "good" for this category?
- How to measure "regret avoided" objectively?
- What engagement level indicates product-market fit?

---

## Risks & Mitigation

### Technical Risks

**Risk: CDR sync failures**
- Impact: Critical, entire product breaks
- Mitigation: Choose reliable provider, implement robust error handling, fallback manual entry
- Monitoring: Sync success rate, latency, downtime alerts

**Risk: Inaccurate bill predictions**
- Impact: High, erodes trust if Safe-to-Spend is wrong
- Mitigation: Conservative defaults, user correction feedback loop, confidence thresholds
- Monitoring: User correction rate, prediction accuracy metrics

**Risk: LLM response quality**
- Impact: Medium-High, bad answers damage trust
- Mitigation: Guardrails, prompt engineering, human-in-loop review initially
- Monitoring: User satisfaction ratings, response review

### Business Risks

**Risk: Up Bank competitive threat**
- Impact: High, they have similar feature for free with 500K users
- Mitigation: Differentiate on personality + proactive coaching, target multi-bank users
- Validation: Test if users value conversational coaching over free number

**Risk: Insufficient willingness-to-pay**
- Impact: Critical, can't sustain if users won't pay
- Mitigation: Validate pricing before full build, test with fake-door landing page
- Kill criteria: <3% conversion on landing page test

**Risk: CDR costs exceed revenue**
- Impact: Critical, unit economics negative
- Mitigation: Paid-first model, monitor COGS closely, negotiate rates
- Kill criteria: LTV:CAC ratio <3:1 after 6 months

### Product Risks

**Risk: Users ignore Payday Coach messages**
- Impact: High, defeats core value prop
- Mitigation: Optimize timing/frequency, A/B test messaging, make messages valuable
- Monitoring: Open rates, engagement rates

**Risk: Ask Anytime not fast enough**
- Impact: Medium, defeats "in the moment" use case
- Mitigation: Optimize response time, cache calculations, fast LLM provider
- Target: <2 second response time

**Risk: Privacy concerns from bank access**
- Impact: Medium-High, blocks adoption
- Mitigation: Clear communication, CDR compliance, transparent data practices
- Monitoring: Conversion rate at bank connection step

---

## Development Roadmap

### Phase 1: Foundation (Weeks 1-4)
**Goal:** Core infrastructure + basic Safe-to-Spend calculation

**Deliverables:**
- Backend setup (database, API structure)
- CDR integration (Basiq connection working)
- Basic React Native app shell
- User authentication
- Simple Safe-to-Spend calculation (manual bill entry)

**Success Criteria:**
- Can connect bank and pull transactions
- Can calculate a conservative safe-to-spend number

---

### Phase 2: MVP (Weeks 5-10)
**Goal:** Minimal viable product with core flows working

**Deliverables:**
- Spending Roast onboarding
- Basic Payday Coach (manual triggers initially)
- Simple Ask Anytime (text input, basic responses)
- Push notifications working
- Bill prediction v1

**Success Criteria:**
- 10 beta users can complete onboarding
- Users receive at least one useful Payday Coach message
- Users can ask and get answers to spending questions

---

### Phase 3: Refinement (Weeks 11-16)
**Goal:** Improve accuracy, UX, and engagement

**Deliverables:**
- Automated Payday Coach triggers
- Improved bill prediction accuracy
- Better Ask Anytime responses (LLM integration)
- Notification optimization
- Analytics implementation

**Success Criteria:**
- 50+ active users
- D7 retention >40%
- Payday Coach message open rate >60%
- Ask Anytime queries averaging 2+ per user per week

---

### Phase 4: Scale Prep (Weeks 17-20)
**Goal:** Polish for broader launch

**Deliverables:**
- Waitlist page + landing site
- App Store submission
- Monetization implementation
- Referral/sharing features
- Customer support system

**Success Criteria:**
- App approved on App Store
- Waitlist at 200+ signups
- Billing system functional
- Ready for public launch

---

### Launch (Week 21+)
**Goal:** Acquire first 1,000 users, validate product-market fit

**Activities:**
- Public launch
- Content marketing (Reddit, Twitter)
- Direct outreach
- Measure retention, engagement, WTP

**Kill/Pivot Criteria:**
- If D30 retention <20%: Significant product problem
- If conversion to paid <5%: Pricing or value problem
- If LTV:CAC <2:1: Business model problem

---

## Open Questions for Development

### Critical Technical Questions
1. Which CDR provider offers best balance of cost/reliability/features?
2. Should we build custom transaction categorization or use provider's?
3. What's the minimum viable bill prediction accuracy?
4. How to handle users with irregular income (gig workers)?
5. Self-host LLM or use API (OpenAI/Anthropic)?
6. Expo managed workflow or bare?
7. Monorepo or separate app/backend repos?

### Critical Product Questions
8. Is Spending Roast required onboarding or optional?
9. How aggressive should Payday Coach warnings be?
10. Max notifications per day before it's annoying?
11. Should Ask Anytime remember conversation context?
12. What's the fallback if CDR sync fails?
13. Should we allow manual bank entry (no CDR)?
14. How to handle first-time users with zero transaction history?

### Critical Business Questions
15. Freemium or paid-first pricing?
16. What price point? ($4.99? $7.99? $9.99?)
17. Free trial duration if any?
18. What's minimum viable retention rate to continue?
19. What's target LTV:CAC ratio?
20. Should we white-label for banks instead of B2C?

### User Experience Questions
21. How much personality is too much?
22. Should tone adapt to user preferences?
23. Option to turn off personality for formal tone?
24. How to handle users who don't have regular income?
25. What if user ignores all warnings and goes negative anyway?

---

## Appendix A: Competitive Analysis

### Up Bank
**Strengths:**
- 500K+ users
- Free "Spendable Balance" feature (similar to safe-to-spend)
- Polished app
- Strong brand with young Australians

**Weaknesses:**
- No proactive coaching
- No conversational interface
- Embedded in full banking app (not focused tool)
- Single-bank only

**Our Differentiation:**
- Personality + coaching vs passive number
- Multi-bank aggregation
- Proactive + reactive modes
- Focused tool vs feature in bank

---

### Frollo / WeMoney
**Strengths:**
- Multi-bank CDR aggregation
- Dashboard analytics
- Subscription tracking

**Weaknesses:**
- Dashboard-first, not conversational
- No personality
- No proactive coaching
- Passive information, no guidance

**Our Differentiation:**
- Conversational coaching vs dashboards
- Moment-of-decision guidance
- Personality

---

### CommBank Bill Sense
**Strengths:**
- Bill prediction timeline
- Built into major bank app
- Large user base

**Weaknesses:**
- No conversational interface
- Corporate tone
- Single-bank only
- Timeline view, not actionable guidance

**Our Differentiation:**
- Proactive coaching messages
- Ask Anytime decision support
- Personality

---

### Cleo (UK/US, not in Australia)
**Strengths:**
- Conversational AI assistant ($250M ARR)
- Personality-driven
- Viral roast feature
- Chat interface

**Weaknesses:**
- Not available in Australia
- Complex product (cash advances, savings, credit)
- Large team (100+ people)

**Our Differentiation:**
- Simpler focus (just payday coaching)
- Australian market
- CDR advantage (better data access)

**Inspiration from Cleo:**
- Spending Roast for acquisition/onboarding
- Conversational interface pattern
- Personality-first approach

---

## Appendix B: User Research Insights

*(To be populated after interviews/testing)*

**Hypothesis to validate:**
1. Users want guidance at decision moments, not just data
2. Users respond well to direct, playful Australian tone
3. Users will pay $7.99/month for this value
4. Proactive coaching creates habit formation
5. Reactive queries convert hesitation into saved money

---

## Appendix C: Australian Market Context

**CDR Open Banking:**
- Live since 2020
- Enables secure bank data sharing
- User controls consent
- Banks must comply
- Enables multi-bank aggregation

**Target Market Size:**
- Australia population: ~26M
- Working adults 25-40: ~5M
- Financially stressed: ~30-40% = 1.5-2M addressable

**Payment Patterns:**
- Weekly pay: ~20% of workers
- Fortnightly: ~45%
- Monthly: ~35%

**Cultural Context:**
- Direct communication valued
- "Tall poppy" syndrome (humble, not flashy)
- Casual language acceptable in business
- Trust in financial institutions moderate

---

## Appendix D: Voice & Tone Examples

### Payday Coach Messages

**Scenario: Post-Payday**
❌ Bad: "Your salary has been deposited. After accounting for scheduled bills, your discretionary spending allowance is $780."
✅ Good: "Your $2,450 just hit. Bills take $1,550. You've got $780 safe to spend this fortnight. Don't blow it on weekend one."

**Scenario: Mid-Cycle Warning**
❌ Bad: "Your current spending velocity is 22% above your average. Consider moderating expenditures."
✅ Good: "Mate, you're 60% through your safe-to-spend and only halfway to payday. Ease up or you'll be eating Mi Goreng again."

**Scenario: Success**
❌ Bad: "Congratulations, you've maintained a positive buffer."
✅ Good: "You legend. $156 buffer going into payday. That's how it's done."

### Ask Anytime Responses

**Green Light:**
❌ Bad: "This purchase is within acceptable parameters."
✅ Good: "Yeah, go for it. You've got $340 safe and this leaves you $260. You're fine."

**Yellow Light:**
❌ Bad: "This purchase may result in reduced financial flexibility."
✅ Good: "You can, but it's tight. $85 left for 3 days after this. If something unexpected comes up, you might be stuck."

**Red Light:**
❌ Bad: "This purchase is not recommended given current balance projections."
✅ Good: "Nah mate, not today. You've only got $65 for 4 days. Wait till Friday."

---

## Document Control

**Changes:**
- v1.0 (Feb 7, 2026): Initial comprehensive PRD

**Next Reviews:**
- After initial user research
- After technical spike on CDR providers
- After pricing validation testing

**Document Owner:** Ray (Founder)

**Stakeholders:** Development team (to be built)

---

*This is a living document. All sections marked with "Open Questions" require validation before final implementation decisions.*