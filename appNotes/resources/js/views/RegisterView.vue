<template>
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card shadow-sm">
          <div class="card-body">
            <h4 class="mb-4">Inscription</h4>
            <div v-if="error" class="alert alert-danger">{{ error }}</div>
            <form @submit.prevent="onSubmit">
              <div class="mb-3">
                <label class="form-label">Nom</label>
                <input v-model="name" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Email</label>
                <input v-model="email" type="email" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Mot de passe</label>
                <input v-model="password" type="password" class="form-control" required />
              </div>
              <button class="btn btn-success w-100" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                Créer le compte
              </button>
            </form>
            <hr>
            <router-link to="/login">J'ai déjà un compte</router-link>
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
const { loading, error } = storeToRefs(auth);

const name = ref('');
const email = ref('');
const password = ref('');

const onSubmit = async () => {
  const ok = await auth.register({ name: name.value, email: email.value, password: password.value });
  if (ok) router.push('/login');
};
</script>
