package com.srrfrr.api.exceptions;

public class StorageServiceException extends RuntimeException {
  public StorageServiceException(final String message, final Throwable cause) {
    super(message, cause);
  }
}
