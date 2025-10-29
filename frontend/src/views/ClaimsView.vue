<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow mb-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center space-x-4">
            <router-link to="/dashboard" class="text-blue-600 hover:text-blue-800">
              ← Retour
            </router-link>
            <h1 class="text-xl font-semibold">
              {{ authStore.isEtudiant ? 'Mes Réclamations' : authStore.isProfesseur ? 'Réclamations (Professeur)' : 'Gestion des Réclamations' }}
            </h1>
          </div>
        </div>
      </div>
    </nav>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Boutons -->
      <div class="mb-4 flex space-x-3">
        <button
          @click="showCreateModal = true"
          class="px-4 py-2 rounded-md"
          style="background-color: #ca8a04; color: white;"
        >
          {{ authStore.isEtudiant ? 'Nouvelle réclamation' : 'Faire une réclamation' }}
        </button>
        <button
          @click="fetchUserGrades"
          class="px-4 py-2 rounded-md"
          style="background-color: #4f46e5; color: white;"
        >
          Recharger mes notes ({{ userGrades.length }})
        </button>
      </div>

      <!-- Liste des réclamations -->
      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul class="divide-y divide-gray-200">
          <li v-for="claim in claims" :key="claim.id" class="px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-indigo-600">
                    {{ claim.grade?.course?.name || 'Cours' }}
                  </p>
                  <div class="ml-2 flex-shrink-0 flex">
                    <p class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                       :class="{
                         'bg-yellow-100 text-yellow-800': claim.statut === 'en_attente',
                         'bg-green-100 text-green-800': claim.statut === 'approuve',
                         'bg-red-100 text-red-800': claim.statut === 'rejete'
                       }">
                      {{ getStatusLabel(claim.statut) }}
                    </p>
                  </div>
                </div>
                <div class="mt-2">
                  <p class="text-sm text-gray-900">{{ claim.commentaire }}</p>
                </div>
                <div class="mt-2 sm:flex sm:justify-between">
                  <div class="sm:flex">
                    <p class="flex items-center text-sm text-gray-500">
                      Note: {{ claim.grade?.note }}/20
                    </p>
                    <p class="mt-2 flex items-center text-sm text-gray-500 sm:mt-0 sm:ml-6">
                      Par: {{ claim.creator?.name }}
                    </p>
                  </div>
                </div>
              </div>
              <div v-if="(authStore.isAdmin || authStore.isProfesseur) && claim.statut === 'en_attente'" class="flex space-x-2">
                <button
                  @click="updateClaimStatus(claim.id, 'approuve')"
                  class="px-3 py-1 rounded text-sm"
                  style="background-color: #16a34a; color: white;"
                >
                  Approuver
                </button>
                <button
                  @click="updateClaimStatus(claim.id, 'rejete')"
                  class="px-3 py-1 rounded text-sm"
                  style="background-color: #dc2626; color: white;"
                >
                  Rejeter
                </button>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <!-- Modal Nouvelle réclamation -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg max-w-md w-full">
        <h3 class="text-lg font-medium mb-4">
          {{ authStore.isEtudiant ? 'Nouvelle réclamation' : 'Nouvelle réclamation (Professeur)' }}
        </h3>
        <form @submit.prevent="createClaim">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">
                {{ authStore.isEtudiant ? 'Note concernée' : 'Note à réclamer' }}
              </label>
              <select v-model="form.grade_id" required class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option value="">Sélectionner une note</option>
                <option v-if="userGrades.length === 0" disabled>Aucune note disponible</option>
                <option v-for="grade in userGrades" :key="grade.id" :value="grade.id">
                  <span v-if="authStore.isEtudiant">
                    {{ grade.course || 'Cours' }} - {{ grade.note }}/20 ({{ grade.semestre }})
                  </span>
                  <span v-else>
                    {{ grade.student?.user?.name || 'Étudiant' }} - {{ grade.course?.name || 'Cours' }} - {{ grade.note }}/20
                  </span>
                </option>
              </select>
              <p v-if="userGrades.length === 0" class="text-sm text-red-600 mt-1">
                {{ authStore.isEtudiant ? 'Aucune note trouvée. Vous devez avoir des notes pour faire une réclamation.' : 'Aucune note disponible pour réclamation.' }}
              </p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Commentaire</label>
              <textarea
                v-model="form.commentaire"
                required
                rows="4"
                class="mt-1 block w-full border-gray-300 rounded-md"
                :placeholder="authStore.isEtudiant ? 'Décrivez votre réclamation...' : 'Motif de la réclamation (erreur de saisie, etc.)...'"
              ></textarea>
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-3">
            <button
              type="button"
              @click="closeModal"
              class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
              style="background-color: #f9fafb; color: #374151;"
            >
              Annuler
            </button>
            <button
              type="submit"
              class="px-4 py-2 rounded-md"
              style="background-color: #ca8a04; color: white;"
            >
              Soumettre
            </button>
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

const claims = ref([])
const userGrades = ref([])
const showCreateModal = ref(false)
const form = ref({
  grade_id: '',
  commentaire: ''
})

onMounted(() => {
  fetchClaims()
  fetchUserGrades()
})

const fetchClaims = async () => {
  try {
    const response = await api.get('/claims')
    claims.value = response.data
  } catch (error) {
    console.error('Erreur lors du chargement des réclamations:', error)
  }
}

const fetchUserGrades = async () => {
  try {
    if (authStore.isEtudiant) {
      // Étudiant : utiliser l'endpoint debug
      const response = await api.get('/debug/user')
      userGrades.value = response.data.grades || []
    } else if (authStore.isProfesseur) {
      // Professeur : charger toutes les notes pour faire des réclamations
      const response = await api.get('/grades')
      userGrades.value = response.data || []
    }
    console.log('Notes chargées pour réclamation:', userGrades.value.length)
  } catch (error) {
    console.error('Erreur lors du chargement des notes:', error)
    userGrades.value = []
  }
}

const createClaim = async () => {
  try {
    await api.post('/claims', form.value)
    closeModal()
    fetchClaims()
  } catch (error) {
    console.error('Erreur lors de la création de la réclamation:', error)
  }
}

const updateClaimStatus = async (id, statut) => {
  try {
    await api.put(`/claims/${id}`, { statut })
    fetchClaims()
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut:', error)
  }
}

const getStatusLabel = (statut) => {
  const labels = {
    'en_attente': 'En attente',
    'approuve': 'Approuvé',
    'rejete': 'Rejeté'
  }
  return labels[statut] || statut
}

const closeModal = () => {
  showCreateModal.value = false
  form.value = { grade_id: '', commentaire: '' }
}


</script>