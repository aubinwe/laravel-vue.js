<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-3">
            <div class="h-8 w-8 bg-indigo-600 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold">📚</span>
            </div>
            <h1 class="text-xl font-bold text-gray-900">Gestion Notes</h1>
          </div>
          
          <div class="flex items-center space-x-4">
            <div class="text-right">
              <p class="text-sm font-medium text-gray-900">{{ authStore.user?.name }}</p>
              <p class="text-xs text-gray-500 capitalize">{{ authStore.user?.role?.name }}</p>
            </div>
            <div class="h-8 w-8 bg-gray-300 rounded-full flex items-center justify-center">
              <span class="text-gray-600 text-sm font-medium">
                {{ authStore.user?.name?.charAt(0).toUpperCase() }}
              </span>
            </div>
            <button
              @click="handleLogout"
              class="text-gray-400 hover:text-gray-600 transition-colors"
              title="Déconnexion"
            >
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <!-- Welcome Section -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold text-gray-900 mb-2">
          Bienvenue, {{ authStore.user?.name }} !
        </h2>
        <p class="text-gray-600">
          Accédez rapidement à vos fonctionnalités principales
        </p>
      </div>

      <!-- Quick Actions Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Notes Card -->
        <router-link
          to="/grades"
          class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-indigo-300"
        >
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-indigo-100 rounded-lg flex items-center justify-center group-hover:bg-indigo-200 transition-colors">
                <svg class="h-6 w-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-indigo-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Notes</h3>
            <p class="text-gray-600 text-sm">
              {{ authStore.isEtudiant ? 'Consulter mes notes' : 'Gérer les notes' }}
            </p>
          </div>
        </router-link>

        <!-- Claims Card -->
        <router-link
          to="/claims"
          class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-yellow-300"
        >
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-yellow-100 rounded-lg flex items-center justify-center group-hover:bg-yellow-200 transition-colors">
                <svg class="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-yellow-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Réclamations</h3>
            <p class="text-gray-600 text-sm">
              {{ authStore.isAdmin ? 'Traiter les réclamations' : 'Mes réclamations' }}
            </p>
          </div>
        </router-link>

        <!-- Gestion Étudiants (Admin seulement) -->
        <router-link v-if="authStore.isAdmin"
             to="/students"
             class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-purple-300 cursor-pointer block">
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-purple-100 rounded-lg flex items-center justify-center group-hover:bg-purple-200 transition-colors">
                <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-purple-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Étudiants</h3>
            <p class="text-gray-600 text-sm">Gérer les étudiants</p>
          </div>
        </router-link>

        <!-- Gestion Cours (Admin seulement) -->
        <div v-if="authStore.isAdmin"
             @click="showCourseModal = true"
             class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-orange-300 cursor-pointer">
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-orange-100 rounded-lg flex items-center justify-center group-hover:bg-orange-200 transition-colors">
                <svg class="h-6 w-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-orange-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Cours</h3>
            <p class="text-gray-600 text-sm">Gérer les cours</p>
          </div>
        </div>

        <!-- Bulletin Card (Étudiant seulement) -->
        <div v-if="authStore.user?.role?.name === 'etudiant'"
             @click="downloadBulletin"
             class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-blue-300 cursor-pointer">
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 transition-colors">
                <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-blue-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Mon Bulletin</h3>
            <p class="text-gray-600 text-sm">Télécharger mon bulletin de notes</p>
          </div>
        </div>

        <!-- Profile Card (Toujours visible) -->
        <router-link to="/profile"
             class="group bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 hover:border-green-300 cursor-pointer block">
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="h-12 w-12 bg-green-100 rounded-lg flex items-center justify-center group-hover:bg-green-200 transition-colors">
                <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <svg class="h-5 w-5 text-gray-400 group-hover:text-green-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Profil</h3>
            <p class="text-gray-600 text-sm">Mes informations personnelles</p>
          </div>
        </router-link>
      </div>

      <!-- Stats Section (if admin) -->
      <div v-if="authStore.isAdmin" class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Statistiques</h3>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div class="text-center p-4 bg-blue-50 rounded-lg">
            <div class="text-2xl font-bold text-blue-600">{{ stats.total_students }}</div>
            <div class="text-sm text-gray-600">Total Étudiants</div>
          </div>
          <div class="text-center p-4 bg-green-50 rounded-lg">
            <div class="text-2xl font-bold text-green-600">{{ stats.total_grades }}</div>
            <div class="text-sm text-gray-600">Notes Saisies</div>
          </div>
          <div class="text-center p-4 bg-yellow-50 rounded-lg">
            <div class="text-2xl font-bold text-yellow-600">{{ stats.total_claims }}</div>
            <div class="text-sm text-gray-600">Réclamations</div>
          </div>
          <div class="text-center p-4 bg-purple-50 rounded-lg">
            <div class="text-2xl font-bold text-purple-600">{{ stats.total_courses }}</div>
            <div class="text-sm text-gray-600">Cours Actifs</div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Ajouter Étudiant -->
    <div v-if="showStudentModal" class="modal-overlay">
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
            <button type="button" @click="showStudentModal = false" class="px-4 py-2 border border-gray-300 rounded-md" style="background-color: #f9fafb; color: #374151;">Annuler</button>
            <button type="submit" class="px-4 py-2 rounded-md" style="background-color: #9333ea; color: white;">Ajouter</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Ajouter Cours -->
    <div v-if="showCourseModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="text-lg font-medium mb-4">Ajouter un cours</h3>
        <form @submit.prevent="createCourse">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Nom du cours</label>
              <input v-model="courseForm.name" type="text" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Code</label>
              <input v-model="courseForm.code" type="text" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Coefficient</label>
              <input v-model="courseForm.coefficient" type="number" min="1" required class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-3">
            <button type="button" @click="showCourseModal = false" class="px-4 py-2 border border-gray-300 rounded-md" style="background-color: #f9fafb; color: #374151;">Annuler</button>
            <button type="submit" class="px-4 py-2 rounded-md" style="background-color: #ea580c; color: white;">Ajouter</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Profil -->
    <div v-if="showProfileModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="text-lg font-medium mb-4">Mon Profil</h3>
        <div v-if="userProfile" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Nom</label>
            <p class="mt-1 text-sm text-gray-900">{{ userProfile.name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Email</label>
            <p class="mt-1 text-sm text-gray-900">{{ userProfile.email }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Rôle</label>
            <p class="mt-1 text-sm text-gray-900 capitalize">{{ userProfile.role?.name }}</p>
          </div>
          <div v-if="userProfile.student">
            <label class="block text-sm font-medium text-gray-700">Matricule</label>
            <p class="mt-1 text-sm text-gray-900">{{ userProfile.student.matricule }}</p>
          </div>
          <div v-if="userProfile.student">
            <label class="block text-sm font-medium text-gray-700">Filière</label>
            <p class="mt-1 text-sm text-gray-900">{{ userProfile.student.filiere }}</p>
          </div>
        </div>
        <div class="mt-6 flex justify-end">
          <button @click="showProfileModal = false" class="px-4 py-2 rounded-md" style="background-color: #16a34a; color: white;">Fermer</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/lib/axios'

const router = useRouter()
const authStore = useAuthStore()

const showStudentModal = ref(false)
const showCourseModal = ref(false)
const showProfileModal = ref(false)
const userProfile = ref(null)
const stats = ref({
  total_students: 0,
  total_grades: 0,
  total_claims: 0,
  total_courses: 0
})

const studentForm = ref({
  name: '',
  email: '',
  filiere: '',
  password: ''
})

const courseForm = ref({
  name: '',
  code: '',
  coefficient: 1
})

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}

const downloadBulletin = async () => {
  try {
    const response = await api.get('/bulletin/download')
    
    // Ouvrir le bulletin dans une nouvelle fenêtre
    const newWindow = window.open('', '_blank')
    newWindow.document.write(response.data)
    newWindow.document.close()
    
  } catch (error) {
    console.error('Erreur lors du téléchargement:', error)
    if (error.response?.status === 404) {
      alert('Aucune note disponible pour générer le bulletin')
    } else {
      alert('Erreur lors du téléchargement du bulletin')
    }
  }
}

const createStudent = async () => {
  try {
    await api.post('/students', studentForm.value)
    showStudentModal.value = false
    studentForm.value = { name: '', email: '', filiere: '', password: '' }
    alert('Étudiant ajouté avec succès')
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors de l\'ajout de l\'\u00e9tudiant')
  }
}

const createCourse = async () => {
  try {
    const data = { ...courseForm.value }
    if (authStore.isProfesseur) {
      data.professor_id = authStore.user.id
    }
    await api.post('/courses', data)
    showCourseModal.value = false
    courseForm.value = { name: '', code: '', coefficient: 1 }
    alert('Cours ajouté avec succès')
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors de l\'ajout du cours')
  }
}

const loadProfile = async () => {
  try {
    const response = await api.get('/profile')
    userProfile.value = response.data
    showProfileModal.value = true
  } catch (error) {
    console.error('Erreur:', error)
  }
}

const loadStats = async () => {
  if (authStore.isAdmin) {
    try {
      const response = await api.get('/stats')
      stats.value = response.data
    } catch (error) {
      console.error('Erreur:', error)
    }
  }
}

onMounted(() => {
  loadStats()
})
</script>