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
    <div class="card p-6 w-full max-w-sm">
      <h1 class="text-2xl mb-6 text-center">🔐 Dostęp</h1>
      
      <form @submit.prevent="login" class="flex flex-col gap-4">
        <div>
          <input 
            v-model="password" 
            type="password" 
            placeholder="Hasło"
            class="w-full p-3 border rounded text-lg"
            autofocus
          />
          <p v-if="error" class="text-red-500 mt-2 text-sm text-center">{{ error }}</p>
        </div>
        
        <button type="submit" class="btn btn-primary w-full py-3 text-lg">
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
  background: var(--color-background);
  padding: 1rem;
}

input {
  background: var(--color-surface);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

input:focus {
  border-color: var(--color-primary);
  outline: none;
}
</style>
