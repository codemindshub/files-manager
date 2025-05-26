package gtp.filesmanager.service;

import gtp.filesmanager.dto.request.LoginRequest;
import gtp.filesmanager.dto.request.RegisterRequest;
import gtp.filesmanager.model.Users;

public interface UserService {
    abstract Users registerUser(RegisterRequest registerRequest);
    abstract Users loginUser(LoginRequest loginRequest);
}