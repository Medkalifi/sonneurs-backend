package fr.sonneurs.sonneurs.entities;

import java.time.LocalDate;
import java.util.Set;

import fr.sonneurs.sonneurs.enums.EventType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "events")
public class Events {
	
	 @Id
	 @GeneratedValue(strategy = GenerationType.IDENTITY)
	    private Long id;

	    private String title;
	    private LocalDate date;
	    private String location;
	    private String description;
	    private boolean published;  // true = visible sur le site public
	    @Lob
	    private String publicDescription; // description courte ou mise en avant
	    @ManyToMany
	    private Set<Users> participants;

	    @Enumerated(EnumType.STRING)
	    private EventType type; // COURSE, SORTIE_CLUB, MARATHON, AUTRE

}
