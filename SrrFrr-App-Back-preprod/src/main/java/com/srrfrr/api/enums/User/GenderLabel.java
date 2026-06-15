package com.srrfrr.api.enums.user;

import com.srrfrr.api.exceptions.authentication.InvalidRequestException;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum GenderLabel {
    MALE("ذكر", "Homme", "Male"),
    FEMALE("أنثى", "Femme", "Female");

    private final String arabic;
    private final String french;
    private final String english;

    public static GenderLabel fromString(final String value) {
        if (value == null || value.isBlank()) {
            throw new InvalidRequestException("Gender is required");
        }
        for (final GenderLabel g : values()) {
            if (g.name().equalsIgnoreCase(value) || g.english.equalsIgnoreCase(value)) {
                return g;
            }
        }
        throw new InvalidRequestException("Invalid gender selection");
    }
}