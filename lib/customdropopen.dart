library customdropopen;
import 'package:flutter/material.dart';


class CustomDropOpen extends StatefulWidget {
  final dynamic items; /// Lists of items
  final String? title;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final bool isDataLoading;
  final ValueChanged<int>? onChange;
  final int? index;
  final double? height;
  final ShapeBorder? shape;
  final double? elevation;


  const CustomDropOpen({
    Key? key,
    this.backgroundColor = Colors.black,
    this.items,
    this.title,
    this.borderRadius,
    this.textColor = Colors.white,
    this.iconColor = Colors.black,
    this.onChange,
    this.index, /// selected index is required to change the color
    this.height,
    this.shape,
     this.elevation = 0,
    this.isDataLoading = false,

  })  : assert(items != null),
        super(key: key);
  @override
  _CustomDropOpenState createState() => _CustomDropOpenState();
}

class _CustomDropOpenState extends State<CustomDropOpen>
    with SingleTickerProviderStateMixin {
  GlobalKey? key;
  bool isMenuOpen = false;
  bool isSelect = false;
  Offset? buttonPosition;
  Size? buttonSize;
  late OverlayEntry overlayEntry;
  BorderRadius? borderRadius;
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    borderRadius = widget.borderRadius ?? BorderRadius.circular(4);
    key = LabeledGlobalKey("button_icon");
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    closeMenu();
    super.dispose();
  }

  findButton() {
    RenderBox? renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    buttonSize = renderBox!.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    overlayEntry.remove();

    animationController!.reverse();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    animationController!.forward();
    overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)!.insert(overlayEntry);
    isMenuOpen = !isMenuOpen;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
        closeMenu();
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      },
      child: Card(
        key:  key,
        color:  Colors.transparent,
        elevation: widget.elevation,
        shape: widget.shape == null ?  StadiumBorder() : widget.shape,
        child: Padding(
          padding:  const EdgeInsets.all(0),
          child: TextButton(
            onPressed: (){
               if (isMenuOpen) {
                  closeMenu();
                  setState(() {
                    isSelect = false;
                  });
                } else {
                  openMenu();
                  setState(() {
                    isSelect = true;
                  });
                }

            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child:  Text(widget.title!,style:  TextStyle(
                    color: widget.textColor,fontSize: 14
                  ),),
                ),
               isSelect == false ?
               const   Icon(Icons.keyboard_arrow_down_outlined,
                      size: 30,
                        color: Colors.white,) :
               const  Icon(Icons.keyboard_arrow_up_outlined,
                 size: 30,
                 color: Colors.white,)

              ],
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition!.dy + buttonSize!.height,
          left: buttonPosition!.dx,
          width: buttonSize!.width,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipPath(
                    clipper: ArrowClipper(),
                    child: Container(
                      width: 14,
                      height: 14,
                      color: widget.backgroundColor ,
                    ),
                  ),
                ),
                Container(
                  height: widget.height,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: borderRadius,
                  ),
                  child: Theme(
                    data: ThemeData(
                      iconTheme: IconThemeData(
                        color: widget.iconColor,
                      ),
                    ),
                    child: widget.isDataLoading == true ?  Center(
                      child:  Text('Please wait...',
                        textAlign: TextAlign.center,style: TextStyle(
                            color:widget.textColor,fontWeight: FontWeight.bold
                        ),),
                    ) : ListView.builder(
                        itemCount: widget.items!.length,
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context,index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                widget.onChange!(index);
                                closeMenu();
                              },
                              child: Text(
                                widget.items[index].name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: widget.index == index ?
                                    widget.textColor : Colors.grey ,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height /2);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
