package com.srrfrr.api.enums.user;

public enum Approval {
    PENDING,
    VALIDATED,
    REJECTED;

    public static Approval defaultStatus() {
        return PENDING;
    }

    public static Approval defaultBackofficeStatus() {
        return VALIDATED;
    }
}