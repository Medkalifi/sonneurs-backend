package fr.sonneurs.sonneurs.entities;

import java.time.LocalDate;

import fr.sonneurs.sonneurs.enums.DocumentType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "documents")
public class Documents {

	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String gcsUrl; // lien vers GCS

    private LocalDate uploadDate;

    @ManyToOne
    private Users uploadedBy;

    @Enumerated(EnumType.STRING)
    private DocumentType type; // STATUTS, RESULTATS, INSCRIPTION, AUTRE
}
