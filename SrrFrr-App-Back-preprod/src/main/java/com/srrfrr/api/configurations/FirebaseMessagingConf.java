package com.srrfrr.api.configurations;

import com.google.firebase.messaging.FirebaseMessaging;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.Message;

@Slf4j
@Service
public class FirebaseMessagingConf {

    @PostConstruct
    public void initializeFirebase() throws IOException {
        final InputStream serviceAccount = getClass()
                .getClassLoader()
                .getResourceAsStream("firebase-service-account.json");

        if (serviceAccount == null) {
            throw new FileNotFoundException("Fichier firebase-service-account.json non trouvé dans resources");
        }

        final FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp.initializeApp(options);
        }
    }

    public String sendMessage(final String token, final String title, final String body)
            throws FirebaseMessagingException {

        final Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        final Message message = Message.builder()
                .setToken(token)
                .setNotification(notification)
                .build();

        return FirebaseMessaging.getInstance().send(message);
    }

}
