import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'core/api_constants.dart';
import 'core/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';
import 'providers/users_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/companies_provider.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/user_service.dart';
import 'services/order_service.dart';
import 'services/company_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(
    baseUrl: ApiConstants.apiBase,
    tokenProvider: tokenStorage.getToken,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        
        // Serviços
        Provider(create: (_) => AuthService(apiClient)),
        Provider(create: (_) => ProductService(apiClient)),
        Provider(create: (_) => UserService(apiClient)),
        Provider(create: (_) => OrderService(apiClient)),
        Provider(create: (_) => CompanyService(apiClient)),
        
        // Providers de Estado
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            tokenStorage: tokenStorage,
          )..init(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => ProductsProvider(
            productService: context.read<ProductService>(),
          )..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => UsersProvider(
            userService: context.read<UserService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OrdersProvider(
            orderService: context.read<OrderService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CompaniesProvider(
            companyService: context.read<CompanyService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
