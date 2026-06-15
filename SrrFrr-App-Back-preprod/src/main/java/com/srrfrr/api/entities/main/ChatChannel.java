package com.srrfrr.api.entities.main;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chat_channels", schema = "app_mobile")

public class ChatChannel {
	@Id
	@Column(name = "id", nullable = false, unique = true)
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "ride_id", nullable = false, unique = true)
	private Ride ride;

	@Column(name = "driver_id", nullable = false)
	private UUID driverId;

	@Column(name = "passenger_id", nullable = false)
	private UUID passengerId;

	@Column(name = "is_active")
	private boolean isActive;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private LocalDateTime createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private LocalDateTime updatedAt;

	@Column(name = "last_message_at")
	private LocalDateTime lastMessageAt;

	public static ChatChannel createForRide(final Ride ride) {
		return ChatChannel.builder()
				.ride(ride)
				.driverId(ride.getDriverId())
				.passengerId(ride.getPassengerId())
				.isActive(true)
				.build();
	}
}