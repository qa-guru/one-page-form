package config;

import org.aeonbits.owner.Config;

@Config.LoadPolicy(Config.LoadType.MERGE)
@Config.Sources({
        "system:properties",
        "system:env",
        "classpath:config/${env}.properties"
})
public interface TestConfig extends Config {

    @Key("baseUrl")
    @DefaultValue("")
    String baseUrl();

    @Key("browser")
    @DefaultValue("chrome")
    String browser();

    @Key("browserSize")
    @DefaultValue("1920x1280")
    String browserSize();

    @Key("headless")
    @DefaultValue("false")
    boolean headless();
}
