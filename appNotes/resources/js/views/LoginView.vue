<template>
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-10">
        <div class="card shadow-sm overflow-hidden">
          <div class="row g-0">
            <div class="col-md-6 p-4">
              <h4 class="mb-4">Connexion</h4>
              <div v-if="error" class="alert alert-danger">{{ error }}</div>
              <form @submit.prevent="onSubmit">
                <div class="mb-3">
                  <label class="form-label">Email</label>
                  <input v-model="email" type="email" class="form-control" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">Mot de passe</label>
                  <input v-model="password" type="password" class="form-control" required />
                </div>
                <button class="btn btn-primary w-100" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                  Se connecter
                </button>
              </form>
              <hr>
              <router-link to="/register">Créer un compte</router-link>
            </div>
            <div class="col-md-6 bg-light d-flex align-items-center justify-content-center p-4">
              <div class="text-center">
                <div class="mb-3">
                  <!-- Student logo SVG -->
                  <svg width="140" height="140" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M2 7l10-4 10 4-10 4L2 7z" fill="#0d6efd"/>
                    <path d="M4 9v5c0 1.657 3.582 3 8 3s8-1.343 8-3V9" stroke="#0d6efd" stroke-width="1.5"/>
                    <circle cx="12" cy="8" r="1" fill="#fff"/>
                  </svg>
                </div>
                <h5 class="mb-1">Étudiant</h5>
                <p class="text-muted mb-0">Accédez à vos notes et votre bulletin</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';

const router = useRouter();
const auth = useAuthStore();
const { loading, error, isAuthenticated } = storeToRefs(auth);

const email = ref('');
const password = ref('');

// Pas de redirection automatique ici; on laisse l'user décider ou on redirige après login

const onSubmit = async () => {
  const ok = await auth.login(email.value, password.value);
  if (ok) {
    const role = auth.user?.role;
    if (role === 'admin') return router.push('/admin');
    if (role === 'teacher') return router.push('/teacher');
    return router.push('/student');
  }
};
</script>

