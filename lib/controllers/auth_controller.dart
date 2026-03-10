import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'tasks_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserName => _auth.currentUser?.displayName;

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final tc = Get.find<TasksController>();
      tc.tasks.clear();
      await tc.fetchTasks();

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.updateDisplayName(name);

      final tc = Get.find<TasksController>();
      tc.tasks.clear();

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Email Sent ✅',
        'Password reset link sent to $email\n\nCheck your spam folder if you don\'t see it.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('user-not-found')) {
        msg = 'No account found with this email.';
      } else if (msg.contains('invalid-email')) {
        msg = 'Please enter a valid email address.';
      } else if (msg.contains('too-many-requests')) {
        msg = 'Too many attempts. Please try again later.';
      }
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.find<TasksController>().tasks.clear();
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}