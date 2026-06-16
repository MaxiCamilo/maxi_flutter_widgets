import 'dart:async';

import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

abstract class FiealdTemplateController<T> with DisposableMixin, InitializableMixin, LifecycleHub implements FieldController<T> {
  final List<String> _listeningFieldNames;
  final List<Validator> _validators;

  @override
  final bool aceptInvalidValues;

  T _currentValue;
  bool _isValid = true;
  NegativeResult? _actualError;

  @override
  bool get isValid => _isValid;

  late StreamController<T> _valueChangedController;
  late StreamController<NegativeResult> _valueChangeErrorController;
  late StreamController<bool> _isValidChangedController;

  T get currentValue => _currentValue;

  FiealdTemplateController({required List<String> listeningFieldNames, required T initialValue, required List<Validator> validators, required this.aceptInvalidValues})
    : _listeningFieldNames = listeningFieldNames,
      _currentValue = initialValue,
      _validators = validators;
  FiealdTemplateController.oneName({required String name, required T initialValue, required List<Validator> validators, required this.aceptInvalidValues})
    : _listeningFieldNames = [name],
      _currentValue = initialValue,
      _validators = validators;

  @override
  Type get typeManager => T;

  @override
  Stream<T> get onValueChanged => initialize().onCorrectDirectOrThrow((_) => _valueChangedController.stream);

  @override
  Stream<NegativeResult> get onValueChangeError => initialize().onCorrectDirectOrThrow((_) => _valueChangeErrorController.stream);

  @override
  Stream<bool> get isValidChanged => initialize().onCorrectDirectOrThrow((_) => _isValidChangedController.stream);

  @override
  bool isListeningToFieldName(String fieldName) => initialize().onCorrectSelect((_) => _listeningFieldNames.contains(fieldName)).content;

  @override
  Result<void> performInitialization() {
    _valueChangedController = lifecycleScope.joinStreamController(StreamController<T>.broadcast());
    _valueChangeErrorController = lifecycleScope.joinStreamController(StreamController<NegativeResult>.broadcast());
    _isValidChangedController = lifecycleScope.joinStreamController(StreamController<bool>.broadcast());

    final verResult = checkValue(_currentValue);
    _isValid = verResult.itsCorrect;
    if (_isValid) {
      _actualError = null;
    } else {
      _actualError = NegativeResult(error: verResult.error);
    }

    return voidResult;
  }

  @override
  Result<void> changeFieldValueByName({required String name, required T newValue}) {
    final initResult = initialize();
    if (initResult.itsFailure) {
      return initResult.cast();
    }

    if (isListeningToFieldName(name)) {
      return changeFieldValue(newValue);
    }
    return voidResult;
  }

  bool compareValues(T value) => value == _currentValue;

  @override
  Result<void> changeFieldValue(T newValue) {
    final initResult = initialize();
    if (initResult.itsFailure) {
      return initResult.cast();
    }

    if (compareValues(newValue)) {
      return voidResult;
    }

    final verResult = checkValue(newValue);
    if (verResult.itsFailure && !aceptInvalidValues) {
      return verResult.cast();
    }
    final actualValid = _isValid;
    _isValid = verResult.itsCorrect;
    _currentValue = newValue;
    _valueChangedController.add(newValue);

    if (verResult.itsFailure) {
      _actualError = NegativeResult(error: verResult.error);
      _valueChangeErrorController.add(_actualError!);
    } else {
      _actualError = null;
    }

    if (actualValid != _isValid) {
      _isValidChangedController.add(_isValid);
    }

    return voidResult;
  }

  @override
  Result<T> getFieldValue({required String name}) => initialize().onCorrect((_) => ResultValue(content: _currentValue));

  Result<void> extraCheckValue(dynamic value);

  @override
  Result<void> checkValue(value) {
    final extraCheckResult = extraCheckValue(value);
    if (extraCheckResult.itsFailure) {
      return extraCheckResult;
    }

    for (final val in _validators) {
      final valResult = val.validateValue(value: value);
      if (valResult.itsFailure) {
        return valResult.cast();
      }
    }

    return voidResult;
  }

  @override
  NegativeResult<void> getActualError() {
    final initResult = initialize();
    if (initResult.itsFailure) {
      return NegativeResult(error: initResult.error);
    }

    if (_isValid || _actualError == null) {
      return NegativeResult.controller(
        code: ErrorCode.invalidValue,
        message: const FixedOration(message: 'The current value is valid, there is no error'),
      );
    } else {
      return _actualError!;
    }
  }

  @override
  void defineAsInvalid(NegativeResult error) {
    final actualValid = _isValid;
    _isValid = false;
    _actualError = error;
    _valueChangeErrorController.add(error);
    if (actualValid != _isValid) {
      _isValidChangedController.add(_isValid);
    }
  }
}
