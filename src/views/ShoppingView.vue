<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const items = ref([])
const loading = ref(true)
const newItemName = ref('')

const fetchItems = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('shopping_list')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) console.error('Error fetching shopping list:', error)
  else items.value = data || []
  loading.value = false
}

const addItem = async () => {
  if (!newItemName.value.trim()) return

  const { error } = await supabase
    .from('shopping_list')
    .insert([{
      name: newItemName.value.trim(),
      is_bought: false
    }])

  if (error) {
    alert('Błąd dodawania produktu')
    console.error(error)
  } else {
    newItemName.value = ''
  }
}

const toggleBought = async (item) => {
  const newValue = !item.is_bought
  // Optimistic update
  const originalValue = item.is_bought
  item.is_bought = newValue

  const { error } = await supabase
    .from('shopping_list')
    .update({ is_bought: newValue })
    .eq('id', item.id)

  if (error) {
    item.is_bought = originalValue
    console.error('Error updating item:', error)
  }
}

const deleteItem = async (id) => {
  if (!confirm('Usunąć produkt?')) return
  
  const { error } = await supabase
    .from('shopping_list')
    .delete()
    .eq('id', id)
    
  if (error) console.error('Error deleting item:', error)
}

// Realtime
let subscription = null

onMounted(() => {
  fetchItems()

  subscription = supabase
    .channel('public:shopping_list')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'shopping_list' }, (payload) => {
      if (payload.eventType === 'INSERT') {
        items.value.unshift(payload.new)
      } else if (payload.eventType === 'UPDATE') {
        const index = items.value.findIndex(i => i.id === payload.new.id)
        if (index !== -1) items.value[index] = payload.new
      } else if (payload.eventType === 'DELETE') {
        items.value = items.value.filter(i => i.id !== payload.old.id)
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
      <h1>Lista Zakupów</h1>
    </header>

    <!-- Add Form -->
    <div class="card mb-6 add-form flex gap-2">
      <input 
        v-model="newItemName" 
        @keyup.enter="addItem"
        placeholder="Co kupić?" 
        class="flex-1"
      />
      <button @click="addItem" class="btn btn-primary" :disabled="!newItemName.trim()">
        +
      </button>
    </div>

    <!-- List -->
    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="shopping-list">
      <div v-if="items.length === 0" class="text-center py-8 text-muted">
        Lista jest pusta.
      </div>
      
      <div 
        v-for="item in items" 
        :key="item.id" 
        class="card item-row flex items-center justify-between mb-2"
        :class="{ 'is-bought': item.is_bought }"
        @click="toggleBought(item)"
      >
        <div class="flex items-center gap-3 flex-1">
          <div class="checkbox" :class="{ checked: item.is_bought }">
            <span v-if="item.is_bought">✓</span>
          </div>
          <span class="item-name">{{ item.name }}</span>
        </div>
        
        <button @click.stop="deleteItem(item.id)" class="btn btn-ghost delete-btn">🗑️</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.item-row {
  cursor: pointer;
  padding: 1rem;
  transition: all 0.2s;
  user-select: none;
}

.item-row.is-bought {
  opacity: 0.5;
  background-color: rgba(0,0,0,0.05);
}

.item-row.is-bought .item-name {
  text-decoration: line-through;
}

.checkbox {
  width: 24px;
  height: 24px;
  border: 2px solid var(--color-primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  transition: all 0.2s;
}

.checkbox.checked {
  background-color: var(--color-success);
  border-color: var(--color-success);
}
</style>
