import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final List<String> donatedItems;
  final String id;
  final bool isPickup;
  final String weight;
  final List<String> addressForPickup;
  final String donorId;
  final String recipientId;
  final String status;
  final String contactNumber;
  final Timestamp selectedDateandTime;
  final String url;

  Donation({
    required this.id,
    required this.donatedItems,
    required this.isPickup,
    required this.weight,
    required this.donorId,
    required this.recipientId,
    required this.status,
    this.contactNumber = '',
    required this.selectedDateandTime,
    this.addressForPickup = const [],
    this.url = '',
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      donatedItems: List<String>.from(json['donatedItems'] ?? []),
      id: json['id']?? '',
      isPickup: json['isPickup'] ?? false,
      weight: json['weight'] ?? 0.0,
      addressForPickup: List<String>.from(json['addressForPickup'] ?? []),
      donorId: json['donorId'],
      recipientId: json['recipientId'],
      status: json['status'],
      contactNumber: json['contactNumber'],
      url: json['url'] ?? '',
      selectedDateandTime: json['selectedDateandTime'] ?? Timestamp.now(),
    );
  }

  static List<Donation> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Donation>((dynamic d) => Donation.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(Donation donation) {
    return {
      'id':id,
      'donatedItems': donation.donatedItems.where((item) => item.isNotEmpty).toList(),
      'isPickup': isPickup,
      'weight': weight,
      'addressForPickup': addressForPickup,
      'donorId': donorId,
      'recipientId': recipientId,
      'status': status,
      'contactNumber': contactNumber,
      'url': url,
      'selectedDateandTime': selectedDateandTime,
    };
  }
}
