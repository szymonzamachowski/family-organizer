<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { supabase } from '../supabase'

const items = ref([])
const loading = ref(true)
const newItemName = ref('')
const newItemCategory = ref('Inne')
const editingItem = ref(null) // ID of item being edited
const editName = ref('')

const categories = [
  'Pieczywo',
  'Mięso', 
  'Nabiał', 
  'Owoce/Warzywa', 
  'Chemia', 
  'Inne'
]

// Group items by category
const groupedItems = computed(() => {
  const groups = {}
  categories.forEach(cat => groups[cat] = [])
  
  items.value.forEach(item => {
    const cat = item.category || 'Inne'
    if (!groups[cat]) groups[cat] = []
    groups[cat].push(item)
  })
  
  return groups
})

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
      category: newItemCategory.value,
      is_bought: false
    }])

  if (error) {
    alert('Błąd dodawania produktu')
    console.error(error)
  } else {
    newItemName.value = ''
    // Keep category or reset? Keeping might be nice for bulk adding.
  }
}

const toggleBought = async (item) => {
  if (editingItem.value === item.id) return // Don't toggle if editing

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

const startEdit = (item) => {
  editingItem.value = item.id
  editName.value = item.name
}

const saveEdit = async (item) => {
  if (editingItem.value !== item.id) return
  if (!editName.value.trim()) {
    cancelEdit()
    return
  }

  const oldName = item.name
  item.name = editName.value.trim()
  editingItem.value = null

  const { error } = await supabase
    .from('shopping_list')
    .update({ name: item.name })
    .eq('id', item.id)
    
  if (error) {
    item.name = oldName
    console.error('Error updating item name:', error)
  }
}

const cancelEdit = () => {
  editingItem.value = null
  editName.value = ''
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
        if (index !== -1) {
           // If we are editing this exact item locally, maybe don't overwrite user input?
           // For simplicity, we overwrite, assuming single user or rare conflict.
           if (editingItem.value !== payload.new.id) {
             items.value[index] = payload.new
           }
        }
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
    <header class="mb-6 fade-in">
      <h1>Lista Zakupów</h1>
    </header>

    <!-- Add Form -->
    <div class="card mb-6 add-form fade-in" style="animation-delay: 0.1s">
      <div class="flex flex-col gap-2">
        <input 
          v-model="newItemName" 
          @keyup.enter="addItem"
          placeholder="Co kupić?" 
          class="flex-1 input-field"
        />
        <div class="flex gap-2">
          <select v-model="newItemCategory" class="flex-1 input-field">
            <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
          </select>
          <button @click="addItem" class="btn btn-primary" :disabled="!newItemName.trim()">
            +
          </button>
        </div>
      </div>
    </div>

    <!-- List -->
    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="shopping-list fade-in" style="animation-delay: 0.2s">
      <div v-if="items.length === 0" class="text-center py-8 text-muted">
        Lista jest pusta.
      </div>
      
      <div v-else>
        <template v-for="cat in categories" :key="cat">
          <div v-if="groupedItems[cat] && groupedItems[cat].length > 0" class="category-block mb-4">
            <h3 class="category-title mb-2">{{ cat }}</h3>
            
            <div 
              v-for="item in groupedItems[cat]" 
              :key="item.id" 
              class="card item-row flex items-center justify-between mb-2"
              :class="{ 'is-bought': item.is_bought }"
              @click="toggleBought(item)"
            >
              <div class="flex items-center gap-3 flex-1 overflow-hidden">
                <!-- Checkbox -->
                <div class="checkbox" :class="{ checked: item.is_bought }">
                  <span v-if="item.is_bought">✓</span>
                </div>
                
                <!-- Content -->
                <div v-if="editingItem === item.id" class="flex-1 mr-2">
                   <input 
                      v-model="editName"
                      @click.stop
                      @keyup.enter="saveEdit(item)"
                      @blur="saveEdit(item)" 
                      class="edit-input"
                      autoFocus
                   />
                </div>
                <span v-else class="item-name truncate">{{ item.name }}</span>
              </div>
              
              <!-- Actions -->
              <div class="flex items-center gap-1">
                 <button 
                  v-if="editingItem !== item.id"
                  @click.stop="startEdit(item)" 
                  class="btn btn-ghost action-btn"
                >✏️</button>
                <button @click.stop="deleteItem(item.id)" class="btn btn-ghost action-btn destroy">✕</button>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
.input-field {
  padding: 0.75rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  background: var(--color-background);
  color: var(--color-text-main);
}

.category-title {
  color: var(--color-primary);
  font-size: 1.1rem;
  font-weight: 700;
  padding-left: 0.5rem;
  border-left: 4px solid var(--color-accent);
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
}

.item-row {
  cursor: pointer;
  padding: 1rem;
  transition: all 0.2s;
  user-select: none;
  border: 1px solid transparent;
}

.item-row:active {
  transform: scale(0.98);
}

.item-row.is-bought {
  opacity: 0.6;
  background-color: var(--color-background);
  box-shadow: none;
  border-color: var(--color-border);
}

.item-row.is-bought .item-name {
  text-decoration: line-through;
  color: var(--color-text-muted);
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
  flex-shrink: 0;
}

.checkbox.checked {
  background-color: var(--color-success);
  border-color: var(--color-success);
}

.action-btn {
  padding: 0.5rem;
  font-size: 1rem;
  opacity: 0.5;
  transition: opacity 0.2s;
}

.item-row:hover .action-btn {
  opacity: 1;
}

.destroy {
  color: var(--color-danger);
}

.edit-input {
  padding: 0.25rem 0.5rem;
  font-size: 1rem;
  background: white;
  border: 1px solid var(--color-primary);
  border-radius: var(--radius-md);
}

.truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
