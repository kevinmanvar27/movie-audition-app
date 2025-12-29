import 'package:flutter/material.dart';
import '../../models/reel.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_header.dart';

class ReelProfileScreen extends StatelessWidget {
  final Reel reel;

  const ReelProfileScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Reel Profile',
      ),
      endDrawer: CustomDrawer(),
      backgroundColor: const Color(0xFF383950),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            
            // Reel Details Card
            Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reel Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildDetailRow('Caption', reel.caption),
                    const SizedBox(height: 15),
                    _buildDetailRow('Status', reel.status?.toString().split('.').last ?? 'Not set'),
                    const SizedBox(height: 15),
                    _buildDetailRow('Video Path', reel.assetPath),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}