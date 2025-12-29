import 'getsubmittedmodel.dart';

// Updated enum to include all possible audition statuses
enum ReelStatus { pending, viewed, accepted, rejected }

class Reel {
  final String assetPath;
  final String caption;
  ReelStatus? status;
  
  // Additional audition data for casting directors
  final User? actorData;
  final String? notes;
  final int? auditionId;
  final String? currentStatus; // pending, viewed, shortlisted, rejected
  final String? movieTitle; // Added movie title field

  Reel({
    required this.assetPath,
    required this.caption,
    this.status,
    this.actorData,
    this.notes,
    this.auditionId,
    this.currentStatus,
    this.movieTitle, // Added movie title parameter
  });

  // Convert Reel object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'caption': caption,
      'status': status?.index,
    };
  }

  // Create Reel object from JSON map
  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      assetPath: json['assetPath'] ?? '',
      caption: json['caption'] ?? '',
      status: _statusFromInt(json['status']),
      currentStatus: json['currentStatus'],
      movieTitle: json['movieTitle'], // Added movie title from JSON
    );
  }

  static ReelStatus? _statusFromInt(int? index) {
    if (index == null) return null;
    switch (index) {
      case 0:
        return ReelStatus.pending;
      case 1:
        return ReelStatus.viewed;
      case 2:
        return ReelStatus.accepted;
      case 3:
        return ReelStatus.rejected;
      default:
        return null;
    }
  }
  
  // Helper method to convert string status to enum
  static ReelStatus? statusFromString(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return ReelStatus.pending;
      case 'viewed':
        return ReelStatus.viewed;
      case 'shortlisted':
      case 'accepted':
        return ReelStatus.accepted;
      case 'rejected':
        return ReelStatus.rejected;
      default:
        return null;
    }
  }
  
  // Helper method to convert enum to string status
  static String statusToString(ReelStatus? status) {
    if (status == null) return 'pending';
    switch (status) {
      case ReelStatus.pending:
        return 'pending';
      case ReelStatus.viewed:
        return 'viewed';
      case ReelStatus.accepted:
        return 'shortlisted'; // Return shortlisted for accepted status
      case ReelStatus.rejected:
        return 'rejected';
    }
  }
}