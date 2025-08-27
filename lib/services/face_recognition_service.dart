import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  static const String modelPath = 'assets/models/mobile_face_net.tflite';
  static const int inputSize = 112; // MobileFaceNet input size
  static const int embeddingSize = 192; // Output embedding dimensions

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Singleton pattern
  static final FaceRecognitionService _instance =
      FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  // Load TFLite model
  Future<bool> loadModel() async {
    try {
      print("Loading MobileFaceNet model from $modelPath...");

      // Load model from assets
      _interpreter = await Interpreter.fromAsset(modelPath);

      // Verify model input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      print("Model loaded successfully!");
      print("Input shape: $inputShape");
      print("Output shape: $outputShape");
      print("Expected input: [1, $inputSize, $inputSize, 3]");
      print("Expected output: [1, $embeddingSize]");

      _isModelLoaded = true;
      return true;
    } catch (e) {
      print("Error loading model: $e");
      _isModelLoaded = false;
      return false;
    }
  }

  // Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  // Generate face embedding from cropped face image
  Future<List<double>?> generateEmbedding(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      print("Model not loaded. Call loadModel() first.");
      return null;
    }

    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print("Failed to decode image");
        return null;
      }

      // Preprocess image for MobileFaceNet
      final preprocessed = _preprocessImage(image);
      if (preprocessed == null) {
        print("Failed to preprocess image");
        return null;
      }

      // Run inference
      final output = List.filled(
        1 * embeddingSize,
        0.0,
      ).reshape([1, embeddingSize]);
      _interpreter!.run(preprocessed, output);

      // Extract embedding from output
      final embedding = List<double>.from(output[0]);

      // Normalize embedding (L2 normalization)
      final normalizedEmbedding = _normalizeEmbedding(embedding);

      print(
        "Generated embedding with ${normalizedEmbedding.length} dimensions",
      );
      return normalizedEmbedding;
    } catch (e) {
      print("Error generating embedding: $e");
      return null;
    }
  }

  // Preprocess image for MobileFaceNet input
  List<List<List<List<double>>>>? _preprocessImage(img.Image image) {
    try {
      // Resize image to 112x112
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );

      // Convert to RGB format and normalize to [-1, 1]
      final input = List.generate(
        1,
        (b) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) => List.generate(3, (c) {
              final pixel = resized.getPixel(x, y);
              double value;

              switch (c) {
                case 0: // Red
                  value = pixel.r.toDouble();
                  break;
                case 1: // Green
                  value = pixel.g.toDouble();
                  break;
                case 2: // Blue
                  value = pixel.b.toDouble();
                  break;
                default:
                  value = 0.0;
              }

              // Normalize from [0, 255] to [-1, 1]
              return (value - 127.5) / 127.5;
            }),
          ),
        ),
      );

      return input;
    } catch (e) {
      print("Error preprocessing image: $e");
      return null;
    }
  }

  // Normalize embedding using L2 normalization
  List<double> _normalizeEmbedding(List<double> embedding) {
    double norm = 0.0;
    for (double value in embedding) {
      norm += value * value;
    }
    norm = math.sqrt(norm);

    if (norm == 0.0) return embedding;

    return embedding.map((value) => value / norm).toList();
  }

  // Calculate cosine similarity between two embeddings
  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      print(
        "Embedding dimensions mismatch: ${embedding1.length} vs ${embedding2.length}",
      );
      return 0.0;
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    final similarity = dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
    return similarity.clamp(-1.0, 1.0); // Clamp to valid range
  }

  // Convert similarity to percentage
  double similarityToPercentage(double similarity) {
    // Convert from [-1, 1] to [0, 100]
    return ((similarity + 1.0) / 2.0 * 100.0).clamp(0.0, 100.0);
  }

  // Dispose resources
  void dispose() {
    try {
      _interpreter?.close();
      _isModelLoaded = false;
      print("FaceRecognitionService disposed");
    } catch (e) {
      print("Error disposing FaceRecognitionService: $e");
    }
  }

  // Get model info
  Map<String, dynamic> getModelInfo() {
    if (!_isModelLoaded) return {};

    return {
      'inputSize': inputSize,
      'embeddingSize': embeddingSize,
      'modelPath': modelPath,
      'isLoaded': _isModelLoaded,
    };
  }
}
