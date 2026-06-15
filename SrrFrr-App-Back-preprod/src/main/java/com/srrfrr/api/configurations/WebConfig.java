package com.srrfrr.api.configurations;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;


@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(final ResourceHandlerRegistry registry) {

        registry
                .addResourceHandler("/**")
                .addResourceLocations("file:///C:/Users/zineb/OneDrive/Pictures/temp");
    }
}