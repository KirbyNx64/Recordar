import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Para formatear la fecha y la hora
import 'reminder.dart';  // Asegúrate de importar Reminder aquí

class EditReminderPage extends StatefulWidget {
  final Reminder reminder;

  const EditReminderPage({super.key, required this.reminder});

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late TextEditingController _descriptionController;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reminder.name);
    _placeController = TextEditingController(text: widget.reminder.place);
    _descriptionController = TextEditingController(text: widget.reminder.description);
    _dateTime = widget.reminder.dateTime;
  }

  // Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dateTime.hour,
          _dateTime.minute,
        );
      });
    }
  }

  // Función para seleccionar la hora
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _dateTime.hour, minute: _dateTime.minute),
    );

    if (picked != null) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Recordatorio")),
      body: SingleChildScrollView(  // Se añadió este widget para permitir el desplazamiento
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
          children: [
            // Título y cuadro para el nombre
            Text(
              'Nombre',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Título y cuadro para el lugar
            Text(
              'Lugar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _placeController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Título y cuadro para la descripción
            Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Título para la fecha
            Text(
              'Fecha',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Cuadro para la fecha
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(_dateTime),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Título para la hora
            Text(
              'Hora',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Cuadro para la hora
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('hh:mm a').format(_dateTime),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Botón para guardar cambios alineado a la derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final editedReminder = Reminder(
                      name: _nameController.text,
                      place: _placeController.text,
                      description: _descriptionController.text,
                      dateTime: _dateTime,
                    );

                    Navigator.pop(context, editedReminder); // Volver con el recordatorio editado
                  },
                  child: Text("Guardar cambios"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
