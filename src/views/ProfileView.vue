<script setup>
import { useUserStore } from '../stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

const switchUser = () => {
  if (confirm('Czy na pewno chcesz zmienić użytkownika?')) {
    userStore.clearRole()
    router.push({ name: 'welcome' })
  }
}
</script>

<template>
  <div class="container p-4">
    <header class="mb-8">
      <h1>Profil</h1>
    </header>

    <div class="card text-center py-8">
      <div class="avatar mb-4">
        {{ userStore.currentRole ? userStore.currentRole[0] : '?' }}
      </div>
      <h2 class="mb-2">Cześć, {{ userStore.currentRole }}!</h2>
      <p class="text-muted mb-6">Miłego dnia ❤️</p>
      
      <button @click="switchUser" class="btn btn-outline w-full">
        Zmień osobę
      </button>
    </div>
    
     <div class="text-center mt-8 text-muted text-sm version-info">
      Family Organizer v1.0
     </div>
  </div>
</template>

<style scoped>
.avatar {
  width: 80px;
  height: 80px;
  background: var(--color-primary-light);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  font-weight: bold;
  margin: 0 auto;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--color-danger);
  color: var(--color-danger);
}

.btn-outline:hover {
  background: var(--color-danger);
  color: white;
}
</style>
