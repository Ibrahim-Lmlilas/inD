package com.srrfrr.api.enums.user;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum Language {
	FR("fr"),
	EN("en"),
	AR("ar");

	private final String code;

	Language(String code) {
		this.code = code;
	}

	@JsonValue
	public String getCode() {
		return code;
	}

	@JsonCreator
	public static Language fromCode(String code) {
		if (code == null) {
			return FR;
		}

		for (Language language : Language.values()) {
			if (language.code.equalsIgnoreCase(code)) {
				return language;
			}
		}
		return FR; // default
	}

	@Override
	public String toString() {
		return code;
	}
}