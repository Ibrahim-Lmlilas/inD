package com.srrfrr.api.configurations;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudfront.CloudFrontClient;
import software.amazon.awssdk.services.s3.S3Client;

/**
 * AWS S3 Configuration for preprod and prod environments.
 * Uses IAM instance profile credentials by default.
 */
@Slf4j
@Configuration
public class S3Config {

    /**
     * Configuration for preprod and prod - Uses IAM Role (Instance Profile)
     */
    @Configuration
    @Profile({"prod", "preprod"})
    static class IamRoleConfig {

        @Value("${aws.region}")
        private String region;

        @Bean
        public S3Client s3Client() {
            log.info("[IAM Role] Initializing S3Client with region: {}", region);
            return S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(InstanceProfileCredentialsProvider.create())
                    .build();
        }

        @Bean
        public CloudFrontClient cloudFrontClient() {
            log.info("[IAM Role] Initializing CloudFrontClient with region: {}", region);
            return CloudFrontClient.builder()
                    .region(Region.of(region))
                    .credentialsProvider(InstanceProfileCredentialsProvider.create())
                    .build();
        }
    }

    /**
     * Configuration for other environments - Uses static credentials if needed
     * (e.g., for local testing with real AWS, staging with specific credentials)
     */
    @Configuration
    @Profile("aws-credentials")
    static class StaticCredentialsConfig {

        @Value("${aws.region}")
        private String region;

        @Value("${aws.accessKeyId}")
        private String accessKeyId;

        @Value("${aws.secretAccessKey}")
        private String secretAccessKey;

        @Value("${aws.sessionToken:}")
        private String sessionToken;

        @Bean
        public S3Client s3Client() {
            log.info("[Static Credentials] Initializing S3Client with region: {}", region);
            return S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(getCredentialsProvider())
                    .build();
        }

        @Bean
        public CloudFrontClient cloudFrontClient() {
            log.info("[Static Credentials] Initializing CloudFrontClient with region: {}", region);
            return CloudFrontClient.builder()
                    .region(Region.of(region))
                    .credentialsProvider(getCredentialsProvider())
                    .build();
        }

        private AwsCredentialsProvider getCredentialsProvider() {
            if (sessionToken != null && !sessionToken.isEmpty()) {
                log.info("Using temporary session credentials");
                return StaticCredentialsProvider.create(
                        AwsSessionCredentials.create(accessKeyId, secretAccessKey, sessionToken));
            }

            log.info("Using basic static credentials");
            return StaticCredentialsProvider.create(
                    AwsBasicCredentials.create(accessKeyId, secretAccessKey));
        }
    }
}
