package fr.sonneurs.sonneurs.services;

import java.util.Optional;
import java.util.List;

import org.springframework.stereotype.Service;

import fr.sonneurs.sonneurs.entities.Users;
import fr.sonneurs.sonneurs.repositories.UsersRepository;

@Service
public class UsersService {
	private final UsersRepository usersRepository;

    // Injection via constructeur
    public UsersService(UsersRepository userRepository) {
        this.usersRepository = userRepository;
    }

    // Créer un utilisateur
    public Users createUser(Users user) {
        // ici tu peux ajouter validations, hash mot de passe, etc.
        return usersRepository.save(user);
    }

    // Chercher un utilisateur par son id
    public Optional<Users> getUserById(Long id) {
        return usersRepository.findById(id);
    }

    // Chercher tous les utilisateurs
    public List <Users> getAllUsers() {
        return usersRepository.findAll();
    }

    // Mettre à jour un utilisateur
    public Users updateUser(Long id, Users userUpdates) {
        return usersRepository.findById(id)
            .map(user -> {
                user.setEmail(userUpdates.getEmail());
                user.setFirstName(userUpdates.getFirstName());
                user.setLastName(userUpdates.getLastName());
                user.setRole(userUpdates.getRole());
                // autres champs à mettre à jour
                return usersRepository.save(user);
            })
            .orElseThrow(() -> new RuntimeException("User not found with id " + id));
    }

    // Supprimer un utilisateur
    public void deleteUser(Long id) {
        usersRepository.deleteById(id);
    }

}
