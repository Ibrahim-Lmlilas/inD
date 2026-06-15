package com.srrfrr.api.entities.archive;

import com.srrfrr.api.entities.main.*;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "chat_message_files", schema = "archive")
public class ArchiveMessageFile {

    @Id
    @Column(name = "id", nullable = true, unique = true)
    private UUID id;

    @Column(name = "message_id", nullable = true)
    private UUID messageId;

    @Column(name = "file_url", nullable = true)
    private String fileUrl;

    @Column(name = "file_size")
    private Long fileSize;



    public static ArchiveMessageFile fromMain(MessageFile file) {
        return ArchiveMessageFile.builder()
                .id(file.getId())
                .messageId(file.getMessage().getId())
                .fileUrl(file.getFileUrl())
                .fileSize(file.getFileSize())
                
                .build();
    }
}
