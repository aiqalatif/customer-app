import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? size;
  double? height;
  double? paddingvalue; 
  Color? backgroundColor, borderColor, titleFontColor;
  double? borderWidth, borderRadius;

  SimBtn({
    Key? key,
    this.title,
    this.onBtnSelected,
    this.size,
    this.height,
    this.titleFontColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.paddingvalue,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * size!;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      padding: paddingvalue != null ? EdgeInsets.all(paddingvalue!) : null,
      child: Container(
        width: size,
        height: height ?? 35,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1]),
          color: backgroundColor ?? colors.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius ?? 0.0,
            ),
          ),
          border: Border.all(
            width: borderWidth ?? 0,
            color: borderColor ?? Colors.transparent,
          ),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleFontColor ?? colors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}

// appbtn

class AppBtn extends StatelessWidget {
  final String? title;
  final AnimationController? btnCntrl;
  final Animation? btnAnim;
  final VoidCallback? onBtnSelected;
  final bool removeTopPadding;

  const AppBtn({
    Key? key,
    this.title,
    this.btnCntrl,
    this.btnAnim,
    this.onBtnSelected,
    this.removeTopPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialWidth = btnAnim!.value;
    return AnimatedBuilder(
      builder: (c, child) => _buildBtnAnimation(
        c,
        child,
        initialWidth: initialWidth,
      ),
      animation: btnCntrl!,
    );
  }

  Widget _buildBtnAnimation(BuildContext context, Widget? child,
      {required double initialWidth}) {
    return Padding(
      padding: EdgeInsets.only(top: removeTopPadding ? 0 : 25),
      child: CupertinoButton(
        child: Container(
          width: btnAnim!.value,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                circularBorderRadius10,
              ),
            ),
          ),
          child: btnAnim!.value > 75.0
              ? Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: colors.whiteTemp,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'ubuntu',
                      ),
                )
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.whiteTemp,
                  ),
                ),
        ),
        onPressed: () {
          //if it's not loading do the thing
          if (btnAnim!.value == initialWidth) {
            onBtnSelected!();
          }
        },
      ),
    );
  }
}
