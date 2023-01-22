class ProductVariant{
  String Product_Variant_Options_id;
  String Product_Variant_Options_name;
  String Product_Variant_Price;
  int Product_Variant_Quantity;
  List<String> options;

  ProductVariant({
    required this.Product_Variant_Options_id,
    required this.Product_Variant_Options_name,
    required this.Product_Variant_Price,
    this.Product_Variant_Quantity = 0,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'Product_Variant_Options_id': Product_Variant_Options_id,
      'Product_Variant_Options_name': Product_Variant_Options_name,
      'Product_Variant_Price': Product_Variant_Price,
    };
  }
}

class ProductVariantType{
  String Product_Variant_Types_id;
  String Product_Variant_Types_name;
  List<ProductVariantOption> productVariantOptions;
  ProductVariantOption? selectedVariantOptions;

  ProductVariantType({
    required this.Product_Variant_Types_id,
    required this.Product_Variant_Types_name,
    required this.productVariantOptions,
    this.selectedVariantOptions,
  });
}

class ProductVariantOption{
  String Option_id;
  String Option_name;

  ProductVariantOption({
    required this.Option_id,
    required this.Option_name,
  });
}

class ProductVariantResult{
  String Product_Variant_Types_id;
  String Product_Variant_Types_name;
  List<ProductVariant> productVariantOptionsList;

  ProductVariantResult({
    required this.Product_Variant_Types_id,
    required this.Product_Variant_Types_name,
    required this.productVariantOptionsList,
  });
}