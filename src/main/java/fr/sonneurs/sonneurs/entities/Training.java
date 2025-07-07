package fr.sonneurs.sonneurs.entities;

import java.time.LocalDateTime;
import java.util.Set;

import fr.sonneurs.sonneurs.enums.TrainingType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "trainings")
public class Training {
	
	 @Id
	 @GeneratedValue(strategy = GenerationType.IDENTITY)
	    private Long id;

	    private LocalDateTime dateTime;

	    @Enumerated(EnumType.STRING)
	    private TrainingType type; // COURSE, PPG

	    private String location;

	    private String notes;

	    @ManyToMany
	    @JoinTable(name = "training_participants")
	    private Set<Users> participants;

	    @ManyToOne
	    private Users coach;

}
