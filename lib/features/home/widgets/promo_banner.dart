import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color : const Color(0xffE7DFEB), 
        borderRadius: BorderRadius.circular(18), 
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }
}