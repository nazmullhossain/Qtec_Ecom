import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:qtec_ecom/repository/product_repository.dart';
import 'package:qtec_ecom/screen/home_screen.dart';

import 'bloc/product/product_bloc.dart';
import 'bloc/product/product_event.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  final productRepository = ProductRepository();
  runApp(MyApp(productRepository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;

  const MyApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
            ProductBloc(productRepository: productRepository)..add(FetchProducts()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ConnectivityWatcher(),
        ),
      ),
    );
  }
}


class ConnectivityWatcher extends StatefulWidget {
  const ConnectivityWatcher({super.key});

  @override
  State<ConnectivityWatcher> createState() => _ConnectivityWatcherState();
}

class _ConnectivityWatcherState extends State<ConnectivityWatcher> {
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _checkInternet(); // Initial check
  }

  Future<void> _checkInternet() async {
    final hasConnection = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isConnected = hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _checkInternet();
        }

        return _isConnected ? const HomeScreen() : const OfflineScreen();
      },
    );
  }
}


class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'You are offline',
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
    );
  }
}
