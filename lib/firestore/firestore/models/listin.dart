class Listin {
  String id;
  String name;

  Listin({required this.id, required this.name});

  //recebe um map do firebase
  Listin.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"];

  //Manda para o firebase em forma de map chave valor 
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}
