package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.Events;
@Repository
public interface EventsRepository extends JpaRepository<Events, Long>{

}
