import 'package:flutter/material.dart';

// Welcome Page Illustration
class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background buildings
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 48, height: 128, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Container(width: 32, height: 96, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Container(width: 40, height: 112, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Container(width: 24, height: 80, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
        // Sofa
        Positioned(
          bottom: 80,
          child: Container(
            width: 192,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -8,
                  left: 32,
                  child: Container(
                    width: 48,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Character
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Head
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDBAC),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            // Shirt
            Container(
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
            // Pants
            Container(
              width: 96,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Services Page Illustration
class ServicesIllustration extends StatelessWidget {
  const ServicesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background tools
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ),
        // Phone mockup
        Container(
          width: 128,
          height: 224,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade800, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Notch
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 64,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Screen content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.pink, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(height: 8, color: Colors.grey.shade200),
                        const SizedBox(height: 4),
                        Container(
                          height: 8,
                          width: 80,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Hand pointing
        Positioned(
          bottom: 64,
          right: 80,
          child: Container(
            width: 96,
            height: 128,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBAC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Booking Page Illustration
class BookingIllustration extends StatelessWidget {
  const BookingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background elements
        Positioned(
          top: 80,
          left: 80,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 32,
              height: 48,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        Positioned(
          top: 96,
          right: 112,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 40,
              height: 64,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        // Character upper body
        Positioned(
          top: 64,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDBAC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Calendar
        Positioned(
          bottom: 48,
          child: Container(
            width: 160,
            height: 176,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      Color color;
                      if (index % 4 == 0) {
                        color = Colors.green.shade300;
                      } else if (index % 3 == 0) {
                        color = Colors.purple.shade300;
                      } else if (index % 2 == 0) {
                        color = Colors.yellow.shade300;
                      } else {
                        color = Colors.pink.shade300;
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Clock
        Positioned(
          bottom: 64,
          left: 48,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade600, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(60, 60),
                painter: ClockPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.shade700
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    // Hour hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height / 2 - 15),
      paint,
    );

    // Minute hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2 + 20, size.height / 2 - 5),
      paint,
    );

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Payment Page Illustration
class PaymentIllustration extends StatelessWidget {
  const PaymentIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background frames
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(width: 48, height: 64, color: Colors.grey.shade300),
                Container(width: 64, height: 48, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
        // Invoice
        Positioned(
          left: 48,
          child: Transform.rotate(
            angle: -0.1,
            child: Container(
              width: 112,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    8,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Credit Card
        Container(
          width: 144,
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade500, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Coins
        Positioned(
          bottom: 64,
          right: 64,
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.yellow.shade700, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6914),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow.shade700, width: 2),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: -16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow.shade700, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
