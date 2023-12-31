import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feira_de_compras/firestore_produtos/firestore_produtos/presentation/produto_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Listin> listListins = [];

  final String colectionName = 'listins';

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  listListins.length,
                  (index) {
                    Listin model = listListins[index];
                    return Dismissible(
                      key: ValueKey<Listin>(model),
                      onDismissed: (direction) {
                        deletedListin(model);
                      },
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        padding: const EdgeInsets.only(top: 20),
                        color: Colors.red,
                        child: const Text(
                          'Deletando...',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        subtitle: Text(model.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProdutoScreen(listin: model),
                            ),
                          );
                        },
                        onLongPress: () {
                          showFormModal(model: model);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      title = 'Editando ${model.name}';
      nameController.text = model.name;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Listin listin = Listin(
                        id: const Uuid().v1(),
                        name: nameController.text,
                      );

                      if (model != null) {
                        listin.id = model.id;
                      }

                      firestore
                          .collection(colectionName)
                          .doc(listin.id)
                          .set(listin.toMap());

                      refresh();

                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> listEmpty = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(colectionName).get();

    for (var doc in snapshot.docs) {
      listEmpty.add(Listin.fromMap(doc.data()));
      setState(() {
        listListins = listEmpty;
      });
    }
  }

  deletedListin(Listin model) async {
    await firestore.collection(colectionName).doc(model.id).delete();
    refresh();
  }
}
