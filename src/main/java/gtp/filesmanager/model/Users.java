package gtp.filesmanager.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.sql.Date;

//create a user entity
@Getter
@Entity
@Table(name = "users")
public class Users {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Setter
    @Column(unique = true,nullable = false)
    private String userName; //unique for all

    @Setter
    @JsonIgnore //ignores this field when serializing the object to JSON
    private String password;

    @Setter
    @Column(unique = true,nullable = false)
    private String userEmail;

    @Setter
    private Boolean isActive;

    @Setter
    private Date createdAt;

    @Setter
    private Date updatedAt;
}