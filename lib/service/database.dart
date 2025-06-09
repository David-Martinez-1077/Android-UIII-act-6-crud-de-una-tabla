import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Añadir nuevo curso
  Future addCourse(Map<String, dynamic> courseInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("cursos")
        .doc(id)
        .set(courseInfoMap);
  }

  // Obtener todos los cursos
  Stream<QuerySnapshot> getCoursesDetails() {
    return FirebaseFirestore.instance.collection("cursos").snapshots();
  }

  // Eliminar curso
  deleteCourseData(String id) async {
    return await FirebaseFirestore.instance
        .collection("cursos")
        .doc(id)
        .delete();
  }

  // Actualizar curso
  updateCourseData(String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("cursos")
        .doc(id)
        .update(updateInfo);
  }
}