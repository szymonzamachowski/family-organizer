<script setup>
import { ref, onMounted, computed, onUnmounted } from 'vue'
import { supabase } from '../supabase'
import { useUserStore } from '../stores/user'

const userStore = useUserStore()
const tasks = ref([])
const loading = ref(true)
const showAddForm = ref(false)

// Filters
const filterAssignee = ref('all') // 'all' or specific role
const filterStatus = ref('all') // 'all', 'todo', 'done'

// New Task Form
const newTask = ref({
  title: '',
  assigned_to: userStore.currentRole || 'Tata',
  deadline: new Date().toISOString().split('T')[0]
})

const submitOnEnter = (e) => {
  if (!e.shiftKey) {
    e.preventDefault()
    addTask()
  }
}

const roles = ['Tata', 'Mama', 'Gosia', 'Szymon']

// Computed
const filteredTasks = computed(() => {
  return tasks.value.filter(task => {
    const matchAssignee = filterAssignee.value === 'all' || task.assigned_to === filterAssignee.value
    const matchStatus = filterStatus.value === 'all' || task.status === filterStatus.value
    return matchAssignee && matchStatus
  }).sort((a, b) => {
    // Sort by status (todo first) then deadline
    if (a.status !== b.status) return a.status === 'todo' ? -1 : 1
    return new Date(a.deadline) - new Date(b.deadline)
  })
})

const fetchTasks = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('tasks')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) console.error('Error fetching tasks:', error)
  else tasks.value = data || []
  loading.value = false
}

const addTask = async () => {
  if (!newTask.value.title) return

  const { error } = await supabase
    .from('tasks')
    .insert([{
      title: newTask.value.title,
      assigned_to: newTask.value.assigned_to,
      deadline: newTask.value.deadline,
      status: 'todo'
    }])

  if (error) {
    alert('Błąd dodawania zadania')
    console.error(error)
  } else {
    newTask.value.title = ''
    showAddForm.value = false
  }
}

const toggleStatus = async (task) => {
  const newStatus = task.status === 'todo' ? 'done' : 'todo'
  // Optimistic update
  const originalStatus = task.status
  task.status = newStatus

  const { error } = await supabase
    .from('tasks')
    .update({ status: newStatus })
    .eq('id', task.id)

  if (error) {
    task.status = originalStatus // Revert on error
    console.error('Error updating task:', error)
  }
}

const deleteTask = async (id) => {
  if (!confirm('Usunąć zadanie?')) return
  
  const { error } = await supabase
    .from('tasks')
    .delete()
    .eq('id', id)
    
  if (error) console.error('Error deleting task:', error)
}

// Realtime Subscription
let subscription = null

onMounted(() => {
  fetchTasks()

  subscription = supabase
    .channel('public:tasks')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'tasks' }, (payload) => {
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
    <header class="flex justify-between items-center mb-6 fade-in">
      <h1>Obowiązki</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary shadow-lg" style="width: 50px; height: 50px; border-radius: 50%; font-size: 1.5rem; padding: 0;">
        {{ showAddForm ? '✕' : '+' }}
      </button>
    </header>

    <!-- Filters -->
    <div class="filters flex gap-2 mb-6 overflow-x-auto pb-2 fade-in" style="animation-delay: 0.1s">
      <select v-model="filterAssignee" class="filter-select">
        <option value="all">Wszyscy</option>
        <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
      </select>
      <select v-model="filterStatus" class="filter-select">
        <option value="all">Wszystkie</option>
        <option value="todo">Do zrobienia</option>
        <option value="done">Zrobione</option>
      </select>
    </div>

    <!-- Add Form -->
    <div v-if="showAddForm" class="card mb-6 add-form fade-in">
      <h3 class="mb-4">Nowe zadanie</h3>
      <textarea 
        v-model="newTask.title" 
        @keydown.enter="submitOnEnter" 
        placeholder="Co trzeba zrobić?" 
        class="mb-4 input-field" 
        rows="3"
        autofocus
      ></textarea>
      <div class="flex flex-col gap-3">
        <div class="flex gap-2">
            <select v-model="newTask.assigned_to" class="input-field flex-1">
              <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
            </select>
            <input type="date" v-model="newTask.deadline" class="input-field flex-1" />
        </div>
        <button @click="addTask" class="btn btn-primary w-full shadow-md">Dodaj</button>
      </div>
    </div>

    <!-- Task List -->
    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="task-list flex flex-col gap-3 fade-in" style="animation-delay: 0.2s">
      <div v-if="filteredTasks.length === 0" class="text-center py-8 text-muted">
        Brak zadań.
      </div>
      
      <div 
        v-for="task in filteredTasks" 
        :key="task.id" 
        class="card task-item"
        :class="{ 'task-done': task.status === 'done' }"
      >
        <div class="flex items-start gap-3"> 
           <!-- Custom Checkbox -->
           <div class="status-indicator" @click="toggleStatus(task)">
              <div class="checkbox-circle" :class="{ checked: task.status === 'done' }">
                 <span v-if="task.status === 'done'">✓</span>
              </div>
           </div>

           <div class="flex-1 content-area" @click="toggleStatus(task)">
             <div class="flex items-center gap-2 mb-1 flex-wrap">
                <span class="badge" :class="task.assigned_to">{{ task.assigned_to }}</span>
                <span v-if="task.deadline" class="text-sm date-badge" :class="{'overdue': new Date(task.deadline) < new Date() && task.status !== 'done'}">
                  🗓 {{ new Date(task.deadline).toLocaleDateString('pl-PL', { day: 'numeric', month: 'numeric' }) }}
                </span>
             </div>
             <h3 class="task-title">{{ task.title }}</h3>
           </div>
            
           <button @click="deleteTask(task.id)" class="btn btn-ghost delete-btn">🗑️</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.task-item {
  padding: 1rem;
  border-left: none; /* override old style */
  margin-bottom: 0;
  transition: transform 0.2s;
}

.task-item:active {
  transform: scale(0.98);
}

.status-indicator {
  padding-top: 0.25rem;
  cursor: pointer;
}

.checkbox-circle {
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

.checkbox-circle.checked {
  background: var(--color-success);
  border-color: var(--color-success);
}

.task-item.task-done .task-title {
  text-decoration: line-through;
  color: var(--color-text-muted);
}

.task-item.task-done {
   opacity: 0.6;
}

.badge {
  font-size: 0.7rem;
  padding: 0.2rem 0.6rem;
  border-radius: 99px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* Updated Colors for badges to better match new palette */
.badge.Tata { background: #e0e7ff; color: #4338ca; }
.badge.Mama { background: #fce7f3; color: #be185d; }
.badge.Gosia { background: #dcfce7; color: #15803d; }
.badge.Szymon { background: #ffedd5; color: #c2410c; }

.date-badge {
  color: var(--color-text-muted);
  font-weight: 500;
}
.date-badge.overdue {
  color: var(--color-danger);
  font-weight: 700;
}

.input-field {
  width: 100%;
  padding: 0.75rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  background: var(--color-background);
  color: var(--color-text-main);
  font-size: 1rem;
}

.filter-select {
  padding: 0.5rem 1rem;
  border-radius: 99px;
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  min-width: 120px;
}
</style>
