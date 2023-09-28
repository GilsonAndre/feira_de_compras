import 'package:flutter/material.dart';
import '../../model/produto.dart';

class ListTileProduto extends StatelessWidget {
  final Produto produto;
  final bool isComprado;
  final Function onClick;
  final Function iconClick;
  const ListTileProduto({
    super.key,
    required this.produto,
    required this.isComprado,
    required this.onClick,
    required this.iconClick,
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
        onClick();
      },
    );
  }
}
