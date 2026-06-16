import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ScannedDocumentData {
  String? name;
  String? dob;
  String? idNumber;

  ScannedDocumentData({this.name, this.dob, this.idNumber});

  @override
  String toString() {
    return 'Name: $name, DOB: $dob, ID: $idNumber';
  }
}

class DocumentScannerService {
  static final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<ScannedDocumentData?> scanDocument(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;
      print("Extracted Text:\n$fullText");

      return _parseExtractedText(fullText);
    } catch (e) {
      print("Error scanning document: $e");
      return null;
    }
  }

  static ScannedDocumentData _parseExtractedText(String text) {
    ScannedDocumentData data = ScannedDocumentData();
    List<String> lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // 1. Extract DOB (Common formats: DD/MM/YYYY or DD-MM-YYYY)
      RegExp dobRegExp = RegExp(r'\b(\d{2}[-/]\d{2}[-/]\d{4})\b');
      var dobMatch = dobRegExp.firstMatch(line);
      if (dobMatch != null && data.dob == null) {
        data.dob = dobMatch.group(1);
      } else if ((line.toLowerCase().contains("dob") || line.toLowerCase().contains("date of birth")) && data.dob == null) {
         // Sometimes it's on the same line "DOB: 12/12/1990"
         var match = dobRegExp.firstMatch(line);
         if(match != null) data.dob = match.group(1);
      }

      // 2. Extract Name (Heuristic: usually ALL CAPS, might follow "Name" or be near the top)
      if (data.name == null) {
        if (line.toLowerCase().startsWith("name")) {
          // If it explicitly says "Name : John Doe"
          data.name = line.replaceAll(RegExp(r'(?i)name[\s:]*'), '').trim();
        } else if (line.isNotEmpty && line == line.toUpperCase() && !line.contains(RegExp(r'\d')) && line.length > 3) {
           // Heuristic: If it's all uppercase, has no numbers, and is reasonably long, it might be a name.
           // Works well for Indian IDs where name is often capitalized.
           // Avoid common keywords if possible.
           List<String> ignoreWords = ["GOVERNMENT", "INDIA", "STATE", "LICENSE", "CARD", "ELECTION", "COMMISSION", "PAN", "INCOME", "TAX", "DEPARTMENT"];
           bool shouldIgnore = false;
           for(var word in ignoreWords) {
             if(line.contains(word)) shouldIgnore = true;
           }
           if(!shouldIgnore) {
              data.name = line;
           }
        }
      }

      // 3. Extract common ID numbers (e.g. Aadhar: 12 digits space separated, PAN: 10 chars)
      RegExp aadharRegExp = RegExp(r'\b\d{4}\s\d{4}\s\d{4}\b');
      var aadharMatch = aadharRegExp.firstMatch(line);
      if (aadharMatch != null && data.idNumber == null) {
        data.idNumber = aadharMatch.group(0);
      }
      
      RegExp panRegExp = RegExp(r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b');
      var panMatch = panRegExp.firstMatch(line);
      if (panMatch != null && data.idNumber == null) {
          data.idNumber = panMatch.group(0);
      }
    }

    return data;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
