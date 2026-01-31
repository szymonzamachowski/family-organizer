<script setup>
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const isActive = (path) => route.path.startsWith(path)

const navItems = [
  { name: 'Obowiązki', path: '/tasks', icon: '📝' },
  { name: 'Zakupy', path: '/shopping', icon: '🛒' },
  { name: 'Obiady', path: '/meals', icon: '🍽️' },
  // { name: 'Weekend', path: '/weekend', icon: '🌴' }, // Optional, can add back if needed
]
</script>

<template>
  <nav class="bottom-nav">
    <div class="nav-content">
      <router-link 
        v-for="item in navItems" 
        :key="item.path" 
        :to="item.path"
        class="nav-item"
        :class="{ active: isActive(item.path) }"
      >
        <div class="icon-container">
          <span class="icon">{{ item.icon }}</span>
        </div>
        <span class="label">{{ item.name }}</span>
      </router-link>
    </div>
  </nav>
</template>

<style scoped>
.bottom-nav {
  /* Positioned in flow now */
  width: 90%;
  max-width: 500px;
  background: var(--color-surface-translucent);
  /* Glassmorphism */
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: var(--radius-xl);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.5);
  z-index: 100;
  padding: 0.5rem;
  margin: 1rem auto 1.5rem auto;
  flex-shrink: 0;
  /* Prevent shrinking */
}

.nav-content {
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-decoration: none;
  color: var(--color-text-muted);
  font-size: 0.75rem;
  font-weight: 500;
  padding: 0.5rem;
  border-radius: var(--radius-lg);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  flex: 1;
}

.nav-item .icon-container {
  font-size: 1.5rem;
  margin-bottom: 2px;
  transition: transform 0.2s;
}

.nav-item.active {
  color: var(--color-primary);
  background: rgba(79, 70, 229, 0.05); /* Slight tint */
}

.nav-item.active .icon-container {
  transform: translateY(-2px);
}

.nav-item:active {
  transform: scale(0.95);
}
</style>
