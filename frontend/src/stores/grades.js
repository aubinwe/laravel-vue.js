import { defineStore } from 'pinia'
import api from '../lib/axios'

export const useGradesStore = defineStore('grades', {
  state: () => ({
    grades: [],
    loading: false
  }),

  actions: {
    async fetchGrades() {
      this.loading = true
      try {
        const response = await api.get('/grades')
        this.grades = response.data
      } catch (error) {
        console.error('Erreur lors du chargement des notes:', error)
      } finally {
        this.loading = false
      }
    },

    async createGrade(gradeData) {
      try {
        const response = await api.post('/grades', gradeData)
        this.grades.push(response.data)
        return { success: true }
      } catch (error) {
        return { 
          success: false, 
          message: error.response?.data?.message || 'Erreur lors de la création' 
        }
      }
    },

    async updateGrade(id, gradeData) {
      try {
        const response = await api.put(`/grades/${id}`, gradeData)
        const index = this.grades.findIndex(g => g.id === id)
        if (index !== -1) {
          this.grades[index] = response.data
        }
        return { success: true }
      } catch (error) {
        return { 
          success: false, 
          message: error.response?.data?.message || 'Erreur lors de la mise à jour' 
        }
      }
    },

    async deleteGrade(id) {
      try {
        await api.delete(`/grades/${id}`)
        this.grades = this.grades.filter(g => g.id !== id)
        return { success: true }
      } catch (error) {
        return { 
          success: false, 
          message: error.response?.data?.message || 'Erreur lors de la suppression' 
        }
      }
    }
  }
})