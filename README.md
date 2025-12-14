# 👨‍👩‍👧‍👦 Family Organizer

A modern, real-time web application designed to help families organize their daily lives. Simple, fast, and responsive.

## ✨ Features

- **📝 Tasks & Chores**: Assign tasks to family members, track deadlines, and mark completion.
- **🛒 Shopping List**: Shared shopping list with real-time updates. Add items and check them off as you shop.
- **🎁 Wishlist**: track family wishes and gift ideas. Mark items as "bought" to avoid duplicates.
- **🍽️ Meal Planner**: Plan dinners for the upcoming week.
- **🌳 Weekend Plans**: Collaborate on ideas for weekend activities.
- **👤 Role Switching**: Easily switch between family member profiles.
- **⚡ Real-time Sync**: All changes are instantly visible on all devices.

## 🛠️ Tech Stack

- **Frontend**: [Vue 3](https://vuejs.org/) (Composition API, Script Setup)
- **Build Tool**: [Vite](https://vitejs.dev/)
- **State Management**: [Pinia](https://pinia.vuejs.org/)
- **Routing**: [Vue Router](https://router.vuejs.org/)
- **Database & Realtime**: [Supabase](https://supabase.com/)
- **Styling**: Vanilla CSS (Custom properties, modern Layouts)

## 🚀 Getting Started

### Prerequisites

- Node.js installed
- A [Supabase](https://supabase.com/) account (free tier is sufficient)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/szymonzamachowski/family-organizer.git
    cd family-organizer
    ```

2.  **Install dependencies**
    ```bash
    npm install
    ```

3.  **Setup Environment Variables**
    Create a `.env` file in the root directory (or use `.env.example` as a template):
    ```ini
    VITE_SUPABASE_URL=your_project_url
    VITE_SUPABASE_ANON_KEY=your_anon_key
    ```

4.  **Setup Database**
    - Go to your Supabase project dashboard -> SQL Editor.
    - Copy the contents of `schema.sql` file from this repository.
    - Run the SQL query to create tables and set up Realtime policies.

5.  **Run Locally**
    ```bash
    npm run dev
    ```

## 📱 Usage

- Navigate to the local URL (usually `http://localhost:5173`).
- Select your profile/role on the welcome screen.
- Use the bottom navigation to switch between modules.
