<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200 mb-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-4">
            <router-link 
              to="/dashboard" 
              class="flex items-center text-gray-600 hover:text-indigo-600 transition-colors"
            >
              <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
              Retour
            </router-link>
            <div class="h-6 w-px bg-gray-300"></div>
            <h1 class="text-xl font-bold text-gray-900">Mon Profil</h1>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-12">
        <div class="flex items-center space-x-3">
          <svg class="animate-spin h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="text-gray-600">Chargement du profil...</span>
        </div>
      </div>

      <!-- Profile Content -->
      <div v-else-if="userProfile" class="space-y-6">
        <!-- Profile Header -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="px-6 py-8">
            <div class="flex items-center space-x-6">
              <div class="h-20 w-20 bg-indigo-100 rounded-full flex items-center justify-center">
                <span class="text-indigo-600 text-2xl font-bold">
                  {{ userProfile.name?.charAt(0).toUpperCase() }}
                </span>
              </div>
              <div>
                <h2 class="text-2xl font-bold text-gray-900">{{ userProfile.name }}</h2>
                <p class="text-gray-600 capitalize">{{ userProfile.role?.name }}</p>
                <p class="text-sm text-gray-500">{{ userProfile.email }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Personal Information -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Informations Personnelles</h3>
          </div>
          <div class="px-6 py-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Nom complet</label>
                <p class="text-gray-900 bg-gray-50 px-3 py-2 rounded-md">{{ userProfile.name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Adresse email</label>
                <p class="text-gray-900 bg-gray-50 px-3 py-2 rounded-md">{{ userProfile.email }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Rôle</label>
                <p class="text-gray-900 bg-gray-50 px-3 py-2 rounded-md capitalize">{{ userProfile.role?.name }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Date d'inscription</label>
                <p class="text-gray-900 bg-gray-50 px-3 py-2 rounded-md">{{ formatDate(userProfile.created_at) }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Student Specific Information -->
        <div v-if="userProfile.student" class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Informations Étudiant</h3>
          </div>
          <div class="px-6 py-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Matricule</label>
                <p class="text-gray-900 bg-blue-50 px-3 py-2 rounded-md font-mono">{{ userProfile.student.matricule }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Filière</label>
                <p class="text-gray-900 bg-blue-50 px-3 py-2 rounded-md">{{ userProfile.student.filiere }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Statistics for Students -->
        <div v-if="userProfile.student && studentStats" class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Mes Statistiques</h3>
          </div>
          <div class="px-6 py-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="text-center p-4 bg-blue-50 rounded-lg">
                <div class="text-2xl font-bold text-blue-600">{{ studentStats.total_grades }}</div>
                <div class="text-sm text-gray-600">Notes obtenues</div>
              </div>
              <div class="text-center p-4 bg-green-50 rounded-lg">
                <div class="text-2xl font-bold text-green-600">{{ studentStats.average?.toFixed(2) || 'N/A' }}</div>
                <div class="text-sm text-gray-600">Moyenne générale</div>
              </div>
              <div class="text-center p-4 bg-yellow-50 rounded-lg">
                <div class="text-2xl font-bold text-yellow-600">{{ studentStats.total_claims }}</div>
                <div class="text-sm text-gray-600">Réclamations</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Actions</h3>
          </div>
          <div class="px-6 py-6">
            <div class="flex flex-wrap gap-4">
              <button
                @click="showPasswordModal = true"
                class="px-4 py-2 rounded-lg flex items-center space-x-2"
                style="background-color: #4f46e5; color: white;"
              >
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-11.83 1.5M9 7a2 2 0 00-2 2m0 0a6 6 0 1011.83-1.5M9 9h6" />
                </svg>
                <span>Changer mot de passe</span>
              </button>
              
              <router-link 
                v-if="userProfile.student"
                to="/grades"
                class="px-4 py-2 rounded-lg flex items-center space-x-2"
                style="background-color: #16a34a; color: white; text-decoration: none;"
              >
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                <span>Voir mes notes</span>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Change Password -->
    <div v-if="showPasswordModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="text-lg font-medium mb-4">Changer le mot de passe</h3>
        <form @submit.prevent="changePassword">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Mot de passe actuel</label>
              <input v-model="passwordForm.current_password" type="password" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nouveau mot de passe</label>
              <input v-model="passwordForm.new_password" type="password" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Confirmer le nouveau mot de passe</label>
              <input v-model="passwordForm.new_password_confirmation" type="password" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-3">
            <button type="button" @click="showPasswordModal = false" class="px-4 py-2 border border-gray-300 rounded-md" style="background-color: #f9fafb; color: #374151;">Annuler</button>
            <button type="submit" class="px-4 py-2 rounded-md" style="background-color: #4f46e5; color: white;">Changer</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/lib/axios'

const authStore = useAuthStore()

const userProfile = ref(null)
const studentStats = ref(null)
const loading = ref(false)
const showPasswordModal = ref(false)

const passwordForm = ref({
  current_password: '',
  new_password: '',
  new_password_confirmation: ''
})

onMounted(() => {
  loadProfile()
  if (authStore.isEtudiant) {
    loadStudentStats()
  }
})

const loadProfile = async () => {
  loading.value = true
  try {
    const response = await api.get('/profile')
    userProfile.value = response.data
  } catch (error) {
    console.error('Erreur:', error)
  } finally {
    loading.value = false
  }
}

const loadStudentStats = async () => {
  try {
    const [gradesResponse, claimsResponse] = await Promise.all([
      api.get('/grades'),
      api.get('/claims')
    ])
    
    const grades = gradesResponse.data
    const claims = claimsResponse.data
    
    studentStats.value = {
      total_grades: grades.length,
      average: grades.length > 0 ? grades.reduce((sum, grade) => sum + parseFloat(grade.note), 0) / grades.length : 0,
      total_claims: claims.length
    }
  } catch (error) {
    console.error('Erreur lors du chargement des statistiques:', error)
  }
}

const changePassword = async () => {
  if (passwordForm.value.new_password !== passwordForm.value.new_password_confirmation) {
    alert('Les mots de passe ne correspondent pas')
    return
  }
  
  try {
    await api.post('/change-password', passwordForm.value)
    showPasswordModal.value = false
    passwordForm.value = { current_password: '', new_password: '', new_password_confirmation: '' }
    alert('Mot de passe changé avec succès')
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors du changement de mot de passe')
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR')
}
</script>