import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import AdminDashboard from '../views/admin/AdminDashboard.vue';
import AdminUsersView from '../views/admin/AdminUsersView.vue';
import AdminSubjectsView from '../views/admin/AdminSubjectsView.vue';
import AdminStudentsView from '../views/admin/AdminStudentsView.vue';
import AdminGradesView from '../views/admin/AdminGradesView.vue';
import AdminStudentShow from '../views/admin/AdminStudentShow.vue';
import TeacherDashboard from '../views/teacher/TeacherDashboard.vue';
import TeacherGradesView from '../views/teacher/TeacherGradesView.vue';
import TeacherComplaintsView from '../views/teacher/TeacherComplaintsView.vue';
import StudentDashboard from '../views/student/StudentDashboard.vue';
import StudentGradesView from '../views/student/StudentGradesView.vue';
import StudentComplaintsView from '../views/student/StudentComplaintsView.vue';
import Page403 from '../views/errors/Page403.vue';
import Page404 from '../views/errors/Page404.vue';
import { useAuthStore } from '../stores/auth';

const routes = [
  { path: '/', name: 'login', component: LoginView },
  { path: '/admin', name: 'admin', component: AdminDashboard, meta: { role: 'admin' } },
  { path: '/admin/students', name: 'admin-students', component: AdminStudentsView, meta: { role: 'admin' } },
  { path: '/admin/students/:id', name: 'admin-student-show', component: AdminStudentShow, props: true, meta: { role: 'admin' } },
  { path: '/admin/users', name: 'admin-users', component: AdminUsersView, meta: { role: 'admin' } },
  { path: '/admin/subjects', name: 'admin-subjects', component: AdminSubjectsView, meta: { role: 'admin' } },
  { path: '/admin/grades', name: 'admin-grades', component: AdminGradesView, meta: { role: 'admin' } },
  { path: '/teacher', name: 'teacher', component: TeacherDashboard, meta: { role: 'teacher' } },
  { path: '/teacher/grades', name: 'teacher-grades', component: TeacherGradesView, meta: { role: 'teacher' } },
  { path: '/teacher/complaints', name: 'teacher-complaints', component: TeacherComplaintsView, meta: { role: 'teacher' } },
  { path: '/student', name: 'student', component: StudentDashboard, meta: { role: 'user' } },
  { path: '/student/grades', name: 'student-grades', component: StudentGradesView, meta: { role: 'user' } },
  { path: '/student/complaints', name: 'student-complaints', component: StudentComplaintsView, meta: { role: 'user' } },
  { path: '/403', name: '403', component: Page403 },
  { path: '/:pathMatch(.*)*', name: '404', component: Page404 },
];

const router = createRouter({ history: createWebHistory(), routes });

router.beforeEach((to) => {
  const auth = useAuthStore();
  const publicNames = new Set(['login']);
  if (!publicNames.has(to.name as string) && !auth.token) return { name: 'login' };
  const needRole = (to.meta as any)?.role as string|undefined;
  if (needRole && auth.user?.role && auth.user.role !== needRole) return { name: '403' };
  if (to.name === 'login' && auth.token) {
    const role = auth.user?.role;
    if (role === 'admin') return { name: 'admin' };
    if (role === 'teacher') return { name: 'teacher' };
    return { name: 'student' };
  }
  return true;
});

export default router;
