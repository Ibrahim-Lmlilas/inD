package com.srrfrr.api.utils;

public class PhoneNumberUtils {
    public static String normalizeToInternational(final String phone) {
        if (phone == null) {
            return null;
        }

        final String cleanedPhone = phone.replaceAll("[\\s\\-()]", "");

        if (cleanedPhone.matches("^0[678]\\d{8}$")) {
            return "+212" + cleanedPhone.substring(1);
        }

        if (cleanedPhone.startsWith("+212")) {
            String rest = cleanedPhone.substring(4);

            rest = rest.replaceFirst("^0+", "");

            if (rest.matches("^[678]\\d{8}$") && rest.length() == 9) {
                return "+212" + rest;
            } else {
                return null;
            }
        }

        if (cleanedPhone.matches("^\\+\\d{8,15}$")) {
            return cleanedPhone;
        }

        return null;
    }
}