package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.Newsletter;

@Repository
public interface NewsletterRepository extends JpaRepository<Newsletter, Long> {

}
