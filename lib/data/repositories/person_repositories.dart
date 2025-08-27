import 'dart:convert';
import '../local/database_helper.dart';
import 'dart:math' as math;

import '../models/person_model.dart';

class PersonRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Save person with face embedding
  Future<int> savePerson({
    required String name,
    required List<double> embedding,
    String? thumbnailPath,
    double confidenceThreshold = 0.7,
  }) async {
    try {
      final now = DateTime.now();

      final person = Person(
        name: name,
        embedding: jsonEncode(embedding), // Convert List<double> to JSON string
        thumbnailPath: thumbnailPath,
        createdAt: now,
        updatedAt: now,
        confidenceThreshold: confidenceThreshold,
      );

      final id = await _databaseHelper.insertPerson(person);
      print("Person '$name' saved successfully with ID: $id");
      return id;
    } catch (e) {
      print("Error saving person '$name': $e");
      throw Exception("Failed to save person: $e");
    }
  }

  // Get all persons with parsed embeddings
  Future<List<Map<String, dynamic>>> getAllPersonsWithEmbeddings() async {
    try {
      final persons = await _databaseHelper.getAllPersons();

      return persons.map((person) {
        List<double> embedding = [];
        try {
          // Parse JSON string back to List<double>
          final embeddingJson = jsonDecode(person.embedding);
          embedding = List<double>.from(embeddingJson);
        } catch (e) {
          print("Error parsing embedding for person ${person.name}: $e");
          embedding = [];
        }

        return {
          'id': person.id,
          'name': person.name,
          'embedding': embedding,
          'thumbnailPath': person.thumbnailPath,
          'createdAt': person.createdAt,
          'confidenceThreshold': person.confidenceThreshold,
        };
      }).toList();
    } catch (e) {
      print("Error getting all persons: $e");
      return [];
    }
  }

  // Search person by embedding similarity (akan digunakan nanti untuk face matching)
  Future<Map<String, dynamic>?> findSimilarPerson(
    List<double> queryEmbedding,
    double similarityThreshold,
  ) async {
    try {
      final personsWithEmbeddings = await getAllPersonsWithEmbeddings();

      double highestSimilarity = 0.0;
      Map<String, dynamic>? mostSimilarPerson;

      for (final person in personsWithEmbeddings) {
        final List<double> storedEmbedding = person['embedding'];

        if (storedEmbedding.isEmpty) continue;

        // Calculate cosine similarity (will implement this in next phase)
        double similarity = _calculateCosineSimilarity(
          queryEmbedding,
          storedEmbedding,
        );

        if (similarity > highestSimilarity &&
            similarity >= similarityThreshold) {
          highestSimilarity = similarity;
          mostSimilarPerson = {...person, 'similarity': similarity};
        }
      }

      if (mostSimilarPerson != null) {
        print(
          "Found similar person: ${mostSimilarPerson['name']} (similarity: ${mostSimilarPerson['similarity']})",
        );
      }

      return mostSimilarPerson;
    } catch (e) {
      print("Error finding similar person: $e");
      return null;
    }
  }

  // Temporary cosine similarity calculation (will be improved in Phase 2)
  double _calculateCosineSimilarity(
    List<double> embedding1,
    List<double> embedding2,
  ) {
    if (embedding1.length != embedding2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  // Update person name
  Future<bool> updatePersonName(int personId, String newName) async {
    try {
      final person = await _databaseHelper.getPersonById(personId);
      if (person == null) return false;

      final updatedPerson = person.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      final result = await _databaseHelper.updatePerson(updatedPerson);
      return result > 0;
    } catch (e) {
      print("Error updating person name: $e");
      return false;
    }
  }

  // Delete person
  Future<bool> deletePerson(int personId) async {
    try {
      final result = await _databaseHelper.deletePerson(personId);
      return result > 0;
    } catch (e) {
      print("Error deleting person: $e");
      return false;
    }
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final totalPersons = await _databaseHelper.getPersonCount();
      return {'totalPersons': totalPersons};
    } catch (e) {
      print("Error getting statistics: $e");
      return {'totalPersons': 0};
    }
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    try {
      await _databaseHelper.clearAllPersons();
      print("All person data cleared");
    } catch (e) {
      print("Error clearing data: $e");
    }
  }
}
