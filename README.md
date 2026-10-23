---

## 🚀 SleepWise 2.0 – Social Features

SleepWise is evolving beyond a traditional sleep calculator into a personalized sleep wellness platform with optional user accounts, cloud synchronization, and social features.

### 👤 Guest Mode vs. Registered Users

SleepWise offers two different experiences.

| Feature | Guest | Registered User |
|---|:---:|:---:|
| Sleep Calculator | ✅ | ✅ |
| Smart Questionnaire | ✅ | ✅ |
| Personalized Recommendations | ✅ | ✅ |
| Sleep Timeline | ✅ | ✅ |
| Save Sleep Plans | ❌ | ✅ |
| Sleep History | ❌ | ✅ |
| Sleep Analytics | ❌ | ✅ |
| Sleep Streaks | ❌ | ✅ |
| Sleep Friends | ❌ | ✅ |
| Social Challenges | ❌ | ✅ |
| Private Groups | ❌ | ✅ |
| Cloud Synchronization | ❌ | ✅ |

**Guest Mode:** Users can calculate their sleep schedule without registration. Calculation data is temporary and is not saved.

**Registered Mode:** Users can securely save their sleep plans, track progress, connect with friends, and synchronize data between devices.

## 👫 Sleep Friends

Connect with friends and build better sleep habits together.

Features include:

- Search for friends by username.
- Send and accept friend requests.
- Manage your friends list.
- Share selected sleep goals.
- Participate in shared challenges.
- Control what friends can see.
- Block or remove users.

Personal sleep information remains private unless explicitly shared.

## 🔗 Sleep Plan Sharing

Share your sleep schedule with others.

Supported sharing methods:

- Download a sleep plan as an image.
- Share using the device's native sharing features.
- Copy a formatted sleep plan.
- Create secure sharing links when logged in.
- Configure sharing permissions.
- Revoke previously shared links.

Shared plans may contain bedtime, wake-up time, planned sleep duration, and optional profile information.

Private sleep history and questionnaire responses are never shared automatically.

## 🔥 Sleep Streaks

Track consistency and build healthier sleep routines.

Features:

- Current sleep streak
- Longest sleep streak
- Weekly consistency
- Monthly consistency
- Achievement badges
- Personal sleep goals

Streaks are based on user-reported sleep data and are intended to encourage healthy habits rather than sleep deprivation.

## 🏆 Social Sleep Challenges

Complete sleep-related challenges with friends.

Examples:

- 7-Day Sleep Consistency Challenge
- 14-Day Sleep Journal Challenge
- Healthy Bedtime Routine Challenge
- Morning Energy Tracking Challenge
- Weekend Sleep Consistency Challenge

Users can create challenges, invite friends, track progress, and earn achievements.

Challenge participation is optional.

## 👥 Private Sleep Groups

Create private groups with friends.

Group features include:

- Create and customize groups.
- Invite members.
- Manage group membership.
- Assign group roles.
- Create group challenges.
- Track shared challenge progress.
- Leave or delete groups.

Group roles:

- Owner
- Admin
- Member

Private sleep records are not automatically accessible to group members.

## 📊 Advanced Sleep Analytics

Registered users can access detailed sleep statistics.

Available insights include:

- Daily sleep duration
- Weekly sleep averages
- Monthly sleep trends
- Bedtime consistency
- Wake-up consistency
- Morning energy tracking
- Subjective sleep quality
- Planned versus reported sleep
- Sleep streak history

Analytics are based on saved or self-reported data.

SleepWise does not claim to measure sleep stages or diagnose medical conditions.

## 🔑 Authentication and Cloud Storage

SleepWise uses Supabase for authentication and cloud-backed functionality.

Authentication features:

- Email registration
- Secure login
- Email verification
- Password recovery
- User profiles
- Persistent sessions
- Account deletion

Registered user data is stored in Supabase PostgreSQL.

Database access is protected using Row Level Security (RLS).

### Supabase Configuration

Create a project at [Supabase](https://supabase.com).

Configure the required environment variables:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

Apply the database migrations included in the repository.

Configure the authentication redirect URLs for your deployed website.

Never expose Supabase service-role keys or other privileged credentials in frontend code.

## 🌐 GitHub Pages Deployment

The static version of SleepWise is designed to be hosted using GitHub Pages.

The deployment architecture uses:

- React
- Vite
- TypeScript
- Tailwind CSS
- Supabase
- GitHub Actions
- GitHub Pages

GitHub Pages serves the frontend, while Supabase provides authentication and database services.

### Deployment Steps

1. Create a GitHub repository.
2. Push the SleepWise source code.
3. Configure the GitHub Actions deployment workflow.
4. Set the correct Vite base path.
5. Configure Supabase public environment variables.
6. Open the repository's **Settings → Pages**.
7. Select **GitHub Actions** as the deployment source.
8. Run the deployment workflow.

The website will be available at:

```text
https://YOUR_USERNAME.github.io/sleepwise/
```

The exact URL depends on the repository name and GitHub account.

For GitHub Pages compatibility, use a routing strategy that supports direct navigation and page refreshes.

**Important:** GitHub Pages does not execute server-side application code. Any privileged backend operations must run through properly secured external services such as Supabase Edge Functions.

## 🛡️ Additional Privacy and Security

SleepWise follows a privacy-first design.

Security features include:

- Private sleep records by default.
- Optional user accounts.
- Row Level Security.
- Secure authentication.
- Explicit sharing permissions.
- Revocable sharing links.
- Private groups.
- User blocking.
- Personal data export.
- Account deletion.

Guest calculations are not stored persistently.

Registered users control which information is saved or shared.

## 🧪 Testing

SleepWise includes or plans automated tests for:

- Sleep calculations
- Age-based recommendations
- Midnight transitions
- Authentication
- Saved sleep plans
- Friend requests
- Sleep streaks
- Challenges
- Group permissions
- Database access restrictions

Recommended commands:

```bash
npm run test
npm run build
```

Additional test commands depend on the scripts configured in `package.json`.

## 🗺️ SleepWise 2.0 Roadmap

- [ ] Guest and authenticated modes
- [ ] Supabase authentication
- [ ] Cloud-saved sleep plans
- [ ] Personal sleep dashboard
- [ ] Sleep journal
- [ ] Advanced sleep analytics
- [ ] Sleep streak tracking
- [ ] Sleep Friends
- [ ] Secure sleep plan sharing
- [ ] Social sleep challenges
- [ ] Private sleep groups
- [ ] User privacy controls
- [ ] Account deletion and data export
- [ ] GitHub Pages deployment
- [ ] Automated security testing

Features should be marked complete only after they are implemented and verified.

---

### 🌙 The Future of SleepWise

Our mission is simple:

**Make healthy sleep habits easier to understand, track, and maintain.**

Whether you're calculating your bedtime for the first time or building better routines with friends, SleepWise helps you make informed decisions about your sleep.

**SleepWise** 🌙

*Sleep smarter. Wake up better. Together.*
