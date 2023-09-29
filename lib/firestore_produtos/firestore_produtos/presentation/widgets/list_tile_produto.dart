import 'package:flutter/material.dart';
import '../../model/produto.dart';

class ListTileProduto extends StatelessWidget {
  final Produto produto;
  final bool isComprado;
  final Function editClick;
  final Function iconClick;
  final Function deletedClick;
  const ListTileProduto({
    super.key,
    required this.produto,
    required this.isComprado,
    required this.editClick,
    required this.iconClick,
    required this.deletedClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          (isComprado) ? Icons.check : Icons.shopping_basket,
        ),
        onPressed: () {
          iconClick();
        },
      ),
      title: Text(
        (produto.amount == null)
            ? produto.name
            : "${produto.name} (x${produto.amount!.toInt()})",
      ),
      subtitle: Text(
        (produto.price == null)
            ? "Clique para adicionar preço"
            : "R\$ ${produto.price!}",
      ),
      onTap: () {
        editClick();
      },
      trailing: IconButton(
        onPressed: () {
          deletedClick();
        },
        icon: const Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
      ),
    );
  }
}
