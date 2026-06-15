package com.srrfrr.api.services.payment;

import com.srrfrr.api.enums.Ride.PaymentType;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePaymentTypeRequest {
    private PaymentType paymentType;
}

