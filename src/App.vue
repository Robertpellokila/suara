<script setup>
import { RouterView } from 'vue-router'
import AppHeader from './layout/AppHeader.vue'
import AppFooter from './layout/AppFooter.vue'
</script>

<template>
  <AppHeader />
  <main class="app__main">
    <RouterView v-slot="{ Component }">
      <Transition name="route" mode="out-in">
        <component :is="Component" />
      </Transition>
    </RouterView>
  </main>
  <AppFooter />
</template>

<style scoped>
.app__main {
  flex: 1;
}
</style>
