package gtp.filesmanager.dto.request;

import lombok.Getter;

@Getter
public class RegisterRequest {

    private String userName;
    private String password;
    private String userEmail;
}