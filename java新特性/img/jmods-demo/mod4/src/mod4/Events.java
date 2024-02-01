package mod4;

import mod5.Person;
import sun.security.action.GetPropertyAction;

import java.util.UUID;

/**
 * @author Emac
 * @since 2020-05-30
 */
public class Events {

    public static String newEvent() {
        return UUID.randomUUID().toString();
    }

}
