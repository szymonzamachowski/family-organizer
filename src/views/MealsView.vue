<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const weekDays = ref([])
const loading = ref(true)

// Helper to format date as YYYY-MM-DD for DB comparison
const formatDate = (date) => {
  return date.toISOString().split('T')[0]
}

// Helper for display
const getDayName = (date) => {
  return date.toLocaleDateString('pl-PL', { weekday: 'long', day: 'numeric', month: 'numeric' })
}

const generateWeek = () => {
  const days = []
  const today = new Date()
  for (let i = 0; i < 7; i++) {
    const d = new Date(today)
    d.setDate(today.getDate() + i)
    days.push({
      dateObj: d,
      dateStr: formatDate(d),
      dayName: getDayName(d),
      id: null, // to track DB id
      dish_name: ''
    })
  }
  return days
}

const fetchMeals = async () => {
  loading.value = true
  weekDays.value = generateWeek()
  
  const { data, error } = await supabase
    .from('meal_plan')
    .select('*')
    .gte('day_date', weekDays.value[0].dateStr) // fetch from today onwards
  
  if (error) {
    console.error('Error fetching meals:', error)
  } else if (data) {
    // Map DB data to local state
    data.forEach(meal => {
      const day = weekDays.value.find(d => d.dateStr === meal.day_date)
      if (day) {
        day.id = meal.id
        day.dish_name = meal.dish_name
      }
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

// Realtime
let subscription = null

onMounted(() => {
  fetchMeals()

  subscription = supabase
    .channel('public:meal_plan')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'meal_plan' }, (payload) => {
       // Refresh all for simplicity to ensure alignment, or manually update
       // For simple fields, just finding by ID is enough
       if (payload.eventType === 'UPDATE') {
         const day = weekDays.value.find(d => d.id === payload.new.id)
         if (day) day.dish_name = payload.new.dish_name
       } else if (payload.eventType === 'INSERT') {
          // Check if it belongs to one of our days
          const day = weekDays.value.find(d => d.dateStr === payload.new.day_date)
          if (day) {
            day.id = payload.new.id
            day.dish_name = payload.new.dish_name
          }
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
      <p class="text-muted">Plan na najbliższy tydzień</p>
    </header>

    <div v-if="loading" class="text-center py-8 text-muted">Ładowanie...</div>
    
    <div v-else class="meal-list flex flex-col gap-3">
      <div 
        v-for="day in weekDays" 
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
</template>

<style scoped>
.text-primary {
  color: var(--color-primary);
}
</style>
