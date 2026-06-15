package com.srrfrr.api.annotations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import jakarta.validation.constraints.NotNull;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = {})
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)

@NotNull(message = "Status Accepted cannot be null")
public @interface ValidStatus {
    String message() default "Invalid Status Accepted";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}