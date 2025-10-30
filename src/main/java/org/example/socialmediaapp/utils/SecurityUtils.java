    package org.example.socialmediaapp.utils;

    import org.example.socialmediaapp.entities.User;
    import org.springframework.security.core.Authentication;
    import org.springframework.security.core.context.SecurityContextHolder;

    public class SecurityUtils {
        public static User getCurrentUser() {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

            if (authentication == null || !authentication.isAuthenticated()) {
                throw new RuntimeException("Unauthenticated access");
            }

            Object principal = authentication.getPrincipal();

            if (principal instanceof User user) {
                return user;
            }

            throw new RuntimeException("Invalid user in security context");
        }
    }
