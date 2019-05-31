class Task {
  final String name;
  final String created;
  bool checked;
  int id;

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        created = json['created'],
        checked = json['checked'],
        id = json['id'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'created': created, 'checked': checked, 'id': id};

  Task(this.name, this.created, this.checked, this.id);
}
