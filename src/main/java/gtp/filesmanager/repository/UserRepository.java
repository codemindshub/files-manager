package gtp.filesmanager.repository;

import gtp.filesmanager.model.Users;
import org.springframework.data.repository.CrudRepository;

public interface UserRepository extends CrudRepository<Users, Integer> {
    public Users findByUserName(String userName);
    public Users findByUserEmail(String userEmail);
}