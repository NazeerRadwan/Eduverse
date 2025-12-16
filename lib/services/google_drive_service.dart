import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  // Optional OAuth client id (used by GoogleSignIn fallback)
  static const String clientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive',
    ],
  );

  /// Authenticate using a Service Account and return a DriveApi instance.
  ///
  /// NOTE: Storing service account private keys in the client app is insecure.
  /// This helper implements the same approach you used previously; consider
  /// moving this to a secure backend if possible.
  static Future<drive.DriveApi?> authenticateWithServiceAccount() async {
    try {
      final accountCredentials = auth.ServiceAccountCredentials.fromJson({
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDEniyhy08oxLJd\nYsCvgmjiITmPt0QbelaAzN2ogHUPNiForDyNwbOdJijzou6u/vZ4PnqggWVQNxXe\nGY5TGa76PGmdrYgq7uXg+GLEVAX7bsIrZbmAPUqeiJst3o1UA88zSytRlGVwrdtW\nExlaAzKW4bQ66T9d+d6vwoj01YffxosWtfMgjdKQnr+m73m6kmRsBCwhM19VQ4dr\nK/PmZ32tjQbH+mLw4zVtXEBR6PVMPvR6keyyEhmLlCrz4BiOoW0exMh1UcMtmS9Y\nqzm0CAHO1jHxulHWLxzeDi1iW/BXdbX26tL14dG2ZjVk8/p/hcgpncMVhaAzObV9\nk9vGgLXZAgMBAAECggEADa74ajYtByhRRYCG6nAH/pzTVbYqbkMgXAxl7MEr5Ggf\nARrjh/YQGwK53OLc+57Q5mNqw1reAywiQHfE2PGzpMSpkQivrlU7+GEw9nrmg64c\no0qME2mwlMHrEtEnQs6VD/vOQvox6RqgZigkHoiUb727flIXT+IA5niCcY+eyir2\n7K1766Gq3CKdMyTLxzcNotuHDVfIySKAMinEHNmRVLptHgHALs+L9nQ281ZL1MHN\nkLEBUFst1V6q31sztw4GAvCYjPaFR0iTQ2yIm20k/6iBktg2qX1D60zW855SRkbp\ngTZkXWSNrd8fGp9oAEZ6LUGTHTVxpM4dorocdQcg0QKBgQDljUVk41CvPfQmYRvP\nQ7N/fDQhoITKZbBSSWJvPDW1EMI0G5ozj0EVLhJcgYujRDJZ4UxAFKqwa0Dmb3UM\nf3gLnlsE8PwaxYZNngltI1T3vXr3q2N5KRJrX5xE4b7SLv1kBCXGJ+bGCPGwgTgd\nf4DXRizb5yP2hDRsFyV33f4+/QKBgQDbRYB2YNjdn3qlhbNlidn2n0J9vaVs+irK\nc5Ff7Cmw6OpgJdgevGhTqRR9Swvs4r6fvBh9q+nXcXVS4nwMxkQYFpPjbCOwuXe2\nkQ1zb6dln6sydAoXRpH6X10SEUvoErzru27qzZejiUOFS/24+9bHQaNJBkZWNRFi\nuQKAeDh/DQKBgQCtHhKUmH5T+wQzIY9Ii4VGgtQJ/DXJMlF8bU2oGB9k80OS6rIr\nakEqCPnd+/Dka10RvcC0nyFvNSPX5Xy/tS5CjOWV32wxgH/d726qeTfuMl8Xg5Dc\nYiY7BfsjU6CGgNumXx5hx9vZxAsKExnP3UW8lHbmTPYpRuEGF5qxQKEqvQKBgCIs\ndNb+RQ5VWqINcmYy09uR+qTqN6wCWUTwOgn/HohJ5K1TeJlht8jCI0VbuuISfK8c\ne5yqfGltb2GZlsfO5rHyYt4g7ncOkM/NT5FcJ3S5K89TMndqMjoZPsIgG/pxYSxE\nLAdAP4/nRrSxoTuBVHn9ittItRGed7UxLGilU/jJAoGBAJNkb7NQJtWNDW0RihAh\nwsmaCiMVPNivT1mbRSRtEc7MBGLvlgl3FZRxiF3Lvt1yq6kOByll055AC0cnCcgH\ncTUcvu77pNQlqBC8OcyOvnw2GkmOaOdGXIRMqaNcIqbp4RV2J09NSO/VjZks3BvB\n+waTyNw3Y5ldeRgGpdL1ItXn\n-----END PRIVATE KEY-----\n",
        "client_email":
            "flutter-drive-service@eduverse-455909.iam.gserviceaccount.com",
        "client_id": "105416982775370069322",
        "type": "service_account",
      });
      final scopes = [drive.DriveApi.driveFileScope, drive.DriveApi.driveScope];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      return drive.DriveApi(client);
    } catch (e, stackTrace) {
      print('خطأ في المصادقة (service account): $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  /// Upload image to Google Drive and return the public link
  static Future<String?> uploadImageToGoogleDrive(File imageFile) async {
    try {
      // Verify file exists
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // First try using service account (preferred for server-owned Drive)
      final serviceDrive = await authenticateWithServiceAccount();
      if (serviceDrive != null) {
        print('Using service account for Drive upload');

        final fileMetadata =
            drive.File()
              ..name = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'
              ..mimeType = 'image/jpeg';

        final media = drive.Media(imageFile.openRead(), imageFile.lengthSync());

        final uploaded = await serviceDrive.files.create(
          fileMetadata,
          uploadMedia: media,
        );

        if (uploaded.id == null) {
          throw Exception('Upload returned no file ID');
        }

        try {
          await serviceDrive.permissions.create(
            drive.Permission()
              ..role = 'reader'
              ..type = 'anyone',
            uploaded.id!,
          );
        } catch (e) {
          print('Permission error (non-fatal): $e');
        }

        final fileLink =
            'https://drive.google.com/uc?export=view&id=${uploaded.id}';
        print('Service account public link: $fileLink');
        return fileLink;
      }

      // Fallback: use GoogleSignIn flow
      // Sign in to Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      print('Signed in as: ${googleUser.email}');

      // Get authentication
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      if (accessToken == null) {
        throw Exception('Failed to get access token');
      }
      print('Access token obtained');

      // Create HTTP client with access token
      final authClient = _AuthenticatedClient(http.Client(), accessToken);

      // Create Drive API
      final driveApi = drive.DriveApi(authClient);

      // Create file metadata
      final fileMetadata =
          drive.File()
            ..name = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'
            ..mimeType = 'image/jpeg';

      final media = drive.Media(imageFile.openRead(), imageFile.lengthSync());

      final uploadedFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      if (uploadedFile.id == null) {
        throw Exception('Upload returned no file ID');
      }

      try {
        await driveApi.permissions.create(
          drive.Permission()
            ..role = 'reader'
            ..type = 'anyone',
          uploadedFile.id!,
        );
      } catch (e) {
        print('Permission error (non-fatal): $e');
      }

      final fileLink =
          'https://drive.google.com/uc?export=view&id=${uploadedFile.id}';
      print('Public link generated: $fileLink');
      return fileLink;
    } catch (e) {
      print('Google Drive upload error: $e');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Pick image from device
  static Future<File?> pickImageFromDevice() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Image picker error: $e');
      return null;
    }
  }
}

/// Custom HTTP client with authorization header
class _AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final String _accessToken;

  _AuthenticatedClient(this._inner, this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}
