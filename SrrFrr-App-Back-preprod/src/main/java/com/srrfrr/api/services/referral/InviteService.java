package com.srrfrr.api.services.referral;

import com.srrfrr.api.entities.main.*;
import com.srrfrr.api.enums.LoyaltyTransactionType;
import com.srrfrr.api.exceptions.PassengerAccountExistsException;
import com.srrfrr.api.repositories.main.loyalty.LoyaltyTransactionRepository;
import com.srrfrr.api.repositories.main.InviteRepository;
import com.srrfrr.api.services.notification.NotificationService;
import com.srrfrr.api.services.user.PassengerService;
import com.srrfrr.api.utils.PhoneNumberUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
@Slf4j
public class InviteService {

  private final InviteRepository inviteRepository;
  private final LoyaltyTransactionRepository loyaltyTransactionRepository;
  private final NotificationService notificationService;
  private final PassengerService passengerService;

  public InviteService(final InviteRepository inviteRepository,
      final LoyaltyTransactionRepository loyaltyTransactionRepository,
      final NotificationService notificationService,
      final PassengerService passengerService) {
    this.inviteRepository = inviteRepository;
    this.loyaltyTransactionRepository = loyaltyTransactionRepository;
    this.notificationService = notificationService;
    this.passengerService = passengerService;
  }

  /**
   * Create a new invite for a passenger to invite another person.
   */
  public void createNewInvite(final Passenger inviterPassenger, final String phoneNumber) {

    final String normalizedPhone = PhoneNumberUtils.normalizeToInternational(phoneNumber);
    if (normalizedPhone == null) {
      throw new IllegalArgumentException("Invalid phone number!");
    }

    if (normalizedPhone.equals(inviterPassenger.getPhoneNumber())) {
      throw new IllegalArgumentException("You can't invite yourself!");
    }

    // Check if the phone number already exists as a Passenger
    boolean isPassengerExists = passengerService.checkIfPassengerExistsByPhoneNumber(normalizedPhone);
    if (isPassengerExists) {
      throw new PassengerAccountExistsException();
    }

    // Check if the inviter already invited this number
    if (isAlreadyInvitedNumber(inviterPassenger, normalizedPhone)) {
      log.info("Passenger {} already invited phone {}", inviterPassenger.getId(), normalizedPhone);
      return;
    }

    // Save new invite
    Invite invite = new Invite(normalizedPhone, inviterPassenger);
    inviteRepository.save(invite);

    log.info("New invitation created: inviter={}, inviteePhone={}",
        inviterPassenger.getPhoneNumber(), normalizedPhone);
  }

  /**
   * Check if a passenger already invited a specific phone number.
   */
  public boolean isAlreadyInvitedNumber(final Passenger inviterPassenger, final String phoneNumber) {
    return inviteRepository.findAllByInviter(inviterPassenger).stream()
        .anyMatch(inv -> inv.getInviteePhoneNumber().equals(phoneNumber));
  }

  /**
   * Handle the case where a new user (Passenger or Driver) was invited.
   */
  @Transactional
  public void handlePassengerInvited(final Passenger newPassenger) {
    List<Invite> allInvites = inviteRepository.findAllByInviteePhoneNumber(newPassenger.getPhoneNumber());
    if (allInvites.isEmpty()) {
      log.info("No inviter found for phone {}", newPassenger.getPhoneNumber());
      return;
    }

    log.info("Found {} pending invites for new passenger {}. Points will be awarded after first ride completion.",
        allInvites.size(), newPassenger.getPhoneNumber());
  }

  /**
   * Award referral points after the referee completes their first ride.
   * Should be called from RideService when a ride is completed.
   * 
   * @param referee The passenger who completed their first ride
   */
  @Transactional
  public void awardReferralPointsForFirstRide(final Passenger referee) {
    List<Invite> allInvites = inviteRepository.findAllByInviteePhoneNumber(referee.getPhoneNumber());

    if (allInvites.isEmpty()) {
      log.info("No inviter found for passenger {} - not a referred user", referee.getId());
      return;
    }

    // Pick the LAST inviter (most recent) - business rule for edge case
    Invite lastInvite = allInvites.stream()
        .max(Comparator.comparing(Invite::getInvitedAt))
        .orElse(null);

    if (lastInvite == null || lastInvite.getInviter() == null) {
      log.warn("Invalid invite data for phone {}", referee.getPhoneNumber());
      return;
    }

    Passenger inviter = lastInvite.getInviter();

    // 2 points for referee, 10 points for inviter
    int refereeBonus = 2;
    int inviterBonus = 10;

    // Award points to both parties
    createInvitationTransaction(referee, refereeBonus);
    createInvitationTransaction(inviter, inviterBonus);

    // Send notifications
    notificationService.notifyLoyaltyPoints(referee.getId(), refereeBonus, LoyaltyTransactionType.PARRAINAGE);
    notificationService.notifyLoyaltyPoints(inviter.getId(), inviterBonus, LoyaltyTransactionType.PARRAINAGE);

    // Delete ALL invites for this phone number (cleanup)
    inviteRepository.deleteAll(allInvites);

    log.info("Referral reward processed after first ride: inviter={}, invitee={}, inviterPoints={}, inviteePoints={}",
        inviter.getPhoneNumber(), referee.getPhoneNumber(), inviterBonus, refereeBonus);
  }

  /**
   * Create a loyalty transaction and update balance.
   */
  private void createInvitationTransaction(final Passenger passenger, final int points) {
    LoyaltyTransaction transaction = new LoyaltyTransaction();
    transaction.setPassenger(passenger);
    transaction.setPoints(points);
    transaction.setType(LoyaltyTransactionType.PARRAINAGE);
    transaction.setCreatedAt(LocalDateTime.now());
    passenger.addLoyaltyPoints(points);
    loyaltyTransactionRepository.save(transaction);
  }
}