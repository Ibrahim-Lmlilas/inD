package com.srrfrr.api.utils;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.srrfrr.api.infrastructure.storage.IStorageService;

import java.io.IOException;

/**
 * Utility for converting storage keys to accessible URLs.
 */
@Slf4j
@Component
public class ConvertToURL {

    private static IStorageService storageService;

    @Autowired
    public void setStorageService(IStorageService storageService) {
        ConvertToURL.storageService = storageService;
    }

    /**
     * Convert a storage key to an accessible URL.
     * Automatically determines if the file is private based on path.
     */
    public static String convert(String key) {
        if (key == null || key.isEmpty()) {
            return null;
        }
        return storageService.getFileUrl(key);
    }
}