import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feira_de_compras/firestore/firestore/models/listin.dart';
import 'package:feira_de_compras/firestore_produtos/firestore_produtos/presentation/helpers/enum.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/produto.dart';
import 'widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;
  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Produto> listaProdutosPlanejados = [];

  List<Produto> listaProdutosPegos = [];

  //nome do colletion principal
  final String colectionName = 'listins';
  //nome da subColeção
  final String subColectionName = 'Produtos';

  OrdemProduto ordem = OrdemProduto.name;
  bool isDescrecente = false;

  //responsavel por cancelar o listener quando fechamos o app
  late StreamSubscription listener;

  @override
  void initState() {
    setUpListner();
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (ordem == value) {
                  isDescrecente = !isDescrecente;
                } else {
                  ordem = value;
                  isDescrecente = false;
                }
                refresh();
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: OrdemProduto.name,
                  child: Text('Ordenar por Nome'),
                ),
                const PopupMenuItem(
                  value: OrdemProduto.amount,
                  child: Text('Ordenar por Quantidade'),
                ),
                const PopupMenuItem(
                  value: OrdemProduto.price,
                  child: Text('Ordenar por preço'),
                ),
              ];
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "R\$${calcProduct().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPlanejados.length, (index) {
                Produto produto = listaProdutosPlanejados[index];
                return Dismissible(
                  key: ValueKey<Produto>(produto),
                  onDismissed: (direction) {
                    deletedProduct(produto);
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
                  child: ListTileProduto(
                    editClick: () {
                      showFormModal(model: produto);
                    },
                    iconClick: () {
                      changeBuy(produto);
                    },
                    produto: produto,
                    isComprado: false,
                  ),
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPegos.length, (index) {
                Produto produto = listaProdutosPegos[index];
                return Dismissible(
                  key: ValueKey<Produto>(produto),
                  onDismissed: (direction) {
                    deletedProduct(produto);
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
                  child: ListTileProduto(
                    editClick: () {
                      showFormModal(model: produto);
                    },
                    iconClick: () {
                      changeBuy(produto);
                    },
                    produto: produto,
                    isComprado: true,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = 'Edianto o ${model.name}';
      nameController.text = model.name;

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      if (model.price != null) {
        priceController.text = model.price.toString();
      }
      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(labelTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
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
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        produto.id = model.id;
                      }
                      if (amountController.text != '') {
                        produto.amount = double.parse(amountController.text);
                      }
                      if (priceController.text != '') {
                        produto.price = double.parse(priceController.text);
                      }
                      // Salvar no Firestore
                      firestore
                          .collection(colectionName)
                          .doc(widget.listin.id)
                          .collection(subColectionName)
                          .doc(produto.id)
                          .set(produto.toMap());

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> emptyList = [];
    snapshot ??= await firestore
        .collection(colectionName)
        .doc(widget.listin.id)
        .collection(subColectionName)
        .orderBy(ordem.name, descending: isDescrecente)
        .get();

    for (var doc in snapshot.docs) {
      emptyList.add(Produto.fromMap(doc.data()));
    }
    filterProducts(emptyList);
  }

  filterProducts(List<Produto> listProduct) {
    List<Produto> emptyListPegos = [];
    List<Produto> emptyListPlanejados = [];

    for (var produto in listProduct) {
      if (produto.isComprado) {
        emptyListPegos.add(produto);
      } else {
        emptyListPlanejados.add(produto);
      }
      setState(() {
        listaProdutosPegos = emptyListPegos;
        listaProdutosPlanejados = emptyListPlanejados;
      });
    }
  }

  changeBuy(Produto produto) async {
    produto.isComprado = !produto.isComprado;
    await firestore
        .collection(colectionName)
        .doc(widget.listin.id)
        .collection(subColectionName)
        .doc(produto.id)
        .update({'isComprado': produto.isComprado});
  }

  //resolver bug que apaga o ultimo porem continua mostrando
  deletedProduct(Produto produto) async {
    await firestore
        .collection(colectionName)
        .doc(widget.listin.id)
        .collection(subColectionName)
        .doc(produto.id)
        .delete();
    refresh();
  }

  //Ele vê que ocorreu uma mudança e avisa que mudou assim evintando o refresh
  setUpListner() {
    listener = firestore
        .collection(colectionName)
        .doc(widget.listin.id)
        .collection(subColectionName)
        .orderBy(ordem.name, descending: isDescrecente)
        .snapshots()
        .listen((snapshot) {
      refresh(snapshot: snapshot);
      changeSnackBar(snapshot);
    });
  }

  double calcProduct() {
    double total = 0;
    for (var produto in listaProdutosPegos) {
      if (produto.amount != null && produto.price != null) {
        total += produto.amount! * produto.price!;
      }
    }
    return total;
  }

  changeSnackBar(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (var snapshot in snapshot.docChanges) {
        Produto produto = Produto.fromMap(snapshot.doc.data()!);
        switch (snapshot.type) {
          case DocumentChangeType.added:
            showSnack('Foi Adicionado: ${produto.name}', Colors.green);
            break;
          case DocumentChangeType.modified:
            showSnack('Foi Modificado: ${produto.name}', Colors.amber);
            break;
          case DocumentChangeType.removed:
            showSnack('Foi Removido: ${produto.name}', Colors.red);
            break;
        }
      }
    }
  }

  showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
