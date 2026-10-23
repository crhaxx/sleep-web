# 🌙 SleepWise

### Wake up feeling better.

**SleepWise** is a free, modern, and personalized sleep calculator designed to help you find a suitable bedtime and wake-up schedule based on your age, lifestyle, and sleep preferences.

Sleep smarter. Wake up refreshed. Build better habits.

---

## ✨ Features

- 🧠 **Personalized Sleep Calculator** – Calculate your bedtime or wake-up time based on your preferences.
- 🎂 **Age-Based Recommendations** – Compare your sleep duration with recommended ranges for your age group.
- 📝 **Smart Questionnaire** – Get personalized suggestions based on your lifestyle, caffeine consumption, exercise, and sleep habits.
- ⏰ **Two Calculation Modes** – Calculate when to go to bed or when to wake up.
- 🌙 **Sleep Timeline** – Visualize your planned sleep schedule.
- 📅 **Weekly Sleep Planner** – Create different schedules for weekdays and weekends.
- 📊 **Sleep Insights** – Understand your sleep habits and discover ways to improve them.
- 🌍 **Multilingual Support** – Available in English and Czech.
- 📱 **Responsive Design** – Optimized for mobile, tablet, and desktop.
- 🔒 **Privacy First** – No account required. Preferences can be stored locally in your browser.
- 🎨 **Modern Interface** – Elegant dark theme, subtle animations, and intuitive navigation.

## 🚀 Getting Started

### Prerequisites

Make sure you have installed:

- Node.js (current LTS version)
- npm
- Git

### Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/sleepwise.git
```

Navigate into the project:

```bash
cd sleepwise
```

Install dependencies:

```bash
npm install
```

Start the development server:

```bash
npm run dev
```

Open **http://localhost:3000** in your browser.

## 🧮 How It Works

SleepWise calculates a suggested bedtime using three main inputs:

1. Your desired wake-up time.
2. Your preferred sleep duration.
3. Your estimated time to fall asleep.

### Bedtime Formula

```text
Bedtime = Wake-up Time - Sleep Duration - Sleep Latency
```

### Example

| Parameter | Value |
|---|---|
| Age | 18 years |
| Wake-up time | 07:00 |
| Desired sleep | 8 hours 30 minutes |
| Sleep latency | 15 minutes |
| Suggested bedtime | 22:15 |
| Estimated sleep onset | 22:30 |

SleepWise also provides age-based guidance and personalized suggestions for healthier sleep habits.

**Note:** Sleep cycles vary between individuals. SleepWise does not predict exact REM or deep sleep stages.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Next.js | Web framework |
| React | User interface |
| TypeScript | Type-safe development |
| Tailwind CSS | Styling |
| Motion | Animations |
| Lucide React | Icons |
| LocalStorage | Local preferences (anonymous use) |
| Supabase | Auth, Postgres database, and cloud sync |
| Vercel | Deployment |

## 🗄️ Backend: Supabase

SleepWise uses **Supabase only** for authentication and persisted user data. Anonymous use stays fully local; cloud features require an optional account.

### Why Supabase

- Auth + Postgres + Row Level Security in one platform
- Fits the privacy-first model (RLS so users only access their own rows)
- Works well with Next.js on Vercel
- Optional accounts and cloud sync without a custom backend

### Auth

- Email magic link and/or OAuth (e.g. Google) via Supabase Auth
- No account required for the calculator
- On sign-in, local preferences can be merged into the user’s cloud profile
- Account deletion removes related application data

### Database schema (Postgres)

```text
profiles                 — public profile linked to auth.users (1:1)
user_preferences         — locale, theme, age, sleep duration, latency, default mode
questionnaire_responses  — lifestyle answers (columns + flexible JSONB)
sleep_schedules          — weekday / weekend / custom plans
sleep_calculations       — optional history for Sleep Insights
```

| Table | Role |
|---|---|
| `profiles` | `id` = `auth.users.id`, display name, timestamps |
| `user_preferences` | 1:1 settings synced from LocalStorage when signed in |
| `questionnaire_responses` | Questionnaire answers per user |
| `sleep_schedules` | Weekly planner rows (`wake_time`, `bedtime`, `days_of_week`, …) |
| `sleep_calculations` | Stored calculation history for insights (optional) |

All application tables use **Row Level Security**: `auth.uid() = user_id` (or `id` on `profiles`). Cascading deletes keep data tied to the auth user.

### Data flow

```text
Without account  → LocalStorage only
With account     → Supabase Auth + sync to Postgres
Sign out         → Local cache may remain; cloud data unchanged
Delete account   → Auth user + related rows removed (CASCADE / policies)
```

### Environment variables

```bash
NEXT_PUBLIC_SUPABASE_URL=your_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

Never expose the service role key in the browser. Server-only operations use it only when required.

## 📁 Project Structure

```text
sleepwise/
├── public/
├── src/
│   ├── app/
│   ├── components/
│   │   ├── calculator/
│   │   └── dashboard/
│   ├── hooks/
│   ├── lib/
│   │   ├── sleep/
│   │   ├── i18n/
│   │   └── supabase/
│   ├── data/
│   └── types/
├── supabase/
│   └── migrations/
├── package.json
├── README.md
└── tsconfig.json
```

*The structure may evolve during development.*

## 🌐 Languages

SleepWise is designed to support:

- 🇬🇧 English
- 🇨🇿 Czech

Users can switch languages directly in the application.

## 🔐 Privacy

SleepWise is designed with privacy in mind.

- No registration required for basic calculations.
- Without an account, preferences stay in LocalStorage and are not sent to Supabase.
- Optional accounts sync preferences and schedules to Supabase under RLS.
- Users can delete local preferences and, when signed in, their account and cloud data.
- No third-party tracking is required.

## 📦 Deployment

SleepWise is designed for deployment on Vercel, with Supabase as the backend.

1. Push your project to GitHub.
2. Create a Supabase project and apply migrations.
3. Import your repository into Vercel.
4. Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
5. Deploy the application.

Visit [Vercel](https://vercel.com) and [Supabase](https://supabase.com) for more information.

## 🗺️ Roadmap

- [ ] Core sleep calculator
- [ ] Personalized questionnaire
- [ ] Age-based recommendations
- [ ] Sleep results dashboard
- [ ] Weekly sleep planner
- [ ] Czech and English localization
- [ ] Light and dark themes
- [ ] Optional user accounts (Supabase Auth)
- [ ] Cloud synchronization (Supabase Postgres + RLS)
- [ ] Additional sleep insights

## 🤝 Contributing

Contributions, suggestions, and bug reports are welcome.

If you would like to contribute, open an issue or submit a pull request.

## ⚕️ Medical Disclaimer

SleepWise is intended for general wellness and educational purposes only.

It does not provide medical diagnoses, detect sleep disorders, or replace professional medical advice.

Sleep recommendations are estimates and may not be suitable for everyone.

## 📄 License

A license has not yet been selected. Please contact the project owner before reusing or distributing the source code.

---

**SleepWise** 🌙

*Better nights. Better mornings.*
