package gtp.filesmanager.dto.request;

import lombok.Getter;
import org.antlr.v4.runtime.misc.NotNull;

//DTO to accept when logging in
@Getter
public class LoginRequest {
    private String userName;
    private String password;
}