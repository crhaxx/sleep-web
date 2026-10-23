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
| LocalStorage | Local preferences |
| Vercel | Deployment |

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
│   │   └── i18n/
│   ├── data/
│   └── types/
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
- No personal data needs to be sent to a server.
- User preferences can be saved locally.
- Users can delete their saved preferences.
- No third-party tracking is required.

## 📦 Deployment

SleepWise is designed for deployment on Vercel.

1. Push your project to GitHub.
2. Import your repository into Vercel.
3. Configure the project settings if necessary.
4. Deploy the application.

Visit [Vercel](https://vercel.com) for more information.

## 🗺️ Roadmap

- [ ] Core sleep calculator
- [ ] Personalized questionnaire
- [ ] Age-based recommendations
- [ ] Sleep results dashboard
- [ ] Weekly sleep planner
- [ ] Czech and English localization
- [ ] Light and dark themes
- [ ] Optional user accounts
- [ ] Cloud synchronization
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
