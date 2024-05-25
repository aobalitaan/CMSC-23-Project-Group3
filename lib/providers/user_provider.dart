import 'dart:async';

import 'package:flutter/material.dart';
import '../api/firebase_user_api.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  late FirebaseUserAPI fbService;

  late Stream<List<AppUser>> _uStream = const Stream.empty();
  late Stream<List<AppUser>> _orgStream = const Stream.empty();
  late Stream<List<AppUser>> _pendingOrgStream = const Stream.empty();
  late Stream<List<AppUser>> _donorStream = const Stream.empty();

  Stream<List<AppUser>> get uStream => _uStream;
  Stream<List<AppUser>> get orgStream => _orgStream;
  Stream<List<AppUser>> get pendingOrgStream => _pendingOrgStream;
  Stream<List<AppUser>> get donorStream => _donorStream;

  final int donorAcc = 0, orgAcc = 1, adminAcc = 2;
  
  AppUser? _selectedUser;
  AppUser? get selectedUser => _selectedUser;
  bool unique = false;

  Timer? _timer;

  UserProvider(){
    fbService = FirebaseUserAPI();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      refresh();
    });
  }

  void refresh(){
    if (_selectedUser != null) getAccountInfo(_selectedUser!.uid);
  }

  // Private method to handle the fetching logic.
  void _fetchUsersByType(int accountType, bool approvalStatus) {
    try {
      var newStream = fbService.fetchUsersByAccountType(accountType, approvalStatus);
      switch(accountType){
        case 0: 
          _donorStream = newStream; 
          break;
        case 1:
          if (approvalStatus){_orgStream = newStream;}
          else {_pendingOrgStream = newStream;}
          break;
        default:
          break;
      }

      _uStream = fbService.fetchUsersByAccountType(accountType, approvalStatus);
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      _uStream = const Stream.empty();
      notifyListeners();
    }
  }

  // Public methods to fetch specific user types.
  void fetchDonors() {
    _fetchUsersByType(donorAcc,false);
  }

  void fetchOrganizations() {
    _fetchUsersByType(orgAcc,true);
  }

  void fetchPendingOrganizations() {
    _fetchUsersByType(orgAcc,false);
  }

  void fetchAdmins() {
    _fetchUsersByType(adminAcc,false);
  }

  Future<AppUser?> getAccountInfo(String? id) async {
    if (id == null){
      _selectedUser = null;
      notifyListeners();
      return _selectedUser;
    }

    _selectedUser = await fbService.getAccountInfo(id);
    notifyListeners();
    return _selectedUser;
  }

  Future<bool> isUsernameUnique(String username) async {
    unique = await fbService.isUsernameUnique(username);
    notifyListeners();
    return unique;
  }


  Future<String?> updateUser(String id, AppUser details) async {
    String? message = await fbService.updateUser(id, details.toJson(details));
    notifyListeners();
    return message;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
