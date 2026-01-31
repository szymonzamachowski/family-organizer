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

.app-layout {
  min-height: 100vh;
  background-color: var(--color-background);
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  width: 100%;
}

.main-content.with-nav {
  padding-bottom: 140px; /* More space for floating nav */
}
