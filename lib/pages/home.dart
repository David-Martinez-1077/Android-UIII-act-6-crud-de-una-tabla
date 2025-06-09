import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/add_page.dart';
import 'package:myapp/service/database.dart';
import 'package:intl/intl.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? coursesStream;

  @override
  void initState() {
    super.initState();
    getCourses();
  }

  void getCourses() {
    setState(() {
      coursesStream = DatabaseMethods().getCoursesDetails();
    });
  }

  Future<void> showEditCourseDialog(DocumentSnapshot course) async {
    TextEditingController titleController = TextEditingController(text: course['titulo']);
    TextEditingController descriptionController = TextEditingController(text: course['descripcion']);
    TextEditingController instructorController = TextEditingController(text: course['instructor_id']);
    TextEditingController priceController = TextEditingController(text: course['precio'].toString());
    TextEditingController categoryController = TextEditingController(text: course['categoria']);
    DateTime selectedDate = course['fecha'].toDate();

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

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Course'),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: instructorController,
                    decoration: InputDecoration(labelText: 'Instructor ID'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Date: '),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          "${selectedDate.toLocal()}".split(' ')[0],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      instructorController.text.isNotEmpty &&
                      priceController.text.isNotEmpty &&
                      categoryController.text.isNotEmpty) {
                    await DatabaseMethods().updateCourseData(
                      course.id,
                      {
                        'titulo': titleController.text,
                        'descripcion': descriptionController.text,
                        'instructor_id': instructorController.text,
                        'precio': double.parse(priceController.text),
                        'categoria': categoryController.text,
                        'fecha': selectedDate,
                      },
                    );
                    getCourses();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Course updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> confirmDelete(String courseId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Borrar el curso'),
        content: Text('¿Estás seguro que quieres borrar este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseMethods().deleteCourseData(courseId);
      getCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Curso eliminado exitosamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget coursesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: coursesStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los datos'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cursos disponibles'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return Container(
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ds['titulo'],
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditCourseDialog(ds),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDelete(ds.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    ds['descripcion'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16),
                      SizedBox(width: 5),
                      Text('Instructor: ${ds['instructor_id']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16),
                      SizedBox(width: 5),
                      Text('Precio: \$${ds['precio'].toStringAsFixed(2)}'),
                      Spacer(),
                      Icon(Icons.category, size: 16),
                      SizedBox(width: 5),
                      Text('Categoría: ${ds['categoria']}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text('Fecha: ${DateFormat('yyyy-MM-dd').format(ds['fecha'].toDate())}'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla cursos - Martínez Nava - 1077'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage()))
              .then((_) => getCourses());
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: coursesList(),
            ),
          ],
        ),
      ),
    );
  }
}