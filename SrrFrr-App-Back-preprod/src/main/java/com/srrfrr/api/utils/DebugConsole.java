package com.srrfrr.api.utils;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DebugConsole {

    // ANSI color codes
    public static final String RESET = "\u001B[0m";
    public static final String BLACK = "\u001B[30m";
    public static final String RED = "\u001B[31m";
    public static final String GREEN = "\u001B[32m";
    public static final String YELLOW = "\u001B[33m";
    public static final String BLUE = "\u001B[34m";
    public static final String PURPLE = "\u001B[35m";
    public static final String CYAN = "\u001B[36m";
    public static final String WHITE = "\u001B[37m";
    public static final String BRIGHT_RED = "\u001B[91m";
    public static final String BRIGHT_GREEN = "\u001B[92m";
    public static final String BRIGHT_YELLOW = "\u001B[93m";
    public static final String BRIGHT_BLUE = "\u001B[94m";
    public static final String BRIGHT_MAGENTA = "\u001B[95m";
    public static final String BRIGHT_CYAN = "\u001B[96m";

    // Background colors
    public static final String BG_RED = "\u001B[41m";
    public static final String BG_GREEN = "\u001B[42m";
    public static final String BG_YELLOW = "\u001B[43m";
    public static final String BG_BLUE = "\u001B[44m";
    public static final String BG_PURPLE = "\u001B[45m";
    public static final String BG_CYAN = "\u001B[46m";

    // Text styles
    public static final String BOLD = "\u001B[1m";
    public static final String UNDERLINE = "\u001B[4m";

    // Decorative elements (ASCII-safe)
    private static final String BORDER_DOUBLE = "═══════════════════════════════════════════════════════════════════════";
    private static final String BORDER_SINGLE = "───────────────────────────────────────────────────────────────────────";
    private static final String ARROW_RIGHT = "->";
    private static final String BULLET = "*";

    // Icons (ASCII-safe)
    private static final String ICON_START = "[START]";
    private static final String ICON_SUCCESS = "[SUCCESS]";
    private static final String ICON_ERROR = "[ERROR]";
    private static final String ICON_WARNING = "[WARNING]";
    private static final String ICON_INFO = "[INFO]";
    private static final String ICON_DATA = "[DATA]";
    private static final String ICON_TRACE = "[TRACE]";
    private static final String ICON_SECTION = "[SECTION]";
    private static final String ICON_PERFORMANCE = "[PERF]";
    private static final String ICON_SECURITY = "[SECURITY]";
    private static final String ICON_DATABASE = "[DB]";
    private static final String ICON_API = "[API]";
    private static final String ICON_VALIDATION = "[VALID]";
    private static final String ICON_FILE = "[FILE]";
    private static final String ICON_OTP = "[OTP]";
    private static final String ICON_AUTH = "[AUTH]";
    private static final String ICON_LOCATION = "[LOCATION]";
    private static final String ICON_PRICING = "[PRICE]";
    private static final String ICON_STEP = "[STEP]";
    private static final String ICON_TRANSACTION = "[TRANSACTION]";
    private static final String ICON_REQUEST = "[REQUEST]";
    private static final String ICON_RESPONSE = "[RESPONSE]";

    // Method entry/process start - single parameter version
    public static void methodStart(final String methodName) {
        log.debug("\n{}{}{} {}{}",
                BRIGHT_BLUE, BOLD, ICON_START, methodName, RESET);
    }

    // Method entry with parameters (without class name)
    public static void methodStartParams(final String methodName, final String... params) {
        final String paramString = params.length > 0 ? String.join(", ", params) : "no params";
        log.debug("\n{}{}{} {}{}\n{}{} Parameters: {}{}",
                BRIGHT_BLUE, BOLD, ICON_START, methodName, RESET,
                BRIGHT_BLUE, ARROW_RIGHT, paramString, RESET);
    }

    // Method entry with class name (no params)
    public static void methodStart(final String className, final String methodName) {
        log.debug("\n{}{}{} {}.{}{}",
                BRIGHT_BLUE, BOLD, ICON_START, className, methodName, RESET);
    }

    // Method entry with class name and parameters
    public static void methodStartFull(final String className, final String methodName, final String... params) {
        final String paramString = params.length > 0 ? String.join(", ", params) : "no params";
        log.debug("\n{}{}{} {}.{}{}\n{}{} Parameters: {}{}",
                BRIGHT_BLUE, BOLD, ICON_START, className, methodName, RESET,
                BRIGHT_BLUE, ARROW_RIGHT, paramString, RESET);
    }

    // Success/completion with enhanced visibility
    public static void methodSuccess(final String methodName, final String result) {
        log.debug("{}{}{} {}{}\n{}{} Result: {}{}",
                BRIGHT_GREEN, BOLD, ICON_SUCCESS, methodName, RESET,
                BRIGHT_GREEN, ARROW_RIGHT, result, RESET);
    }

    public static void methodSuccess(final String className, final String methodName, final String result) {
        log.debug("{}{}{} {}.{}{}\n{}{} Result: {}{}",
                BRIGHT_GREEN, BOLD, ICON_SUCCESS, className, methodName, RESET,
                BRIGHT_GREEN, ARROW_RIGHT, result, RESET);
    }

    // Errors/failures with enhanced visibility
    public static void methodError(final String methodName, final String error, final Exception ex) {
        log.error("\n{}{}{} {}{}\n{}{} Error: {}\n{}{} Exception: {}{}\n",
                BRIGHT_RED, BOLD, ICON_ERROR, methodName, RESET,
                BRIGHT_RED, ARROW_RIGHT, error, RESET,
                BRIGHT_RED, ARROW_RIGHT, ex.getMessage(), RESET);
    }

    public static void methodError(final String className, final String methodName, final String error, final Exception ex) {
        log.error("\n{}{}{} {}.{}{}\n{}{} Error: {}\n{}{} Exception: {}{}\n",
                BRIGHT_RED, BOLD, ICON_ERROR, className, methodName, RESET,
                BRIGHT_RED, ARROW_RIGHT, error, RESET,
                BRIGHT_RED, ARROW_RIGHT, ex.getMessage(), RESET);
    }

    public static void methodError(final String methodName, final String error) {
        log.error("\n{}{}{} {}{}\n{}{} Error: {}{}\n",
                BRIGHT_RED, BOLD, ICON_ERROR, methodName, RESET,
                BRIGHT_RED, ARROW_RIGHT, error, RESET);
    }

    // Warnings with enhanced visibility
    public static void methodWarning(final String methodName, final String warning) {
        log.warn("{}{}{} {}{}\n{}{} Warning: {}{}",
                BRIGHT_YELLOW, BOLD, ICON_WARNING, methodName, RESET,
                BRIGHT_YELLOW, ARROW_RIGHT, warning, RESET);
    }

    public static void methodWarning(final String className, final String methodName, final String warning) {
        log.warn("{}{}{} {}.{}{}\n{}{} Warning: {}{}",
                BRIGHT_YELLOW, BOLD, ICON_WARNING, className, methodName, RESET,
                BRIGHT_YELLOW, ARROW_RIGHT, warning, RESET);
    }

    // Information
    public static void info(final String message) {
        log.info("{}{}{} {}{}",
                BRIGHT_CYAN, BOLD, ICON_INFO, message, RESET);
    }

    public static void info(final String context,final String message) {
        log.info("{}{}{} {}{} {} {}",
                BRIGHT_CYAN, BOLD, ICON_INFO, context, RESET, ARROW_RIGHT, message);
    }

    public static void sessionStats(final String context,final int drivers,final int passengers,final int activeOffers) {
        log.info("{}{}{} {}{} {} Session Statistics - Drivers: {}, Passengers: {}, Active Offers: {}",
                BRIGHT_CYAN, BOLD, ICON_INFO, context, RESET, ARROW_RIGHT, drivers, passengers, activeOffers);
    }

    // Debug data with enhanced formatting
    public static void debugData(final String key,final Object value) {
        log.debug("{}{} {} {} = {}{}",
                BRIGHT_MAGENTA, BULLET, key, ARROW_RIGHT, value, RESET);
    }

    public static void debugData(final String context,final String key,final Object value) {
        log.debug("{}{}{} {}{} {} {} {} = {}{}",
                BRIGHT_MAGENTA, BOLD, ICON_DATA, context, RESET,
                BRIGHT_MAGENTA, BULLET, key, ARROW_RIGHT, value, RESET);
    }

    // Trace level detailed information
    public static void trace(final String message) {
        log.trace("{}{} {}{}", CYAN, ICON_TRACE, message, RESET);
    }

    public static void trace(final String context,final String message) {
        log.trace("{}{} {} {} {}{}", CYAN, ICON_TRACE, context, ARROW_RIGHT, message, RESET);
    }

    // Section headers with double borders
    public static void sectionHeader(final String sectionName) {
        log.info("\n{}{}{}\n{}{}{} {}{}\n{}{}{}\n",
                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE,
                BRIGHT_MAGENTA, BOLD, ICON_SECTION, sectionName, RESET,
                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE, RESET);
    }

    public static void sectionHeader(final String className,final String sectionName) {
        log.info("\n{}{}{}\n{}{}{} {}.{}{}\n{}{}{}\n",
                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE,
                BRIGHT_MAGENTA, BOLD, ICON_SECTION, className, sectionName, RESET,
                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE, RESET);
    }

    // Sub-section for grouping related operations
    public static void subSection(final String name) {
        log.info("{}{}{}\n{}{} {} {}{}",
                CYAN, BOLD, BORDER_SINGLE,
                CYAN, BULLET, name, RESET);
    }

    // Performance timing with color coding
    public static void performance(final String operation,final long startTime,final long endTime) {
        final long duration = endTime - startTime;
        final String color = duration > 1000 ? BRIGHT_RED : duration > 500 ? BRIGHT_YELLOW : BRIGHT_GREEN;
        final String status = duration > 1000 ? "SLOW" : duration > 500 ? "MODERATE" : "FAST";
        log.info("{}{}{} {}{} {} {}ms ({}){}",
                color, BOLD, ICON_PERFORMANCE, operation, RESET, ARROW_RIGHT, duration, status, RESET);
    }

    // Security related with distinct styling
    public static void security(final String action,final String details) {
        log.info("{}{}{} {}{} {} {}{}",
                BRIGHT_BLUE, BOLD, ICON_SECURITY, action, RESET, ARROW_RIGHT, details, RESET);
    }

    // Database operations with enhanced visibility
    public static void database(final String operation,final String entity,final String details) {
        log.debug("{}{}{} {} {}{} {} {}{}",
                BRIGHT_CYAN, BOLD, ICON_DATABASE, operation, entity, RESET, ARROW_RIGHT, details, RESET);
    }

    // API calls with status color coding
    public static void apiCall(final String method,final String endpoint,final String status) {
        final String color = status.startsWith("2") ? BRIGHT_GREEN : status.startsWith("4") ? BRIGHT_YELLOW : BRIGHT_RED;
        log.info("{}{}{} {} {}{} {} Status: {}{}",
                color, BOLD, ICON_API, method, endpoint, RESET, ARROW_RIGHT, status, RESET);
    }

    // Validation results
    public static void validation(final String field,final boolean isValid,final String message) {
        final String icon = isValid ? "[OK]" : "[FAIL]";
        final String color = isValid ? BRIGHT_GREEN : BRIGHT_RED;
        log.debug("{}{}{} {} {}{} {} {}{}",
                color, BOLD, icon, ICON_VALIDATION, field, RESET, ARROW_RIGHT, message, RESET);
    }

    // File operations
    public static void fileOperation(final String operation,final String fileName,final String status) {
        final String color = "SUCCESS".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
        log.debug("{}{}{} {} {}{} {} {}{}",
                color, BOLD, ICON_FILE, operation, fileName, RESET, ARROW_RIGHT, status, RESET);
    }

    // OTP operations
    public static void otpOperation(final String operation,final String phone,final String status) {
        final String color = "SENT".equals(status) || "VALID".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
        log.debug("{}{}{} {} {}{} {} {}{}",
                color, BOLD, ICON_OTP, operation, phone, RESET, ARROW_RIGHT, status, RESET);
    }

    // Authentication operations
    public static void authOperation(final String operation,final String userId,final String status) {
        final String color = "SUCCESS".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
        log.info("{}{}{} {} (User: {}){} {} {}{}",
                color, BOLD, ICON_AUTH, operation, userId, RESET, ARROW_RIGHT, status, RESET);
    }

    // Location operations
    public static void locationOperation(final String operation,final String driverId,final double lat,final double lng) {
        log.debug("{}{}{} {} Driver:{}{} {} Coords: [{}, {}]{}",
                BRIGHT_BLUE, BOLD, ICON_LOCATION, operation, driverId, RESET, ARROW_RIGHT, lat, lng, RESET);
    }

    // Price calculation
    public static void priceCalculation(final String operation,final double input,final double result) {
        log.debug("{}{}{} {}{} {} Input: {} {} Result: ${}${}",
                BRIGHT_GREEN, BOLD, ICON_PRICING, operation, RESET, ARROW_RIGHT, input, ARROW_RIGHT, result, RESET);
    }

    // Step indicator for multi-step processes
    public static void step(final int stepNumber,final int totalSteps,final String description) {
        log.debug("{}{}{} {}/{} {}{}",
                BRIGHT_BLUE, BOLD, ICON_STEP, stepNumber, totalSteps, description, RESET);
    }

    // Transaction boundaries
    public static void transactionStart(final String transactionName) {
        log.debug("\n{}{}{} START {}{}\n",
                BRIGHT_CYAN, BOLD, ICON_TRANSACTION, transactionName, RESET);
    }

    public static void transactionEnd(final String transactionName,final String status) {
        final String color = "COMMIT".equals(status) ? BRIGHT_GREEN : BRIGHT_RED;
        log.debug("\n{}{}{} {} {}{}\n",
                color, BOLD, ICON_TRANSACTION, status, transactionName, RESET);
    }

    // Request/Response logging
    public static void request(final String endpoint,final String method,final String body) {
        log.debug("{}{}{} {} {}{}\n{}{} Body: {}{}",
                BRIGHT_BLUE, BOLD, ICON_REQUEST, method, endpoint, RESET,
                BRIGHT_BLUE, ARROW_RIGHT, body, RESET);
    }

    public static void response(final String endpoint,final int statusCode,final String body) {
        final String color = statusCode >= 200 && statusCode < 300 ? BRIGHT_GREEN : BRIGHT_RED;
        log.debug("{}{}{} {} ({}){}\n{}{} Body: {}{}",
                color, BOLD, ICON_RESPONSE, endpoint, statusCode, RESET,
                color, ARROW_RIGHT, body, RESET);
    }
}