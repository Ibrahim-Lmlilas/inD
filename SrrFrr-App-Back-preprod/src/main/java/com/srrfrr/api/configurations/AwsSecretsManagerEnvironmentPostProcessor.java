package com.srrfrr.api.configurations;

import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.boot.logging.DeferredLogFactory;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

public class AwsSecretsManagerEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    private static final String PROPERTY_SOURCE_NAME = "awsSecretsManager";
    private static final String KEY_ENABLED = "aws.secrets.enabled";
    private static final String KEY_SECRET_IDS = "aws.secrets.secret-ids";
    private static final String KEY_REGION = "aws.secrets.region";
    private static final String KEY_FAIL_FAST = "aws.secrets.fail-fast";

    private final Log log;

    public AwsSecretsManagerEnvironmentPostProcessor(DeferredLogFactory logFactory) {
        this.log = logFactory.getLog(getClass());
    }

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {

        if (!isSecretsEnabled(environment)) {
            log.info("AWS Secrets Manager is disabled; using existing environment/property sources");
            return;
        }

        String secretIdsValue = firstNonBlank(
                environment.getProperty(KEY_SECRET_IDS),
                environment.getProperty("AWS_SECRETS_SECRET_IDS"));

        if (!StringUtils.hasText(secretIdsValue)) {
            handleFailure("AWS Secrets enabled but no secret IDs provided", environment, null);
            return;
        }

        // Support comma-separated list of secret IDs
        String[] secretIds = secretIdsValue.split(",");

        String regionValue = firstNonBlank(
                environment.getProperty(KEY_REGION),
                environment.getProperty("AWS_SECRETS_REGION"),
                environment.getProperty("aws.region"),
                environment.getProperty("AWS_REGION"),
                "eu-west-3");

        Map<String, Object> allSecrets = new LinkedHashMap<>();

        try (SecretsManagerClient client = SecretsManagerClient.builder()
                .region(Region.of(regionValue))
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build()) {

            for (String secretId : secretIds) {
                secretId = secretId.trim();
                if (!StringUtils.hasText(secretId)) {
                    continue;
                }

                try {
                    log.info("Fetching secret: " + secretId);

                    String secretString = client
                            .getSecretValue(GetSecretValueRequest.builder()
                                    .secretId(secretId)
                                    .build())
                            .secretString();

                    if (!StringUtils.hasText(secretString)) {
                        handleFailure("Secret " + secretId + " is empty", environment, null);
                        continue;
                    }

                    Map<String, Object> secretMap = new ObjectMapper().readValue(
                            secretString,
                            new TypeReference<Map<String, Object>>() {
                            });

                    for (Map.Entry<String, Object> entry : secretMap.entrySet()) {
                        if (entry.getValue() != null) {
                            allSecrets.put(entry.getKey(), String.valueOf(entry.getValue()));
                        }
                    }

                    log.info("Loaded " + secretMap.size() + " keys from secret: " + secretId);

                } catch (Exception ex) {
                    handleFailure("Failed to load secret " + secretId, environment, ex);
                }
            }

            if (allSecrets.isEmpty()) {
                handleFailure("No secrets were loaded from AWS Secrets Manager", environment, null);
                return;
            }

            // Add AFTER system environment to avoid overriding system env vars
            environment.getPropertySources()
                    .addLast(new MapPropertySource(PROPERTY_SOURCE_NAME, allSecrets));

            log.info("Successfully loaded " + allSecrets.size() + " total keys from AWS Secrets Manager");

        } catch (Exception ex) {
            handleFailure("Failed to initialize AWS Secrets Manager client", environment, ex);
        }
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE + 11;
    }

    private void handleFailure(String message, ConfigurableEnvironment environment, Exception ex) {
        boolean failFast = isFailFastEnabled(environment);
        
        String fullMessage = message + (ex != null ? ": " + ex.getMessage() : "");
        
        if (failFast) {
            log.error(fullMessage);
            throw new IllegalStateException(fullMessage, ex);
        } else {
            log.warn(fullMessage + " (fail-fast disabled, continuing startup)");
        }
    }

    private boolean isSecretsEnabled(ConfigurableEnvironment environment) {
        String raw = firstNonBlank(
                environment.getProperty(KEY_ENABLED),
                environment.getProperty("AWS_SECRETS_ENABLED"),
                "false");
        return Boolean.parseBoolean(raw);
    }

    private boolean isFailFastEnabled(ConfigurableEnvironment environment) {
        String raw = firstNonBlank(
                environment.getProperty(KEY_FAIL_FAST),
                environment.getProperty("AWS_SECRETS_FAIL_FAST"),
                "true");
        return Boolean.parseBoolean(raw);
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (StringUtils.hasText(value)) {
                return value;
            }
        }
        return null;
    }
}