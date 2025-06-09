import 'package:flutter/material.dart';
import 'package:myapp/service/database.dart';
import 'package:random_string/random_string.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController instructorController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  SizedBox(width: 80.0),
                  Text(
                    "Añadir ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Curso",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              
              // Campo Título
              _buildTextField("Título", "Añadir título del curso", titleController),
              
              // Campo Descripción
              _buildTextField("Descripción", "Añadir descripción del curso", descriptionController, maxLines: 3),
              
              // Campo Instructor ID
              _buildTextField("Instructor ID", "Añadir instructor id del curso", instructorController),
              
              // Campo Precio
              _buildTextField("precio", "Añadir precio del curso", priceController, keyboardType: TextInputType.number),
              
              // Campo Categoría
              _buildTextField("Categoría", "Añadir Categoría del curso", categoryController),
              
              // Selector de Fecha
              Row(
                children: [
                  Text(
                    "Fecha: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30.0),
              
              // Botón para agregar curso
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        instructorController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        categoryController.text.isNotEmpty) {
                      
                      String addID = randomAlphaNumeric(10);
                      Map<String, dynamic> courseInfoMap = {
                        "titulo": titleController.text,
                        "descripcion": descriptionController.text,
                        "instructor_id": instructorController.text,
                        "precio": double.parse(priceController.text),
                        "categoria": categoryController.text,
                        "fecha": selectedDate,
                      };
                      
                      await DatabaseMethods()
                          .addCourse(courseInfoMap, addID)
                          .then((value) {
                        // Limpiar campos
                        titleController.clear();
                        descriptionController.clear();
                        instructorController.clear();
                        priceController.clear();
                        categoryController.clear();
                        
                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Curso añadido exitosamente",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                        
                        // Regresar a la página anterior
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Añadir curso",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, 
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.only(left: 20.0),
          decoration: BoxDecoration(
            color: Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}