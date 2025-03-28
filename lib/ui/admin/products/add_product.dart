import 'package:ct312h_project/components/colors.dart';
import 'package:ct312h_project/ui/admin/products/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../shared/dialog_utils.dart';
import 'products_manager.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add_product';

  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;
  File? _pickedImage;
  String? _selectedCategory;
  bool _isLoading = false;

  // Static list of categories
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

  @override
  void initState() {
    super.initState();
    _editedProduct = Product(
      pid: null,
      title: '',
      price: 0,
      description: '',
      imageUrl: '',
      stockQuantity: 0,
      category: _categories.first, 
    );
    _selectedCategory = _categories.first;  
  }

  Future<void> _saveForm() async {
    final bool formIsValid = _editForm.currentState!.validate();

    if (!_editedProduct.hasFeaturedImage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _selectedCategory = _categories.first; 
      _editedProduct = _editedProduct.copyWith(category: _selectedCategory);
    }

    if (!formIsValid) {
      return;
    }

    _editForm.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final productsManager = context.read<AdminProductsManager>();

      print('✅ Saving product with category: ${_editedProduct.category}');
      print(
          '✅ Saving product with stock quantity: ${_editedProduct.stockQuantity}');

      if (_editedProduct.pid != null) {
        await productsManager.updateProduct(_editedProduct);
      } else {
        await productsManager.addProduct(_editedProduct);
      }

      if (mounted) {
        Navigator.of(context).pushNamed(
          AdminProductsScreen.routeName,
        );
      }
    } catch (error) {
      print('❌ Error during save: $error');
      if (mounted) {
        await showErrorDialog(
          context,
          'Failed to save product. Please check all fields and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    try {
      final pickedImageFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImageFile == null) {
        return;
      }
      setState(() {
        _pickedImage = File(pickedImageFile.path);
        _editedProduct = _editedProduct.copyWith(featuredImage: _pickedImage);
      });
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Failed to pick image.');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color13,
        title: const Text('Add Product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: color13, 
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _editForm,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      _buildTitleField(),
                      const SizedBox(height: 30),
                      _buildPriceField(),
                      const SizedBox(height: 30),
                      _buildDescriptionField(),
                      const SizedBox(height: 30),
                      _buildStockQuantityField(),
                      const SizedBox(height: 30),
                      _buildCategoryDropdown(_categories),
                      const SizedBox(height: 20),
                      _buildProductPreview(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _editedProduct.title,
      decoration: _buildInputDecoration('Title'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please provide a title.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(title: value);
      },
    );
  }

  TextFormField _buildPriceField() {
    return TextFormField(
      initialValue: _editedProduct.price.toString(),
      decoration: _buildInputDecoration('Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a price.';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number.';
        }
        if (double.parse(value) <= 0) {
          return 'Please enter a number greater than zero.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(
          price: double.parse(value ?? '0'),
        );
      },
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: _buildInputDecoration('Description'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description.';
        }
        if (value.length < 10) {
          return 'Should be at least 10 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(description: value);
      },
    );
  }

  TextFormField _buildStockQuantityField() {
    return TextFormField(
      initialValue: _editedProduct.stockQuantity.toString(),
      decoration: _buildInputDecoration('Stock Quantity'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a stock quantity.';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number.';
        }
        if (int.parse(value) < 0) {
          return 'Please enter a non-negative number.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(
          stockQuantity: int.parse(value ?? '0'),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: _buildInputDecoration('Category'),
      hint: const Text('Select a category'),
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
          _editedProduct = _editedProduct.copyWith(category: newValue);
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category.';
        }
        return null;
      },
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
              child: !_editedProduct.hasFeaturedImage()
                  ? const Center(
                      child: Text('No Image'),
                    )
                  : FittedBox(
                      child: _editedProduct.featuredImage == null
                          ? Image.network(
                              _editedProduct.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _editedProduct.featuredImage!,
                              fit: BoxFit.cover,
                            ),
                    ),
            ),
            Expanded(
              child: SizedBox(
                height: 100,
                child: TextButton.icon(
                  icon: const Icon(Icons.image, color: color4),
                  label:
                      const Text('Pick Image', style: TextStyle(color: color4)),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
