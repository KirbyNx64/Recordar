import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;
  String _userName = "Usuario";
  String _birthDate = "01/01/2000";
  String _country = "País";
  String _phone = "+000 000000000";
  File? _image;  // Variable para la imagen de perfil

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadImage();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = _prefs.getString('user_name') ?? "Usuario";
      _birthDate = _prefs.getString('birth_date') ?? "01/01/2000";
      _country = _prefs.getString('country') ?? "País";
      _phone = _prefs.getString('phone') ?? "+000 000000000";
    });
  }

  Future<void> _loadImage() async {
    _prefs = await SharedPreferences.getInstance();
    String? imagePath = _prefs.getString('profile_image');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  void _editProfile() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userName: _userName,
          birthDate: _birthDate,
          country: _country,
          phone: _phone,
        ),
      ),
    );

    if (updated == true) {
      _loadUserData(); // Recargar datos después de la edición
    }
  }

  void _showEditOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Perfil"),
          content: const Text("Elige una opción para editar:"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editProfile();
              },
              child: const Text("Editar Datos Personales"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage();
              },
              child: const Text("Editar Foto de Perfil"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Guardar la ruta de la imagen seleccionada en SharedPreferences
      await _prefs.setString('profile_image', pickedFile.path);
    }
  }

  Widget _buildProfileField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _TopPortion(image: _image),  // Foto de perfil ajustada aquí
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildProfileField("Fecha de nacimiento", _birthDate),
                  _buildProfileField("País", _country),
                  _buildProfileField("Número de celular", _phone),
                  const Spacer(),
                  // Eliminamos el ElevatedButton
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditOptions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  final File? image;
  const _TopPortion({required this.image});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
                image: image != null
                    ? DecorationImage(fit: BoxFit.cover, image: FileImage(image!))
                    : null,
              ),
              child: image == null ? const Center(child: Icon(Icons.person, size: 80)) : null,
            ),
          ],
        ),
      ),
    );
  }
}
