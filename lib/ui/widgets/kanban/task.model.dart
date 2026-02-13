import 'package:appflowy_board/appflowy_board.dart';

class KanbanTaskItem extends AppFlowyGroupItem {
  final String taskId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<TaskEmployee> users;

  KanbanTaskItem(
      this.taskId, {
        required this.title,
        required this.description,
        required this.startDate,
        required this.endDate,
        required this.users,
      });

  @override
  String get id => taskId;

  @override
  String toString() {
    return 'KanbanTaskItem('
        '$taskId,'
        'title: $title,'
        'description: $description,'
        'startDate:$startDate,'
        'endDate:$endDate,'
        'users: ${users.map((e) => e.toString())}'
        ')';
  }
}

class TaskEmployee {
  final DateTime registeredOn;
  final String userName;
  final String imagePath;
  final String email;
  final String phoneNumber;
  final String position;
  final bool isActive;

  const TaskEmployee({
    required this.registeredOn,
    required this.userName,
    required this.imagePath,
    required this.email,
    required this.phoneNumber,
    required this.position,
    required this.isActive,
  });

  @override
  String toString() {
    return 'TaskEmployee { '
        'registeredOn: $registeredOn, '
        'userName: $userName, '
        'imagePath: $imagePath, '
        'email: $email, '
        'phoneNumber: $phoneNumber, '
        'position: $position, '
        'isActive: $isActive '
        '}';
  }
}
