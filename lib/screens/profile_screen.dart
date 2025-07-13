import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final dateNaissanceController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = auth.currentUser;
    if (user != null) {
      final snapshot = await firestore.collection('users').doc(user.uid).get();
      final data = snapshot.data();
      if (data != null) {
        nomController.text = data['nom'] ?? '';
        prenomController.text = data['prenom'] ?? '';
        emailController.text = data['email'] ?? '';
        dateNaissanceController.text = data['dateNaissance'] ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = auth.currentUser;
    if (user == null) return;

    try {
      await firestore.collection('users').doc(user.uid).update({
        'nom': nomController.text.trim(),
        'prenom': prenomController.text.trim(),
        'email': emailController.text.trim(),
        'dateNaissance': dateNaissanceController.text.trim(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil mis à jour")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  Future<void> _changePassword() async {
    final user = auth.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPasswordController.text.trim(),
    );

    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text.trim());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mot de passe mis à jour")));
      oldPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer votre nom" : null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer votre prénom" : null,
              ),
              TextFormField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: dateNaissanceController,
                decoration: const InputDecoration(
                  labelText: "Date de naissance",
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateNaissanceController.text = date
                        .toIso8601String()
                        .split('T')
                        .first;
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Mettre à jour"),
              ),
              const Divider(height: 40),
              const Text(
                "Changer le mot de passe",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: "Ancien mot de passe",
                ),
                obscureText: true,
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: "Nouveau mot de passe",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Changer le mot de passe"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
