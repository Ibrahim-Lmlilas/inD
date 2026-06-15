package com.srrfrr.api.dto.user;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class DeleteAccountRequest {
    
    @NotBlank(message = "Password is required")
    private String password;
    
    @Size(max = 255, message = "Reason too long")
    private String reason;
    
    @AssertTrue(message = "You must confirm account deletion")
    private boolean confirmed;
    
    // Getters and setters
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    
    public boolean isConfirmed() { return confirmed; }
    public void setConfirmed(boolean confirmed) { this.confirmed = confirmed; }
}
