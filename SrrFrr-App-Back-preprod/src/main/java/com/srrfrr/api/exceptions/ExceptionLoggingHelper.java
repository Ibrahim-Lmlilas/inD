package com.srrfrr.api.exceptions;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.web.context.request.ServletWebRequest;

@Slf4j
public final class ExceptionLoggingHelper {
    private ExceptionLoggingHelper() {}
    public static void log(final Exception ex, final ServletWebRequest request) {
        final HttpMethod httpMethod = request.getHttpMethod();
        final String requestUrl = request.getRequest().getRequestURL().toString();
        log.error("Request {} {} failed with exception reason: {}",httpMethod, requestUrl, ex);
    }
}