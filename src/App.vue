<script setup>
import { RouterView, useRoute } from 'vue-router'
import BottomNav from './components/BottomNav.vue'
import { computed } from 'vue'

const route = useRoute()
const showNav = computed(() => route.name !== 'welcome' && route.name !== 'home')
</script>

<template>
  <div class="app-layout">
    <main class="main-content" :class="{ 'with-nav': showNav }">
      <RouterView />
    </main>
    <BottomNav v-if="showNav" />
  </div>
</template>

<style scoped>
.app-layout {
  min-height: 100vh;
}

.main-content {
  padding-bottom: 20px;
}

.main-content.with-nav {
  padding-bottom: 84px; /* 64px nav + 20px padding */
}
</style>
