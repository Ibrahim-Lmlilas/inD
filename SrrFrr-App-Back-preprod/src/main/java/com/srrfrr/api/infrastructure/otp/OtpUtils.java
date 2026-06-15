package com.srrfrr.api.infrastructure.otp;

import com.srrfrr.api.enums.user.Language;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.security.SecureRandom;

@Service
public class OtpUtils {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int OTP_LENGTH = 6;

    @Value("${whatsapp.phone.id}")
    private String whatsappPhoneId;

    @Value("${whatsapp.api.token}")
    private String whatsappApiToken;

    @Value("${whatsapp.template}")
    private String whatsappTemplate;

    public static String generateOtp() {
        final StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(RANDOM.nextInt(10));
        }
        return otp.toString();
    }

    public void sendOtpMessage(final String phoneNumber, final String otp, final Language language) {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(whatsappApiToken);

        // Get language code for WhatsApp template
        final String languageCode = getWhatsAppLanguageCode(language);

        final String jsonBody = """
                {
                  "messaging_product": "whatsapp",
                  "to": "%s",
                  "type": "template",
                  "template": {
                    "name": "%s",
                    "language": {
                      "code": "%s"
                    },
                    "components": [
                      {
                        "type": "body",
                        "parameters": [
                          {
                            "type": "text",
                            "text": "%s"
                          }
                        ]
                      },
                      {
                        "type": "button",
                        "sub_type": "url",
                        "index": "0",
                        "parameters": [
                          {
                            "type": "text",
                            "text": "%s"
                          }
                        ]
                      }
                    ]
                  }
                }
                """.formatted(phoneNumber, whatsappTemplate, languageCode, otp, otp);

        final HttpEntity<String> request = new HttpEntity<>(jsonBody, headers);
        final RestTemplate restTemplate = new RestTemplate();
        final String whatsappApiUrl = "https://graph.facebook.com/v22.0/" + whatsappPhoneId + "/messages";
        final ResponseEntity<String> response = restTemplate.postForEntity(whatsappApiUrl, request, String.class);

        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("Failed to send WhatsApp message: " + response.getBody());
        }
    }

    /**
     * Convert Language enum to WhatsApp language code
     */
    private String getWhatsAppLanguageCode(Language language) {
        if (language == null) {
            return "fr"; // Default to French
        }
        
        return language.getCode();
    }
}