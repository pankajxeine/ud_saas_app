enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  dataRange,
  select,
  mutiselect,
  textarea,
  slider
}

extension EntityFieldTypeX on EntityFieldType {
  AppFormFieldType toFormFieldType() {
    switch (this) {
      case EntityFieldType.text:
        return AppFormFieldType.text;
      case EntityFieldType.email:
        return AppFormFieldType.email;
      case EntityFieldType.password:
        return AppFormFieldType.password;
      case EntityFieldType.phone:
        return AppFormFieldType.phone;
      case EntityFieldType.number:
        return AppFormFieldType.number;
      case EntityFieldType.currency:
        return AppFormFieldType.currency;
      case EntityFieldType.boolean:
        return AppFormFieldType.boolean;
      case EntityFieldType.date:
        return AppFormFieldType.date;
      case EntityFieldType.dataRange:
        return AppFormFieldType.dataRange;
      case EntityFieldType.select:
        return AppFormFieldType.select;
      case EntityFieldType.mutiselect:
        return AppFormFieldType.mutiselect;
      case EntityFieldType.textarea:
        return AppFormFieldType.textarea;
      case EntityFieldType.slider:
        return AppFormFieldType.slider;
    }
  }

  AppColumnType toColumnType() {
    switch (this) {
      case EntityFieldType.number:
        return AppColumnType.number;
      case EntityFieldType.currency:
        return AppColumnType.currency;
      case EntityFieldType.date:
      case EntityFieldType.dataRange:
        return AppColumnType.date;
      case EntityFieldType.select:
        return AppColumnType.select;
      default:
        return AppColumnType.slider;
    }
  }
}
