package fr.sonneurs.sonneurs.entities;

import java.util.Set;

import fr.sonneurs.sonneurs.enums.Role;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
@Data
@Entity
@Table(name = "users")
public class Users {


	    @Id 
	    @GeneratedValue(strategy = GenerationType.IDENTITY)
	    private Long id;
	    private String firstName;
	    private String lastName;
	    private String email;
	    private String password;

	    @Enumerated(EnumType.STRING)
	    private Role role; // PRÉSIDENT, TRÉSORIER, COACH, ADHÉRENT, INVITÉ

	    private boolean active;

	    // Invités liés à un adhérent
	    @ManyToOne
	    private Users parentUser;

	    // Entraînements auxquels le membre participe
	    @ManyToMany(mappedBy = "participants")
	    private Set<Training> trainings;
	}