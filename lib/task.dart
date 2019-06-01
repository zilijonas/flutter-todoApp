class Task {
  final String name;
  final String created;
  bool checked;
  int idx;

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        created = json['created'],
        checked = json['checked'],
        idx = json['idx'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'created': created, 'checked': checked, 'idx': idx};

  Task(this.name, this.created, this.checked, this.idx);
}
