import 'package:flutter/material.dart';
import 'package:neat_notifier/neat_notifier.dart';

class CounterNotifier extends NeatNotifier<int, String> {
  CounterNotifier() : super(0);

  void increment() {
    value++;
    if (value % 5 == 0) {
      emitAction('Milestone reached: $value');
    }
  }
}

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  User copyWith({String? name, int? age}) {
    return User(name: name ?? this.name, age: age ?? this.age);
  }
}

class UserNotifier extends NeatNotifier<User, dynamic> {
  UserNotifier() : super(User(name: 'Guest', age: 25));

  void updateName(String name) {
    value = value.copyWith(name: name);
  }

  void incrementAge() {
    value = value.copyWith(age: value.age + 1);
  }
}

class ThemeNotifier extends NeatNotifier<ThemeMode, dynamic> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
