import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String birthDate;
  final String country;
  final String phone;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.birthDate,
    required this.country,
    required this.phone,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _birthController;
  late TextEditingController _phoneController;
  late SharedPreferences _prefs;
  late String _selectedCountry;

  final List<String> _countries = [
    // Sudamérica
    "Argentina", "Bolivia", "Brasil", "Chile", "Colombia", "Ecuador",
    "Paraguay", "Perú", "Uruguay", "Venezuela",

    // Centroamérica
    "Belice", "Costa Rica", "El Salvador", "Guatemala", "Honduras", 
    "Nicaragua", "Panamá",

    // Norteamérica
    "México", "Estados Unidos", "Canadá",

    // Europa
    "España", "Reino Unido", "Francia", "Alemania", "Italia",

    // Asia
    "Japón", "China", "India", "Rusia",

    // Oceanía
    "Australia"
  ];



  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _birthController = TextEditingController(text: widget.birthDate);
    _phoneController = TextEditingController(text: widget.phone);
    _selectedCountry = _countries.contains(widget.country) ? widget.country : _countries.first;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedCountry = _prefs.getString('country');
    if (savedCountry != null && _countries.contains(savedCountry)) {
      setState(() {
        _selectedCountry = savedCountry;
      });
    }
  }

  Future<void> _saveData() async {
    await _prefs.setString('user_name', _nameController.text);
    await _prefs.setString('birth_date', _birthController.text);
    await _prefs.setString('country', _selectedCountry);
    await _prefs.setString('phone', _phoneController.text);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Colors.black,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _birthController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField("Nombre", _nameController),
            _buildDatePickerField("Fecha de nacimiento", _birthController),
            _buildCountryDropdown(),
            _buildEditableField("Número de celular", _phoneController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: const Text("Guardar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String title, TextEditingController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.text.isNotEmpty ? controller.text : "Selecciona una fecha",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black54,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("País", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedCountry = newValue);
              }
            },
            items: _countries.map<DropdownMenuItem<String>>((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
