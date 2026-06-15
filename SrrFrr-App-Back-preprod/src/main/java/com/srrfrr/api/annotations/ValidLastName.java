package com.srrfrr.api.annotations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = {})
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)

@NotBlank(message =  "Last name cannot be null")
@Size(min = 2, max = 20, message = "Last name must be between 1 and 20 characters")
@Pattern(regexp = "^(?!\\s*$)[A-Za-zÀ-ÿ\\u0600-\\u06FF\\u0750-\\u077F\\u08A0-\\u08FF\\u0590-\\u05FF\\s'-]+$", message = "Last name must contain only letters and cannot be empty or just spaces")

public @interface ValidLastName{
    String message() default "Invalid Last name";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}