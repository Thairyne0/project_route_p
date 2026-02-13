import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'buttons/cl_soft_button.widget.dart';

class CLTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FocusNode? focusNode;
  final int? maxLines;
  final TextInputType inputType;
  final bool isObscured;
  final bool isEnabled;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? suffixIcon;
  final bool isTextArea;
  final bool isRequired;
  final bool isRounded;
  final bool isReadOnly;
  final Future Function(String value)? onChanged;
  final List<FormFieldValidator<String>>? validators;
  final GestureTapCallback? onTap;
  final Function(String)? onColorPicked;
  final Function(File?)? onFilePicked;
  final Function(DateTime?)? onDateTimeSelected;
  final Function(TimeOfDay?)? onTimeSelected;
  final bool withTime;
  final bool onlyTime;
  final bool withoutDay;
  final TimeOfDay? initialSelectedTime;
  final DateTime? initialSelectedDateTime;
  final String? initValue;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;

  const CLTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.focusNode,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
    this.isObscured = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffixIcon,
    this.isTextArea = false,
    this.isRequired = false,
    this.isRounded = false,
    this.isReadOnly = false,
    this.onTap,
    this.onChanged,
    this.validators,
    this.onColorPicked,
    this.onFilePicked,
    this.onDateTimeSelected,
    this.onTimeSelected,
    this.initialSelectedTime,
    this.initialSelectedDateTime,
    this.withTime = false,
    this.withoutDay = false,
    this.initValue,
    this.inputFormatters,
    this.onlyTime = false,
    this.fillColor,
  });

  @override
  CLTextFieldState createState() => CLTextFieldState();

  // Factory methods
  factory CLTextField.disabled({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: false,
      validators: validators,
    );
  }

  factory CLTextField.password({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    dynamic prefix,
    dynamic suffix,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isObscured: true,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }

  factory CLTextField.time({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    bool withTime = false,
    bool withoutDay = false,
    TimeOfDay? initialSelectedTime,
    required Function(TimeOfDay?) onTimeSelected,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.datetime,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      onlyTime: true,
      initialSelectedTime: initialSelectedTime,
      onTimeSelected: onTimeSelected,
      validators: validators,
    );
  }

  factory CLTextField.date({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    bool withTime = false,
    bool withoutDay = false,
    DateTime? initialSelectedDateTime,
    required Function(DateTime?) onDateTimeSelected,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      inputType: TextInputType.datetime,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      withoutDay: withoutDay,
      initialSelectedDateTime: initialSelectedDateTime,
      onDateTimeSelected: onDateTimeSelected,
      validators: validators,
      withTime: withTime,
    );
  }

  factory CLTextField.filePicker({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    required Function(File?) onFilePicked,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      onFilePicked: onFilePicked,
    );
  }

  factory CLTextField.colorPicker({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required Function(String) onColorPicked,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      onColorPicked: onColorPicked,
      onTap: onTap,
      isReadOnly: true,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.textArea({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    //onChanged
    final Future Function(String value)? onChanged,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      maxLines: 5,
      isTextArea: true,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
      onChanged: onChanged,
    );
  }

  factory CLTextField.currency({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      prefixIcon: iconAlignment == IconAlignment.start ? Icon(FontAwesomeIcons.moneyCheck, size: Sizes.small, color: Colors.grey) : null,
      inputType: TextInputType.numberWithOptions(decimal: true),
      suffixIcon: iconAlignment == IconAlignment.end ? Icon(FontAwesomeIcons.moneyCheck, size: Sizes.small, color: Colors.grey) : null,
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }

  factory CLTextField.number({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    final List<FormFieldValidator<String>>? validators,
    String? initValue,
    bool withDecimal = false,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      inputType: TextInputType.numberWithOptions(decimal: withDecimal),
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      initValue: initValue,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.icon({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required dynamic icon,
    bool isReadOnly = false,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      isRequired: isRequired,
      initValue: initValue,
      prefixIcon:
          iconAlignment == IconAlignment.start
              ? icon.runtimeType == IconData
                  ? Icon(icon, size: Sizes.small, color: Colors.grey)
                  : icon
              : null,
      suffixIcon:
          iconAlignment == IconAlignment.end
              ? icon.runtimeType == IconData
                  ? Icon(icon, size: Sizes.small, color: Colors.grey)
                  : icon
              : null,
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
    );
  }

  factory CLTextField.rightLeftIcon({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    required dynamic leftIcon,
    required dynamic rightIcon,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    bool isRounded = false,
    bool isEnabled = true,
    String? initValue,
    bool isReadOnly = false,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      prefixIcon: leftIcon.runtimeType == IconData ? Icon(leftIcon, size: Sizes.small, color: Colors.grey) : leftIcon,
      suffixIcon: rightIcon.runtimeType == IconData ? Icon(rightIcon, size: Sizes.small, color: Colors.grey) : rightIcon,
      onChanged: onChanged,
      focusNode: focusNode,
      onTap: onTap,
      isReadOnly: isReadOnly,
      isRounded: isRounded,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }

  factory CLTextField.rounded({
    Key? key,
    required TextEditingController controller,
    required String labelText,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Future Function(String value)? onChanged,
    bool isRequired = false,
    bool isEnabled = true,
    bool isReadOnly = false,
    String? initValue,
    final List<FormFieldValidator<String>>? validators,
  }) {
    return CLTextField(
      key: key,
      controller: controller,
      labelText: labelText,
      suffixIcon: null,
      onTap: onTap,
      onChanged: onChanged,
      focusNode: focusNode,
      isReadOnly: isReadOnly,
      isRounded: true,
      isEnabled: isEnabled,
      validators: validators,
      initValue: initValue,
    );
  }
}

class CLTextFieldState extends State<CLTextField> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
    if (widget.initValue != null) {
      _controller.text = widget.initValue!;
    }
    if (widget.initialSelectedDateTime != null) {
      isDatePicked = true;
      _controller.text = DateFormat(
        widget.withTime
            ? widget.withoutDay
                ? 'MM-yyyy HH:mm'
                : 'dd-MM-yyyy HH:mm'
            : widget.withoutDay
            ? 'MM-yyyy'
            : 'dd-MM-yyyy',
      ).format(widget.initialSelectedDateTime!);
    }
    if (widget.initialSelectedTime != null) {
      isDatePicked = true;
      _controller.text =
          "${widget.initialSelectedTime!.hour.toString().padLeft(2, '0')}:${widget.initialSelectedTime!.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate;
    if (!widget.onlyTime) {
      if (widget.withoutDay) {
        pickedDate = await showMonthPicker(
          context: context,
          initialDate: widget.initialSelectedDateTime,
          firstDate: DateTime(1900),
          lastDate: DateTime(DateTime.now().year + 100),
          monthPickerDialogSettings: MonthPickerDialogSettings(
            actionBarSettings: PickerActionBarSettings(
              confirmWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.small),
                margin: const EdgeInsets.symmetric(vertical: Sizes.small / 2),
                decoration: BoxDecoration(color: CLTheme.of(context).primary, borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                child: Text("Conferma", style: CLTheme.of(context).bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              cancelWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.small),
                margin: const EdgeInsets.symmetric(vertical: Sizes.small / 2),
                decoration: BoxDecoration(
                  color: CLTheme.of(context).danger.withAlpha(26),
                  borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                ),
                child: Text("Annulla", style: CLTheme.of(context).bodyText.copyWith(color: CLTheme.of(context).danger, fontWeight: FontWeight.w500)),
              ),
            ),
            headerSettings: PickerHeaderSettings(
              headerBackgroundColor: CLTheme.of(context).primary,
              headerCurrentPageTextStyle: CLTheme.of(context).heading6.override(color: Colors.white),
            ),
            dateButtonsSettings: PickerDateButtonsSettings(
              buttonBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
              selectedMonthBackgroundColor: CLTheme.of(context).primary,
              unselectedMonthsTextColor: CLTheme.of(context).primaryText,
              currentMonthTextColor: CLTheme.of(context).primary,
            ),
            dialogSettings: PickerDialogSettings(
              scrollAnimationMilliseconds: 0,
              dialogBackgroundColor: CLTheme.of(context).secondaryBackground,
              locale: const Locale('it', 'IT'),
              dialogRoundedCornersRadius: Sizes.borderRadius,
            ),
          ),
        );
      } else {
        pickedDate = await showDatePicker(
          locale: const Locale('it', 'IT'),
          context: context,
          initialDate: widget.initialSelectedDateTime ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(DateTime.now().year + 100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: CLTheme.of(context).primary,
                  onPrimary: Colors.white,
                  onSurface: CLTheme.of(context).primaryText,
                  surface: CLTheme.of(context).secondaryBackground,
                ),
                dialogBackgroundColor: CLTheme.of(context).secondaryBackground,
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: CLTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                  headerBackgroundColor: CLTheme.of(context).primary,
                  headerForegroundColor: Colors.white,
                  dayStyle: CLTheme.of(context).bodyText,
                  yearStyle: CLTheme.of(context).bodyText,
                  dayForegroundColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return CLTheme.of(context).primaryText;
                  }),
                  dayBackgroundColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return CLTheme.of(context).primary;
                    }
                    return Colors.transparent;
                  }),
                  todayBackgroundColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return CLTheme.of(context).primary;
                    }
                    return CLTheme.of(context).primary.withAlpha(26);
                  }),
                  todayForegroundColor: WidgetStateColor.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return CLTheme.of(context).primary;
                  }),
                  cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).danger)),
                  confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).primary)),
                ),
              ),
              child: child!,
            );
          },
        );
      }

      if (pickedDate != null) {
        DateTime? finalDateTime = pickedDate;

        // Controlla se `withTime` è true per mostrare il selettore dell'orario
        if (widget.withTime) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: widget.initialSelectedDateTime?.hour ?? TimeOfDay.now().hour,
              minute: widget.initialSelectedDateTime?.minute ?? TimeOfDay.now().minute,
            ),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: CLTheme.of(context).primary,
                    onPrimary: Colors.white,
                    onSurface: CLTheme.of(context).primaryText,
                    surface: CLTheme.of(context).secondaryBackground,
                  ),
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: CLTheme.of(context).secondaryBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                    hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                    dialBackgroundColor: CLTheme.of(context).primary.withAlpha(26),
                    dialHandColor: CLTheme.of(context).primary,
                    dialTextColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return CLTheme.of(context).primaryText;
                    }),
                    hourMinuteTextColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.selected) ? Colors.white : CLTheme.of(context).primaryText,
                    ),
                    dayPeriodTextColor: CLTheme.of(context).primaryText,
                    dayPeriodColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return CLTheme.of(context).primary.withAlpha(50);
                      }
                      return Colors.transparent;
                    }),
                    cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).danger)),
                    confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).primary)),
                  ),
                ),
                child: child!,
              );
            },
          );

          // Se l'utente non ha selezionato un orario, annulla la data
          if (pickedTime == null) {
            setState(() {
              isDatePicked = false;
              _controller.clear();
            });
            return;
          }

          // Combina data e orario selezionato
          finalDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        }

        // Aggiorna lo stato e passa la data (e ora, se selezionata) al callback
        setState(() {
          isDatePicked = true;
          widget.onDateTimeSelected!(finalDateTime);
          _controller.text = DateFormat(
            widget.withTime
                ? widget.withoutDay
                    ? 'MM-yyyy HH:mm'
                    : 'dd-MM-yyyy HH:mm'
                : widget.withoutDay
                ? 'MM-yyyy'
                : 'dd-MM-yyyy',
          ).format(finalDateTime!);
        });
      }
    } else {
      final TimeOfDay? pickedTime = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.inputOnly,
        context: context,
        initialTime: widget.initialSelectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: CLTheme.of(context).primary,
                onPrimary: Colors.white,
                onSurface: CLTheme.of(context).primaryText,
                surface: CLTheme.of(context).secondaryBackground,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: CLTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                dialBackgroundColor: CLTheme.of(context).primary.withAlpha(26),
                dialHandColor: CLTheme.of(context).primary,
                dialTextColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return CLTheme.of(context).primaryText;
                }),
                hourMinuteTextColor: WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? Colors.white : CLTheme.of(context).primaryText,
                ),
                dayPeriodTextColor: CLTheme.of(context).primaryText,
                dayPeriodColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return CLTheme.of(context).primary.withAlpha(50);
                  }
                  return Colors.transparent;
                }),
                cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).danger)),
                confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(CLTheme.of(context).primary)),
              ),
            ),
            child: child!,
          );
        },
      );
      setState(() {
        if (pickedTime != null) {
          widget.onTimeSelected!(pickedTime);
          isDatePicked = true;
          _controller.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
        }
      });
    }
  }

  Future<void> _selectColor(BuildContext context) async {
    final result = await showColorPickerDialog(context, CLTheme.of(context).primary);
    setState(() {
      widget.onColorPicked!(result.hex);
      _controller.text = result.hex;
    });
  }

  Future<void> _pickFile(BuildContext context) async {
    if (!isPicking) {
      setState(() {
        isPicking = true;
      });
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      setState(() {
        isPicking = false;
      });
      if (result != null) {
        PlatformFile platformFile = result.files.first;
        File file = File(platformFile.path!);
        widget.onFilePicked!(file);
        setState(() {
          isFilePicked = true;
        });
        _controller.text = platformFile.name;
      }
    }
  }

  bool isFilePicked = false;
  bool isDatePicked = false;
  bool isPicking = false;

  @override
  Widget build(BuildContext context) {
    // Determina il callback per il GestureDetector
    final VoidCallback? gestureTapCallback =
        widget.onColorPicked != null
            ? () => _selectColor(context)
            : (widget.onDateTimeSelected != null || widget.onTimeSelected != null)
            ? () => _selectDate(context)
            : widget.onFilePicked != null
            ? () => _pickFile(context)
            : null;

    // Determina se assorbire i pointer
    final bool shouldAbsorbPointer =
        ((widget.onDateTimeSelected != null || widget.onTimeSelected != null) && !isDatePicked) ||
        widget.onColorPicked != null ||
        (widget.onFilePicked != null && !isFilePicked);

    // Determina se il campo è readonly
    final bool isReadOnly =
        widget.onFilePicked != null
            ? isFilePicked
            : widget.onDateTimeSelected != null
            ? isDatePicked
            : widget.isReadOnly;

    return GestureDetector(
      onTap: gestureTapCallback,
      child: AbsorbPointer(
        absorbing: shouldAbsorbPointer,
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          cursorColor: CLTheme.of(context).primary,
          readOnly: isReadOnly,
          onTap: widget.onTap,
          controller: _controller,
          focusNode: widget.focusNode,
          maxLines: widget.isTextArea ? widget.maxLines : 1,
          keyboardType: widget.inputType,
          obscureText: widget.isObscured && !_isPasswordVisible,
          enabled: widget.isEnabled,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
          style: CLTheme.of(context).bodyText,
          decoration: InputDecoration(
            isDense: !widget.isTextArea,
            floatingLabelStyle: CLTheme.of(context).bodyText.merge(TextStyle(color: CLTheme.of(context).primary)),
            labelStyle: CLTheme.of(context).bodyLabel,
            alignLabelWithHint: true,
            errorMaxLines: 200,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: widget.isTextArea ? 12 : 14),
            labelText: widget.isRequired ? "${widget.labelText ?? ''}*" : widget.labelText,
            prefixIcon:
                widget.prefixIcon != null
                    ? Padding(padding: const EdgeInsets.symmetric(horizontal: Sizes.small / 2), child: widget.prefixIcon)
                    : null,
            prefixIconConstraints:
                widget.prefixIconConstraints ?? (widget.prefixIcon != null ? const BoxConstraints(minWidth: 36, minHeight: 36) : null),
            suffixIcon: _buildSuffixIconWidget(),
            suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            hoverColor: Colors.transparent,
            filled: widget.fillColor != null || !widget.isEnabled,
            fillColor: widget.fillColor ?? (widget.isEnabled ? null : CLTheme.of(context).alternate),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isRounded ? 100 : 10.0),
              borderSide: BorderSide(color: CLTheme.of(context).primary, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isRounded ? 100 : 10.0),
              borderSide: widget.isEnabled ? BorderSide(color: CLTheme.of(context).borderColor, width: 1.0) : BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.isRounded ? 100 : 10.0), borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isRounded ? 100 : 10.0),
              borderSide: BorderSide(color: CLTheme.of(context).danger, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isRounded ? 100 : 10.0),
              borderSide: BorderSide(color: CLTheme.of(context).danger, width: 2.0),
            ),
            errorStyle: CLTheme.of(context).smallLabel.merge(TextStyle(color: CLTheme.of(context).danger)),
          ),
          validator: combineValidators(widget.validators),
        ),
      ),
    );
  }

  // Helper per ottenere gli input formatters di default
  List<TextInputFormatter> _getDefaultInputFormatters() {
    if (widget.inputType.decimal != null) {
      return widget.inputType.decimal == true
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$'))]
          : [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }

  // Metodo unificato per costruire il suffixIcon
  Widget? _buildSuffixIconWidget() {
    if (widget.onColorPicked != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 10, 4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Sizes.borderRadius), color: hexToColor(widget.controller.text)),
        ),
      );
    }

    if (widget.onFilePicked != null) {
      return isFilePicked
          ? _deleteButton(
            onPressed: () {
              setState(() {
                isFilePicked = false;
              });
              widget.onFilePicked!(null);
              _controller.text = "";
            },
          )
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: CLSoftButton.primary(icon: FontAwesomeIcons.file, text: "Seleziona file", onTap: () {}, context: context),
          );
    }

    if (widget.onDateTimeSelected != null || widget.onTimeSelected != null) {
      return isDatePicked
          ? _deleteButton(
            onPressed: () {
              setState(() {
                isDatePicked = false;
              });
              if (widget.onDateTimeSelected != null) {
                widget.onDateTimeSelected!(null);
              }
              if (widget.onTimeSelected != null) {
                widget.onTimeSelected!(null);
              }
              _controller.text = "";
            },
          )
          : _buildSuffixIcon();
    }

    return _buildSuffixIcon();
  }

  static FormFieldValidator<String>? combineValidators(List<FormFieldValidator<String>>? validators) {
    if (validators != null && validators.isNotEmpty) {
      return (String? value) {
        String totalError = "";
        for (var validator in validators) {
          var result = validator(value);
          if (result != null) {
            totalError += "$result\n";
          }
        }
        if (totalError.trim().isEmpty) {
          return null;
        } else {
          return totalError; // Tutti i validator hanno passato
        }
      };
    } else {
      return null; // Nessun validator fornito
    }
  }

  Color hexToColor(String? hexString) {
    // Aggiunge il prefisso alpha se manca
    if (hexString != null) {
      if (hexString.isNotEmpty) {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } else {
        return CLTheme.of(context).primary;
      }
    } else {
      return CLTheme.of(context).primary;
    }
  }

  Widget _deleteButton({required Function() onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(right: Sizes.small),
        child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: CLTheme.of(context).danger, size: Sizes.small),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isObscured) {
      return IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        padding: const EdgeInsets.only(right: Sizes.small),
        icon: Icon(
          _isPasswordVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
          size: Sizes.small,
          color: CLTheme.of(context).secondaryText,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    } else if (widget.inputType == TextInputType.datetime) {
      return Padding(
        padding: const EdgeInsets.only(right: Sizes.small),
        child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: Sizes.small, color: CLTheme.of(context).secondaryText),
      );
    } else {
      return widget.suffixIcon;
    }
  }
}
