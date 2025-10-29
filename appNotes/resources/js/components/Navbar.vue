<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <router-link class="navbar-brand" to="/">appNotes</router-link>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="nav">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0" v-if="isAuthenticated">
          <li class="nav-item">
            <router-link class="nav-link" to="/grades">Mes notes (moyenne)</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/complaints">Réclamation</router-link>
          </li>
          <li v-if="isTeacher" class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
              Professeur
            </a>
            <ul class="dropdown-menu">
              <li><router-link class="dropdown-item" to="/teacher">Dashboard</router-link></li>
              <li><router-link class="dropdown-item" to="/teacher/grades">Notes</router-link></li>
              <li><router-link class="dropdown-item" to="/teacher/complaints">Réclamations</router-link></li>
            </ul>
          </li>
          <li v-if="isAdmin" class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
              Admin
            </a>
            <ul class="dropdown-menu">
              <li><router-link class="dropdown-item" to="/admin">Dashboard</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/students">Étudiants</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/subjects">Matières</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/grades">Notes</router-link></li>
            </ul>
          </li>
        </ul>
        <ul class="navbar-nav ms-auto">
          <li v-if="isAdmin && isAuthenticated" class="nav-item me-2">
            <button class="btn btn-sm btn-outline-light" @click="exportStudents">
              <i class="bi bi-download me-1"></i> Etudiants CSV
            </button>
          </li>
          <li v-if="!isAuthenticated" class="nav-item">
            <router-link class="nav-link" to="/login">Connexion</router-link>
          </li>
          <li v-if="!isAuthenticated" class="nav-item">
            <router-link class="nav-link" to="/register">Inscription</router-link>
          </li>
          <li v-else class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
              {{ user?.name || 'Compte' }}
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
              <li><button class="dropdown-item" @click="onLogout">Se déconnecter</button></li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>
<script setup>
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import axios from 'axios';

const auth = useAuthStore();
const { isAuthenticated, user, isAdmin, isTeacher, token } = storeToRefs(auth);
const onLogout = async () => { await auth.logout(); };

const exportStudents = async () => {
  try {
    const api = axios.create({ baseURL: '/api/v1', responseType: 'blob' });
    api.interceptors.request.use((cfg) => {
      if (token.value) cfg.headers.Authorization = `Bearer ${token.value}`;
      return cfg;
    });
    const res = await api.get('/admin/export/students');
    const blob = new Blob([res.data], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'students.csv'; a.click();
    window.URL.revokeObjectURL(url);
  } catch (e) {
    alert('Export impossible');
  }
};
</script>
