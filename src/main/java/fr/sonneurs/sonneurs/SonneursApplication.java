package fr.sonneurs.sonneurs;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SonneursApplication {

	public static void main(String[] args) {
	    System.out.println("DB_NAME: " + System.getenv("DB_NAME"));
	    SpringApplication.run(SonneursApplication.class, args);
	
		
		
	}

}
