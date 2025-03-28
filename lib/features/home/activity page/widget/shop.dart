import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:lottie/lottie.dart';

class Shop extends ConsumerWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loading());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currencyPoints = userData['currencypoints'] ?? 0;

        final List<Product> products = [
          Product(
            name: 'Buy Hint',
            price: 50,
            image: 'assets/logo_icon.png',
            bgColor: Colors.blue,
            onTap: currencyPoints >= 50
                ? () async {
                    print('Buy Hint tapped');
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'currencypoints': currencyPoints - 50,
                      'hints': (userData['hints'] ?? 0) + 1,
                    });
                  }
                : null,
          ),
          Product(
            name: 'Change Pet Name',
            price: 100,
            image: 'assets/logo_icon.png',
            bgColor: Colors.green,
            onTap: currencyPoints >= 100
                ? () async {
                    print('Change Pet Name tapped');
                    String newName =
                        await _showInputDialog(context, 'Change Pet Name');
                    if (newName.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'currencypoints': currencyPoints - 100,
                        'petName': newName,
                      });
                    }
                  }
                : null,
          ),
          Product(
            name: 'Change Username',
            price: 1000,
            image: 'assets/logo_icon.png',
            bgColor: Colors.red,
            onTap: currencyPoints >= 1000
                ? () async {
                    print('Change Username tapped');
                    String newUsername =
                        await _showInputDialog(context, 'Change Username');
                    if (newUsername.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'currencypoints': currencyPoints - 1000,
                        'username': newUsername,
                      });
                    }
                  }
                : null,
          ),
        ];

        return SizedBox(
          height: 1200,
          child: Column(
            children: [
              Lottie.asset('assets/hints.json', height: 150),
              Text(
                'Points: $currencyPoints',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12.0),
                  children: products
                      .map((product) => ProductCard(product: product))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: product.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: product.bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(product.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.price} Points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final int price;
  final String image;
  final Color bgColor;
  final VoidCallback? onTap;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.bgColor,
    this.onTap,
  });
}

Future<String> _showInputDialog(BuildContext context, String title) async {
  String inputText = '';
  await showDialog(
    context: context,
    builder: (context) {
      final TextEditingController controller = TextEditingController();
      return AlertDialog(
        title: Text(title),
        content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              inputText = controller.text;
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
  return inputText;
}
