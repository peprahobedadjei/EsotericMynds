import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/room.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final _postService = PostService();

  List<Post> _allPosts = [];
  List<Room> _rooms = [];
  Room? _selectedRoom;
  bool _isLoading = false;
  bool _isCreatingPost = false;
  String? _errorMessage;
  String? _searchQuery;

  List<Post> get allPosts => _allPosts;
  List<Room> get rooms => _rooms;
  Room? get selectedRoom => _selectedRoom;
  bool get isLoading => _isLoading;
  bool get isCreatingPost => _isCreatingPost;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;

  // Get filtered posts based on selected room and search query
  List<Post> get filteredPosts {
    List<Post> posts = _allPosts.where((post) => !post.isFlagged).toList();
    
    // Filter by room if selected
    if (_selectedRoom != null) {
      posts = posts.where((post) => post.room.id == _selectedRoom!.id).toList();
    }
    
    // Filter by search query if present
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      posts = posts
          .where((post) => post.user.username
              .toLowerCase()
              .contains(_searchQuery!.toLowerCase()))
          .toList();
    }
    
    return posts;
  }

  // Fetch all posts
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _postService.getAllPosts();

    _isLoading = false;

    if (response.success && response.data != null) {
      _allPosts = response.data!;
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  // Fetch all rooms
  Future<void> fetchRooms() async {
    final response = await _postService.getAllRooms();

    if (response.success && response.data != null) {
      _rooms = response.data!;
      notifyListeners();
    }
  }

  // Create post
  Future<bool> createPost({
    required String content,
    required int roomId,
    File? media,
  }) async {
    _isCreatingPost = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _postService.createPost(
      content: content,
      roomId: roomId,
      media: media,
    );

    _isCreatingPost = false;

    if (response.success) {
      // Refresh posts to show the new one
      await fetchPosts();
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Select a room
  void selectRoom(Room? room) {
    _selectedRoom = room;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
  }

  // React to post
  Future<void> reactToPost(int postId, String reactionType) async {
    final response = await _postService.reactToPost(postId, reactionType);

    if (response.success) {
      // Refresh posts to get updated counts
      await fetchPosts();
    }
  }

  // Remove reaction
  Future<void> removeReaction(int postId) async {
    final response = await _postService.removeReaction(postId);

    if (response.success) {
      // Refresh posts to get updated counts
      await fetchPosts();
    }
  }

  // Flag post
  Future<void> flagPost(int postId) async {
    final response = await _postService.flagPost(postId);

    if (response.success) {
      // Remove the post from local list immediately
      _allPosts.removeWhere((post) => post.id == postId);
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}