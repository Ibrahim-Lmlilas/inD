//package com.srrfrr.api.utils;
//
//import lombok.extern.slf4j.Slf4j;
//import static com.srrfrr.api.utils.ConsoleConstants.*;
//
//@Slf4j
//public class MethodLogger {
//    private static final MethodLogger INSTANCE = new MethodLogger();
//
//    void start(final String methodName) {
//        log.debug("\n{}{}{} {}{}",
//                BRIGHT_BLUE, BOLD, ICON_START, methodName, RESET);
//    }
//
//    void startWithParams(final String methodName, final String... params) {
//        final String paramString = params.length > 0 ? String.join(", ", params) : "no params";
//        log.debug("\n{}{}{} {}{}\n{}{} Parameters: {}{}",
//                BRIGHT_BLUE, BOLD, ICON_START, methodName, RESET,
//                BRIGHT_BLUE, ARROW_RIGHT, paramString, RESET);
//    }
//
//    void start(final String className, final String methodName) {
//        log.debug("\n{}{}{} {}.{}{}",
//                BRIGHT_BLUE, BOLD, ICON_START, className, methodName, RESET);
//    }
//
//    void startFull(final String className, final String methodName, final String... params) {
//        final String paramString = params.length > 0 ? String.join(", ", params) : "no params";
//        log.debug("\n{}{}{} {}.{}{}\n{}{} Parameters: {}{}",
//                BRIGHT_BLUE, BOLD, ICON_START, className, methodName, RESET,
//                BRIGHT_BLUE, ARROW_RIGHT, paramString, RESET);
//    }
//
//    void success(final String methodName, final String result) {
//        log.debug("{}{}{} {}{}\n{}{} Result: {}{}",
//                BRIGHT_GREEN, BOLD, ICON_SUCCESS, methodName, RESET,
//                BRIGHT_GREEN, ARROW_RIGHT, result, RESET);
//    }
//
//    void success(final String className, final String methodName, final String result) {
//        log.debug("{}{}{} {}.{}{}\n{}{} Result: {}{}",
//                BRIGHT_GREEN, BOLD, ICON_SUCCESS, className, methodName, RESET,
//                BRIGHT_GREEN, ARROW_RIGHT, result, RESET);
//    }
//
//    void error(final String methodName, final String error, final Exception ex) {
//        log.error("\n{}{}{} {}{}\n{}{} Error: {}\n{}{} Exception: {}{}\n",
//                BRIGHT_RED, BOLD, ICON_ERROR, methodName, RESET,
//                BRIGHT_RED, ARROW_RIGHT, error, RESET,
//                BRIGHT_RED, ARROW_RIGHT, ex.getMessage(), RESET);
//    }
//
//    void error(final String className, final String methodName, final String error, final Exception ex) {
//        log.error("\n{}{}{} {}.{}{}\n{}{} Error: {}\n{}{} Exception: {}{}\n",
//                BRIGHT_RED, BOLD, ICON_ERROR, className, methodName, RESET,
//                BRIGHT_RED, ARROW_RIGHT, error, RESET,
//                BRIGHT_RED, ARROW_RIGHT, ex.getMessage(), RESET);
//    }
//
//    void error(final String methodName, final String error) {
//        log.error("\n{}{}{} {}{}\n{}{} Error: {}{}\n",
//                BRIGHT_RED, BOLD, ICON_ERROR, methodName, RESET,
//                BRIGHT_RED, ARROW_RIGHT, error, RESET);
//    }
//
//    void warning(final String methodName, final String warning) {
//        log.warn("{}{}{} {}{}\n{}{} Warning: {}{}",
//                BRIGHT_YELLOW, BOLD, ICON_WARNING, methodName, RESET,
//                BRIGHT_YELLOW, ARROW_RIGHT, warning, RESET);
//    }
//
//    void warning(final String className, final String methodName, final String warning) {
//        log.warn("{}{}{} {}.{}{}\n{}{} Warning: {}{}",
//                BRIGHT_YELLOW, BOLD, ICON_WARNING, className, methodName, RESET,
//                BRIGHT_YELLOW, ARROW_RIGHT, warning, RESET);
//    }
//
//    public static void methodStart(final String methodName) {
//        INSTANCE.start(methodName);
//    }
//
//    public static void methodStartParams(final String methodName, final String... params) {
//        INSTANCE.startWithParams(methodName, params);
//    }
//
//    public static void methodStart(final String className, final String methodName) {
//        INSTANCE.start(className, methodName);
//    }
//
//    public static void methodStartFull(final String className, final String methodName, final String... params) {
//        INSTANCE.startFull(className, methodName, params);
//    }
//
//    public static void methodSuccess(final String methodName, final String result) {
//        INSTANCE.success(methodName, result);
//    }
//
//    public static void methodSuccess(final String className, final String methodName, final String result) {
//        INSTANCE.success(className, methodName, result);
//    }
//
//    public static void methodError(final String methodName, final String error, final Exception ex) {
//        INSTANCE.error(methodName, error, ex);
//    }
//
//    public static void methodError(final String className, final String methodName, final String error, final Exception ex) {
//        INSTANCE.error(className, methodName, error, ex);
//    }
//
//    public static void methodError(final String methodName, final String error) {
//        INSTANCE.error(methodName, error);
//    }
//
//    public static void methodWarning(final String methodName, final String warning) {
//        INSTANCE.warning(methodName, warning);
//    }
//
//    public static void methodWarning(final String className, final String methodName, final String warning) {
//        INSTANCE.warning(className, methodName, warning);
//    }
//}