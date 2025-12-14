<script setup>
import { useRouter, useRoute } from 'vue-router'
import { computed } from 'vue'

const router = useRouter()
const route = useRoute()

// Simple icons as text or emojis for MVP, can be replaced with proper icons later
const navItems = [
  { name: 'tasks', label: 'Zadania', icon: '📝' },
  { name: 'shopping', label: 'Zakupy', icon: '🛒' },
  { name: 'wishlist', label: 'Życzenia', icon: '🎁' },
  { name: 'meals', label: 'Obiady', icon: '🍽️' },
  { name: 'weekend', label: 'Weekend', icon: '🌳' },
  { name: 'profile', label: 'Profil', icon: '👤' },
]

const isActive = (name) => route.name === name
</script>

<template>
  <nav class="bottom-nav">
    <router-link 
      v-for="item in navItems" 
      :key="item.name"
      :to="{ name: item.name }"
      class="nav-item"
      :class="{ 'active': isActive(item.name) }"
    >
      <span class="nav-icon">{{ item.icon }}</span>
      <span class="nav-label">{{ item.label }}</span>
    </router-link>
  </nav>
</template>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: var(--color-surface);
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-around;
  align-items: center;
  z-index: 100;
  padding-bottom: env(safe-area-inset-bottom);
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: var(--color-text-muted);
  font-size: 0.75rem;
  flex: 1;
  height: 100%;
}

.nav-icon {
  font-size: 1.5rem;
  margin-bottom: 2px;
}

.nav-item.active {
  color: var(--color-primary);
}

.nav-item.active .nav-icon {
  transform: scale(1.1);
}
</style>
