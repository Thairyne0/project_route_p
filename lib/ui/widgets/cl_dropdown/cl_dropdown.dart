import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_text_field.widget.dart';
import 'dropdown_state.dart';

class CLDropdown<T extends Object> extends StatefulWidget {
  CLDropdown({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.valueToShow,
    required this.hint,
    this.asyncSearchCallback,
    this.syncSearchCallback,
    this.items = const [],
    this.searchColumn,
    required this.isMultiple,
    required this.selectedValues,
    this.onSelectItem,
    this.length = 5,
    this.validators,
    this.isEnabled = true,
    this.onSelectItems,
  });

  final TextEditingController controller;
  List<T> items = [];
  final Widget Function(BuildContext, T) itemBuilder;
  final int length;
  final String Function(T) valueToShow;
  final String hint;
  final Future<List<T>> Function(String)? syncSearchCallback;
  final Future<(List<T>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})?
  asyncSearchCallback;
  final String? searchColumn;
  final bool isMultiple;
  final List<T> selectedValues;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final List<FormFieldValidator<String>>? validators;
  final bool isEnabled;

  @override
  State<CLDropdown<T>> createState() => _CLDropdownState<T>();

  factory CLDropdown.singleSync({
    Key? key,
    required String hint,
    required List<T> items,
    required String Function(T) valueToShow,
    Future<List<T>> Function(String value)? searchCallback,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(T?)? onSelectItem,
    final List<FormFieldValidator<String>>? validators,
    int length = 5,
    T? selectedValues,
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
      items: items,
      isMultiple: false,
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      selectedValues: previousvalueToShows,
      hint: hint,
      length: length,
      onSelectItem: onSelectItem,
      syncSearchCallback: searchCallback,
    );
  }

  factory CLDropdown.singleAsync({
    Key? key,
    required String hint,
    required Future<(List<T>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})?
    searchCallback,
    required searchColumn,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) valueToShow,
    final List<FormFieldValidator<String>>? validators,
    final bool isEnabled = true,
    int length = 5,
    T? selectedValues,
    required Function(T?)? onSelectItem,
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
      itemBuilder: itemBuilder,
      hint: hint,
      isMultiple: false,
      isEnabled: isEnabled,
      valueToShow: valueToShow,
      asyncSearchCallback: searchCallback,
      searchColumn: searchColumn,
      selectedValues: previousvalueToShows,
      onSelectItem: onSelectItem,
      validators: validators,
      length: length,
    );
  }

  factory CLDropdown.multipleSync({
    Key? key,
    required String hint,
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required Future<List<T>> Function(String value) searchCallback,
    required String Function(T) valueToShow,
    required Function(List<T>)? onSelectItems,
    final List<FormFieldValidator<String>>? validators,
    List<T> selectedValues = const [],
    int length = 5,
  }) {
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
      items: items,
      isMultiple: true,
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      hint: hint,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      length: length,
      syncSearchCallback: searchCallback,
      validators: validators,
    );
  }

  factory CLDropdown.multipleAsync({
    Key? key,
    required String hint,
    required Future<(List<T>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})?
    searchCallback,
    required searchColumn,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) valueToShow,
    required Function(List<T>)? onSelectItems,
    final List<FormFieldValidator<String>>? validators,
    List<T> selectedValues = const [],
    int length = 5,
  }) {
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      hint: hint,
      isMultiple: true,
      asyncSearchCallback: searchCallback,
      searchColumn: searchColumn,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      length: length,
      validators: validators,
    );
  }
}

class _CLDropdownState<T extends Object> extends State<CLDropdown<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    return ChangeNotifierProvider<DropdownState<T>>(
      create:
          (context) => DropdownState(
            items: widget.items,
            asyncSearchCallback: widget.asyncSearchCallback,
            syncSearchCallback: widget.syncSearchCallback,
            context: context,
            focusNode: focusNode,
            itemBuilder: widget.itemBuilder,
            isMultiple: widget.isMultiple,
            valueToShow: widget.valueToShow,
            onSelectItem: widget.onSelectItem,
            onSelectItems: widget.onSelectItems,
            previousSelectedItems: widget.selectedValues,
            perPage: widget.length,
            searchColumn: widget.searchColumn,
          ),
      builder: (context, child) {
        var state = context.watch<DropdownState<T>>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompositedTransformTarget(
              link: state.layerLink,
              child: CLTextField(
                key: state.textFormFieldKey,
                controller: state.textEditingController,
                labelText: widget.hint,
                isRequired: false,
                isEnabled: widget.isEnabled,
                isReadOnly: true,
                validators: widget.validators,
                onTap: widget.isEnabled ? () => state.toggleOverlay() : null,
                suffixIcon:
                    !widget.isEnabled
                        ? null
                        : state.loading
                        ? Padding(
                          padding: const EdgeInsets.only(right: Sizes.small),
                          child: SizedBox(
                            width: Sizes.medium,
                            height: Sizes.medium,
                            child: Center(
                              child: SizedBox(
                                width: Sizes.medium,
                                height: Sizes.medium,
                                child: CircularProgressIndicator(
                                  color: CLTheme.of(context).primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        : state.selectedItem != null
                        ? _deleteButton(
                          onPressed: () {
                            state.removeItem(state.selectedItem!);
                          },
                        )
                        : Padding(
                          padding: const EdgeInsets.only(right: Sizes.small),
                          child: HugeIcon(
                            icon: state.isOverlayOpen ? HugeIcons.strokeRoundedArrowUp01 : HugeIcons.strokeRoundedArrowDown01,
                            color: CLTheme.of(context).secondaryText,
                            size: Sizes.small,
                          ),
                        ),
              ),
            ),
            widget.isMultiple
                ? Wrap(
                  children:
                      state.selectedItems
                          .map(
                            (item) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                                color: CLTheme.of(context).primary.withOpacity(0.08),
                              ),
                              padding: const EdgeInsets.only(left: Sizes.padding / 2, right: 4),
                              margin: const EdgeInsets.only(top: Sizes.padding, right: Sizes.padding),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(widget.valueToShow(item), style: CLTheme.of(context).bodyText),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onPressed: () {
                                      state.removeItem(item);
                                    },
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedCancel01,
                                      size: Sizes.small,
                                      color: CLTheme.of(context).primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _deleteButton({required Function() onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(right: Sizes.small),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedCancel01,
          color: CLTheme.of(context).danger,
          size: Sizes.small,
        ),
      ),
    );
  }
}
