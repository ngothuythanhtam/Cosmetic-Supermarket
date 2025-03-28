import 'package:ct312h_project/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../products/products_manager.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _productId;
  String _title = '';
  double _price = 0.0;
  String _description = '';
  int _stockQuantity = 0;
  String _category = '';
  String _imageUrl = '';
  File? _pickedImage;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  final List<String> _categories = [
    'Lipstick',
    'Foundation',
    'Mascara',
    'Blush',
    'Concealer',
    'Highlighter',
    'Eye Shadow',
    'Setting Powder'
  ];

  // Focus node for the description field to detect when it's clicked
  final _descriptionFocusNode = FocusNode();
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadProduct);

    // Add a listener to the focus node to expand the description field when focused
    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionExpanded = _descriptionFocusNode.hasFocus;
      });
    });
  }

  void _loadProduct() {
    final productId = ModalRoute.of(context)!.settings.arguments as String?;
    if (productId != null) {
      final product = Provider.of<AdminProductsManager>(context, listen: false)
          .findById(productId);
      if (product != null) {
        setState(() {
          _productId = product.pid;
          _titleController.text = product.title;
          _priceController.text = product.price.toString();
          _descriptionController.text = product.description;
          _stockController.text = product.stockQuantity.toString();
          _category = product.category;
          _imageUrl = product.imageUrl;
        });
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final updatedProduct = Product(
      pid: _productId!,
      title: _title,
      price: _price,
      description: _description,
      stockQuantity: _stockQuantity,
      category: _category,
      imageUrl: _imageUrl,
      featuredImage: _pickedImage,
    );

    try {
      await Provider.of<AdminProductsManager>(context, listen: false)
          .updateProduct(updatedProduct);
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to update product.'),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: color4),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: color4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }

  Widget _buildProductPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Product Image',
          style: TextStyle(fontWeight: FontWeight.bold, color: color4),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(top: 8, right: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
              ),
              child: _pickedImage != null
                  ? FittedBox(
                      child: Image.file(
                        _pickedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _imageUrl.isNotEmpty
                      ? FittedBox(
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text('No Image'),
                        ),
            ),
            Expanded(
              child: SizedBox(
                height: 100,
                child: TextButton.icon(
                  icon: const Icon(Icons.image, color: color4),
                  label: const Text('Pick Image'),
                  onPressed: _pickImage,
                  style: TextButton.styleFrom(
                    foregroundColor: color4, 
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text,
      bool isDescription = false]) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label),
      keyboardType: isDescription ? TextInputType.multiline : keyboardType,
      cursorColor: color4,
      maxLines: isDescription
          ? (_isDescriptionExpanded ? null : 1)
          : 1,  
      minLines: isDescription ? 1 : null, 
      focusNode: isDescription
          ? _descriptionFocusNode
          : null, 
      validator: (value) => value!.isEmpty ? 'Please enter $label.' : null,
      onSaved: (value) {
        if (label == 'Title') {
          _title = value!;
        } else if (label == 'Price') {
          _price = double.parse(value!);
        } else if (label == 'Description') {
          _description = value!;
        } else if (label == 'Stock Quantity') {
          _stockQuantity = int.parse(value!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color13,
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    _buildTextField(_titleController, 'Title'),
                    const SizedBox(height: 30),
                    _buildTextField(
                        _priceController, 'Price', TextInputType.number),
                    const SizedBox(height: 30),
                    _buildTextField(_descriptionController, 'Description',
                        TextInputType.multiline, true),
                    const SizedBox(height: 30),
                    _buildTextField(_stockController, 'Stock Quantity',
                        TextInputType.number),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: _category.isNotEmpty ? _category : null,
                      decoration: _buildInputDecoration('Category'),
                      items: _categories
                          .map((String category) => DropdownMenuItem(
                              value: category, child: Text(category)))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category.' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildProductPreview(),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
