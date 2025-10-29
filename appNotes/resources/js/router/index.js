import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import RegisterView from '../views/RegisterView.vue';
import GradesView from '../views/GradesView.vue';
import ComplaintsView from '../views/ComplaintsView.vue';
import AdminDashboardView from '../views/AdminDashboardView.vue';
import StudentDashboardView from '../views/StudentDashboardView.vue';
import AdminStudentsView from '../views/AdminStudentsView.vue';
import AdminStudentShowView from '../views/AdminStudentShowView.vue';
import AdminSubjectsView from '../views/AdminSubjectsView.vue';
import AdminGradesView from '../views/AdminGradesView.vue';
import TeacherDashboardView from '../views/TeacherDashboardView.vue';
import TeacherGradesView from '../views/TeacherGradesView.vue';
import TeacherComplaintsView from '../views/TeacherComplaintsView.vue';

const routes = [
  { path: '/login', name: 'login', component: LoginView },
  { path: '/register', name: 'register', component: RegisterView },
  { path: '/', name: 'home', component: LoginView },
  { path: '/grades', name: 'grades', component: GradesView },
  { path: '/complaints', name: 'complaints', component: ComplaintsView },
  { path: '/admin', name: 'admin', component: AdminDashboardView },
  { path: '/admin/students', name: 'admin-students', component: AdminStudentsView },
  { path: '/admin/students/:id', name: 'admin-student-show', component: AdminStudentShowView, props: true },
  { path: '/admin/subjects', name: 'admin-subjects', component: AdminSubjectsView },
  { path: '/admin/grades', name: 'admin-grades', component: AdminGradesView },
  { path: '/student', name: 'student', component: StudentDashboardView },
  { path: '/teacher', name: 'teacher', component: TeacherDashboardView },
  { path: '/teacher/grades', name: 'teacher-grades', component: TeacherGradesView },
  { path: '/teacher/complaints', name: 'teacher-complaints', component: TeacherComplaintsView },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Simple auth guard
router.beforeEach((to) => {
  const publicPages = new Set(['login', 'register']);
  try {
    const { useAuthStore } = require('../stores/auth');
    const auth = useAuthStore();

    // Redirect authenticated users away from login/register
    if (publicPages.has(to.name) && auth.token) {
      const role = auth.user?.role;
      if (role === 'admin') return { path: '/complaints' };
      if (role === 'teacher') return { path: '/teacher' };
      return { path: '/grades' };
    }

    // Root path: send to role dashboard if authenticated
    if (to.path === '/') {
      if (auth.token) {
        const role = auth.user?.role;
        if (role === 'admin') return { path: '/complaints' };
        if (role === 'teacher') return { path: '/teacher' };
        return { path: '/grades' };
      }
      return { name: 'login' };
    }

    // Protect private pages
    if (!publicPages.has(to.name) && !auth.token) {
      return { name: 'login' };
    }
  } catch (_) {}
  try {
    const { useAuthStore } = require('../stores/auth');
    const auth = useAuthStore();
  } catch (_) {}
  return true;
});

export default router;

