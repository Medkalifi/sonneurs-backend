package fr.sonneurs.sonneurs.entities;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name ="newsletter")
public class Newsletter {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDate dateSent;
    private String subject;

    @Lob
    private String content;

    @ManyToOne
    private Users sentBy;
}
