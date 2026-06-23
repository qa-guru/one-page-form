import com.codeborne.selenide.Configuration;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import java.nio.file.Paths;

import static com.codeborne.selenide.Selenide.closeWebDriver;

public class TestBase {

    @BeforeAll
    static void setup() {
        Configuration.baseUrl = Paths.get("../").toUri().toString();
        Configuration.browser = "chrome";
//        Configuration.browserSize = "1024x768";
        Configuration.browserSize = "1920x1280";
        Configuration.headless = "true".equalsIgnoreCase(System.getenv("CI"));
//        Configuration.browserVersion = "148.0";
//        Configuration.pageLoadStrategy = "eager";
//        Configuration.timeout = 5000;
    }

    @AfterEach
    void afterEach() {
        closeWebDriver();
    }
}
