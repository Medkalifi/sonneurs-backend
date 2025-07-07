package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.Training;

@Repository
public interface TrainingRepository extends JpaRepository<Training, Long>{

}
