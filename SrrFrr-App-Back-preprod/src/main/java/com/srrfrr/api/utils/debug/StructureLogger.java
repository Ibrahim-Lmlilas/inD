//package com.srrfrr.api.utils;
//
//import lombok.extern.slf4j.Slf4j;
//import static com.srrfrr.api.utils.ConsoleConstants.*;
//
//@Slf4j
//public class StructureLogger {
//
//    private static final StructureLogger INSTANCE = new StructureLogger();
//
//    void sectionHeader(final String sectionName) {
//        log.info("\n{}{}{}\n{}{}{} {}{}\n{}{}{}\n",
//                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE,
//                BRIGHT_MAGENTA, BOLD, ICON_SECTION, sectionName, RESET,
//                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE, RESET);
//    }
//
//    void sectionHeader(final String className, final String sectionName) {
//        log.info("\n{}{}{}\n{}{}{} {}.{}{}\n{}{}{}\n",
//                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE,
//                BRIGHT_MAGENTA, BOLD, ICON_SECTION, className, sectionName, RESET,
//                BRIGHT_MAGENTA, BOLD, BORDER_DOUBLE, RESET);
//    }
//
//    void subSection(final String name) {
//        log.info("{}{}{}\n{}{} {} {}{}",
//                CYAN, BOLD, BORDER_SINGLE,
//                CYAN, BULLET, name, RESET);
//    }
//
//    void step(final int stepNumber, final int totalSteps, final String description) {
//        log.debug("{}{}{} {}/{} {}{}",
//                BRIGHT_BLUE, BOLD, ICON_STEP, stepNumber, totalSteps, description, RESET);
//    }
//    public static void sectionHeader(final String sectionName) {
//        INSTANCE.sectionHeader(sectionName);
//    }
//
//    public static void sectionHeader(final String className, final String sectionName) {
//        INSTANCE.sectionHeader(className, sectionName);
//    }
//
//    public static void subSection(final String name) {
//        INSTANCE.subSection(name);
//    }
//
//    public static void step(final int stepNumber, final int totalSteps, final String description) {
//        INSTANCE.step(stepNumber, totalSteps, description);
//    }
//}