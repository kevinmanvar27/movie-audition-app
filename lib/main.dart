import 'package:flutter/material.dart';
import 'package:movie_audition/screens/addmovie.dart';
import 'package:movie_audition/screens/forgetpasswordscreens.dart';
import 'package:movie_audition/screens/loginscreen.dart';
import 'package:movie_audition/screens/registerscreens.dart';
import 'package:movie_audition/screens/profilescreen.dart';
import 'package:movie_audition/screens/editprofilescreen.dart';
import 'package:movie_audition/screens/moviescreen.dart';
import 'package:movie_audition/screens/moviedetailscreen.dart';
import 'package:movie_audition/screens/myauditionsscreen.dart';
import 'package:movie_audition/screens/reels/reels_page.dart';
import 'package:movie_audition/screens/splash_screen.dart';
import 'package:movie_audition/screens/roleselectionscreen.dart';
import 'package:movie_audition/screens/loginvarifyOtpScreen.dart';
import 'package:movie_audition/screens/ForgetVerifyOtpScreen.dart';
import 'package:movie_audition/screens/setnewpasswordscreen.dart'; // Add set new password screen import
import 'package:movie_audition/screens/editmoviescreen.dart'; // Add edit movie screen import
import 'package:movie_audition/screens/changepasswordscreen.dart'; // Add change password screen import
import 'package:movie_audition/models/editmoviemodel.dart'; // Add edit movie model import
import 'package:movie_audition/models/getmoviemodel.dart' as movie_model; // Import for Roles type
import 'package:movie_audition/screens/rolescard.dart'; // Add roles card screen import
import 'package:movie_audition/screens/grid.dart'; // Add grid screen import
import 'package:movie_audition/screens/status_selection_screen.dart'; // Add status selection screen import
import 'package:movie_audition/screens/deleteaccount.dart'; // Add delete account screen import
import 'package:movie_audition/util/app_theme.dart';
import 'package:movie_audition/services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Audition',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Uses device's theme setting
      initialRoute: '/',
      navigatorObservers: [ProfileScreen.routeObserver], // Add RouteObserver for profile screen
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/add-movie': (context) => const AddMovieScreen(),
        '/edit-movie': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is EditData) {
            return EditMovieScreen(movie: args);
          }
          // Handle the case where args might be a Map or other type
          return EditMovieScreen(movie: EditData());
        },
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/movies': (context) => const MovieScreen(),
        '/movie-detail': (context) => const MovieDetailScreen(),
        '/my-auditions': (context) => const MyAuditionsScreen(),
        '/reels': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final movieId = args?['movieId'] as int?;
          return ReelsPage(movieId: movieId);
        },
        '/role-selection': (context) => const RoleSelectionScreen(), // Add role selection route
        '/otp': (context) => const loginvarifyOtpScreen(
          name: '',
          email: '',
          password: '',
          passwordConfirmation: '',
          roleId: 4,
          tempToken: '', // Add tempToken parameter
        ), // Add OTP screen route
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return ForgetVerifyOtpScreen(
            email: args['email'] as String? ?? '',
            userId: args['userId'] as int? ?? 0,
          );
        }, // Add verify OTP screen route
        '/set-new-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return SetNewPasswordScreen(
            token: args['resetToken'] as String? ?? '',
            email: args['email'] as String? ?? '',
          );
        }, // Add set new password screen route
        '/change-password': (context) => const ChangePasswordScreen(), // Add change password screen route
        '/roles': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final rolesList = args?['roles'];
          List<movie_model.Roles>? roles;
          if (rolesList is List) {
            roles = rolesList.cast<movie_model.Roles>();
          }
          return RolesCardScreen(
            movieId: args?['movieId'] as int?,
            movieTitle: args?['movieTitle'] as String?,
            roles: roles,
          );
        },
        '/audition-grid': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return AuditionGridScreen(
            movieId: args?['movieId'] as int?,
            roleType: args?['roleType'] as String?,
            movieTitle: args?['movieTitle'] as String?,
            statusFilter: args?['statusFilter'] as String?,
          );
        },
        '/status-selection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return StatusSelectionScreen(
            movieId: args?['movieId'] as int?,
            roleType: args?['roleType'] as String?,
            movieTitle: args?['movieTitle'] as String?,
          );
        },
        '/delete-account': (context) => const DeleteAccountScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}