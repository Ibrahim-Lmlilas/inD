package com.srrfrr.api.dto.driver;

import com.srrfrr.api.enums.user.Approval;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateApprovalDriverRequest {

    @NotNull(message = "Approval cannot be null")
    private Approval approval;

}