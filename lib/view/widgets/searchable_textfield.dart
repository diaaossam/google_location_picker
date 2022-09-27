import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchableTextField<T> extends ConsumerStatefulWidget {
  const SearchableTextField({
    Key? key,
    this.onChanged,
    this.controller,
    this.validator,
    this.borderRaduis = 10,
    this.prefix,
    this.margin,
    this.hint,
    this.inputBorder,
    required this.items,
    required this.onSubmit,
    required this.itemToString,
    this.label,
    this.defaultValue,
    this.decoration,
  }) : super(key: key);
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double borderRaduis;
  final Widget? prefix;

  final String? hint;
  final ValueChanged<T> onSubmit;
  final InputBorder? inputBorder;
  final List<T> items;
  final String Function(T) itemToString;
  final String? label;
  final T? defaultValue;
  final EdgeInsetsDirectional? margin;
  final InputDecoration? decoration;
  @override
  ConsumerState<SearchableTextField> createState() =>
      _AutoCompleteTextFieldState<T>();
}

class _AutoCompleteTextFieldState<T>
    extends ConsumerState<SearchableTextField<T>> {
  OverlayEntry? _entry;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  late List displayList = [];
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      _controller.text = widget.itemToString(widget.defaultValue as T);
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverLay();
      } else {
        _hideOverlay();
      }
    });
  }

  void _showOverLay() {
    final overLay = Overlay.of(context)!;
    final RenderBox renderBox = (context.findRenderObject() as RenderBox);
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _entry = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: offset.dx,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0.0, size.height - 10),
          showWhenUnlinked: false,
          child: _buildSearchResult(),
        ),
      ),
    );
    overLay.insert(_entry!);
  }

  void _hideOverlay() {
    _entry?.remove();
    _entry = null;
  }

  Widget _buildSearchResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          constraints: const BoxConstraints(maxHeight: 200),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ]),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Scrollbar(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: displayList.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Material(
                        child: InkWell(
                          onTap: () => _onSelected(index),
                          child: Text(widget
                              .itemToString(displayList.elementAt(index))),
                        ),
                      ),
                    );
                  })),
        ),
      ],
    );
  }

  void _onSelected(int index) {
    _controller.text = widget.itemToString(displayList.elementAt(index));
    widget.onSubmit(displayList.elementAt(index));
    _hideOverlay();
    _focusNode.unfocus();
  }

  void _onSearch(String? query) {
    _hideOverlay();
    widget.onChanged?.call(query!);
    _showOverLay();
  }

  @override
  Widget build(BuildContext context) {
    displayList = widget.items;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        onChanged: _onSearch,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintText: Localizations.localeOf(context).languageCode == "en"
              ? "seach here by location...."
              : "ابحث عن موقع اخر",
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
