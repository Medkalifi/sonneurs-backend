package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.MembershipSubscription;
@Repository
public interface MembershipSubscriptionRepository extends JpaRepository<MembershipSubscription, Long>{

}
