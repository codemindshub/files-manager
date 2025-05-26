package gtp.filesmanager.service;

import gtp.filesmanager.dto.request.LoginRequest;
import gtp.filesmanager.dto.request.RegisterRequest;
import gtp.filesmanager.model.Users;
import gtp.filesmanager.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {  // Removed 'abstract' as this should be a concrete implementation

    @Autowired
    private UserRepository userRepository;

    private  BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder(12);  // Renamed from 'encoder' for clarity

    @Autowired
    private AuthenticationManager authManager;


    @Override
    public Users registerUser(RegisterRequest registerRequest) {
        // Check if a user already exists
        if (userRepository.findByUserName(registerRequest.getUserName()) != null) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepository.findByUserEmail(registerRequest.getUserEmail()) != null) {
            throw new RuntimeException("Email already registered");
        }

        // Create a new user entity
        Users newUser = new Users();
        newUser.setUserName(registerRequest.getUserName());
        newUser.setUserEmail(registerRequest.getUserEmail());
        newUser.setPassword(passwordEncoder.encode(registerRequest.getPassword())); // Encode password

        return userRepository.save(newUser);
    }

    @Override
    public Users loginUser(LoginRequest loginRequest){
        Users user = userRepository.findByUserName(loginRequest.getUserName());
        if(user == null){
            throw new RuntimeException("Invalid username");
        }

        //Authenticate user
        Authentication authentication = authManager
                .authenticate(new UsernamePasswordAuthenticationToken(
                        loginRequest.getUserName(), loginRequest.getPassword()
                ));

        //check user authentication is successful
        if (authentication.isAuthenticated()){
            return user;
        }else{
            throw new RuntimeException("Invalid password");
        }
    }

}