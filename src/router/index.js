import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

// Lazy load views
const LoginView = () => import('../views/LoginView.vue')
const RoleSelectionView = () => import('../views/RoleSelectionView.vue')
const TasksView = () => import('../views/TasksView.vue')
const ShoppingView = () => import('../views/ShoppingView.vue')
const WishlistView = () => import('../views/WishlistView.vue')
const MealsView = () => import('../views/MealsView.vue')
const WeekendView = () => import('../views/WeekendView.vue')

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'home',
            redirect: '/tasks'
        },
        {
            path: '/login',
            name: 'login',
            component: LoginView
        },
        {
            path: '/welcome',
            name: 'welcome',
            component: RoleSelectionView
        },
        {
            path: '/tasks',
            name: 'tasks',
            component: TasksView
        },
        {
            path: '/shopping',
            name: 'shopping',
            component: ShoppingView
        },
        {
            path: '/wishlist',
            name: 'wishlist',
            component: WishlistView
        },
        {
            path: '/meals',
            name: 'meals',
            component: MealsView
        },
        {
            path: '/weekend',
            name: 'weekend',
            component: WeekendView
        },
        {
            path: '/profile',
            name: 'profile',
            component: () => import('../views/ProfileView.vue')
        }
    ]
})

// Navigation Guard
router.beforeEach((to, from, next) => {
    const userStore = useUserStore()
    const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true'

    if (to.name !== 'login' && !isAuthenticated) {
        next({ name: 'login' })
    } else if (to.name === 'login' && isAuthenticated) {
        next({ name: 'welcome' })
    } else {
        // Role check
        if (!userStore.currentRole && to.name !== 'welcome' && to.name !== 'login') {
            next({ name: 'welcome' })
        } else if (userStore.currentRole && to.name === 'welcome') {
            next({ name: 'tasks' })
        } else {
            next()
        }
    }
})

export default router
