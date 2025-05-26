package gtp.filesmanager.controller;

import gtp.filesmanager.dto.request.LoginRequest;
import gtp.filesmanager.dto.request.RegisterRequest;
import gtp.filesmanager.model.Users;
import gtp.filesmanager.service.UserServiceImpl;
import org.springframework.web.bind.annotation.*;

import java.util.logging.Logger;

@RestController
//@RequestMapping("/api/auth")
public class UserController {
    private final Logger logger = Logger.getLogger(UserController.class.getName());
    private final UserServiceImpl userServiceImpl;

    //inject UserServiceImpl via constructor
    public UserController(UserServiceImpl userServiceImpl) {
        this.userServiceImpl = userServiceImpl;
    }

    @PostMapping(path = "/register")
    protected Object registerUser(@RequestBody RegisterRequest registerRequest){
        logger.info("Registering user with name: " + registerRequest.getUserName());
        if(registerRequest.getUserName() == null || registerRequest.getUserEmail() == null || registerRequest.getPassword() == null){
            throw new RuntimeException("Invalid request");
        }
        try{
            return userServiceImpl.registerUser(registerRequest);
        }catch (RuntimeException e){
            return e.getMessage();
        }
    }

    @PostMapping(path = "/login")
    protected Object loginUser(@RequestBody LoginRequest loginRequest){
        logger.info("Logging in user with name: " + loginRequest.getUserName());
        if(loginRequest.getUserName() == null || loginRequest.getPassword() == null){
            throw new RuntimeException("Invalid request");
        }
        try{
            return userServiceImpl.loginUser(loginRequest);
        }catch (RuntimeException e){
            return e.getMessage();
        }
    }
}