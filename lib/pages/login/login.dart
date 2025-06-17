import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/login_service.dart';

// 添加这个包来显示GIF
import 'package:flutter_image/flutter_image.dart';

class MainShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.85, 0,
        size.width * 1.1, size.height * 0.2
    );
    path.lineTo(size.width * 1.1, size.height);
    path.quadraticBezierTo(
        size.width * 0.7, size.height * 0.9,
        size.width * 0.4, size.height * 0.95
    );
    path.quadraticBezierTo(
        size.width * 0.1, size.height,
        0, size.height * 0.8
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SecondaryShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.2,
        size.width * 0.5, size.height * 0.1
    );
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.05,
        size.width * 1.2, size.height * 0.3
    );
    path.lineTo(size.width * 1.2, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.8,
        size.width * 0.5, size.height * 0.85
    );
    path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.9,
        0, size.height * 0.7
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StaggeredLetter extends StatefulWidget {
  final String letter;
  final Duration delay;
  const StaggeredLetter({required this.letter, required this.delay});

  @override
  _StaggeredLetterState createState() => _StaggeredLetterState();
}

class _StaggeredLetterState extends State<StaggeredLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      ),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _anim.value),
          child: child,
        );
      },
      child: Text(
        widget.letter,
        style: GoogleFonts.robotoSlab(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: Colors.brown.shade900,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black.withOpacity(0.2),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key, required params}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _mainShapeCtrl;
  late AnimationController _secondaryShapeCtrl;
  late Animation<Offset> _mainShapeAnim;
  late Animation<Offset> _secondaryShapeAnim;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // To handle loading state
  @override
  void initState() {
    super.initState();
    _mainShapeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _mainShapeAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainShapeCtrl,
        curve: Curves.easeOutQuint,
      ),
    );

    _secondaryShapeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _secondaryShapeAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _secondaryShapeCtrl,
        curve: Curves.easeOutQuad,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainShapeCtrl.forward();
      Future.delayed(Duration(milliseconds: 300), () {
        _secondaryShapeCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _mainShapeCtrl.dispose();
    _secondaryShapeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgStart = Colors.white;
    final bgEnd = Colors.pink.shade50;

    final mainShapeColor = Colors.brown.shade100;
    final secondaryShapeColor = Colors.pinkAccent.withOpacity(0.3);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgStart, bgEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // GIF placeholder in top-left corner
          Positioned(
            top: 150,
            left: 24,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),

            ),
          ),

          Positioned(
            top: 20,
            left: 0,
            child: SlideTransition(
              position: _mainShapeAnim,
              child: ClipPath(
                clipper: MainShapeClipper(),
                child: Container(
                  width: w * 1.1,
                  height: h * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        mainShapeColor,
                        mainShapeColor.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainShapeColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: h * 0.1,
            left: 0,
            child: SlideTransition(
              position: _secondaryShapeAnim,
              child: ClipPath(
                clipper: SecondaryShapeClipper(),
                child: Container(
                  width: w * 1.05,
                  height: h * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        secondaryShapeColor,
                        secondaryShapeColor.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryShapeColor.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 180),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    'Welcome'.length,
                        (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: StaggeredLetter(
                        letter: 'Welcome'[i],
                        delay: Duration(milliseconds: 100 * i),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.pink.shade100,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 在表单左上角添加小鸟GIF
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.only(bottom: 10, left: 10),
                                child: Image(
                                  image: AssetImage(
                                    'asset/animations/login.gif', // 同样的GIF或使用不同的
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Cute email field with heart icon
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                filled: true,
                                fillColor: Colors.pink.shade50,
                                prefixIcon: Icon(Icons.mail_outline, color: Colors.pink),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Cute password field with lock icon
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                filled: true,
                                fillColor: Colors.pink.shade50,
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.pink),
                                suffixIcon: Icon(Icons.remove_red_eye_outlined, color: Colors.pink.shade200),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),

                            // Cute login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final username = usernameController.text.trim();
                                  final password = passwordController.text;

                                  if (username.isEmpty || password.isEmpty) {
                                    print("用户名或密码为空");
                                    // 可弹出提示，如使用 Fluttertoast
                                    return;
                                  }

                                  final success = await LoginService.login(username, password);

                                  if (success) {
                                    print("登录成功，跳转页面...");
                                    // TODO: 跳转主页，例如：
                                    Navigator.pushReplacementNamed(context, '/appMain');
                                  } else {
                                    print("登录失败，请检查用户名密码");
                                    // TODO: 弹出错误提示
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 5,
                                  shadowColor: Colors.pink.shade100,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_border, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Login',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Cute register button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.pink.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add, color: Colors.pink.shade300),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Register',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}