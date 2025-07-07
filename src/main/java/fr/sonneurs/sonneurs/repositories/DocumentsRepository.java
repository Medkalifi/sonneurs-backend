package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.Documents;

@Repository
public interface DocumentsRepository extends JpaRepository<Documents, Long> {

}
