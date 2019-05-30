class Task {
  final String name;
  final String created;
  bool checked;

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        created = json['created'],
        checked = json['checked'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'created': created, 'checked': checked};

  Task(this.name, this.created, this.checked);
}
