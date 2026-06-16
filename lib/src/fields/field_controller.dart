import 'package:maxi_framework/maxi_framework.dart';

abstract interface class FieldController<T> implements Disposable {
  bool get isValid;
  bool get aceptInvalidValues;
  Stream<bool> get isValidChanged;
  Stream<T> get onValueChanged;
  Stream<NegativeResult> get onValueChangeError;
  Type get typeManager;
  bool isListeningToFieldName(String fieldName);
  Result<void> checkValue(dynamic value);
  Result<bool> isControllerAcceptType(Type type);
  Result<void> changeFieldValueByName({required String name, required T newValue});
  Result<void> changeFieldValue(T newValue);
  Result<void> changeGenericFieldValue({required String name, required dynamic newValue});
  Result<T> getFieldValue({required String name});
  NegativeResult<void> getActualError();
  void defineAsInvalid(NegativeResult error);
}
