package config;

import java.nio.file.Paths;

import org.aeonbits.owner.ConfigFactory;

public class ConfigReader {

  public static final TestConfig config = ConfigFactory.create(TestConfig.class);

  public static String resolvedBaseUrl() {
    String baseUrl = config.baseUrlRaw();
    return baseUrl == null || baseUrl.isBlank()
        ? Paths.get("../").toAbsolutePath().normalize().toUri().toString()
        : baseUrl;
  }
}
