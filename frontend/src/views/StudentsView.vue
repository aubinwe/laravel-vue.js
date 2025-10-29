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
            <h1 class="text-xl font-bold text-gray-900">Gestion des Étudiants</h1>
          </div>
          
          <div v-if="authStore.isAdmin">
            <button
              @click="showCreateModal = true"
              class="px-4 py-2 rounded-lg flex items-center space-x-2"
              style="background-color: #9333ea; color: white;"
            >
              <span>+ Nouvel Étudiant</span>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-12">
        <div class="flex items-center space-x-3">
          <svg class="animate-spin h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="text-gray-600">Chargement des étudiants...</span>
        </div>
      </div>

      <!-- Students List -->
      <div v-else class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Liste des Étudiants ({{ students.length }})</h3>
        </div>
        
        <div v-if="students.length === 0" class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Aucun étudiant</h3>
          <p class="mt-1 text-sm text-gray-500">Commencez par ajouter un premier étudiant.</p>
        </div>
        
        <div v-else class="divide-y divide-gray-200">
          <div v-for="student in students" :key="student.id" class="px-6 py-4 hover:bg-gray-50 transition-colors">
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center space-x-3 mb-2">
                  <div class="h-10 w-10 bg-indigo-100 rounded-full flex items-center justify-center">
                    <span class="text-indigo-600 font-medium text-sm">
                      {{ student.user?.name?.charAt(0).toUpperCase() }}
                    </span>
                  </div>
                  <div>
                    <h4 class="text-sm font-medium text-gray-900">
                      {{ student.user?.name }}
                    </h4>
                    <p class="text-sm text-gray-500">{{ student.user?.email }}</p>
                  </div>
                </div>
                
                <div class="flex items-center space-x-6 text-sm text-gray-500 ml-13">
                  <span class="flex items-center">
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                    </svg>
                    {{ student.matricule }}
                  </span>
                  <span class="flex items-center">
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    {{ student.filiere }}
                  </span>
                  <span class="flex items-center">
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a2 2 0 012-2h4a2 2 0 012 2v4m-6 0h6m-6 0l-2 2m8-2l2 2m-2-2v6a2 2 0 01-2 2H8a2 2 0 01-2-2V9" />
                    </svg>
                    {{ formatDate(student.created_at) }}
                  </span>
                </div>
              </div>
              
              <div v-if="authStore.isAdmin" class="flex items-center space-x-2">
                <button
                  @click="viewStudent(student)"
                  class="px-3 py-1 rounded text-sm"
                  style="background-color: #16a34a; color: white;"
                  title="Voir détails"
                >
                  Voir
                </button>
                <button
                  @click="deleteStudent(student.id)"
                  class="px-3 py-1 rounded text-sm"
                  style="background-color: #dc2626; color: white;"
                  title="Supprimer"
                >
                  Supprimer
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Ajouter Étudiant -->
    <div v-if="showCreateModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="text-lg font-medium mb-4">Ajouter un nouvel étudiant</h3>
        <form @submit.prevent="createStudent">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nom complet *</label>
              <input v-model="studentForm.name" type="text" required class="w-full px-3 py-2 border border-gray-300 rounded-md" placeholder="Ex: Jean Dupont" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email *</label>
              <input v-model="studentForm.email" type="email" required class="w-full px-3 py-2 border border-gray-300 rounded-md" placeholder="Ex: jean.dupont@email.com" />
            </div>
            <div class="bg-blue-50 p-3 rounded-md">
              <p class="text-sm text-blue-700">
                <strong>Note :</strong> Le matricule sera généré automatiquement (format: ETU2024XXXX)
              </p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Filière *</label>
              <select v-model="studentForm.filiere" required class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option value="">Sélectionner une filière</option>
                <option value="Informatique">Informatique</option>
                <option value="Mathématiques">Mathématiques</option>
                <option value="Physique">Physique</option>
                <option value="Chimie">Chimie</option>
                <option value="Biologie">Biologie</option>
                <option value="Génie Civil">Génie Civil</option>
                <option value="Électronique">Électronique</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Mot de passe *</label>
              <input v-model="studentForm.password" type="password" required class="w-full px-3 py-2 border border-gray-300 rounded-md" placeholder="Minimum 6 caractères" />
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-3">
            <button type="button" @click="showCreateModal = false" class="px-4 py-2 border border-gray-300 rounded-md" style="background-color: #f9fafb; color: #374151;">Annuler</button>
            <button type="submit" class="px-4 py-2 rounded-md" style="background-color: #9333ea; color: white;">Ajouter</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Voir Étudiant -->
    <div v-if="showViewModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="text-lg font-medium mb-4">Détails de l'étudiant</h3>
        <div v-if="selectedStudent" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Nom</label>
            <p class="mt-1 text-sm text-gray-900">{{ selectedStudent.user?.name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Email</label>
            <p class="mt-1 text-sm text-gray-900">{{ selectedStudent.user?.email }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Matricule</label>
            <p class="mt-1 text-sm text-gray-900">{{ selectedStudent.matricule }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Filière</label>
            <p class="mt-1 text-sm text-gray-900">{{ selectedStudent.filiere }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Date d'inscription</label>
            <p class="mt-1 text-sm text-gray-900">{{ formatDate(selectedStudent.created_at) }}</p>
          </div>
        </div>
        <div class="mt-6 flex justify-end">
          <button @click="showViewModal = false" class="px-4 py-2 rounded-md" style="background-color: #16a34a; color: white;">Fermer</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/lib/axios'

const authStore = useAuthStore()

const students = ref([])
const loading = ref(false)
const showCreateModal = ref(false)
const showViewModal = ref(false)
const selectedStudent = ref(null)

const studentForm = ref({
  name: '',
  email: '',
  filiere: '',
  password: ''
})

onMounted(() => {
  fetchStudents()
})

const fetchStudents = async () => {
  loading.value = true
  try {
    const response = await api.get('/students')
    students.value = response.data
  } catch (error) {
    console.error('Erreur lors du chargement des étudiants:', error)
  } finally {
    loading.value = false
  }
}

const createStudent = async () => {
  try {
    await api.post('/students', studentForm.value)
    showCreateModal.value = false
    studentForm.value = { name: '', email: '', filiere: '', password: '' }
    fetchStudents()
    alert('Étudiant ajouté avec succès')
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors de l\'ajout de l\'étudiant')
  }
}

const viewStudent = (student) => {
  selectedStudent.value = student
  showViewModal.value = true
}

const deleteStudent = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cet étudiant ?')) {
    try {
      await api.delete(`/students/${id}`)
      fetchStudents()
      alert('Étudiant supprimé avec succès')
    } catch (error) {
      console.error('Erreur:', error)
      alert('Erreur lors de la suppression')
    }
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR')
}
</script>