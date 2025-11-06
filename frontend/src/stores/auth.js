import { defineStore } from 'pinia'
import api from '../lib/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token'),
    isAuthenticated: !!localStorage.getItem('token')
  }),

  getters: {
    isEtudiant: (state) => state.user?.role?.name === 'etudiant',
    isProfesseur: (state) => state.user?.role?.name === 'professeur',
    isAdmin: (state) => state.user?.role?.name === 'administration'
  },

  actions: {
    async login(credentials) {
      try {
        const response = await api.post('/login', credentials)
        const { user, token } = response.data
        
        this.user = user
        this.token = token
        this.isAuthenticated = true
        
        localStorage.setItem('token', token)
        
        return { success: true }
      } catch (error) {
        return { 
          success: false, 
          message: error.response?.data?.message || 'Erreur de connexion' 
        }
      }
    },

    async logout() {
      try {
        await api.post('/logout')
      } catch (error) {
        console.error('Erreur lors de la déconnexion:', error)
      } finally {
        this.user = null
        this.token = null
        this.isAuthenticated = false
        localStorage.removeItem('token')
      }
    },

    async fetchUser() {
      if (!this.token) {
        this.isAuthenticated = false
        return
      }
      
      try {
        const response = await api.get('/me')
        this.user = response.data
        this.isAuthenticated = true
      } catch (error) {
        console.error('Erreur fetchUser:', error)
        this.logout()
      }
    },

    async initAuth() {
      if (this.token) {
        await this.fetchUser()
      }
    }
  }
})