import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qtec_ecom/utils/global_varriable.dart';
import '../../models/product_models.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _allProducts = [];
  String _selectedSort = 'none';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<ProductBloc>().add(FetchProducts());
  }

  void _scrollListener() {
    final state = context.read<ProductBloc>().state;
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        state is ProductLoaded &&
        !state.hasReachedMax) {
      context.read<ProductBloc>().add(FetchProducts());
    }
  }

  List<Product> _applySearchAndSort({
    required List<Product> products,
    required String query,
    required String sortType,
  }) {
    List<Product> result = products;

    if (query.isNotEmpty) {
      result = result
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (sortType == 'price') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == 'rating') {
      result.sort((a, b) => b.rate.compareTo(a.rate));
    }

    return result;
  }

  Widget _buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 48,
          width: 250.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xffD1D5DB)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search Anything...",
              hintStyle: TextStyle(
                color: const Color(0xff9CA3AF),
                fontSize: 16.sp,
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
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: SvgPicture.asset("assets/svg/sort.svg"),
          onSelected: (value) {
            setState(() {
              _selectedSort = value;
            });
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'none', child: Text('No Sort')),
            PopupMenuItem(value: 'price', child: Text('Price: Low to High')),
            PopupMenuItem(value: 'rating', child: Text('Rating')),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 156.w,
      height: 263.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        // color: Colors.red
          
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.fill,
                    width: 156.w,
                    height: 164.h,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xff1F2937),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '\$${product.price}',
                  style: TextStyle(
                    color: const Color(0xff1F2937),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              Row(
                children: [
                  SvgPicture.asset("assets/svg/Rating Icon.svg"),
                  SizedBox(width: 4.sp,),
                  Text("${product.rate}",style: GlobalVarriable.customTextStyle(
                      color: Color(0xff1F2937),
                      fontSize: 12, fontWeight: FontWeight.w500),),
                  SizedBox(width: 4.sp,),
                  Text("(${product.count})",
                  style: GlobalVarriable.customTextStyle(
                      color: Color(0xff6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),),

                ],
              )
              
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading && _allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            _allProducts = state.products;
            final filteredProducts = _applySearchAndSort(
              products: _allProducts,
              query: searchController.text,
              sortType: _selectedSort,
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredProducts.length + (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= filteredProducts.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return _buildProductCard(filteredProducts[index]);
                        },
                      ),
                    ),
                  ],
                ),
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
}
