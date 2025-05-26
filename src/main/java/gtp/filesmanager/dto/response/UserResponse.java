package gtp.filesmanager.dto.response;

import lombok.Getter;

@Getter
public class UserResponse {
    private Integer Id;
    private String userName;
    private String userEmail;
    private Boolean isActive;
}