import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'https://reqres.in/api'; // For Website API
  // static const String baseUrl = 'http://10.0.2.2:8000/api';//ANDORID IP
  static const String baseUrl =
      'https://hobibaca.my.id/api'; // For iOS simulator

  static const Map<String, String> headers = {
    'x-api-key': 'reqres-free-v1',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  /// REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String noHp) async {
    final url = Uri.parse('$baseUrl/register-user');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
          'no_hp': noHp,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = json.decode(response.body);
        print("ada error: $error");

        String errorMessage = error['message'] ?? 'Terjadi kesalahan.';
        // Jika ada field "errors", gabungkan semua isi error-nya
        if (error['errors'] != null && error['errors'] is Map) {
          final errors = error['errors'] as Map<String, dynamic>;
          final errorList = errors.values
              .expand((e) => e)
              .toList(); // gabungkan semua list error
          errorMessage = errorList.join('\n666'); // pisahkan pakai newline
        }
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login-user');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = json.decode(response.body);
        String errorMessage = error['message'] ?? 'Terjadi kesalahan.';
        // Jika ada field "errors", gabungkan semua isi error-nya
        if (error['errors'] != null && error['errors'] is Map) {
          final errors = error['errors'] as Map<String, dynamic>;
          final errorList = errors.values
              .expand((e) => e)
              .toList(); // gabungkan semua list error
          errorMessage = errorList.join('\n'); // pisahkan pakai newline
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserDetail() async {
    final url = Uri.parse('$baseUrl/profile');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'error': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': 'Unauthorized or user not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// GET PRODUCT
  static Future<Map<String, dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/books');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return {
        'success': false,
        'error': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// GET PURCHASED BOOKS BY USER
  static Future<Map<String, dynamic>> getPurchasedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    final url = Uri.parse('$baseUrl/books/purchased/$userId');

    if (userId == null) {
      return {
        'success': false,
        'error': 'User ID not found. Please login again.',
      };
    }

    if (token == null) {
      return {
        'success': false,
        'error': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("HTTP status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'error': 'Failed to load books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// GET ALL CATEGORIES
  static Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return {
        'success': false,
        'error': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load Categories',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// GET PRODUCT DETAIL
  static Future<Map<String, dynamic>> getProductDetail(int id) async {
    final url = Uri.parse('$baseUrl/book/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Data not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// GET Transactions by User
  static Future<Map<String, dynamic>> getTransactions(int userId) async {
    final url = Uri.parse('$baseUrl/transactions/user/$userId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Transacation not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

//Cek apakah buku sudah dibeli
  static Future<bool> checkIfBookPurchased(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    final url = Uri.parse('$baseUrl/transactions/user/$userId');

    if (token == null) {
      return false;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;
        return data
            .any((item) => item['book_id'] == bookId && item['status'] == 1);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

//TopUp Saldo
  static Future<Map<String, dynamic>> topUp(int userId, double nominal) async {
    final url = Uri.parse('$baseUrl/top-up');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. Please login again.',
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'user_id': userId.toString(),
          'biaya': nominal.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // print(json.decode(response.body));
        return {
          'success': false,
          'message': 'Topup Gagal!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Purchase Book
  static Future<Map<String, dynamic>> purchaseBook({
    required int userId,
    required int bookId,
    required String keterangan,
    required double biaya,
    int status = 1,
  }) async {
    final url = Uri.parse('$baseUrl/transactions/payment');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'status': 'error',
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'user_id': userId.toString(),
          'book_id': bookId.toString(),
          'keterangan': keterangan,
          'biaya': biaya.toString(),
          'status': status.toString(),
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['status'] == 'success') {
        return data;
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Pembelian gagal.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan jaringan: ${e.toString()}',
      };
    }
  }
}
