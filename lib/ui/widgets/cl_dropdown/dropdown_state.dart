import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import '../cl_text_field.widget.dart';

class DropdownState<T extends Object> extends ChangeNotifier {
  List<T> items = [];
  final Future<(List<T>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})?
  asyncSearchCallback;
  final Future<List<T>> Function(String)? syncSearchCallback;
  int perPage;
  bool loading = false;
  OverlayEntry? _overlayEntry;
  final LayerLink layerLink = LayerLink();
  final Widget Function(BuildContext, T) itemBuilder;
  final String Function(T) valueToShow;
  List<T> selectedItems = [];
  final List<T> previousSelectedItems;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  T? selectedItem;
  final bool isMultiple;
  GlobalKey textFormFieldKey = GlobalKey();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final BuildContext context;
  final FocusNode focusNode;
  final String? searchColumn;
  bool isOverlayOpen = false;

  DropdownState({
    this.items = const [],
    required this.asyncSearchCallback,
    required this.syncSearchCallback,
    required this.context,
    required this.itemBuilder,
    required this.isMultiple,
    required this.valueToShow,
    required this.previousSelectedItems,
    required this.onSelectItems,
    required this.onSelectItem,
    required this.focusNode,
    required this.perPage,
    required this.searchColumn,
  }) {
    if (isMultiple) {
      assert(onSelectItems != null);
    } else {
      assert(onSelectItem != null);
    }
    _init(previousSelectedItems);
  }

  void _init(List<T> previousSelectedItems) {
    // Non precarico più i dati all'inizializzazione, vengono caricati solo quando si apre l'overlay
    _preSelectData(previousSelectedItems);
    // Rimozione del FocusNode e dei listener associati
  }

  Future<void> _prefillData() async {
    if (asyncSearchCallback != null) {
      loading = true;
      notifyListeners();
      try {
        var (values, _) = await asyncSearchCallback!(page: 1, perPage: perPage);

        items = values;
      } catch (e) {
        items = [];
      } finally {
        loading = false;
        notifyListeners();
      }
    }
  }

  void _preSelectData(List<T> previousSelectedItems) {
    if (isMultiple) {
      selectedItems.addAll(previousSelectedItems);
    } else {
      if (previousSelectedItems.isNotEmpty) {
        selectedItem = previousSelectedItems.first;
        textEditingController.text = valueToShow(selectedItem!);
      }
    }
  }

  void toggleOverlay() {
    if (isOverlayOpen) {
      closeOverlay();
    } else {
      openOverlay();
    }
  }

  void openOverlay() async {
    if (isOverlayOpen) return;

    // Carica i dati solo se non sono già stati caricati
    if (items.isEmpty && asyncSearchCallback != null) {
      await _prefillData();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    isOverlayOpen = true;
    notifyListeners();
  }

  void closeOverlay() {
    if (!isOverlayOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    isOverlayOpen = false;

    // Se è stata fatta una ricerca, resetta la lista alla prossima apertura
    if (searchController.text.isNotEmpty) {
      searchController.clear();
      items = []; // Svuota items per forzare il reload alla prossima apertura
    }

    notifyListeners();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = textFormFieldKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Background GestureDetector per chiudere l'Overlay quando si tocca fuori
              GestureDetector(
                onTap: () {
                  closeOverlay();
                },
                behavior: HitTestBehavior.translucent,
              ),
              Positioned(
                width: size.width,
                left: offset.dx,
                top: offset.dy,
                child: CompositedTransformFollower(
                  link: layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0.0, size.height + 4),
                  child: CLContainer(
                    contentMargin: EdgeInsets.zero,
                    showShadow: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo di ricerca nell'overlay
                        if (syncSearchCallback != null || asyncSearchCallback != null)
                          Padding(
                            padding: const EdgeInsets.all(Sizes.padding / 2),
                            child: Material(
                              type: MaterialType.transparency,
                              child: CLTextField(
                                controller: searchController,
                                labelText: 'Cerca...',
                                prefixIcon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedSearch01,
                                  color: CLTheme.of(context).secondaryText,
                                  size: Sizes.medium,
                                ),
                                prefixIconConstraints: BoxConstraints(minWidth: Sizes.medium + 16, minHeight: Sizes.medium + 16),
                                onChanged: (value) async {
                                  await onSearch(searchColumn, value);
                                },
                              ),
                            ),
                          ),
                        // Lista degli elementi
                        items.isEmpty
                            ? Material(
                              type: MaterialType.transparency,
                              child: Container(
                                padding: const EdgeInsets.all(Sizes.padding),
                                child: Text('Nessun risultato trovato', style: CLTheme.of(context).bodyLabel),
                              ),
                            )
                            : ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  var item = items[index];
                                  return GestureDetector(
                                    onTap: () {
                                      _selectItem(item);
                                    },
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: ListTile(
                                        titleTextStyle: CLTheme.of(context).bodyText,
                                        title: itemBuilder(context, item),
                                        trailing:
                                            isMultiple
                                                ? Checkbox(
                                                  splashRadius: 0,
                                                  value: selectedItems.contains(item),
                                                  onChanged: (value) {
                                                    _selectItem(item);
                                                  },
                                                  activeColor: CLTheme.of(context).primary,
                                                  checkColor: Colors.white,
                                                )
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _selectItem(T item) {
    if (isMultiple) {
      // Non chiudiamo e riapriamo l'overlay per i dropdown multipli
      // Aggiorniamo solo lo stato
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
        onSelectItems?.call(selectedItems);
      } else {
        selectedItems.remove(item);
        onSelectItems?.call(selectedItems);
      }
      notifyListeners();
    } else {
      selectedItem = item;
      textEditingController.text = valueToShow(item);
      onSelectItem?.call(selectedItem);
      closeOverlay();
      notifyListeners();
    }
  }

  void removeItem(T item) {
    if (isMultiple) {
      selectedItems.remove(item);
      onSelectItems?.call(selectedItems);
    } else {
      selectedItem = null;
      textEditingController.clear();
      _init([]);
      onSelectItem?.call(null);
      focusNode.unfocus();
      closeOverlay();
    }
    notifyListeners();
  }

  Future<void> onSearch(String? searchColumn, String query) async {
    if (asyncSearchCallback != null) {
      try {
        loading = true;
        notifyListeners();

        if (query.isEmpty) {
          var (values, _) = await asyncSearchCallback!.call(page: 1, perPage: perPage);
          items = values;
        } else {
          var (values, _) = await asyncSearchCallback!.call(page: 1, perPage: perPage, searchBy: {searchColumn!: query});
          items = values;
        }
      } catch (e) {
        items = [];
      } finally {
        loading = false;
        notifyListeners();
        // Aggiorna l'overlay se è aperto
        if (isOverlayOpen) {
          _overlayEntry?.markNeedsBuild();
        }
      }
    } else if (syncSearchCallback != null) {
      items = await syncSearchCallback!.call(query);
      notifyListeners();
      // Aggiorna l'overlay se è aperto
      if (isOverlayOpen) {
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  @override
  void dispose() {
    closeOverlay();
    searchController.dispose();
    super.dispose();
  }
}
