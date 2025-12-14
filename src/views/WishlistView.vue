<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const wishes = ref([])
const loading = ref(true)
const newWishName = ref('')

const fetchWishes = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('wishlist')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) console.error('Error fetching wishlist:', error)
  else wishes.value = data || []
  loading.value = false
}

const addWish = async () => {
  if (!newWishName.value.trim()) return

  const { error } = await supabase
    .from('wishlist')
    .insert([{
      name: newWishName.value.trim(),
      status: 'active'
    }])

  if (error) {
    alert('Błąd dodawania życzenia')
    console.error(error)
  } else {
    newWishName.value = ''
  }
}

const toggleStatus = async (wish) => {
  const newStatus = wish.status === 'active' ? 'bought' : 'active'
  // Optimistic update
  const originalStatus = wish.status
  wish.status = newStatus

  const { error } = await supabase
    .from('wishlist')
    .update({ status: newStatus })
    .eq('id', wish.id)

  if (error) {
    wish.status = originalStatus
    console.error('Error updating wish:', error)
  }
}

const deleteWish = async (id) => {
  if (!confirm('Usunąć życzenie?')) return
  
  const { error } = await supabase
    .from('wishlist')
    .delete()
    .eq('id', id)
    
  if (error) console.error('Error deleting wish:', error)
}

// Realtime
let subscription = null

onMounted(() => {
  fetchWishes()

  subscription = supabase
    .channel('public:wishlist')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'wishlist' }, (payload) => {
      if (payload.eventType === 'INSERT') {
        wishes.value.unshift(payload.new)
      } else if (payload.eventType === 'UPDATE') {
        const index = wishes.value.findIndex(w => w.id === payload.new.id)
        if (index !== -1) wishes.value[index] = payload.new
      } else if (payload.eventType === 'DELETE') {
        wishes.value = wishes.value.filter(w => w.id !== payload.old.id)
      }
    })
    .subscribe()
})

onUnmounted(() => {
  if (subscription) supabase.removeChannel(subscription)
})
</script>

<template>
  <div class="container p-4 pb-24">
    <header class="mb-6">
      <h1>Lista Życzeń</h1>
    </header>

    <!-- Add Form -->
    <div class="card mb-6 add-form flex gap-2">
      <input 
        v-model="newWishName" 
        @keyup.enter="addWish"
        placeholder="O czym marzysz?" 
        class="flex-1"
      />
      <button @click="addWish" class="btn btn-primary" :disabled="!newWishName.trim()">
        +
      </button>
    </div>

    <!-- List -->
    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="wish-list">
      <div v-if="wishes.length === 0" class="text-center py-8 text-muted">
        Lista życzeń jest pusta.
      </div>
      
      <div 
        v-for="wish in wishes" 
        :key="wish.id" 
        class="card wish-item flex items-center justify-between mb-2"
        :class="{ 'is-bought': wish.status === 'bought' }"
        @click="toggleStatus(wish)"
      >
        <div class="flex items-center gap-3 flex-1">
          <span class="star-icon" :class="{ active: wish.status === 'active' }">
            {{ wish.status === 'active' ? '⭐' : '🎁' }}
          </span>
          <span class="wish-name">{{ wish.name }}</span>
        </div>
        
        <button @click.stop="deleteWish(wish.id)" class="btn btn-ghost delete-btn">🗑️</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.wish-item {
  cursor: pointer;
  padding: 1rem;
  transition: all 0.2s;
  user-select: none;
  border-left: 4px solid var(--color-warning);
}

.wish-item.is-bought {
  opacity: 0.6;
  border-left-color: var(--color-success);
  background: var(--color-background-soft);
}

.wish-item.is-bought .wish-name {
  text-decoration: line-through;
}

.star-icon {
  font-size: 1.2rem;
  opacity: 0.5;
}

.star-icon.active {
  opacity: 1;
}
</style>
