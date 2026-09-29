import 'package:flutter/material.dart';
import 'auth_service.dart'; // Upar wali file ko import karna zaroori hy
import 'main.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App ka logo ya icon
            Icon(Icons.lock_person, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text("Nexus AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 50),

            // Google Login Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
              label: Text("Continue with Google", style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Yahan humne bataya ke login k baad 'PlaceholderScreen' par jao
                // Aap yahan apni Dashboard screen ka naam likhengi
                AuthService().loginWithGoogle(context, const TaskListScreen());

              },
            ),
          ],
        ),
      ),
    );
  }
}

// Ye sirf temporary screen hy check karne k liye
class PlaceholderDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(child: Text("Welcome! You are logged in.")),
    );
  }
}