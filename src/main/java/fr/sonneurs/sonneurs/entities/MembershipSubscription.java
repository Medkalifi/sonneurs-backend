package fr.sonneurs.sonneurs.entities;

import java.math.BigDecimal;
import java.time.LocalDate;

import fr.sonneurs.sonneurs.enums.SubscriptionStatus;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "subscriptions")
public class MembershipSubscription {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	private Users user;

	private LocalDate startDate;
	private LocalDate endDate;

	@Enumerated(EnumType.STRING)
	private SubscriptionStatus status; // EN_COURS, TERMINEE, ANNULEE

	private BigDecimal amountPaid;

	private LocalDate paymentDate;
}
