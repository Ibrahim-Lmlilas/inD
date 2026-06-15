//package com.srrfrr.api.utils;
//
//import lombok.extern.slf4j.Slf4j;
//
//import static com.srrfrr.api.utils.ConsoleConstants.*;
//
//@Slf4j
//public class DataLogger {
//
//    private static final DataLogger INSTANCE = new DataLogger();
//
//
//    void info(final String message) {
//        log.info("{}{}{} {}{}",
//                BRIGHT_CYAN, BOLD, ICON_INFO, message, RESET);
//    }
//
//    void info(final String context, final String message) {
//        log.info("{}{}{} {}{} {} {}",
//                BRIGHT_CYAN, BOLD, ICON_INFO, context, RESET, ARROW_RIGHT, message);
//    }
//
//    void data(final String key, final Object value) {
//        log.debug("{}{} {} {} = {}{}",
//                BRIGHT_MAGENTA, BULLET, key, ARROW_RIGHT, value, RESET);
//    }
//
//    void data(final String context, final String key, final Object value) {
//        log.debug("{}{}{} {}{} {} {} {} = {}{}",
//                BRIGHT_MAGENTA, BOLD, ICON_DATA, context, RESET,
//                BRIGHT_MAGENTA, BULLET, key, ARROW_RIGHT, value, RESET);
//    }
//
//    void trace(final String message) {
//        log.trace("{}{} {}{}", CYAN, ICON_TRACE, message, RESET);
//    }
//
//    void trace(final String context, final String message) {
//        log.trace("{}{} {} {} {}{}", CYAN, ICON_TRACE, context, ARROW_RIGHT, message, RESET);
//    }
//
//
//    public static void info(final String message) {
//        INSTANCE.info(message);
//    }
//
//    public static void info(final String context, final String message) {
//        INSTANCE.info(context, message);
//    }
//
//    public static void debugData(final String key, final Object value) {
//        INSTANCE.data(key, value);
//    }
//
//    public static void debugData(final String context, final String key, final Object value) {
//        INSTANCE.data(context, key, value);
//    }
//
//    public static void trace(final String message) {
//        INSTANCE.trace(message);
//    }
//
//    public static void trace(final String context, final String message) {
//        INSTANCE.trace(context, message);
//    }
//}