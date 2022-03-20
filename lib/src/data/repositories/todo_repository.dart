import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:todo_app_myroshnykov/src/data/firebase/auth_data_source.dart';
import 'package:todo_app_myroshnykov/src/data/firebase/profile_data_source.dart';
import 'package:todo_app_myroshnykov/src/data/firebase/todo_data_source.dart';
import 'package:todo_app_myroshnykov/src/data/mappers/todo_mapper.dart';
import 'package:todo_app_myroshnykov/src/data/mappers/user_mapper.dart';
import 'package:todo_app_myroshnykov/src/domain/entities/todo/add_todo_params.dart';
import 'package:todo_app_myroshnykov/src/domain/entities/todo/todo.dart';
import 'package:todo_app_myroshnykov/src/domain/entities/todo/update_todo_params.dart';
import 'package:todo_app_myroshnykov/src/domain/repositories/todo_repository.dart';
import 'package:todo_app_myroshnykov/src/logger/custom_logger.dart';

@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(
    this._authDataSource,
    this._todoDataSource,
  );

  final AuthDataSource _authDataSource;
  final TodoDataSource _todoDataSource;

  final logger = getLogger('TodoRepositoryImpl');

  @override
  Future<void> addTodo(AddTodoParams params) async {
    final newTodoId = _getRandomString();

    try {
      _todoDataSource.updateTodoData(
        id: newTodoId,
        title: params.title,
        description: params.description,
        todoType: params.todoType,
        dateTime: params.dateTime,
        completed: false,
      );

      final userSnapshot = await _authDataSource.getUserInfo();

      final user = UserMapper().fromDocument(userSnapshot);

      List<dynamic> updatedTodoIds = user.todoIds..add(newTodoId);

      ProfileDataSource(id: user.email).updateProfileData(
        email: user.email,
        name: user.name,
        image: user.image,
        todoIds: updatedTodoIds,
        completedTodos: user.completedTodos,
      );
    } on Exception catch (error) {
      logger.e('$error, hashCode: ${error.hashCode}');
      throw Exception();
    }
  }

  @override
  Future<void> changeTodoCompleteStatus(String id) {
    // TODO: implement changeTodoCompleteStatus
    throw UnimplementedError();
  }

  @override
  Future<void> removeTodo(String id) {
    // TODO: implement removeTodo
    throw UnimplementedError();
  }

  @override
  Future<void> updateTodo(UpdateTodoParams params) async {
    try {
      _todoDataSource.updateTodoData(
        id: params.id,
        title: params.updatedTitle,
        description: params.updatedDescription,
        todoType: params.updatedTodoType,
        dateTime: params.updateDateTime,
        completed: params.updatedCompleteStatus,
      );
    } on Exception catch (error) {
      logger.e('$error, hashCode: ${error.hashCode}');
      throw Exception();
    }
  }

  @override
  Future<Todo> getTodo(String id) {
    // TODO: implement getTodo
    throw UnimplementedError();
  }

  @override
  Future<List<Todo>> getAllUserTodos(List<dynamic> todoIds) async {
    try {
      List<Todo> todoList = [];

      for (var todoId in todoIds) {
        final todoSnapshot = await _todoDataSource.getTodo(id: todoId);

        final todo = TodoMapper().fromDocument(todoSnapshot);

        todoList.add(todo);
      }

      todoList.sort((a, b) {
        return a.dateTime.compareTo(b.dateTime);
      });

      return todoList;
    } on Exception catch (error) {
      logger.e(error);
      throw Exception();
    }
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final _rnd = Random();

  static String _getRandomString() {
    return String.fromCharCodes(
      Iterable.generate(
        20,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }
}