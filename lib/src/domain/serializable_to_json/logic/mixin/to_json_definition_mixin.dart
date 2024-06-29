import 'package:macros/macros.dart';

import '../../../class_info/logic/mixin/class_info_mixin.dart';
import '../interface/serializable_to_json_interface.dart';

mixin ToJsonDefinitionMixin on ClassInfoMixin implements SerializableToJsonInterface {
  Future<void> defineToJson(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    // TODO(alphamikle): Implement it
  }
}
