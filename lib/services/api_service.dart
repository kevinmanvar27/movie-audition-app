import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/deleteauditionsmodel.dart';
import '../models/loginmodel.dart';
import '../models/getmoviemodel.dart';
import '../models/Addmoviemodel.dart';
import '../models/editmoviemodel.dart'; // Make sure this import is correct
import '../models/deletemoviemodel.dart'; // Contains deleteauditionmodel
import '../models/getmyauditionsmodel.dart';
import '../models/apireel.dart';
import '../models/sendotpmodel.dart'; // Import send OTP model
import '../models/varifyotpmodel.dart'; // Import verify OTP model
import '../models/forgetsendotpmodel.dart'; // Import forget password OTP model
import '../models/forgetvarifyotpmodel.dart'; // Import forget password verify OTP model
import '../models/forgetresetpasswordmodel.dart'; // Import forget reset password model
import '../models/allmoviemodel.dart'; // Import all movies model for actor-specific API
import '../models/updateprofiledatamodel.dart'; // Import update profile data model
import '../models/updateprofileimagemodel.dart';
import '../models/getprofilemodel.dart'; // Import get profile model
import '../models/UploadGallerymodel.dart'; // Import upload gallery model
import '../models/deletegalerymodel.dart'; // Import delete gallery model
import '../models/passwordchangemodel.dart'; // Import password change model
import '../models/getsubmittedmodel.dart'; // Import get submitted auditions model
import '../models/addauditionsmodel.dart'; // Import add auditions model
import '../models/updateauditionmodel.dart'; // Import update audition model
import '../models/deleteaccoutmodel.dart'; // Import delete account model
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Import for image compression

// API Service class
// TODO: Update baseUrl with the correct server URL for your environment
// For local development, you might use something like 'http://localhost:8000'
// For production, use the appropriate production URL
class ApiService {
  static const String baseUrl = 'https://movieaudition.rektech.work'; // TODO: Update with correct server URL
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String logoutEndpoint = '/api/v1/auth/logout';
  static const String getAllMoviesEndpoint = '/api/v1/movies';
  static const String getUserAuditionsEndpoint = '/api/v1/auditions';
  static const String getReelsEndpoint = '/api/v1/reels';
  static const String sendOtpEndpoint = '/api/v1/auth/send-registration-otp';
  static const String verifyOtpEndpoint = '/api/v1/auth/verify-registration-otp';
  static const String sendPasswordResetOtpEndpoint = '/api/v1/auth/send-password-reset-otp';
  static const String verifyPasswordResetOtpEndpoint = '/api/v1/auth/verify-password-reset-otp';
  static const String resetPasswordEndpoint = '/api/v1/auth/reset-password-otp';
  static const String getAllMoviesEndpointforactor = '/api/v1/normal-user/movies';

  static Future<forgetsendotpmodel?> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$sendPasswordResetOtpEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Send Password Reset OTP response: $jsonResponse');
        return forgetsendotpmodel.fromJson(jsonResponse);
      } else {
        // Handle error response
        print('Send Password Reset OTP failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during send password reset OTP: $e');
      return null;
    }
  }

  static Future<forgetvarifyotpmodel?> verifyPasswordResetOtp({
    required String email,
    required String otp,
    required int userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$verifyPasswordResetOtpEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp_code': otp, // Changed from otp_code to token
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('$jsonResponse');
        return forgetvarifyotpmodel.fromJson(jsonResponse);
      } else {
        // Handle error response
        print('Verify Password Reset OTP failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during verify password reset OTP: $e');
      return null;
    }
  }

  /// Resets the user's password
  static Future<forgetresetpasswordmodel?> resetPassword({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$resetPasswordEndpoint');
      print('$resetToken');
      print('$email');
      print('$password');
      print('$passwordConfirmation');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'reset_token': resetToken,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Reset Password response: $jsonResponse');

        return forgetresetpasswordmodel.fromJson(jsonResponse);

      } else {
        // Handle error response
        print('Reset Password failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during reset password: $e');
      return null;
    }
  }

  /// Sends OTP for registration
  static Future<sendotpmodel?> sendRegistrationOtp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int roleId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$sendOtpEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role_id': roleId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Send OTP response: $jsonResponse');
        return sendotpmodel.fromJson(jsonResponse);
      } else {
        // Handle error response
        print('Send OTP failed with status: ${response.statusCode}');
        print('${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during send OTP: $e');
      return null;
    }
  }

  /// Verifies OTP for registration
  static Future<varifyotpmodel?> verifyRegistrationOtp({
    required String email,
    required String otp,
    required String tempToken, // Add temp token parameter
  }) async {
    try {
      final url = Uri.parse('$baseUrl$verifyOtpEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp_code': otp, // Changed from otp_code to token
          'temp_token': tempToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return varifyotpmodel.fromJson(jsonResponse);
      } else {
        // Handle error response
        print('Verify OTP failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during verify OTP: $e');
      return null;
    }
  }

  /// Logs in a user with the provided credentials
  static Future<loginmodel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$loginEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Login response: $jsonResponse');
        return loginmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return loginmodel.fromJson({
          'success': false,
          'message': 'Invalid credentials. Please check your email and password.',
        });
      } else {
        // Handle error response
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return loginmodel.fromJson({
          'success': false,
          'message': 'Server error. Please try again later.',
        });
      }
    } on SocketException {
      print('Network error: Failed to connect to the server');
      return loginmodel.fromJson({
        'success': false,
        'message': 'Network error. Please check your internet connection and try again.',
      });
    } catch (e) {
      print('Exception during login: $e');
      // Handle timeout scenarios
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        print('Request timeout: Server is not responding');
        return loginmodel.fromJson({
          'success': false,
          'message': 'Request timeout. Server is not responding. Please try again later.',
        });
      }
      return loginmodel.fromJson({
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      });
    }
  }

  /// Logs out the current user
  static Future<bool> logoutUser({
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$logoutEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired
        print('Logout failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      } else {
        // Handle error response
        print('Logout failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during logout: $e');
      return false;
    }
  }

  /// Gets all movies
  static Future<getmoviesmodel?> getAllMovies({
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getAllMoviesEndpoint');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Get all movies response: $jsonResponse');
        print('Get all movies response: $jsonResponse');
        return getmoviesmodel.fromJson(jsonResponse);

      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Unauthorized access - token may be expired or invalid');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Get all movies failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get all movies: $e');
      return null;
    }
  }

  /// Gets user auditions
  static Future<GetmyauditionsModel?> getUserAuditions({
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getUserAuditionsEndpoint');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Get user auditions response: $jsonResponse');
        print('Get user auditions response: $jsonResponse');
        print('==========================================');
        print('==========================================');
        print('Get user auditions response: $jsonResponse');
        print('Get user auditions response: $jsonResponse');

        return GetmyauditionsModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        return null;
      } else {
        // Handle error response
        print('Get user auditions failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get user auditions: $e');
      return null;
    }
  }

  /// Gets all reels
  static Future<ReelsResponse?> getReels({
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getReelsEndpoint');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ReelsResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Unauthorized access - token may be expired or invalid');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Get reels failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get reels: $e');
      return null;
    }
  }

  /// Adds a new movie
  static Future<AddMovieModel?> addMovie({
    required String title,
    required String description,
    required List<String> genre, // Changed to List<String>
    required String endDate,
    required String director,
    required String budget,
    required String status,
    List<Map<String, dynamic>>? roles, // Add roles parameter
    String? token,
    int? userId, // Add userId parameter
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getAllMoviesEndpoint');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Prepare request body - matching the expected API format
      final Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'genre': genre, // Passed as List<String> now
        'end_date': endDate,
        'director': director,
        'budget': budget,
        'status': status, // Passed directly (e.g., 'Active' or 'Inactive')
        'user_id': userId ?? '', // Include userId if available
      };

      // Add roles to request body if provided
      if (roles != null) {
        requestBody['roles'] = roles;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AddMovieModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Add movie failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response and try to parse the error message
        print('Add movie failed with status: ${response.statusCode}');
        print('${response.body}');

        try {
          final jsonError = jsonDecode(response.body);
          return AddMovieModel.fromJson(jsonError); // Use the model to carry the error message
        } catch (_) {
          // If JSON decoding fails, return null or a model with a generic error
          return null;
        }
      }
    } catch (e) {
      print('Exception during add movie: $e');
      return null;
    }
  }

  /// Updates an existing movie
  static Future<EditMovieModel?> updateMovie({
    required int movieId,
    required String title,
    required String description,
    required List<String> genre,
    required String endDate,
    required String director,
    required String budget,
    required String status,
    List<Map<String, dynamic>>? roles, // Add roles parameter
    String? token,
    int? userId, // Add userId parameter
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getAllMoviesEndpoint/$movieId');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Prepare request body - matching the expected API format
      final Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'genre': genre,
        'end_date': endDate,
        'director': director,
        'budget': budget,
        'status': status,
      };

      // Only add user_id to request body if it's not null
      if (userId != null) {
        requestBody['user_id'] = userId;
      }

      // Only add roles to request body if provided (not null)
      if (roles != null) {
        requestBody['roles'] = roles;
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Update movie response: $jsonResponse');

        // Check if the API actually indicates success
        final success = jsonResponse['success'] as bool?;
        if (success == true) {
          return EditMovieModel.fromJson(jsonResponse);
        } else {
          // Even though HTTP status is 200, the API indicates failure
          print('API indicates failure despite HTTP 200 status: $jsonResponse');
          return EditMovieModel.fromJson(jsonResponse); // Still return the response so UI can handle the error message
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Update movie failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle other error responses
        print('Update movie failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during update movie: $e');
      return null;
    }
  }

  // api_service.dart

// ... (other functions)

  /// Updates user profile data
  static Future<updateprofiledatamodel?> updateProfileData({
    required String name,
    required String email,
    String? phone,
    String? location,
    String? gender, // Add gender parameter
    String? dateOfBirth, // Add dateOfBirth parameter
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/profile');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        // FIX: Explicitly set Content-Type for the server to read the JSON body
        'Content-Type': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
      };

      // Add optional fields if provided
      if (phone != null && phone.isNotEmpty) {
        requestBody['mobile_number'] = phone;
      }

      if (location != null && location.isNotEmpty) {
        requestBody['location'] = location;
      }

      if (gender != null && gender.isNotEmpty) {
        // Convert gender to lowercase as required by API
        requestBody['gender'] = gender.toLowerCase();
      }

      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        requestBody['date_of_birth'] = dateOfBirth;
      }

      print('Profile Update Request Body: ${jsonEncode(requestBody)}'); // Debugging check

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Update profile data response: $jsonResponse');

        // Check if the API actually indicates success
        final success = jsonResponse['success'] as bool?;
        if (success == true) {
          return updateprofiledatamodel.fromJson(jsonResponse);
        } else {
          // The API indicates failure with a non-200 status or success: false
          print('API indicates failure despite HTTP status: $jsonResponse');
          return updateprofiledatamodel.fromJson(jsonResponse);
        }
      } else {
        print('Update profile data failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        // Decode and return error model if possible
        try {
          return updateprofiledatamodel.fromJson(jsonDecode(response.body));
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      print('Exception during update profile data: $e');
      return null;
    }
  }

  /// Updates user profile image
  static Future<updateprofileimagemodel?> updateProfileImage({
    required File imageFile,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/profile/photo');

      // Create multipart request for file upload
      final request = http.MultipartRequest('post', url);

      // Add authorization header if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      // Add image file to request
      final fileBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'photo', // Field name expected by the API
        fileBytes,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Update profile image response: $jsonResponse');
        return updateprofileimagemodel.fromJson(jsonResponse);
      } else {
        print('Update profile image failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during update profile image: $e');
      return null;
    }
  }

  /// Gets user profile data
  static Future<GetProfileModel?> getProfileData({
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/profile');

      final Map<String, String> headers = {
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Get profile data response: $jsonResponse');

        // Check if the API actually indicates success
        final success = jsonResponse['success'] as bool?;
        if (success == true) {
          return GetProfileModel.fromJson(jsonResponse);
        } else {
          // Even though HTTP status is 200, the API indicates failure
          print('API indicates failure despite HTTP 200 status: $jsonResponse');
          return GetProfileModel.fromJson(jsonResponse); // Still return the response so UI can handle the error message
        }
      } else {
        print('Get profile data failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get profile data: $e');
      return null;
    }
  }

  /// Deletes a movie
  static Future<DeleteMovieModel?> deleteMovie({
    required int movieId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$getAllMoviesEndpoint/$movieId');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        // Check if the API actually indicates success
        final success = jsonResponse['success'] as bool?;
        if (success == true) {
          return DeleteMovieModel.fromJson(jsonResponse);
        } else {
          // Even though HTTP status is 200, the API indicates failure
          print('API indicates failure despite HTTP 200 status: $jsonResponse');
          return DeleteMovieModel.fromJson(jsonResponse); // Still return the response so UI can handle the error message
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Delete movie failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Delete movie failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during delete movie: $e');
      return null;
    }
  }

  /// Deletes an audition
  static Future<deleteauditionmodel?> deleteAudition({
    required int auditionId,
    String? token,
  }) async {
    try {
      // Assuming the DELETE endpoint is BASE_URL/api/v1/auditions/ID
      final url = Uri.parse('$baseUrl$getUserAuditionsEndpoint/$auditionId');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Delete audition response: $jsonResponse');
        return deleteauditionmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Delete audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        // Return a model with failure status if possible or null
        return null;
      } else {
        // Handle error response
        print('Delete audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during delete audition: $e');
      return null;
    }
  }

  /// Gets all movies for actors
  static Future<Allmoviemodel?> getAllMoviesForActor({
    String? token,
  }) async {
    try {
      // Actor-specific endpoint
      final url = Uri.parse('$baseUrl$getAllMoviesEndpointforactor');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Get all movies for actor response: $jsonResponse');
        return Allmoviemodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Unauthorized access - token may be expired or invalid');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Get all movies for actor failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get all movies for actor: $e');
      return null;
    }
  }

  /// Uploads a gallery image
  static Future<UploadGallerymodel?> uploadGalleryImage({
    required File imageFile,
    required int userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/users/$userId/gallery');

      // Create multipart request
      final request = http.MultipartRequest('post', url);

      // Add authorization header if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      // Add image file to request with correct field name
      final fileBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'images[]', // Changed field name to match API expectations
        fileBytes,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Upload gallergety image response: $jsonResponse');

        // Check if the response actually contains uploaded images
        if (jsonResponse['success'] == true) {
          // Ensure we're returning a proper response with the uploaded images
          return UploadGallerymodel.fromJson(jsonResponse);
        } else {
          print('Upload gallery image API reported failure: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print('Upload gallery image failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during upload gallery image: $e');
      return null;
    }
  }

  /// Deletes a gallery image
  static Future<DeleteGalleryModel?> deleteGalleryImage({
    required int userId,
    required String imageUrl,
    String? token,
  }) async {
    try {
      print('Attempting to delete image: $imageUrl for user ID: $userId');

      // Extract the image filename from the URL
      // Handle both full URLs and relative paths
      String imageName;
      if (imageUrl.startsWith('http')) {
        // For full URLs, extract the filename from the path
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        print('Full URL path segments: $pathSegments');

        // Find the segment after 'storage' which should be the image filename
        int storageIndex = pathSegments.indexOf('storage');
        if (storageIndex != -1 && storageIndex < pathSegments.length - 1) {
          // Get everything after 'storage/' as the image path
          imageName = pathSegments.skip(storageIndex + 1).join('/');
        } else {
          // Fallback to last segment
          imageName = pathSegments.last;
        }
      } else {
        // For relative paths, remove leading slash if present
        imageName = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
      }

      print('Extracted image name for deletion: $imageName');

      // URL encode the image name to handle special characters
      final encodedImageName = Uri.encodeComponent(imageName);
      final url = Uri.parse('$baseUrl/api/v1/users/$userId/gallery/$encodedImageName');
      print('Delete URL: $url');

      final Map<String, String> headers = {
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Delete gallery image response: $jsonResponse');

        // Check if the API actually indicates success
        if (jsonResponse['success'] == true) {
          return DeleteGalleryModel.fromJson(jsonResponse);
        } else {
          print('Delete gallery image API reported failure: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print('Delete gallery image failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during delete gallery image: $e');
      return null;
    }
  }

  /// Get auditions for a specific movie
  static Future<getsubmittedauditionsmodel?> getMovieAuditions({
    required int movieId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/movies/$movieId/auditions');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = jsonDecode(response.body);
          print('Get movie auditions response: $jsonResponse');
          print('Get movie auditions response: $jsonResponse');
          print('Get movie auditions response: $jsonResponse');
          print('Get movie auditions response: $jsonResponse');
          print('Get movie auditions response: $jsonResponse');


          final result = getsubmittedauditionsmodel.fromJson(jsonResponse);
          print('Parsed ${result.data?.length ?? 0} auditions');
          return result;
        } catch (e) {
          print('JSON parsing error in getMovieAuditions: $e');
          return null;
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Unauthorized access - token may be expired or invalid');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Get movie auditions failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during get movie auditions: $e');
      return null;
    }
  }

  /// Changes user password
  static Future<PasswordChangeModel?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/profile/password');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Change password response: $jsonResponse');
        return PasswordChangeModel.fromJson(jsonResponse);
      } else {
        print('Change password failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during change password: $e');
      return null;
    }
  }

  /// Uploads an audition video
  static Future<String?> uploadAuditionVideo({
    required File videoFile,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auditions/upload');

      // Create multipart request for file upload
      final request = http.MultipartRequest('post', url);

      // Add authorization header if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      // Add video file to request
      final fileBytes = await videoFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'video', // Field name expected by the API
        fileBytes,
        filename: videoFile.path.split('/').last,
        contentType: MediaType('video', 'mp4'),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Upload audition video response: $jsonResponse');

        // Extract video URL from response
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Handle different response formats
          if (jsonResponse['data']['video_url'] != null) {
            return jsonResponse['data']['video_url'].toString();
          } else if (jsonResponse['data']['url'] != null) {
            return jsonResponse['data']['url'].toString();
          } else if (jsonResponse['data']['path'] != null) {
            // If it's a relative path, make it absolute
            String path = jsonResponse['data']['path'].toString();
            if (!path.startsWith('http')) {
              return '$baseUrl$path';
            }
            return path;
          }
        }
        return null;
      } else {
        print('Upload audition video failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during upload audition video: $e');
      return null;
    }
  }

  /// Submits a new audition with multipart form data
  static Future<addauditionsmodel?> submitAuditionWithVideo({
    required int movieId,
    required String role,
    required String applicantName,
    required File videoFile,
    required String notes,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auditions');

      // Create multipart request
      final request = http.MultipartRequest('post', url);

      // Add authorization header if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      // Add form fields
      request.fields['movie_id'] = movieId.toString();
      request.fields['role'] = role;
      request.fields['applicant_name'] = applicantName;
      request.fields['notes'] = notes;

      // Add video file to request
      final fileBytes = await videoFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'uploaded_videos', // Field name expected by the API
        fileBytes,
        filename: videoFile.path.split('/').last,
        contentType: MediaType('video', 'mp4'),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Submit audition response: $jsonResponse');
        return addauditionsmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Submit audition failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      } else {
        // Handle error response
        print('Submit audition failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during submit audition: $e');
      return null;
    }
  }

  /// Submits a new audition with JSON data
  static Future<addauditionsmodel?> submitAudition({
    required int movieId,
    required String role,
    required String applicantName,
    required String uploadedVideos,
    required String notes,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auditions');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> requestBody = {
        'movie_id': movieId,
        'role': role,
        'applicant_name': applicantName,
        'uploaded_videos': uploadedVideos,
        'notes': notes,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Submit audition response: $jsonResponse');
        print('Submit audition response: $jsonResponse');
        print('Submit audition response: $jsonResponse');
        print('Submit audition response: $jsonResponse');
        print('Submit audition response: $jsonResponse');

        return addauditionsmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Submit audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Submit audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during submit audition: $e');
      return null;
    }
  }
  //deepseek
  /// Updates an existing audition with multipart form data (with new video)
  static Future<updateauditionmodel?> updateAuditionWithVideo({
    required int auditionId,
    required int movieId,
    required String role,
    required String applicantName,
    required File videoFile,
    required String notes,
    String? token,
  }) async {
    try {
      // Note: Using PUT with _method parameter as per your API screenshot
      final url = Uri.parse('$baseUrl/api/v1/auditions/$auditionId');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add authorization header if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      // Add _method field for PUT request (as shown in your screenshot)
      request.fields['_method'] = 'PUT';
      request.fields['movie_id'] = movieId.toString();
      request.fields['role'] = role;
      request.fields['applicant_name'] = applicantName;
      request.fields['notes'] = notes;

      // Add video file to request with correct field name 'new_videos'
      // As shown in your screenshot, the field is 'new_videos' for update
      final fileBytes = await videoFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'new_videos', // Field name for new video in update API
        fileBytes,
        filename: videoFile.path.split('/').last,
        contentType: MediaType('video', 'mp4'),
      );

      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Update audition with video response: $jsonResponse');
        return updateauditionmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Update audition failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      } else {
        // Handle error response
        print('Update audition failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during update audition with video: $e');
      return null;
    }
  }

  /// Updates an existing audition without changing the video (text only)
  static Future<updateauditionmodel?> updateAudition({
    required int auditionId,
    required int movieId,
    required String role,
    required String applicantName,
    required String notes,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auditions/$auditionId');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> requestBody = {
        '_method': 'PUT', // For PUT request
        'movie_id': movieId,
        'role': role,
        'applicant_name': applicantName,
        'notes': notes,
      };

      // Use POST with _method=PUT
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Update audition response: $jsonResponse');
        return updateauditionmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Update audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Update audition failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during update audition: $e');
      return null;
    }
  }

  /// Updates audition status (accept/reject) - For Casting Directors
  static Future<bool> updateAuditionStatus({
    required int auditionId,
    required String status, // 'accepted' or 'rejected'
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auditions/$auditionId/status');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch( // Changed to PATCH method
        url,
        headers: headers,
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Audition status updated successfully');
        return true;
      } else {
        print('Update audition status failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during update audition status: $e');
      return false;
    }
  }

  /// Deletes user account
  static Future<Deleteaccountmodel?> deleteAccount({
    required String password, // Add required password parameter
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/delete-account');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Add password to request body as per API requirement
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode({
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('Delete account response: $jsonResponse');
        return Deleteaccountmodel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Handle unauthorized access - token might be expired or invalid
        print('Delete account failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      } else {
        // Handle error response
        print('Delete account failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during delete account: $e');
      return null;
    }
  }
}