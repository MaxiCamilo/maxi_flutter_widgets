import 'package:maxi_framework/maxi_framework.dart';

mixin FieldController on Disposable {
  List<String> get fieldNames;
  Stream<bool> get validityChange;

  bool get isValid;
  void defineAsValid();
  void defineAsInvalid(ErrorData reason);
  bool itsCanAcceptType(Type type);
  dynamic obtainFieldValue();
  Result<void> checkValue(dynamic value);
  Result changeFieldValue(dynamic value);

  Result<Channel<Result, dynamic>> buildFieldChannel();
}
