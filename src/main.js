import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import { useAuthStore } from './stores/useAuthStore'
import './style.css'
import App from './App.vue'

const app = createApp(App)

const pinia = createPinia()
app.use(pinia)
app.use(router)

// Initialize auth store before mounting so the first render has the session
const auth = useAuthStore(pinia)
auth.init().finally(() => {
  app.mount('#app')
})
