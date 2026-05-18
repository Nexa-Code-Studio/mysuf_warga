import 'package:flutter/material.dart';

class VerificationFormControllers {
  final TextEditingController dob = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController district = TextEditingController();
  final TextEditingController subdistrict = TextEditingController();
  final TextEditingController postalCode = TextEditingController();

  final TextEditingController plateNumber = TextEditingController();
  final TextEditingController stnkNumber = TextEditingController();
  final TextEditingController brand = TextEditingController();
  final TextEditingController vehicleType = TextEditingController();
  final TextEditingController vehicleYear = TextEditingController();
  final TextEditingController vehicleColor = TextEditingController();
  final TextEditingController vehicleCc = TextEditingController();
  final TextEditingController taxValue = TextEditingController();

  final TextEditingController companyName = TextEditingController();
  final TextEditingController companyId = TextEditingController();
  final TextEditingController businessName = TextEditingController();
  final TextEditingController workLocation = TextEditingController();
  final TextEditingController distance = TextEditingController();

  final TextEditingController householdActiveCount = TextEditingController();
  final TextEditingController sharedName = TextEditingController();
  final TextEditingController sharedNik = TextEditingController();
  final TextEditingController sharedRelation = TextEditingController();

  final TextEditingController nibNumber = TextEditingController();

  void dispose() {
    dob.dispose();
    phone.dispose();
    address.dispose();
    province.dispose();
    city.dispose();
    district.dispose();
    subdistrict.dispose();
    postalCode.dispose();
    plateNumber.dispose();
    stnkNumber.dispose();
    brand.dispose();
    vehicleType.dispose();
    vehicleYear.dispose();
    vehicleColor.dispose();
    vehicleCc.dispose();
    taxValue.dispose();
    companyName.dispose();
    companyId.dispose();
    businessName.dispose();
    workLocation.dispose();
    distance.dispose();
    householdActiveCount.dispose();
    sharedName.dispose();
    sharedNik.dispose();
    sharedRelation.dispose();
    nibNumber.dispose();
  }
}
