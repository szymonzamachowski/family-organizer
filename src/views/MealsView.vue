<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const weeks = ref([])
const loading = ref(true)

// Helper to format date as YYYY-MM-DD for DB comparison
const formatDate = (date) => {
  return date.toISOString().split('T')[0]
}

// Helper for display
const getDayName = (date) => {
  return date.toLocaleDateString('pl-PL', { weekday: 'long', day: 'numeric', month: 'numeric' })
}

const getSaturday = (date) => {
  const d = new Date(date)
  const day = d.getDay() // 0=Sun, 6=Sat
  // Calculate difference to get previous Saturday (or today if Saturday)
  // Sat(6) -> 0
  // Sun(0) -> 1
  // Mon(1) -> 2
  // ...
  // Fri(5) -> 6
  const diff = (day + 1) % 7
  d.setDate(d.getDate() - diff)
  return d
}

const generateWeekDocs = (startDate) => {
  const days = []
  for (let i = 0; i < 7; i++) {
    const d = new Date(startDate)
    d.setDate(startDate.getDate() + i)
    days.push({
      dateObj: d,
      dateStr: formatDate(d),
      dayName: getDayName(d),
      id: null,
      dish_name: ''
    })
  }
  return {
    startDate: new Date(startDate),
    endDate: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + 6),
    label: `${startDate.toLocaleDateString('pl-PL', {day: 'numeric', month: 'numeric'})} - ${new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + 6).toLocaleDateString('pl-PL', {day: 'numeric', month: 'numeric'})}`,
    days: days,
    isOpen: true // default open?
  }
}

const fetchMeals = async () => {
  loading.value = true
  
  const today = new Date()
  const currentSaturday = getSaturday(today)
  const nextSaturday = new Date(currentSaturday)
  nextSaturday.setDate(nextSaturday.getDate() + 7)
  
  const currentWeek = generateWeekDocs(currentSaturday)
  const nextWeek = generateWeekDocs(nextSaturday)
  nextWeek.isOpen = false // Collapsed by default
  
  weeks.value = [currentWeek, nextWeek]
  
  // Fetch for range
  const { data, error } = await supabase
    .from('meal_plan')
    .select('*')
    .gte('day_date', currentWeek.days[0].dateStr)
    .lte('day_date', nextWeek.days[6].dateStr)
  
  if (error) {
    console.error('Error fetching meals:', error)
  } else if (data) {
    // Map DB data
    weeks.value.forEach(week => {
      week.days.forEach(day => {
        const meal = data.find(m => m.day_date === day.dateStr)
        if (meal) {
          day.id = meal.id
          day.dish_name = meal.dish_name
        }
      })
    })
  }
  loading.value = false
}

const updateMeal = async (day) => {
  if (!day.dish_name && !day.id) return // nothing to save and no ID

  if (day.id) {
    // Update
    const { error } = await supabase
      .from('meal_plan')
      .update({ dish_name: day.dish_name })
      .eq('id', day.id)
    if (error) console.error('Error updating meal:', error)
  } else {
    // Insert
    const { data, error } = await supabase
      .from('meal_plan')
      .insert([{
        day_date: day.dateStr,
        dish_name: day.dish_name
      }])
      .select()
    
    if (error) console.error('Error adding meal:', error)
    else if (data && data[0]) {
      day.id = data[0].id
    }
  }
}

const toggleWeek = (week) => {
  week.isOpen = !week.isOpen
}

// Realtime
let subscription = null

onMounted(() => {
  fetchMeals()

  subscription = supabase
    .channel('public:meal_plan')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'meal_plan' }, (payload) => {
       if (payload.eventType === 'UPDATE') {
         weeks.value.forEach(w => {
           const day = w.days.find(d => d.id === payload.new.id)
           if (day) day.dish_name = payload.new.dish_name
         })
       } else if (payload.eventType === 'INSERT') {
          weeks.value.forEach(w => {
            const day = w.days.find(d => d.dateStr === payload.new.day_date)
            if (day) {
              day.id = payload.new.id
              day.dish_name = payload.new.dish_name
            }
          })
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
      <h1>Obiady</h1>
    </header>

    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="weeks-list flex flex-col gap-4">
      <div v-for="(week, index) in weeks" :key="index" class="week-group">
        
        <button 
          @click="toggleWeek(week)"
          class="flex items-center justify-between w-full p-3 bg-surface rounded-lg mb-2 shadow-sm font-bold text-lg"
          :class="{'text-primary': index === 0}"
        >
          <span>{{ week.label }}</span>
          <span>{{ week.isOpen ? '▼' : '►' }}</span>
        </button>

        <div v-if="week.isOpen" class="week-days flex flex-col gap-3 pl-2">
          <div 
            v-for="day in week.days" 
            :key="day.dateStr" 
            class="card p-3"
          >
            <label class="block text-sm font-bold mb-1 text-primary">{{ day.dayName }}</label>
            <input 
              v-model="day.dish_name" 
              @blur="updateMeal(day)"
              @keydown.enter="$event.target.blur()"
              placeholder="Co dobrego?" 
              class="w-full bg-transparent border-b border-gray-600 focus:border-primary outline-none py-1"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.text-primary {
  color: var(--color-primary);
}
.bg-surface {
  background-color: var(--color-surface);
}
</style>
