/// Tab Toko, urut `TabToko.dc.html`.
enum ShopTab {
  items,
  kitties,
  accessories,
  snacks;

  /// Tab dengan nama [name] (parameter `?tab=` di rute), atau [items].
  static ShopTab parse(String? name) => values.asNameMap()[name] ?? items;
}
