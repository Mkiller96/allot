import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense>  _expenses   = [];
  List<Category> _categories = [];
  bool   _loading = false;
  String? _error;

  List<Expense>  get expenses   => _expenses;
  List<Category> get categories => _categories;
  bool           get loading    => _loading;
  String?        get error      => _error;

  ApiService? _api;

  void init(String token) {
    _api = ApiService(token);
  }

  Category? getCat(String id) {
    try { return _categories.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  // ── Categories ───────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    try {
      final data = await _api!.get('/categories') as List<dynamic>;
      _categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addCategory(Map<String, dynamic> body) async {
    await _api!.post('/categories', body);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _api!.delete('/categories/$id');
    await loadCategories();
  }

  // ── Expenses ─────────────────────────────────────────────────────────────
  Future<void> loadExpenses({
    String period   = 'all',
    String catId    = '',
    String sort     = 'newest',
    String search   = '',
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final params = <String, String>{'period': period, 'sort': sort};
      if (catId.isNotEmpty)  params['categoryId'] = catId;
      if (search.isNotEmpty) params['search'] = search;
      final data = await _api!.get('/expenses', params: params) as List<dynamic>;
      _expenses  = data.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } on Exception catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<void> addExpense(Map<String, dynamic> body) async {
    await _api!.post('/expenses', body);
    await loadExpenses();
  }

  Future<void> updateExpense(String id, Map<String, dynamic> body) async {
    await _api!.put('/expenses/$id', body);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _api!.delete('/expenses/$id');
    await loadExpenses();
  }

  // ── Metrics ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchMonthly(int year) async =>
      await _api!.get('/metrics/monthly', params: {'year': '$year'})
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> fetchAnnual(int year) async =>
      await _api!.get('/metrics/annual', params: {'year': '$year'})
          as Map<String, dynamic>;
  Future<void> deleteAll() async {
    final ids = List<String>.from(_expenses.map((e) => e.id));
    for (final id in ids) {
      await _api!.delete('/expenses/$id');
    }
    _expenses.clear();
    notifyListeners();
  }
}