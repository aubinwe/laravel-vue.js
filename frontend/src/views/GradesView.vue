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
            <h1 class="text-xl font-bold text-gray-900">Gestion des Notes</h1>
          </div>
          
          <!-- Boutons selon les rôles -->
          <div class="flex space-x-3">
            <!-- Professeur et Admin peuvent ajouter des notes -->
            <button
              v-if="authStore.isProfesseur || authStore.isAdmin"
              @click="showCreateModal = true"
              class="px-4 py-2 rounded-lg flex items-center space-x-2"
              style="background-color: #4f46e5; color: white;"
            >
              <span>+ Ajouter Note</span>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Loading State -->
      <div v-if="gradesStore.loading" class="flex justify-center items-center py-12">
        <div class="flex items-center space-x-3">
          <svg class="animate-spin h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="text-gray-600">Chargement des notes...</span>
        </div>
      </div>

      <!-- Notes Grid -->
      <div v-else class="grid gap-6">
        <div v-if="gradesStore.grades.length === 0" class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Aucune note</h3>
          <p class="mt-1 text-sm text-gray-500">Commencez par ajouter une première note.</p>
        </div>
        
        <div v-else class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Liste des Notes</h3>
          </div>
          
          <div class="divide-y divide-gray-200">
            <div v-for="grade in gradesStore.grades" :key="grade.id" class="px-6 py-4 hover:bg-gray-50 transition-colors">
              <div class="flex items-center justify-between">
                <div class="flex-1">
                  <div class="flex items-center space-x-3 mb-2">
                    <h4 class="text-sm font-medium text-gray-900">
                      {{ grade.course?.name || 'Cours' }}
                    </h4>
                    <span class="px-2 py-1 text-xs font-medium rounded-full"
                          :class="grade.note >= 10 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'">
                      {{ grade.note }}/20
                    </span>
                  </div>
                  
                  <div class="flex items-center space-x-6 text-sm text-gray-500">
                    <span class="flex items-center">
                      <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                      {{ grade.student?.user?.name || 'N/A' }}
                    </span>
                    <span class="flex items-center">
                      <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a2 2 0 012-2h4a2 2 0 012 2v4m-6 0h6m-6 0l-2 2m8-2l2 2m-2-2v6a2 2 0 01-2 2H8a2 2 0 01-2-2V9" />
                      </svg>
                      {{ grade.semestre }}
                    </span>
                  </div>
                </div>
                
                <!-- Boutons selon les rôles -->
                <div v-if="authStore.isProfesseur || authStore.isAdmin" class="flex items-center space-x-2">
                  <button
                    @click="editGrade(grade)"
                    class="px-3 py-1 rounded text-sm"
                    style="background-color: #4f46e5; color: white;"
                    title="Modifier"
                  >
                    Modifier
                  </button>
                  <button
                    @click="deleteGrade(grade.id)"
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
      </div>
    </main>

    <!-- Modal Créer/Modifier -->
    <div v-if="showCreateModal" class="modal-overlay">
      <div class="modal-content" style="max-width: 500px; max-height: 90vh; overflow-y: auto;">
        <h3 class="text-lg font-medium mb-4">
          {{ editingGrade ? 'Modifier la note' : 'Ajouter une note' }}
        </h3>
        <form @submit.prevent="saveGrade">
          <div class="space-y-4">
            <div v-if="!editingGrade">
              <label class="block text-sm font-medium text-gray-700 mb-2">Étudiant</label>
              <select v-model="form.student_id" required class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option value="">Sélectionner un étudiant</option>
                <option v-for="student in students" :key="student.id" :value="student.id">
                  {{ student.user?.name }} ({{ student.matricule }})
                </option>
              </select>
            </div>
            <div v-if="!editingGrade">
              <label class="block text-sm font-medium text-gray-700 mb-2">Cours</label>
              <select v-model="form.course_id" required class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option value="">Sélectionner un cours</option>
                <option v-for="course in courses" :key="course.id" :value="course.id">
                  {{ course.name }} ({{ course.code }})
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Note (/20)</label>
              <input
                v-model="form.note"
                type="number"
                min="0"
                max="20"
                step="0.01"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md"
                placeholder="Ex: 15.5"
              />
            </div>
            <div v-if="!editingGrade">
              <label class="block text-sm font-medium text-gray-700 mb-2">Semestre</label>
              <input
                v-model="form.semestre"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md"
                placeholder="Ex: S1 2024"
              />
            </div>
          </div>
          <div class="mt-6 flex justify-end space-x-3">
            <button
              type="button"
              @click="closeModal"
              class="px-4 py-2 border border-gray-300 rounded-md"
              style="background-color: #f9fafb; color: #374151;"
            >
              Annuler
            </button>
            <button
              type="submit"
              class="px-4 py-2 rounded-md"
              style="background-color: #2563eb; color: white;"
            >
              {{ editingGrade ? 'Modifier' : 'Ajouter' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Ajouter Cours -->
    <div v-if="showCourseModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center" style="z-index: 9999;">
      <div class="bg-white p-6 rounded-lg max-w-md w-full mx-4">
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useGradesStore } from '@/stores/grades'
import api from '@/lib/axios'

const authStore = useAuthStore()
const gradesStore = useGradesStore()

const showCreateModal = ref(false)
const showCourseModal = ref(false)
const editingGrade = ref(null)
const students = ref([])
const courses = ref([])
const form = ref({
  student_id: '',
  course_id: '',
  note: '',
  semestre: ''
})
const courseForm = ref({
  name: '',
  code: '',
  coefficient: 1
})

onMounted(() => {
  gradesStore.fetchGrades()
  fetchStudents()
  fetchCourses()
})

const fetchStudents = async () => {
  try {
    const response = await api.get('/students')
    students.value = response.data
  } catch (error) {
    console.error('Erreur lors du chargement des étudiants:', error)
  }
}

const fetchCourses = async () => {
  try {
    const response = await api.get('/courses')
    courses.value = response.data
  } catch (error) {
    console.error('Erreur lors du chargement des cours:', error)
  }
}

const editGrade = (grade) => {
  editingGrade.value = grade
  form.value = { note: grade.note }
  showCreateModal.value = true
}

const saveGrade = async () => {
  let result
  if (editingGrade.value) {
    result = await gradesStore.updateGrade(editingGrade.value.id, form.value)
  } else {
    result = await gradesStore.createGrade(form.value)
  }
  
  if (result.success) {
    closeModal()
  }
}

const deleteGrade = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette note ?')) {
    await gradesStore.deleteGrade(id)
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingGrade.value = null
  form.value = { student_id: '', course_id: '', note: '', semestre: '' }
}

const createCourse = async () => {
  try {
    const data = { ...courseForm.value, professor_id: authStore.user.id }
    await api.post('/courses', data)
    showCourseModal.value = false
    courseForm.value = { name: '', code: '', coefficient: 1 }
    fetchCourses()
    alert('Cours ajouté avec succès')
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors de l\'ajout du cours')
  }
}
</script>