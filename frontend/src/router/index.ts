import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import AdminDashboard from '../views/admin/AdminDashboard.vue';
import AdminUsersView from '../views/admin/AdminUsersView.vue';
import AdminSubjectsView from '../views/admin/AdminSubjectsView.vue';
import AdminStudentsView from '../views/admin/AdminStudentsView.vue';
import TeacherDashboard from '../views/teacher/TeacherDashboard.vue';
import StudentDashboard from '../views/student/StudentDashboard.vue';
import { useAuthStore } from '../stores/auth';

const routes = [
  { path: '/', name: 'login', component: LoginView },
  { path: '/admin', name: 'admin', component: AdminDashboard },
  { path: '/admin/students', name: 'admin-students', component: AdminStudentsView },
  { path: '/admin/users', name: 'admin-users', component: AdminUsersView },
  { path: '/admin/subjects', name: 'admin-subjects', component: AdminSubjectsView },
  { path: '/teacher', name: 'teacher', component: TeacherDashboard },
  { path: '/student', name: 'student', component: StudentDashboard },
];

const router = createRouter({ history: createWebHistory(), routes });

router.beforeEach((to) => {
  const auth = useAuthStore();
  const publicNames = new Set(['login']);
  if (!publicNames.has(to.name as string) && !auth.token) return { name: 'login' };
  if (to.name === 'login' && auth.token) {
    const role = auth.user?.role;
    if (role === 'admin') return { name: 'admin' };
    if (role === 'teacher') return { name: 'teacher' };
    return { name: 'student' };
  }
  return true;
});

export default router;
