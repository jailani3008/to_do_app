import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'tasks_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final tc = Get.find<TasksController>();
      tc.tasks.clear();
      await tc.fetchTasks();

      Get.snackbar("Success", "Welcome back!",
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> register({required String name, required String email, required String password}) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.updateDisplayName(name);

      await _auth.signOut();
      Get.find<TasksController>().tasks.clear();

      Get.snackbar(
        "Account Created", "Registration successful! Please sign in.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 4),
      );
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        "Email Sent",
        "Check your inbox to reset your password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
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