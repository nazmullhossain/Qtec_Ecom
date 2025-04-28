import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qtec_ecom/screen/home_screen.dart';

import 'bloc/product/product_bloc.dart';
import 'bloc/product/product_event.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BlocProvider(
            create: (context) => ProductBloc()..add(FetchProducts()),
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}
