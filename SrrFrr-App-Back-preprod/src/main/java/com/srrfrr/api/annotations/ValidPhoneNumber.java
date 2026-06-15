package com.srrfrr.api.annotations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

import java.lang.annotation.*;
@Documented
@Constraint(validatedBy = {})
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)

@NotBlank(message = "Phone number cannot be null")
@Pattern(
        regexp = "^(\\+\\d{8,15}|0[678]\\d{8})$",
        message = "The number must be valid: in international format (+1, +33, +212...) or Moroccan format (06/07/08) with the correct length."
)

public @interface ValidPhoneNumber {
    String message() default "Invalid Phone Number";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}