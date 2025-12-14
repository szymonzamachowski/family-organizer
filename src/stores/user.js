import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
    const currentRole = ref(localStorage.getItem('family_role') || null)

    function setRole(role) {
        currentRole.value = role
        localStorage.setItem('family_role', role)
    }

    function clearRole() {
        currentRole.value = null
        localStorage.removeItem('family_role')
    }

    return { currentRole, setRole, clearRole }
})
