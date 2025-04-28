import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qtec_ecom/utils/global_varriable.dart';

import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<ProductBloc>().add(FetchProducts());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<ProductBloc>().add(FetchProducts());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading && (state is! ProductLoaded)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  _buildSearchAndSortBar(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 48,
          width: 269,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: const Color(0xffD1D5DB)),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search Anything...",
              hintStyle: GlobalVarriable.customTextStyle(
                color: const Color(0xff9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.sp),
                child: SvgPicture.asset(
                  "assets/svg/search-normal.svg",
                  height: 24.sp,
                  width: 24.sp,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        SvgPicture.asset("assets/svg/sort.svg"),
      ],
    );
  }

  Widget _buildProductCard(product) {
    return Container(
      width: 156.w,
      height: 263.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  product.image,
                  fit: BoxFit.fill,
                  width: 156.w,
                  height: 164.h,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GlobalVarriable.customTextStyle(
                    color: const Color(0xff1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '\$${product.price}',
                  style: GlobalVarriable.customTextStyle(
                    color: const Color(0xff1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 18,
            child: Container(
              height: 16.h,
              width: 16.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffFFFFFF),
              ),
              child: SvgPicture.asset("assets/svg/heart.svg"),
            ),
          ),
        ],
      ),
    );
  }
}





