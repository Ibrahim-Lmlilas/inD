//package com.srrfrr.api.utils;
//
//import lombok.extern.slf4j.Slf4j;
//import static com.srrfrr.api.utils.ConsoleConstants.*;
//
//@Slf4j
//public class OperationLogger {
//    private static final OperationLogger INSTANCE = new OperationLogger();
//
//    void performance(final String operation, final long startTime, final long endTime) {
//        final long duration = endTime - startTime;
//        final String color = duration > 1000 ? BRIGHT_RED : duration > 500 ? BRIGHT_YELLOW : BRIGHT_GREEN;
//        final String status = duration > 1000 ? "SLOW" : duration > 500 ? "MODERATE" : "FAST";
//        log.info("{}{}{} {}{} {} {}ms ({}){}",
//                color, BOLD, ICON_PERFORMANCE, operation, RESET, ARROW_RIGHT, duration, status, RESET);
//    }
//
//    void security(final String action, final String details) {
//        log.info("{}{}{} {}{} {} {}{}",
//                BRIGHT_BLUE, BOLD, ICON_SECURITY, action, RESET, ARROW_RIGHT, details, RESET);
//    }
//
//    void database(final String operation, final String entity, final String details) {
//        log.debug("{}{}{} {} {}{} {} {}{}",
//                BRIGHT_CYAN, BOLD, ICON_DATABASE, operation, entity, RESET, ARROW_RIGHT, details, RESET);
//    }
//
//    void apiCall(final String method, final String endpoint, final String status) {
//        final String color = status.startsWith("2") ? BRIGHT_GREEN :
//                status.startsWith("4") ? BRIGHT_YELLOW : BRIGHT_RED;
//        log.info("{}{}{} {} {}{} {} Status: {}{}",
//                color, BOLD, ICON_API, method, endpoint, RESET, ARROW_RIGHT, status, RESET);
//    }
//
//    void validation(final String field, final boolean isValid, final String message) {
//        final String icon = isValid ? "[OK]" : "[FAIL]";
//        final String color = isValid ? BRIGHT_GREEN : BRIGHT_RED;
//        log.debug("{}{}{} {} {}{} {} {}{}",
//                color, BOLD, icon, ICON_VALIDATION, field, RESET, ARROW_RIGHT, message, RESET);
//    }
//
//    void fileOperation(final String operation, final String fileName, final String status) {
//        final String color = "SUCCESS".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
//        log.debug("{}{}{} {} {}{} {} {}{}",
//                color, BOLD, ICON_FILE, operation, fileName, RESET, ARROW_RIGHT, status, RESET);
//    }
//
//    void otpOperation(final String operation, final String phone, final String status) {
//        final String color = "SENT".equals(status) || "VALID".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
//        log.debug("{}{}{} {} {}{} {} {}{}",
//                color, BOLD, ICON_OTP, operation, phone, RESET, ARROW_RIGHT, status, RESET);
//    }
//
//    void authOperation(final String operation, final String userId, final String status) {
//        final String color = "SUCCESS".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
//        log.info("{}{}{} {} (User: {}){} {} {}{}",
//                color, BOLD, ICON_AUTH, operation, userId, RESET, ARROW_RIGHT, status, RESET);
//    }
//
//    void locationOperation(final String operation, final String driverId, final double lat, final double lng) {
//        log.debug("{}{}{} {} Driver:{}{} {} Coords: [{}, {}]{}",
//                BRIGHT_BLUE, BOLD, ICON_LOCATION, operation, driverId, RESET, ARROW_RIGHT, lat, lng, RESET);
//    }
//
//    void priceCalculation(final String operation, final double input, final double result) {
//        log.debug("{}{}{} {}{} {} Input: {} {} Result: ${}${}",
//                BRIGHT_GREEN, BOLD, ICON_PRICING, operation, RESET, ARROW_RIGHT, input, ARROW_RIGHT, result, RESET);
//    }
//
//    void transactionStart(final String transactionName) {
//        log.debug("\n{}{}{} START {}{}\n",
//                BRIGHT_CYAN, BOLD, ICON_TRANSACTION, transactionName, RESET);
//    }
//
//    void transactionEnd(final String transactionName, final String status) {
//        final String color = "COMMIT".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
//        log.debug("\n{}{}{} {} {}{}\n",
//                color, BOLD, ICON_TRANSACTION, status, transactionName, RESET);
//    }
//
//    void request(final String endpoint, final String method, final String body) {
//        log.debug("{}{}{} {} {}{}\n{}{} Body: {}{}",
//                BRIGHT_BLUE, BOLD, ICON_REQUEST, method, endpoint, RESET,
//                BRIGHT_BLUE, ARROW_RIGHT, body, RESET);
//    }
//
//    void response(final String endpoint, final int statusCode, final String body) {
//        final String color = statusCode >= 200 && statusCode < 300 ? BRIGHT_GREEN : BRIGHT_RED;
//        log.debug("{}{}{} {} ({}){}\n{}{} Body: {}{}",
//                color, BOLD, ICON_RESPONSE, endpoint, statusCode, RESET,
//                color, ARROW_RIGHT, body, RESET);
//    }
//
//    void sessionStats(final String context, final int drivers, final int passengers, final int activeOffers) {
//        log.info("{}{}{} {}{} {} Session Statistics - Drivers: {}, Passengers: {}, Active Offers: {}",
//                BRIGHT_CYAN, BOLD, ICON_INFO, context, RESET, ARROW_RIGHT, drivers, passengers, activeOffers);
//    }
//
//
//
//
//
//
//
//    public static void performance(final String operation, final long startTime, final long endTime) {
//        INSTANCE.performance(operation, startTime, endTime);
//    }
//
//    public static void security(final String action, final String details) {
//        INSTANCE.security(action, details);
//    }
//
//    public static void database(final String operation, final String entity, final String details) {
//        INSTANCE.database(operation, entity, details);
//    }
//
//    public static void apiCall(final String method, final String endpoint, final String status) {
//        INSTANCE.apiCall(method, endpoint, status);
//    }
//
//    public static void validation(final String field, final boolean isValid, final String message) {
//        INSTANCE.validation(field, isValid, message);
//    }
//
//    public static void fileOperation(final String operation, final String fileName, final String status) {
//        INSTANCE.fileOperation(operation, fileName, status);
//    }
//
//    public static void otpOperation(final String operation, final String phone, final String status) {
//        INSTANCE.otpOperation(operation, phone, status);
//    }
//
//    public static void authOperation(final String operation, final String userId, final String status) {
//        INSTANCE.authOperation(operation, userId, status);
//    }
//
//    public static void locationOperation(final String operation, final String driverId, final double lat, final double lng) {
//        INSTANCE.locationOperation(operation, driverId, lat, lng);
//    }
//
//    public static void priceCalculation(final String operation, final double input, final double result) {
//        INSTANCE.priceCalculation(operation, input, result);
//    }
//
//    public static void transactionStart(final String transactionName) {
//        INSTANCE.transactionStart(transactionName);
//    }
//
//    public static void transactionEnd(final String transactionName, final String status) {
//        INSTANCE.transactionEnd(transactionName, status);
//    }
//
//    public static void request(final String endpoint, final String method, final String body) {
//        INSTANCE.request(endpoint, method, body);
//    }
//
//    public static void response(final String endpoint, final int statusCode, final String body) {
//        INSTANCE.response(endpoint, statusCode, body);
//    }
//
//    public static void sessionStats(final String context, final int drivers, final int passengers, final int activeOffers) {
//        INSTANCE.sessionStats(context, drivers, passengers, activeOffers);
//    }
//}
