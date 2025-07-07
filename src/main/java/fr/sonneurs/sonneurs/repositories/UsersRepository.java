package fr.sonneurs.sonneurs.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.sonneurs.sonneurs.entities.Users;

@Repository
public interface UsersRepository extends JpaRepository<Users, Long>{

}
