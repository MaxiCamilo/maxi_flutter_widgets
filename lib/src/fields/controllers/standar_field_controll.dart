import 'dart:async';

import 'package:maxi_flutter_widgets/src/architecture/field_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';
import 'package:meta/meta.dart';

abstract class StandarFieldControll<T> implements Disposable, FieldController {
  final LifeCoordinator heart;
  @override
  final List<String> fieldNames;
  final List<Validator> validators;

  late final StreamController<bool> _validityChangeController;
  late final StreamController<ErrorData> _notifyChangeErrorController;

  bool _isValid = true;
  late T _currentValue;
  MasterChannel<dynamic, Result<T>>? _masterChannel;

  ErrorData _lastError = const ControlledFailure(
    errorCode: ErrorCode.implementationFailure,
    message: FixedOration(message: 'No error has occurred yet'),
  );

  @override
  bool get itWasDiscarded => heart.itWasDiscarded;

  @override
  Future<dynamic> get onDispose => heart.onDispose;

  ErrorData get lastError => _lastError;

  @override
  Stream<bool> get validityChange => _validityChangeController.stream;

  @override
  void dispose() => heart.dispose();

  @override
  bool itsCanAcceptType(Type type) => type == T;

  @override
  T obtainFieldValue() => _currentValue;

  @override
  bool get isValid => _isValid;

  Stream<ErrorData> get notifyChangeError => _notifyChangeErrorController.stream;

  StandarFieldControll({required T currentValue, required this.heart, required this.fieldNames, required this.validators}) {
    _validityChangeController = heart.joinStreamController(StreamController<bool>.broadcast());
    _notifyChangeErrorController = heart.joinStreamController(StreamController<ErrorData>.broadcast());
    _currentValue = currentValue;
    final firstValidation = checkValue(currentValue);
    if (firstValidation.itsFailure) {
      defineAsInvalid(firstValidation.error);
    } else {
      defineAsValid();
    }
  }

  @override
  Result<Channel<Result<T>, dynamic>> buildFieldChannel() {
    if (heart.itWasDiscarded) {
      return NegativeResult.controller(
        code: ErrorCode.discontinuedFunctionality,
        message: FixedOration(message: 'Cannot build channel from a disposed controller'),
      );
    }
    if (_masterChannel == null) {
      _masterChannel = MasterChannel<dynamic, Result<T>>();
      heart.joinDisposableObject(_masterChannel!);
      _masterChannel!.getReceiver().onCorrectLambda(_onChannelReceive).logIfFails(errorName: '[$runtimeType -> buildFieldChannel] Could not get channel receiver');
    }

    return _masterChannel!.buildConnector();
  }

  void _onChannelReceive(Stream<dynamic> stream) {
    heart.joinStream(
      stream: stream,
      onData: (data) {
        changeFieldValue(data);
      },
    );
  }

  @override
  void defineAsInvalid(ErrorData reason) {
    if (_isValid) {
      _isValid = false;
      _lastError = reason;
      _validityChangeController.add(_isValid);
      _notifyChangeErrorController.add(reason);
    } else if (_lastError != reason) {
      _lastError = reason;
      _notifyChangeErrorController.add(reason);
    }
  }

  @override
  void defineAsValid() {
    if (!_isValid) {
      _isValid = true;
      _validityChangeController.add(_isValid);
    }
  }

  @protected
  Result<T> whenUnkownTypeValue(dynamic value) {
    return NegativeResult.controller(
      code: ErrorCode.wrongType,
      message: FlexibleOration(message: 'Only values of type %1 are accepted', textParts: [T]),
    );
  }

  @protected
  Result<T> adaptedValue(T value) {
    return ResultValue(content: value);
  }

  void redefineEqualValue(T value) {}

  @override
  Result<T> changeFieldValue(value) {
    if (value is! T) {
      final convert = whenUnkownTypeValue(value);
      if (convert.itsFailure) {
        return convert;
      } else {
        value = convert.content;
      }
    }

    final adaptValue = adaptedValue(value);
    if (adaptValue.itsFailure) {
      return adaptValue;
    } else {
      value = adaptValue.content;
    }

    if (value == _currentValue) {
      redefineEqualValue(value);
      return isValid ? ResultValue(content: _currentValue) : NegativeResult<T>.controller(code: ErrorCode.invalidValue, message: _lastError.message);
    }

    final validation = checkValue(value);
    _currentValue = value;
    if (validation.itsFailure) {
      defineAsInvalid(validation.error);
      _masterChannel?.sendItem(validation.cast<T>());
    } else {
      defineAsValid();
      _masterChannel?.sendItem(validation.changeValueResult((_) => value));
    }

    return ResultValue(content: _currentValue);
  }

  @protected
  Result<void> previousChecks(T value) {
    return voidResult;
  }

  @protected
  Result<void> beforeValidatorsCheck(T value) {
    return voidResult;
  }

  @override
  Result<void> checkValue(value) {
    if (value is! T) {
      return NegativeResult.controller(
        code: ErrorCode.wrongType,
        message: FlexibleOration(message: 'Only values of type %1 are accepted', textParts: [T]),
      );
    }

    final previous = previousChecks(value);
    if (previous.itsFailure) {
      return previous;
    }

    for (final validator in validators) {
      final validationResult = validator.validateValue(value: value);
      if (validationResult.itsFailure) {
        return validationResult;
      }
    }

    final before = beforeValidatorsCheck(value);
    if (before.itsFailure) {
      return before;
    }

    return voidResult;
  }
}
