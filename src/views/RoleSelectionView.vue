<script setup>
import { useUserStore } from '../stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

const roles = ['Tata', 'Mama', 'Gosia', 'Szymon']

const selectRole = (role) => {
  userStore.setRole(role)
  router.push({ name: 'tasks' })
}
</script>

<template>
  <div class="welcome-container">
    <div class="card text-center">
      <h1>Cześć! 👋</h1>
      <p class="mb-4">Kim dzisiaj jesteś?</p>
      
      <div class="roles-grid">
        <button 
          v-for="role in roles" 
          :key="role" 
          @click="selectRole(role)"
          class="role-btn"
        >
          {{ role }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.welcome-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 1rem;
  background: var(--color-background);
}

.roles-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 2rem;
}

.role-btn {
  background: var(--color-surface);
  border: 2px solid var(--color-primary-light);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-primary);
  cursor: pointer;
  transition: all 0.2s;
}

.role-btn:hover {
  background: var(--color-primary);
  color: white;
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}
</style>
