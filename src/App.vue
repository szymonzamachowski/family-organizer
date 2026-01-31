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
  height: 100dvh;
  /* Use dvh for better mobile support */
  width: 100%;
  background-color: var(--color-background);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.main-content {
  flex: 1;
  width: 100%;
  overflow-y: auto;
  /* Internal scrolling */
  -webkit-overflow-scrolling: touch;
  /* Smooth scroll on iOS */
  padding-bottom: 2rem;
  /* Default padding */
}

/* No specific padding needed for nav state anymore as nav is in flow */
.main-content.with-nav {}
</style>
