<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const tasks = ref([])
const loading = ref(true)
const newTaskTitle = ref('')

const fetchTasks = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('weekend_tasks')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) console.error('Error fetching weekend tasks:', error)
  else tasks.value = data || []
  loading.value = false
}

const addTask = async () => {
  if (!newTaskTitle.value.trim()) return

  const { error } = await supabase
    .from('weekend_tasks')
    .insert([{
      title: newTaskTitle.value.trim(),
      is_completed: false
    }])

  if (error) {
    alert('Błąd dodawania planu')
    console.error(error)
  } else {
    newTaskTitle.value = ''
  }
}

const toggleCompleted = async (task) => {
  const newValue = !task.is_completed
  // Optimistic update
  const originalValue = task.is_completed
  task.is_completed = newValue

  const { error } = await supabase
    .from('weekend_tasks')
    .update({ is_completed: newValue })
    .eq('id', task.id)

  if (error) {
    task.is_completed = originalValue
    console.error('Error updating task:', error)
  }
}

const deleteTask = async (id) => {
  if (!confirm('Usunąć plan?')) return
  
  const { error } = await supabase
    .from('weekend_tasks')
    .delete()
    .eq('id', id)
    
  if (error) console.error('Error deleting task:', error)
}

// Realtime
let subscription = null

onMounted(() => {
  fetchTasks()

  subscription = supabase
    .channel('public:weekend_tasks')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'weekend_tasks' }, (payload) => {
      if (payload.eventType === 'INSERT') {
        tasks.value.unshift(payload.new)
      } else if (payload.eventType === 'UPDATE') {
        const index = tasks.value.findIndex(t => t.id === payload.new.id)
        if (index !== -1) tasks.value[index] = payload.new
      } else if (payload.eventType === 'DELETE') {
        tasks.value = tasks.value.filter(t => t.id !== payload.old.id)
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
      <h1>Weekend</h1>
      <p class="text-muted">Plany i pomysły</p>
    </header>

    <!-- Add Form -->
    <div class="card mb-6 add-form flex gap-2">
      <input 
        v-model="newTaskTitle" 
        @keyup.enter="addTask"
        placeholder="Co robimy w weekend?" 
        class="flex-1"
      />
      <button @click="addTask" class="btn btn-primary" :disabled="!newTaskTitle.trim()">
        +
      </button>
    </div>

    <!-- List -->
    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="weekend-list">
      <div v-if="tasks.length === 0" class="text-center py-8 text-muted">
        Brak planów.
      </div>
      
      <div 
        v-for="task in tasks" 
        :key="task.id" 
        class="card task-row flex items-center justify-between mb-2"
        :class="{ 'is-completed': task.is_completed }"
        @click="toggleCompleted(task)"
      >
        <div class="flex items-center gap-3 flex-1">
          <div class="checkbox" :class="{ checked: task.is_completed }">
            <span v-if="task.is_completed">✓</span>
          </div>
          <span class="task-title">{{ task.title }}</span>
        </div>
        
        <button @click.stop="deleteTask(task.id)" class="btn btn-ghost delete-btn">🗑️</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.task-row {
  cursor: pointer;
  padding: 1rem;
  transition: all 0.2s;
  user-select: none;
  border-left: 4px solid var(--color-primary);
}

.task-row.is-completed {
  opacity: 0.5;
  border-left-color: var(--color-success);
}

.task-row.is-completed .task-title {
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
