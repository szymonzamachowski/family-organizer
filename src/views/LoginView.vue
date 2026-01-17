<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const password = ref('')
const error = ref('')
const router = useRouter()
const userStore = useUserStore()

const login = () => {
  // Simple hardcoded password as requested
  if (password.value === 'rodzina123') {
    localStorage.setItem('isAuthenticated', 'true')
    router.push({ name: 'welcome' })
  } else {
    error.value = 'Nieprawidłowe hasło'
  }
}
</script>

<template>
  <div class="login-container">
    <div class="card p-8 w-full max-w-sm shadow-glow text-center fade-in">
      <div class="mb-6">
        <h1 class="text-3xl mb-2">🔐</h1>
        <h2 class="text-xl font-bold">Witaj w domu</h2>
      </div>
      
      <form @submit.prevent="login" class="flex flex-col gap-4">
        <div>
          <input 
            v-model="password" 
            type="password" 
            placeholder="Podaj hasło"
            class="text-center text-lg"
            autofocus
          />
          <p v-if="error" class="text-danger mt-2 text-sm">{{ error }}</p>
        </div>
        
        <button type="submit" class="btn btn-primary w-full py-4 text-lg shadow-lg">
          Wejdź
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-background) 0%, #e0e7ff 100%);
  padding: 1.5rem;
}

.text-danger {
  color: var(--color-danger);
}

.shadow-glow {
  box-shadow: 0 10px 40px -10px rgba(79, 70, 229, 0.2);
}
</style>
